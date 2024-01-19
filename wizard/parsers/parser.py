import traceback
import logging

from .parser_base import Parser
from .parser_gps import GPSParser, GPSCSVParser
from .parser_pathtrack import PathtrackParser, PathtrackParserNoUnknown

available_parsers = [
    GPSParser,
    GPSCSVParser,
    PathtrackParser,
    PathtrackParserNoUnknown,
]


def detect(stream) -> Parser:
    for parser in available_parsers:
        try:
            stream.seek(0)
            return parser(stream)
        except:
            logging.warning(traceback.format_exc())
    
    raise NotImplementedError("File not supported")
