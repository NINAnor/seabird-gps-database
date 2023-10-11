#!/usr/bin/env python3

import logging
import os
from urllib.parse import parse_qs, urlparse
import io

import requests
from pywebio import start_server
from pywebio.input import actions, file_upload, input, input_group, NUMBER
from pywebio.output import clear, put_error, put_link, put_success, put_text, use_scope
import openpyxl
import orjson

logging.basicConfig(level=os.getenv("LOGGING", "INFO"))

POSTGREST_URL = os.getenv("POSTGREST_URL", "http://localhost:3000")
POSTGREST_TOKEN = os.getenv("POSTGREST_TOKEN")

logging.debug(os.environ)


def wizard():
    user_inputs = input_group(
        "Import", [
            file_upload("Select spreadsheets:", multiple=True, name="files"),
            input("Ignore first N line(s) at beginning of file", NUMBER, value=1, name="ignorelines"),
        ]
    )

    data = []
    for index, file in enumerate(user_inputs["files"]):
        workbook = openpyxl.load_workbook(io.BytesIO(file['content']), data_only=True)
        rows = workbook['METADATA'].iter_rows()
        for _ in range(user_inputs["ignorelines"]):
            next(rows)
        header = [cell.value for cell in next(rows)]
        for row in rows:
            row = [cell.value for cell in row]
            logging.debug(row)
            if not any(row):
                continue
            data.append(dict(zip(header, row)))

    put_text(
        "The files have loaded."
    )

    actions(
        buttons=[{"label": "Import", "value": "import", "color": "primary"}]
    )
    clear("import")
    put_text("Importing...")
    try:
        headers = {"Content-Type": "application/json"}
        if POSTGREST_TOKEN:
            headers["Authorization"] = "Bearer " + POSTGREST_TOKEN
        response = requests.post(
            POSTGREST_URL + "/import",
            headers=headers,
            data=orjson.dumps(data),
        )
        logging.debug(response.text)
        response.raise_for_status()
    except Exception as instance:
        put_error(str(instance) + "\n" + response.text)
    else:
        put_success("Data has been imported sucessfully.")

if __name__ == "__main__":
    start_server(wizard, port=8000, debug=True)
