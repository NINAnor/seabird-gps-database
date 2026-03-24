import time

import pyarrow.parquet as pq
import requests
import schedule
import typer
from gps_logger_parser.parser import detect_file

from seapop_wizard.settings import CHECK_UNKNOWN_INTERVAL, LOGGERS_PATH, POSTGREST_URL

from .settings import log

app = typer.Typer()

UNKNOWN_PATH = (
    LOGGERS_PATH
    / "colony=unknown"
    / "species=unknown"
    / "ring=unknown"
    / "deployment=unknown"
    / "type=unknown"
)


def check_missing():
    log.info("checking...")
    try:
        for s3_file in LOGGERS_PATH.glob("**/*"):
            if s3_file.is_dir():
                continue

            filename = s3_file.name

            parquet_path = s3_file.with_suffix(".parquet")

            if not parquet_path.exists():
                log.info(f"{filename} not found in parquets, processing...")

                # Parse and convert
                try:
                    parser = detect_file(path=s3_file)
                    log.info("parsed", parser=parser)
                    pq.write_table(
                        parser.as_table(),
                        str(parquet_path),
                        filesystem=parquet_path.fs,
                        compression="zstd",
                    )
                except NotImplementedError:
                    log.error(f"Unable to parse {filename}, skipping...")
    except Exception as e:
        log.error(f"Error checking missing files: {e}")


def check_unknown():
    log.info("checking unknown files...")
    try:
        for s3_file in UNKNOWN_PATH.glob("*"):
            if s3_file.is_dir() or s3_file.suffix == ".parquet":
                continue

            filename = s3_file.name
            url = (
                f"{POSTGREST_URL}/flat_logger_files"
                f"?select=filename,deployment(colony,id,ring(id,animal(species))),type"
                f"&filename=ilike.*{filename}&limit=1"
            )
            response = requests.get(url)
            response.raise_for_status()
            result = response.json()

            log.info("checked unknown file", filename=filename, result=result)

            if not result or not isinstance(result, list) or len(result) == 0:
                continue

            logger = result[0]
            dest_path = (
                LOGGERS_PATH
                / f"colony={logger['deployment']['colony']}"
                / f"species={logger['deployment']['ring']['animal']['species']}"
                / f"ring={logger['deployment']['ring']['id']}"
                / f"deployment={logger['deployment']['id']}"
                / f"type={logger['type']}"
                / filename
            )

            log.info("moving unknown file", filename=filename, destination=str(dest_path))
            dest_path.write_bytes(s3_file.read_bytes())
            s3_file.unlink()

            parquet_src = s3_file.with_suffix(".parquet")
            if parquet_src.exists():
                parquet_dest = dest_path.with_suffix(".parquet")
                parquet_dest.write_bytes(parquet_src.read_bytes())
                parquet_src.unlink()
                log.info("moved companion parquet", filename=parquet_dest.name)
    except Exception as e:
        log.error(f"Error checking unknown files: {e}")


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
