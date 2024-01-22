import traceback
import logging
from chardet.universaldetector import UniversalDetector

from .parser_base import Parser
from .parser_gps import PARSERS as GPS_PARSERS
from .parser_accelerometer import PARSERS as ACCELEROMETER_PARSERS
from .parser_tdr import PARSERS as TDR_PARSERS
from .parser_gpx import GPXParser
from .parser_pathtrack import PathtrackParser, PathtrackParserNoUnknown

available_parsers = [
    PathtrackParser,
    PathtrackParserNoUnknown,
    GPXParser,
] + GPS_PARSERS + ACCELEROMETER_PARSERS + TDR_PARSERS


def detect(stream) -> Parser:
    for parser in available_parsers:
        try:
            stream.seek(0)
            return parser(stream)
        except:
            logging.warning(traceback.format_exc())
    
    raise NotImplementedError("File not supported")


def detect_file(path):
    encoding = detect_encoding(path)
    print(encoding)
    with open(path, encoding=encoding) as stream:
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
