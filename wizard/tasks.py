import os
import pathlib
import shutil
import tempfile
import time

import schedule
import typer
from gps_logger_parser.parser import detect_file
from upath import UPath

from logger import log

# S3 Configuration
S3_BUCKET = os.getenv("S3_BUCKET")

# S3 paths using UPath
LOGGERS_PATH = UPath(f"s3://{S3_BUCKET}/loggers")
PARQUET_PATH = UPath(f"s3://{S3_BUCKET}/parquet")

app = typer.Typer()


def check_missing():
    print("checking...")
    try:
        # List all files in loggers path
        logger_files = list(LOGGERS_PATH.iterdir())
        for s3_file in logger_files:
            filename = s3_file.name
            parquet_filename = filename + ".parquet"
            parquet_path = PARQUET_PATH / parquet_filename

            if not parquet_path.exists():
                log.info(f"{filename} not found in parquets, processing...")

                # Download file to temp location for parsing
                temp_dir = pathlib.Path(tempfile.mkdtemp())
                temp_file = temp_dir / filename

                with s3_file.open("rb") as s3f:
                    with temp_file.open("wb") as tf:
                        tf.write(s3f.read())

                # Parse and convert
                parser = detect_file(path=temp_file)
                temp_parquet_dir = pathlib.Path(tempfile.mkdtemp())
                parser.write_parquet(temp_parquet_dir)

                # Upload parquet files to S3
                for parquet_file in temp_parquet_dir.iterdir():
                    s3_parquet_path = PARQUET_PATH / parquet_file.name
                    with parquet_file.open("rb") as pf:
                        with s3_parquet_path.open("wb") as s3pf:
                            s3pf.write(pf.read())

                # Cleanup
                shutil.rmtree(temp_dir)
                shutil.rmtree(temp_parquet_dir)
    except Exception as e:
        log.error(f"Error checking missing files: {e}")


def main():
    log.info("Setting up scheduler")
    schedule.every().minute.do(check_missing)

    while True:
        try:
            schedule.run_pending()
        except Exception as e:
            log.error(e)
        time.sleep(1)


if __name__ == "__main__":
    typer.run(main)
