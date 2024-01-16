#!/usr/bin/env python3

import io
import logging
import os
import os.path
import traceback

import openpyxl
import orjson
import requests
from pywebio import start_server
from pywebio.input import NUMBER, actions, file_upload, input, input_group
from pywebio.output import clear, put_error, put_success, put_text, put_button, put_html
from pywebio.session import run_js

from parsers.parser import detect, parse

logging.basicConfig(level=os.getenv("LOGGING", "INFO"))

POSTGREST_URL = os.getenv("POSTGREST_URL", "http://localhost:3000")
POSTGREST_TOKEN = os.getenv("POSTGREST_TOKEN")

logging.debug(os.environ)


def print_response_error(instance, response):
    try:
        body = response.json()
        put_html(f"""
<div class="alert alert-danger " role="alert" >
    <h4>Error</h4>
    <p>{str(instance)}</p>
    <table>
        <thead>
            <tr>
            {''.join([f'<th>{k}</th>' for k in body.keys()])}
            </tr>
        </thead>
        <tbody>
            <tr>
            {''.join([f'<td>{k}</td>' for k in body.values()])}
            </tr>
        </tbody>
    </table>
</div>
""")
    except:
        put_error(str(instance) + "\n" + response.text)


def put_reload_button():
    put_button("Upload new data",onclick=lambda: run_js('window.location.reload()'))


def wizard():
    user_inputs = input_group(
        "Import",
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
        header = [cell.value for cell in next(rows) if cell.value]
        logging.debug(header)
        for row in rows:
            row = [cell.value for cell in row]
            if any(row):
                logging.debug(row)
                data.append(dict(zip(header, row)))
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

    logger_files = file_upload("Select logger data:", multiple=True)
    try:
        for logger_file in logger_files:
            logger_file_local = "loggers_data/" + logger_file["filename"]
            if os.path.exists(logger_file_local):
                raise FileExistsError(f"File {logger_file['filename']} exists already")
            with open(logger_file_local, "wb") as output:
                output.write(logger_file["content"])
    except Exception:
        for logger_file in logger_files:
            logger_file_local = "loggers_data/" + logger_file["filename"]
            os.remove(logger_file_local)
        put_error(traceback.format_exc())
        return
    else:
        put_success("Loggers data have been uploaded.")
    try:
        stream = open(logger_file_local)
        datatype = detect(stream).DATATYPE
        headers["Content-Type"] = "text/csv"
        response = requests.post(
            POSTGREST_URL + f"/import_logger_data_{datatype}",
            headers=headers,
            data="\n".join(parse(stream)),
        )
        logging.debug(response.text)
        response.raise_for_status()
    except Exception as instance:
        print_response_error(instance, response)
    else:
        put_success("Loggers data have been imported sucessfully.")

    put_reload_button()


if __name__ == "__main__":
    start_server(wizard, port=8000, debug=True)
