import traceback
import logging
from chardet.universaldetector import UniversalDetector

from .parser_base import Parser, ParserNotSupported, Parsable
from .gps import PARSERS as GPS_PARSERS
from .accelerometer import PARSERS as ACCELEROMETER_PARSERS
from .tdr import PARSERS as TDR_PARSERS
# from .parser_excel import GPSUnknownFormatExcelParser

available_parsers = GPS_PARSERS + ACCELEROMETER_PARSERS + TDR_PARSERS

binary_parsers = [
    # GPSUnknownFormatExcelParser,
]

def detect_file(path):
    parsable = Parsable(file_path=path)

    for parser in available_parsers:
        try:
            result = parser(parsable)
            logging.info(f'Parsed with {parser}')
            return result
        except ParserNotSupported:
            logging.debug('Expected: ' + traceback.format_exc())
        except:
            logging.error(traceback.format_exc())
    
    raise NotImplementedError("File not supported")
