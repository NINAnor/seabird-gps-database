import io
import csv

import pandas as pd

from parsers.parser_base import Parser, Parsable
from parsers.helpers import stream_chunk_contains

class GPS2JMParser(Parser):
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


    # TODO: understand the fields first
    # MAPPINGS = {
    #     "id": "",
    #     "date": None,
    #     "time": None,
    #     "latitude": None,
    #     "longitude": None,
    #     "altitude": None,
    #     "speed_km_h": None,
    #     "type": None,
    #     "distance": None,
    #     "course": None,
    #     "hdop": None,
    #     "pdop": None,
    #     "satellites_count": None,
    #     "direction_deg": None,
    #     "temperature": None,
    #     "solar_I_mA": None,
    #     "bat_soc_pct": None,
    #     "ring_nr": None,
    #     "trip_nr": None,
    # }
    
    def __init__(self, parsable: Parsable):
        super().__init__(parsable)

        with self.file.get_stream(binary=False) as stream:
            if not stream.seekable():
                self._raise_not_supported('Stream not seekable')
        
            if not stream_chunk_contains(stream, 30, "2JmGPS-LOG"):
                self._raise_not_supported(f"Stream must start with 2JmGPS-LOG")
        
            groups = stream.read().split('\n\n')[1:]
            data = None
            for group in groups:
                if group in self.ENDINGS:
                    break
                data = group

            content = io.StringIO(data)

            reader = csv.reader(content, delimiter=self.SEPARATOR, skipinitialspace=True)
            header = next(reader)
            if len(header) != len(self.FIELDS):
                self._raise_not_supported(f"Stream have fields different than expected, {len(header)} != {len(self.FIELDS)}")

            self.data = pd.read_csv(content, header=0, names=self.FIELDS, sep=self.SEPARATOR, index_col=False)

PARSERS = [
    GPS2JMParser,
]
