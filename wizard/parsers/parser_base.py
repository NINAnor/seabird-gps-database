import csv
import pathlib
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
import pyarrow.csv as pacsw


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
        if not self.stream.seekable():
            self._raise_not_supported('Stream not seekable')

        reader = csv.reader(self.stream, delimiter=self.SEPARATOR, skipinitialspace=self.SKIP_INITIAL_SPACE)
        header = next(reader)
        if header != self.FIELDS:
            self._raise_not_supported(f"Stream have a header different than expected, {header} != {self.FIELDS}")

        self.stream.seek(0)
        self.data = pd.read_csv(self.stream, header=1, names=self.FIELDS, sep=self.SEPARATOR, index_col=False)
