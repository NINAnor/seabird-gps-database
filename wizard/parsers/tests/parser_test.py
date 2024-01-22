import pathlib
import pytest
import csv
from pyarrow.compute import is_in
from ..parser import detect


TESTS_DATA_PATH = pathlib.Path('./parsers/tests/data')

testdata_success = []
for dir in (TESTS_DATA_PATH / 'success').iterdir():
    if dir.is_dir() and not dir.name.endswith('__ignore'):
        for f in dir.iterdir():
            if not f.is_dir():
                testdata_success.append((f.name, f, dir.name))

testdata_fail = [(f.name, f) for f in (TESTS_DATA_PATH / 'fail').iterdir() if not f.is_dir()]

@pytest.mark.parametrize("file,path,format", testdata_success)
def test_parser_success(file, path, format):
    with open(str(path)) as f:
        parser_instance = detect(f)
        assert parser_instance.DATATYPE == format
        table = parser_instance.as_table()
        assert table
        assert is_in([format], table.column('datatype'))
        assert is_in([parser_instance.__class__.__name__], table.column('parser'))


@pytest.mark.parametrize("file,path", testdata_fail)
def test_parser_fail(file, path):
    with open(str(path)) as f:
        with pytest.raises(NotImplementedError):
            result = detect(f)
            print(result)
