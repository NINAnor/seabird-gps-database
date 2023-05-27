#!/usr/bin/env python3

import json
import logging
import os
from urllib.parse import parse_qs, urlparse

import requests
from pywebio import start_server
from pywebio.input import actions, file_upload
from pywebio.output import clear, put_error, put_link, put_success, put_text, use_scope

logging.basicConfig(level=os.getenv("LOGGING", "INFO"))

OPENREFINE_URL = os.getenv("OPENREFINE_URL", "http://localhost:3333")
OPENREFINE_PUBLIC_URL = os.getenv("OPENREFINE_PUBLIC_URL", OPENREFINE_URL)
POSTGREST_URL = os.getenv("POSTGREST_URL", "http:://localhost:3000")
POSTGREST_TOKEN = os.getenv("POSTGREST_TOKEN")

logging.debug(os.environ)

DEFAULT_OPTIONS = {
    "ignoreLines": -1,
    "headerLines": 1,
    "skipDataLines": 0,
    "limit": -1,
    "storeBlankRows": True,
    "storeBlankCellsAsNulls": True,
    "includeFileSources": False,
    "includeArchiveFileName": False,
    "disableAutoPreview": False,
    "forceText": True,
}


class OpenRefine:
    def __init__(self, url, public_url):
        self.url = url
        self.public_url = public_url
        self.csrf_token = None
        self.update_csrf_token()

    def update_csrf_token(self):
        response = self.request("get-csrf-token")
        parsed = response.json()
        self.csrf_token = parsed["token"]

    def request(self, command, method="GET", files=None, **params):
        if self.csrf_token:
            params["csrf_token"] = self.csrf_token
        response = requests.request(
            method,
            self.url + "/command/core/" + command,
            files=files,
            params=params,
            stream=True,
        )
        return response

    def create_project(self, name, files, file_format, index=0, **options):
        all_options = DEFAULT_OPTIONS
        all_options.update(options)

        all_options["sheets"] = []
        form = []
        # https://requests.readthedocs.io/en/latest/user/advanced/#post-multiple-multipart-encoded-files
        for file in files:
            form.append(
                (
                    "project-file",
                    (
                        file["filename"],
                        file["content"],
                        file["mime_type"],
                    ),
                )
            )
            sheet = {"fileNameAndSheetIndex": file["filename"] + "#%d" % index}
            all_options["sheets"].append(sheet)
        form.extend(
            [
                ("project-name", (None, name)),
                ("format", (None, file_format)),
                ("options", (None, json.dumps(all_options))),
            ]
        )

        response = self.request("create-project-from-upload", method="POST", files=form)

        project = parse_qs(urlparse(response.url).query)["project"]

        # https://github.com/OpenRefine/OpenRefine/issues/5387
        response = self.request("get-rows", project=project, start=0, limit=0)

        return project

    def project_url(self, project):
        internal_url = requests.get(
            self.url + "/project", params={"project": project}
        ).url
        if not internal_url.startswith(self.url):
            logging.error(
                f"{self.url} differs from the URL of the project {internal_url}"
            )
            return internal_url
        return internal_url.replace(self.url, self.public_url, 1)

    def project_export(self, project, file_format="csv"):
        return self.request(
            "export-rows/csv",
            method="POST",
            project=project,
            format=file_format,
        )


def wizard():
    openrefine = OpenRefine(OPENREFINE_URL, OPENREFINE_PUBLIC_URL)

    files = file_upload("Select spreadsheets:", multiple=True)

    project = openrefine.create_project(
        files[0]["filename"], files, "binary/text/xml/xls/xlsx", ignoreLines=1
    )
    project_url = openrefine.project_url(project)

    put_text(
        "The files have been imported into an OpenRefine project, which can be reviewed before importing the data in the database."
    )
    put_link(name="Open the project in OpenRefine", url=project_url, new_window=True)

    while True:
        with use_scope("import"):
            actions(
                buttons=[{"label": "Import", "value": "import", "color": "primary"}]
            )
            clear("import")
            put_text("Importing...")
            try:
                response = openrefine.project_export(project)
                response.raise_for_status()
                clean_csv = b""
                for line in response.raw.readlines():
                    line = line
                    if len(line.strip()) == 0:
                        continue
                    clean_csv += line
                headers = {"Content-Type": "text/csv"}
                if POSTGREST_TOKEN:
                    headers["Authorization"] = "Bearer " + POSTGREST_TOKEN
                response = requests.post(
                    POSTGREST_URL + "/import_entry",
                    headers=headers,
                    data=clean_csv,
                )
                logging.debug(response.text)
                response.raise_for_status()
            except Exception as instance:
                put_error(str(instance) + "\n" + response.text)
            else:
                break
    with use_scope("import", clear=True):
        put_success("Data has been imported sucessfully.")


if __name__ == "__main__":
    start_server(wizard, port=8000, debug=True)
