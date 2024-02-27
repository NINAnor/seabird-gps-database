import pandas as pd
import csv

from parsers.parser_base import CSVParser


class GPSUnknownFormatParser(CSVParser):
    '''
    Parser for a format, its a GPS CSV like format
    with the following fields
    '''
    DATATYPE = "gps_unknown"
    SEPARATOR = '\t'
    FIELDS = [
            "DataID", "ID","Ring_nr","Date","Time","Altitude","Speed","Course","HDOP","Latitude","Longitude","TripNr"]
    
    MAPPINGS = {
        "id": "DataID",
        "date": "Date",
        "time": "Time",
        "latitude": "Latitude",
        "longitude": "Longitude",
        "altitude": "Altitude",
        "speed_km_h": "Speed",
        "type": None,
        "distance": None,
        "course": "Course",
        "hdop": "HDOP",
        "pdop": None,
        "satellites_count": None,
        "temperature": None,
        "solar_I_mA": None,
        "bat_soc_pct": None,
        "ring_nr": "Ring_nr",
        "trip_nr": "TripNr",
    }



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


PARSERS = [
    GPSUnknownFormatParser,
    GPSUnknownFormatParserWithEmptyColumns,
]