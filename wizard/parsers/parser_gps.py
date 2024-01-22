import pandas as pd
import csv
import io
import logging
from .parser_base import CSVParser
from .helpers import stream_starts_with, stream_chunk_contains


class GPSParser(CSVParser):
    DATATYPE = "gps"
    FIELDS = [
            "device_id",
            "UTC_datetime",
            "UTC_date",
            "UTC_time",
            "datatype",
            "satcount",
            "U_bat_mV",
            "bat_soc_pct",
            "solar_I_mA",
            "hdop",
            "Latitude",
            "Longitude",
            "Altitude_m",
            "speed_km_h",
            "direction_deg",
            "temperature_C",
            "mag_x",
            "mag_y",
            "mag_z",
            "acc_x",
            "acc_y",
            "acc_z",
            "depth_m",
            "",
        ]
    

class IGotU_GT_Parser(CSVParser):
    '''
    Parser for IGotU_GT X version Logger
    '''
    DATATYPE = "gps_igotugl"
    FIELDS = [
            "Date", "Time", "Latitude", "Longitude", "Altitude", "Speed", "Course", "Type", "Distance", "Essential"
        ]


class IGotU_GT_TabSeparatedParser(IGotU_GT_Parser):
    '''
    Parser for Earth&Ocean Logger separated by tabs
    '''
    SEPARATOR = '\t'


class GPSUnknownFormatParser(CSVParser):
    '''
    Parser for a format, its a GPS CSV like format
    with the following fields
    '''
    DATATYPE = "gps_unknown"
    SEPARATOR = '\t'
    FIELDS = [
            "DataID", "ID","Ring_nr","Date","Time","Altitude","Speed","Course","HDOP","Latitude","Longitude","TripNr"]


class GPSUnknownFormatParserWithEmptyColumns(GPSUnknownFormatParser):
    '''
    Parser for a format, its a GPS CSV like format
    with the following fields
    '''
    
    def __init__(self, stream):
        self.stream = stream
        self.data = []

        if not self.stream.seekable():
            self._raise_not_supported('Stream not seekable')

        reader = csv.reader(self.stream, delimiter=self.SEPARATOR, skipinitialspace=self.SKIP_INITIAL_SPACE)
        header = next(reader)

        # Filter empty columns
        header = [c for c in header if c != ""]

        if header != self.FIELDS:
            self._raise_not_supported(f"Stream have a header different than expected, {header} != {self.FIELDS}")

        self.stream.seek(0)
        self.data = pd.read_csv(self.stream, header=1, names=self.FIELDS, sep=self.SEPARATOR, index_col=False)


class GPSCatTrackParser(CSVParser):
    '''
    Parser for a format, its a GPS CSV like format
    with the following fields
    '''
    DATATYPE = "gps_cattrack"
    DIVIDER = "--------\n"
    FIELDS = [
"Date", "Time", "Latitude", "Longitude", "Altitude", "Satellites", "HDOP", "PDOP", "Temperature [C]", "Speed [km/h]", "TTFF", "SNR", "tbd"]
    
    def __init__(self, stream):
        self.stream = stream
        self.data = []

        if not self.stream.seekable():
            self._raise_not_supported('Stream not seekable')
        
        if not stream_starts_with(self.stream, "Name:CatLog"):
            self._raise_not_supported(f"Stream must start with Name:CatLog")

        _intro, data = self.stream.read().split(self.DIVIDER)
        content = io.StringIO(data)

        reader = csv.reader(content, delimiter=self.SEPARATOR, skipinitialspace=self.SKIP_INITIAL_SPACE)
        header = next(reader)
        if header != self.FIELDS:
            self._raise_not_supported(f"Stream have fields different than expected, {header} != {self.FIELDS}")

        self.data = pd.read_csv(content, header=0, names=self.FIELDS, sep=self.SEPARATOR, index_col=False)


class GPS2JMParser(CSVParser):
    '''
    Parser for 2Jm format
    '''
    DATATYPE = "gps_2jm"
    # TODO: define fields
    FIELDS = [str(x) for x in range(0,13)]
    SEPARATOR = " "
    ENDINGS = [
        "[EOF]",
        "---- End of data ----",
    ]
    
    def __init__(self, stream):
        self.stream = stream
        self.data = []

        if not self.stream.seekable():
            self._raise_not_supported('Stream not seekable')
        
        if not stream_chunk_contains(self.stream, 30, "2JmGPS-LOG"):
            self._raise_not_supported(f"Stream must start with 2JmGPS-LOG")
        
        groups = self.stream.read().split('\n\n')[1:]
        data = None
        for group in groups:
            if group in self.ENDINGS:
                break
            data = group

        content = io.StringIO(data)

        reader = csv.reader(content, delimiter=self.SEPARATOR, skipinitialspace=self.SKIP_INITIAL_SPACE)
        header = next(reader)
        if len(header) != len(self.FIELDS):
            self._raise_not_supported(f"Stream have fields different than expected, {len(header)} != {len(self.FIELDS)}")

        self.data = pd.read_csv(content, header=0, names=self.FIELDS, sep=self.SEPARATOR, index_col=False)



PARSERS = [
    GPSParser,
    GPSUnknownFormatParser,
    GPSUnknownFormatParserWithEmptyColumns,
    GPSCatTrackParser,
    IGotU_GT_Parser,
    IGotU_GT_TabSeparatedParser,
    GPS2JMParser,
]