import pandas as pd
import csv
import io
import re
import datetime
from parsers.parser_base import Parser
from parsers.helpers import stream_starts_with


class AcceleratorParser(Parser):
    DATATYPE = "accelerometer"
    FIELDS = ["X", "Y", "Z"]
    HEAD = "ACCELERATION DATA"
    SEPARATOR = ","
    DATE_REGEX = 'START DATE\s+((\d{4})\/\s*(\d{1,2})\/\s*(\d{1,2}))'
    TIME_REGEX = 'START TIME\s+((\d{2}):(\d{2}):(\d{2}))'
    STRP_FORMAT = '%Y/%m/%d %H:%M:%S'
    FREQUENCY_REGEX = '\s*(\d*)\smsec\/point'
    DELTA_ATTR = 'milliseconds'

    def __init__(self, stream):
        super().__init__(stream)

        if not self.stream.seekable():
            self._raise_not_supported('Stream not seekable')

        self.stream.seek(0)

        if not stream_starts_with(self.stream, self.HEAD):
            self._raise_not_supported('Stream head different than expected')
        
        intro, data = self.stream.read().split("\n\n\n")

        content = io.StringIO(data)
        reader = csv.reader(content, delimiter=self.SEPARATOR)
        header = next(reader)
        if [h.strip().upper() for h in header] != self.FIELDS:
            self._raise_not_supported(f"Stream have different of fields than expected, {header} != {self.FIELDS}")

        self.data = pd.read_csv(content, names=self.FIELDS, sep=self.SEPARATOR, index_col=False)
        frequency = self.get_frequency(intro)
        start = self.get_start_datetime(intro)
        self.data['datetime'] = [start + (frequency * index) for index in range(len(self.data))]
    
    def get_start_datetime(self, intro):
        date, year, month, day = re.search(self.DATE_REGEX, intro).groups()
        time, hour, minutes, seconds = re.search(self.TIME_REGEX, intro).groups()

        return datetime.datetime.strptime(f'{date.replace(" ", "")} {time}', self.STRP_FORMAT)
    
    def get_frequency(self, intro):
        frequency = re.search(self.FREQUENCY_REGEX, intro).group(1)
        delta = {self.DELTA_ATTR: int(frequency)}
        return datetime.timedelta(**delta)


class AcceleratorDDMMYYParser(AcceleratorParser):
    DATE_REGEX = 'START DATE\s+((\d{1,2})\/\s*(\d{1,2})\/\s*(\d{1,2}))'
    STRP_FORMAT = '%d/%m/%y %H:%M:%S'



PARSERS = [
    AcceleratorParser,
    AcceleratorDDMMYYParser,
]