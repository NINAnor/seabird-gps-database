import pandas as pd
import csv
import io
from .parser_base import Parser
from .helpers import stream_chunk_match


class TDRParser(Parser):
    DATATYPE = "tdr"
    FIELDS = ["Date/Time Stamp", "Pressure", "Temp"]
    SEPARATOR = ","
    ALLOWED_META = ['Resolution']
    HEAD = '\n?Comment\s:-'

    def __init__(self, stream):
        super().__init__(stream)
        meta = {}

        if not self.stream.seekable():
            self._raise_not_supported('Stream not seekable')

        self.stream.seek(0)

        if not stream_chunk_match(self.stream, 200, self.HEAD):
            self._raise_not_supported('Stream head different than expected')
        
        intro, data, _end = self.stream.read().split("\n\n\n\n")
        print(intro)

        # TODO: some metadata could be present also in the intro

        # Split line by line iteratively until the expected header is found
        print(data.split('\n', 1)[0], ','.join(self.FIELDS))
        while data.split('\n', 1)[0] != ','.join(self.FIELDS):
            row, data = data.split('\n', 1)
            print(row)
            # In the meantime we expect rows like "Key = Value"
            if '=' in row:
                key, value = row.split('=')
                if key in self.ALLOWED_META:
                    meta[key.strip()] = value.strip()
            else:
                try:
                    # Only the csv data start with a number (it's a date)
                    # so if the first value is a number, then header is not what we expect
                    # ---> fail fast without reading the whole file
                    if int(row[0]):
                        self._raise_not_supported('Header not recognized')
                except ValueError:
                    # this is expected
                    pass

        content = io.StringIO(data)
        reader = csv.reader(content, delimiter=self.SEPARATOR)
        header = next(reader)
        if header != self.FIELDS:
            self._raise_not_supported(f"Stream have different of fields than expected, {header} != {self.FIELDS}")

        self.data = pd.read_csv(content, names=self.FIELDS, sep=self.SEPARATOR, index_col=False)

        for key, value in meta:
            self.data[key] = [value] * len(self.data)


class TDR2Parser(TDRParser):
    FIELDS = [
        "Time Stamp", "Pressure", "Temp",
    ]

PARSERS = [
    TDRParser,
    TDR2Parser
]