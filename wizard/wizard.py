#!/usr/bin/env python3

import io
import logging
import os
import os.path
import traceback
import json
import pathlib
import tempfile
import shutil
import datetime
from dateutil import parser
from collections import defaultdict

import openpyxl
import orjson
import requests
from pywebio import start_server, config
from pywebio.input import NUMBER, actions, file_upload, input, input_group
from pywebio.output import clear, put_error, put_success, put_text, put_button, put_html, put_table, put_warning, put_link, put_widget
from pywebio.session import run_js
from jinja2 import Environment, FileSystemLoader, select_autoescape

from tasks import to_parquet, app

if os.getenv("SENTRY_DSN"):
    import sentry_sdk
    sentry_sdk.init(
        dsn=os.getenv("SENTRY_DSN")
    )

env = Environment(
    loader=FileSystemLoader("./templates"),
    autoescape=select_autoescape()
)

from parsers.parser import detect_file

logging.basicConfig(level=os.getenv("LOGGING", "INFO"))

POSTGREST_URL = os.getenv("POSTGREST_URL", "http://localhost:3000")
POSTGREST_TOKEN = os.getenv("POSTGREST_TOKEN")
TO_PARQUET = os.getenv("TO_PARQUET", 'False').lower() in ('true', '1', 't')
ACCEPTED_EXTENSIONS = os.getenv("ACCEPTED_EXTENSIONS", '.csv,.pos,.gpx,.txt,.log').split(',')
ACCEPTED_EXTENSIONS += [ext.upper() for ext in ACCEPTED_EXTENSIONS]
DATA_PATH = pathlib.Path(os.getenv("DATA_PATH", '/data/'))

LOGGERS_PATH = DATA_PATH  / 'loggers'
SPREADSHEETS_PATH = DATA_PATH  / 'metadata'
PARQUET_PATH = DATA_PATH / 'parquet'

PATHS = [LOGGERS_PATH, SPREADSHEETS_PATH, PARQUET_PATH]
for path in PATHS:
    path.mkdir(exist_ok=True)


def fix_string(value):
    return value.strip() if isinstance(value, str) else value


def fix_dates(value):
    if isinstance(value, datetime.datetime):
        return value.strftime("%Y-%m-%d")
    elif isinstance(value, str):
        return parser.parse(value)
    else:
        return value


FIX_COLUMNS = defaultdict(lambda: fix_string, {
    'gps_startup_date': fix_dates,
    'gps_deployment_date': fix_dates,
    'gps_retrieval_date': fix_dates,
    'gls_startup_date_gmt': fix_dates,
    'gls_deployment_date': fix_dates,
    'gls_retrieval_date': fix_dates,
    'tdr_startup_date': fix_dates, 
    'tdr_deployment_date': fix_dates,
    'tdr_retrieval_date': fix_dates,
    'other_sensor_startup_date': fix_dates, 
    'other_sensor_deployment_date': fix_dates,
    'other_sensor_retrieval_date': fix_dates,
})

logging.debug(os.environ)


def print_response_error(instance, response, filename=None):
    try:
        body = response.json()
        no_detail = {k:v for k,v in body.items() if k != 'details'}
        template = env.get_template("import_error.html")
        detail = {}
        detail_text = body.get('details')
        try:
            detail = json.loads(body.get('details'))
        except json.decoder.JSONDecodeError:
            pass

        put_html(template.render(
            headers=no_detail.keys(),
            body=no_detail.values(),
            details=detail or detail_text,
            title=str(instance),
            filename=filename,
        ))
    except:
        logging.warn(traceback.format_exc())
        put_error(str(instance) + "\n" + response.text)


def put_reload_button():
    put_button("Upload new data", onclick=lambda: run_js('window.location.reload()'))

tpl = '''
<div>
    <h5>Links</h5>
    <ul>
    {{#contents}}
        <li>{{& pywebio_output_parse}}</li>
    {{/contents}}
    </ul>
</div>
'''

def wizard():
    with app.open():
        put_widget(tpl, {'contents': [
            put_link('Explore Database', '/pgweb/', new_window=True),
            put_link('Rest APIs', '/postgrest/', new_window=True),
            put_link('Uploaded Data', '/data/', new_window=True),
        ]})

        result = actions(
            "What you want to upload?",
            buttons=[
            {"value": "metadata", "type": "submit", "label": "Metadata"},
            {"value": "loggers", "type": "submit", "label": "Loggers"},
        ])
        if result == "metadata":
            handle_metadata()
        elif result == "loggers":
            handle_loggers()
        else:
            put_reload_button()
    
if os.getenv("SENTRY_DSN"):
    wizard = config(js_file="/data/scripts/sentry.js")(wizard)

