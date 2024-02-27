import pandas as pd
import csv
import io
from parsers.parser_base import Parser
from parsers.helpers import stream_chunk_match, stream_starts_with


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



class PathtrackPressParser(Parser):
    DATATYPE = "tdr"
    DIVIDER = "*" * 85 + "\n"
    HEAD = DIVIDER + "PathTrack Raw Pressure Data File Downloaded from Base Station 50854 (NanoFix Pressure Format)"
    FIELDS = (
        "year",
        "month",
        "day",
        "hour",
        "minute",
        "second",
        "temperature",
        "temperature_decimal",
        "depth_mbar",
        "depth_mbar_decimal",
        "depth_m",
        "depth_m_decimal",
    )
    OUTLIERS = None
    SEPARATOR = ','

    def normalize_data(self):
        self.data['time'] = self.data['hour'].astype(str) + ':' + self.data['minute'].astype(str) + ":" + self.data['second'].astype(str)
        self.data['date'] = self.data['day'].astype(str) + '/' + self.data['month'].astype(str) + ":" + self.data['year'].astype(str)
        return super().normalize_data()

    def __init__(self, stream):
        super().__init__(stream)

        if not self.stream.seekable():
            self._raise_not_supported('Stream not seekable')

        self.stream.seek(0)

        if not stream_starts_with(self.stream, self.HEAD):
            self._raise_not_supported('Stream head different than expected')
        
        _soi, _metadata, data = self.stream.read().split(self.DIVIDER, 2)
        content = io.StringIO(data)
        reader = csv.reader(content, delimiter=self.SEPARATOR)
        header = next(reader)
        if len(header) != len(self.FIELDS):
            self._raise_not_supported(f"Stream have a number of fields different than expected, {len(header)} != {len(self.FIELDS)}")

        self.data = pd.read_csv(content, header=0, names=self.FIELDS, sep=self.SEPARATOR, index_col=False)



PARSERS = [
    TDRParser,
    TDR2Parser,
    PathtrackPressParser,
]