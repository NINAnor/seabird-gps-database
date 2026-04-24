import time

import pyarrow.parquet as pq
import requests
import schedule
import typer
from gps_logger_parser.parser import detect_file

from seapop_wizard.settings import (
    CHECK_UNKNOWN_INTERVAL,
    LOGGERS_PATH,
    PARQUET_PATH,
    POSTGREST_URL,
)

from .settings import log

app = typer.Typer()

UNKNOWN_PATH = LOGGERS_PATH / "deployment=unknown"


def check_missing():
    log.info("checking...")
    for s3_file in LOGGERS_PATH.glob("**/*"):
        try:
            if s3_file.is_dir() or s3_file.suffix == ".parquet":
                continue

            filename = s3_file.name

            relative = s3_file.relative_to(LOGGERS_PATH).with_suffix(".parquet")
            parquet_path = PARQUET_PATH / relative

            if not parquet_path.exists():
                log.info("not found in parquets, processing...", filename=filename)

                # Parse and convert
                try:
                    parser = detect_file(path=s3_file, logger=log)
                    log.info("parsed", parser=parser)
                    pq.write_table(
                        parser.as_table(),
                        str(parquet_path),
                        filesystem=parquet_path.fs,
                        compression="zstd",
                    )
                    log.info("parquet written", path=str(parquet_path))
                except NotImplementedError:
                    log.error(
                        "Unable to parse file, skipping...",
                        filename=filename,
                        path=str(s3_file),
                    )
        except Exception as e:
            log.error(
                "Error checking missing files",
                error=e,
                filename=s3_file.name,
                path=str(s3_file),
            )


def check_unknown():
    log.info("checking unknown files...")
    for s3_file in UNKNOWN_PATH.glob("*"):
        try:
            if s3_file.is_dir() or s3_file.suffix == ".parquet":
                continue

            filename = s3_file.name
            url = (
                f"{POSTGREST_URL}/flat_logger_files"
                f"?select=filename,deployment_id,type"
                f"&filename=ilike.*{filename}&limit=1"
            )
            response = requests.get(url)
            response.raise_for_status()
            result = response.json()

            log.info("checked unknown file", filename=filename, result=result)

            if not result or not isinstance(result, list) or len(result) == 0:
                log.info("not found in database", filename=filename)
                continue

            logger = result[0]
            dest_path = (
                LOGGERS_PATH / f"deployment={logger['deployment_id']}" / filename
            )

            log.info(
                "moving unknown file", filename=filename, destination=str(dest_path)
            )
            dest_path.write_bytes(s3_file.read_bytes())
            s3_file.unlink()

            parquet_src = PARQUET_PATH / s3_file.relative_to(LOGGERS_PATH).with_suffix(".parquet")
            if parquet_src.exists():
                parquet_dest = PARQUET_PATH / dest_path.relative_to(LOGGERS_PATH).with_suffix(".parquet")
                parquet_dest.write_bytes(parquet_src.read_bytes())
                parquet_src.unlink()
                log.info(
                    "moved companion parquet",
                    filename=parquet_dest.name,
                    path=str(parquet_dest),
                )
        except Exception as err:
            log.error(
                "Error checking unknown file",
                error=err,
                filename=s3_file.name,
                path=str(s3_file),
            )


@app.command()
def main():
    check_missing()
    check_unknown()

    log.info("Setting up scheduler")
    schedule.every().minute.do(check_missing)
    schedule.every(CHECK_UNKNOWN_INTERVAL).minutes.do(check_unknown)

    while True:
        try:
            schedule.run_pending()
        except Exception as e:
            log.error(e)
        time.sleep(1)


if __name__ == "__main__":
    app()
