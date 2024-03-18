import pathlib
import pytest
import os
from pyarrow.compute import is_in
from ..parser import detect_file
import logging


TESTS_DATA_PATH = pathlib.Path(os.environ.get('TEST_DATA_PATH'))
IGNORED_FILES = [
    '.gitkeep',
]
IGNORED_DIRS = [
    # 'gps_gpx',
    # 'gps_cattrack',
    # 'gps_igotugl',
    # 'gps_unknown',
    # 'gps_2jm',
    'accelerometer',
    # 'gps_pathtrack',
    'tdr',
    # 'gps_ho11',
    'gps_axytrek',
]

testdata_success = []
for dir in (TESTS_DATA_PATH / 'success').iterdir():
    if dir.is_dir() and dir.name not in IGNORED_DIRS:
        for f in dir.iterdir():
            if not f.is_dir() and f.name not in IGNORED_FILES:
                testdata_success.append((f.name, f, dir.name))

testdata_fail = [(f.name, f) for f in (TESTS_DATA_PATH / 'fail').iterdir() if not f.is_dir()]

@pytest.mark.parametrize("file,path,format", testdata_success)
def test_parser_success(file, path, format):
    parser_instance = detect_file(path)
    assert parser_instance.DATATYPE == format
    table = parser_instance.as_table()
    assert table
    assert is_in([format], table.column('_datatype'))
    assert is_in([parser_instance.__class__.__name__], table.column('_parser'))


@pytest.mark.parametrize("file,path", testdata_fail)
def test_parser_fail(file, path):
    with pytest.raises(NotImplementedError):
        detect_file(path)
