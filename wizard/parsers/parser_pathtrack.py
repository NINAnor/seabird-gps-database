import csv
import io
import pandas as pd
from .helpers import stream_starts_with
from .parser_base import Parser, ParserNotSupported


class PathtrackParser(Parser):
    DATATYPE = "gps_pathtrack"
    DIVIDER = "*" * 85 + "\n"
    HEAD = DIVIDER + "PathTrack Archival Tracking System Results File"
    FIELDS = (
        "day",
        "month",
        "year",
        "hour",
        "minute",
        "second",
        "second_of_day",
        "satellites",
        "lat",
        "lon",
        "altitude",
        "clock_offset",
        "accuracy",  # HDOP?
        "battery",
        "unknown1",
        "unknown2",
    )
    SEPARATOR = ','

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


class PathtrackParserNoUnknown(PathtrackParser):
    FIELDS = (
        "day",
        "month",
        "year",
        "hour",
        "minute",
        "second",
        "second_of_day",
        "satellites",
        "lat",
        "lon",
        "altitude",
        "clock_offset",
        "accuracy",  # HDOP?
        "battery",
    )
