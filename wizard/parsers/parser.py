import traceback
import logging

from .parser_base import Parser
from .parser_gps import PARSERS as GPS_PARSERS
from .parser_accelerometer import PARSERS as ACCELEROMETER_PARSERS
from .parser_gpx import GPXParser
from .parser_pathtrack import PathtrackParser, PathtrackParserNoUnknown

available_parsers = [
    PathtrackParser,
    PathtrackParserNoUnknown,
    GPXParser,
] + GPS_PARSERS + ACCELEROMETER_PARSERS


def detect(stream) -> Parser:
    for parser in available_parsers:
        try:
            stream.seek(0)
            return parser(stream)
        except:
            logging.warning(traceback.format_exc())
    
    raise NotImplementedError("File not supported")
