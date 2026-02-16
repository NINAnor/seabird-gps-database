import os
import pathlib
import time

import schedule
import typer
from gps_logger_parser.parser import detect_file

from logger import log

DATA_PATH = pathlib.Path(os.getenv("DATA_PATH", "/data/"))

LOGGERS_PATH = DATA_PATH / "loggers"
PARQUET_PATH = DATA_PATH / "parquet"

app = typer.Typer()


def check_missing():
    print("checking...")
    for f in LOGGERS_PATH.iterdir():
        if not (PARQUET_PATH / (f.name + ".parquet")).exists():
            log.info(f.name + " not found, adding a task to generate it")
            parser = detect_file(path=pathlib.Path(f))
            parser.write_parquet(PARQUET_PATH)


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
