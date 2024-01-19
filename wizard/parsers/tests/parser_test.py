import pathlib
import pytest
import csv

from ..parser import detect


TESTS_DATA_PATH = pathlib.Path('./parsers/tests/data')

TEST_FORMAT = [
    'gps_pathtrack'
]

testdata_success = []
for dir in (TESTS_DATA_PATH / 'success').iterdir():
    if dir.is_dir():
        for f in dir.iterdir():
            if not f.is_dir():
                testdata_success.append((f.name, f, dir.name))

testdata_fail = [(f.name, f) for f in (TESTS_DATA_PATH / 'fail').iterdir() if not f.is_dir()]

@pytest.mark.parametrize("file,path,format", testdata_success)
def test_parser_success(file, path, format):
    with open(str(path)) as f:
        parser_instance = detect(f)
        assert parser_instance.DATATYPE == format
        assert parser_instance.as_table()


@pytest.mark.parametrize("file,path", testdata_fail)
def test_parser_fail(file, path):
    with open(str(path)) as f:
        with pytest.raises(NotImplementedError):
            result = detect(f)
            print(result)
