import time

import pyarrow.parquet as pq
import schedule
import typer
from gps_logger_parser.parser import detect_file

from seapop_wizard.settings import LOGGERS_PATH

from .settings import log

app = typer.Typer()


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
                    )
                except NotImplementedError:
                    log.error(f"Unable to parse {filename}, skipping...")
    except Exception as e:
        log.error(f"Error checking missing files: {e}")


@app.command()
def main():
    check_missing()

    log.info("Setting up scheduler")
    schedule.every().minute.do(check_missing)

    while True:
        try:
            schedule.run_pending()
        except Exception as e:
            log.error(e)
        time.sleep(1)


if __name__ == "__main__":
    app()
