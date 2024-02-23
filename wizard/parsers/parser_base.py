import csv
import pathlib
import os
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
import pyarrow.csv as pacsw
import logging

MAX_SPEED = float(os.environ.get('MAX_SPEED', default="10"))

class ParserNotSupported(Exception):
    pass


class Parser:
    DATATYPE = "generic_parser"
    OUTLIERS = {
        "speed_km_h": lambda x: x > MAX_SPEED
    }

    def __init__(self, stream):
        self.stream = stream
        self.data = []

    def _raise_not_supported(self, text):
        raise ParserNotSupported(f'{self.__class__.__name__}: {text}')
    
    def get_mappings(self):
        return getattr(self, 'MAPPINGS', {}) 
    
    def get_outliers(self):
        return getattr(self, 'OUTLIERS', {})
    
    def normalize_data(self):
        '''
        Remap values parsed
        '''
        mappings = self.get_mappings()
        if mappings:
            data = self.data
            df = pd.DataFrame(columns=mappings.keys(), index=range(1, data.size))

            for k,v in mappings.items():
                if v:
                    df[k] = data[v]

            self.data = df

    def detect_outliers(self):
        '''
        Apply conditions on fields to check for outliers
        '''
        outliers = self.get_outliers()
        if outliers:
            def check_conditions(row):
                return any(condition(row[k]) for k, condition in outliers.items() if k in self.data)

            self.data['outlier'] = self.data.apply(check_conditions, axis=1)

    def as_table(self) -> pa.Table:
        self.normalize_data()
        self.detect_outliers()
        table = pa.Table.from_pandas(self.data, preserve_index=False)
        table = table.append_column('datatype', pa.array([self.DATATYPE] * len(table), pa.string()))
        table = table.append_column('parser', pa.array([self.__class__.__name__] * len(table), pa.string()))
        return table
    
    def write_parquet(self, path: pathlib.Path, filename: str = None):
        if filename:
            filename = pathlib.Path(filename)
        if not filename and self.stream.name:
            filename = pathlib.Path(self.stream.name)
        else:
            raise Exception("Stream has no name and no filename is provided")

        pq.write_table(self.as_table(), str(path / f'{filename.stem}.parquet'))

    def write_csv(self, path):
        pacsw.write_csv(self.as_table(), str(path))


class CSVParser(Parser):
    DATATYPE = "generic_csv"
    FIELDS = []
    SEPARATOR = ','
    SKIP_INITIAL_SPACE = True

    def __init__(self, stream):
        super().__init__(stream)

        if 'b' in self.stream.mode:
            self._raise_not_supported('Stream is binary')

        if not self.stream.seekable():
            self._raise_not_supported('Stream not seekable')

        reader = csv.reader(self.stream, delimiter=self.SEPARATOR, skipinitialspace=self.SKIP_INITIAL_SPACE)
        header = next(reader)
        if header != self.FIELDS:
            self._raise_not_supported(f"Stream have a header different than expected, {header} != {self.FIELDS}")

        self.stream.seek(0)
        self.data = pd.read_csv(self.stream, header=1, names=self.FIELDS, sep=self.SEPARATOR, index_col=False)


class ExcelParser(Parser):
    DATATYPE = "generic_excel"
    FIELDS = []
    SKIPROWS = 0

    def __init__(self, stream):
        super().__init__(stream)

        if not 'b' in self.stream.mode:
            self._raise_not_supported('Stream is not binary')

        if 'xls' not in pathlib.Path(self.stream.name).suffix:
            self._raise_not_supported('Extension is not xls')

        self.data = pd.read_excel(self.stream, header=0, index_col=False, skiprows=self.SKIPROWS)
        if set(self.data.columns.values) != set(self.FIELDS):
            self._raise_not_supported('Field name not matching: ' + str({
                    "missing": list(set(self.data.columns.values) - set(self.FIELDS)),
                    "extra": list(set(self.FIELDS) - set(self.data.columns.values)),
                })
            )
