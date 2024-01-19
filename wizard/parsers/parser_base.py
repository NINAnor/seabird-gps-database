import csv
import pathlib
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq


class ParserNotSupported(Exception):
    pass


class Parser:
    DATATYPE = "generic_parser"

    def __init__(self, stream):
        self.stream = stream
        self.data = []

    def _raise_not_supported(self, text):
        raise ParserNotSupported(f'{self.__class__.__name__}: {text}')
    
    def as_table(self) -> pa.Table:
        return pa.Table.from_pandas(self.data, preserve_index=False)
    
    def write_parquet(self, path: pathlib.Path, filename: str = None):
        if filename:
            filename = pathlib.Path(filename)
        if not filename and self.stream.name:
            filename = pathlib.Path(self.stream.name)
        else:
            raise Exception("Stream has no name and no filename is provided")

        pq.write_table(self.as_table(), str(path / f'{filename.stem}_{self.DATATYPE}.parquet'))


class CSVParser(Parser):
    DATATYPE = "generic_csv"
    FIELDS = []
    SEPARATOR = ','

    def __init__(self, stream):
        super().__init__(stream)
        if not self.stream.seekable():
            self._raise_not_supported('Stream not seekable')

        reader = csv.reader(self.stream, delimiter=self.SEPARATOR)
        header = next(reader)
        if len(header) != len(self.FIELDS):
            self._raise_not_supported(f"Stream have a number of fields different than expected, {len(header)} != {len(self.FIELDS)}")

        self.stream.seek(0)
        self.data = pd.read_csv(self.stream, sep=self.SEPARATOR)
