import traceback
import logging
from chardet.universaldetector import UniversalDetector

from .parser_base import Parser, ParserNotSupported
from .parser_gps import PARSERS as GPS_PARSERS
from .parser_accelerometer import PARSERS as ACCELEROMETER_PARSERS
from .parser_tdr import PARSERS as TDR_PARSERS
from .parser_gpx import GPXParser
from .parser_pathtrack import PathtrackParser, PathtrackParserNoUnknown
from .parser_excel import GPSUnknownFormatExcelParser

available_parsers = [
    PathtrackParser,
    PathtrackParserNoUnknown,
    GPXParser,
] + GPS_PARSERS + ACCELEROMETER_PARSERS + TDR_PARSERS

binary_parsers = [
    GPSUnknownFormatExcelParser,
]


def detect(stream) -> Parser:
    if 'b' in stream.mode:
        for parser in binary_parsers:
            try:
                stream.seek(0)
                return parser(stream)
            except ParserNotSupported:
                logging.warning('Expected: ' + traceback.format_exc())
            except:
                logging.error(traceback.format_exc())
    else:
        for parser in available_parsers:
            try:
                stream.seek(0)
                return parser(stream)
            except ParserNotSupported:
                logging.debug('Expected: ' + traceback.format_exc())
            except:
                logging.error(traceback.format_exc())
    
    raise NotImplementedError("File not supported")


def detect_file(path):
    encoding = detect_encoding(path)
    if encoding:
        print('here...')
        with open(path, 'r', encoding=encoding) as stream:
            return detect(stream)
    else:
        try:
            with open(path, 'r') as stream:
                stream.read()
                return detect(stream)
        except UnicodeDecodeError:
            with open(path, 'rb') as stream:
                return detect(stream)


def detect_encoding(path):
    detector = UniversalDetector()
    with open(path, 'rb') as stream:
        for line in stream.readlines():
            detector.feed(line)
            if detector.done: break
        detector.close()
        print(detector.result)
        return detector.result['encoding']