def handle_metadata():
    fields = []
    expected_fields = ()
    can_be_empty = ()
    try:
        headers = {}
        headers["Content-Type"] = "application/json"
        response = requests.get(
            POSTGREST_URL + "/import_fields",
            headers=headers,
        )
        response.raise_for_status()
        fields = response.json()
        expected_fields = set(e.get('column_name') for e in fields)
        can_be_empty = set(e.get('column_name') for e in fields if e.get('is_nullable'))
    except Exception as instance:
        put_error(f'Error while retriving list of valid import fields - {str(instance)}')
        return
    
    user_inputs = input_group(
        "Import Metadata",
        [
            file_upload("Select spreadsheets:", multiple=True, name="files", 
                accept="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            ),
            input(
                "Ignore first N line(s) at beginning of file",
                NUMBER,
                value=1,
                name="ignorelines",
            ),
        ],
    )
    MAX_CONSECUTIVE_EMPTY_LINES = 200

    data = []
    for index, file in enumerate(user_inputs["files"]):
        workbook = openpyxl.load_workbook(io.BytesIO(file["content"]), data_only=True)
        rows = workbook["METADATA"].iter_rows()
        for _ in range(user_inputs["ignorelines"]):
            next(rows)
        header = [cell.value.strip() for cell in next(rows) if cell.value]
        missing = expected_fields - set(header)
        extra = set(header) - expected_fields
        if (missing - can_be_empty) or extra:
            errors = [(f, 'missing', f in can_be_empty, ) for f in missing] + [(f, 'extra', '-') for f in extra]
            
            errors.sort(key=lambda e: e[0])
            put_warning(f'Spreadsheet {file["filename"]} structure does not match')
            put_table([
                ('field', 'status', 'can be empty'),
                *errors,
            ])

            if missing - can_be_empty:
                put_error(f'Some properties are required to proceed, please fix them')
                put_reload_button()
                return

            result = actions(buttons=[
                {"label": "Ignore extra fields and missing fields", "value": "proceed", "color": "danger"},
                {"label": "Upload new data", "value": "stop", "type": "cancel" },
            ])
            if not result:
                run_js('window.location.reload()')
                return

        logging.debug(header)
        for row in rows:
            row = [cell.value for cell in row]
            if any(row):
                logging.debug(row)
                data.append({k: FIX_COLUMNS[k](v) for k,v in zip(header, row) if k in expected_fields})
            elif MAX_CONSECUTIVE_EMPTY_LINES > 0:
                MAX_CONSECUTIVE_EMPTY_LINES -= 1
            else:
                break

    put_text("The files have loaded.")

    actions(buttons=[{"label": "Import", "value": "import", "color": "primary"}])
    clear("import")
    put_text("Importing...")
    headers = {}
    if POSTGREST_TOKEN:
        headers["Authorization"] = "Bearer " + POSTGREST_TOKEN
    try:
        headers["Content-Type"] = "application/json"
        response = requests.post(
            POSTGREST_URL + "/import",
            headers=headers,
            data=orjson.dumps(data),
        )
        logging.debug(response.text)
        response.raise_for_status()
    except Exception as instance:
        print_response_error(instance=instance, response=response)
        put_reload_button()
        return
    else:
        put_success("Data has been imported sucessfully.")

    for f in user_inputs["files"]:
        filepath = SPREADSHEETS_PATH / f["filename"]

        if filepath.exists():
            name, first_dot, rest = pathlib.Path(f["filename"]).name.partition('.')
            filepath = SPREADSHEETS_PATH / f'{name}_1.{rest}'

        with open(str(filepath), 'wb') as output:
            output.write(f["content"])

    put_reload_button()


def handle_loggers():
    TEMP_DIR = pathlib.Path(tempfile.mkdtemp())
    headers = {}
    if POSTGREST_TOKEN:
        headers["Authorization"] = "Bearer " + POSTGREST_TOKEN

    inputs = input_group(
        "Import Loggers",
        [
            file_upload("Select logger data:", multiple=True, accept=ACCEPTED_EXTENSIONS, name="files", max_size='800M'),
        ]
    )
    logger_files = inputs["files"]

    for logger_file in logger_files:
        filename = logger_file["filename"]
        temp_path = TEMP_DIR / filename
        definitive_path = LOGGERS_PATH / filename

        # TODO: check consistency also with database, is there a logger instrumentator already defined
        if definitive_path.exists() or temp_path.exists():
            put_warning(f"File {filename} exists already, will be skipped")
        else:
            with open(str(temp_path), "wb") as output:
                output.write(logger_file["content"])
            try:
                parser = detect_file(temp_path)
                if TO_PARQUET:
                    parser.write_parquet(PARQUET_PATH)
            except NotImplementedError:
                put_error(f"Logger data {filename}: Format not supported")
            except Exception as instance:
                put_error(f"Logger data {filename}: {traceback.format_exc()}")
            else:
                shutil.move(temp_path, definitive_path)
                to_parquet.configure(lock=definitive_path.name).defer(file_path=str(definitive_path))
                put_success(f"Logger data {filename} have been imported sucessfully.")

    shutil.rmtree(TEMP_DIR)
    put_reload_button()


if __name__ == "__main__":
    start_server(wizard, port=8000, debug=True, max_payload_size='800M')
