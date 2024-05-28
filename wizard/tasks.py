import os
import pathlib
from procrastinate import App, PsycopgConnector

from parsers.parser import detect_file

DATABASE_URL = os.getenv("DATABASE_URL")

DATA_PATH = pathlib.Path(os.getenv("DATA_PATH", '/data/'))

LOGGERS_PATH = DATA_PATH  / 'loggers'
SPREADSHEETS_PATH = DATA_PATH  / 'metadata'
PARQUET_PATH = DATA_PATH / 'parquet'

if not DATABASE_URL:
    raise Exception('Missing DATABASE_URL')

app = App(
    connector=PsycopgConnector(
        conninfo=DATABASE_URL
    )
)


@app.task(name='to_parquet')
def to_parquet(file_path: str):
    parser = detect_file(path=pathlib.Path(file_path))
    parser.write_parquet(PARQUET_PATH)


@app.periodic(cron="* * * * *")
@app.task(name='check_missing')
def check_missing(timestamp: int):
    for f in LOGGERS_PATH.iterdir():
        if not (PARQUET_PATH / (f.name + '.parquet')).exists():
            print(f.name + ' not found, adding a task to generate it')
            to_parquet.configure(lock=f.name).defer(file_path=str(f))
