from .helpers import read_csv
from .parser_base import Parser


class PathtrackParser(Parser):
    DATATYPE = "gps_pathtrack"
    DIVIDER = "*" * 85 + "\n"
    HEAD = DIVIDER + "PathTrack Archival Tracking System Results File"
    HEADER = (
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

    def parse(self):
        _soi, _metadata, data = self.stream.read().split(self.DIVIDER, 2)
        yield self.HEADER
        for line in read_csv(data):
            if len(line) == len(self.HEADER):
                yield line
            elif len(line) == (len(self.HEADER) - 2):
                line += ["", ""]
                yield line
            else:
                assert len(line) == len(self.HEADER)
