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

import openpyxl
import orjson
import requests
from pywebio import start_server
from pywebio.input import NUMBER, actions, file_upload, input, input_group
from pywebio.output import clear, put_error, put_success, put_text, put_button, put_html, put_table, put_warning
from pywebio.session import run_js
from jinja2 import Environment, FileSystemLoader, select_autoescape

env = Environment(
    loader=FileSystemLoader("./templates"),
    autoescape=select_autoescape()
)

from parsers.parser import detect, parse

logging.basicConfig(level=os.getenv("LOGGING", "INFO"))

POSTGREST_URL = os.getenv("POSTGREST_URL", "http://localhost:3000")
POSTGREST_TOKEN = os.getenv("POSTGREST_TOKEN")
DATA_PATH = pathlib.Path(os.getenv("DATA_PATH", '/data/'))

LOGGERS_PATH = DATA_PATH  / 'loggers'
SPREADSHEETS_PATH = DATA_PATH  / 'metadata'

LOGGERS_PATH.mkdir(exist_ok=True)
SPREADSHEETS_PATH.mkdir(exist_ok=True)


logging.debug(os.environ)


def print_response_error(instance, response, filename):
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


def wizard():
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
            row = [cell.value.strip() if isinstance(cell.value, str) else cell.value for cell in row]
            if any(row):
                logging.debug(row)
                data.append({k:v for k,v in zip(header, row) if k in expected_fields})
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
            file_upload("Select logger data:", multiple=True, accept=['.csv', '.pos', '.gpx'], name="files"),
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
                stream = open(str(temp_path))
                datatype = detect(stream).DATATYPE
                headers["Content-Type"] = "text/csv"
                response = requests.post(
                    POSTGREST_URL + f"/import_logger_data_{datatype}",
                    headers=headers,
                    data="\n".join(parse(stream)),
                )
                logging.debug(response.text)
                response.raise_for_status()
            except requests.exceptions.HTTPError as instance:
                print_response_error(instance, response, filename=filename)
            except Exception as instance:
                put_error(f"Logger data {filename}: {traceback.format_exc()}")
            else:
                shutil.move(temp_path, definitive_path)
                put_success(f"Logger data {filename} have been imported sucessfully.")

    shutil.rmtree(TEMP_DIR)
    put_reload_button()


if __name__ == "__main__":
    start_server(wizard, port=8000, debug=True)
