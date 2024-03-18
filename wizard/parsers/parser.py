import traceback
import logging

from .parser_base import ParserNotSupported, Parsable
from .gps import PARSERS as GPS_PARSERS
from .accelerometer import PARSERS as ACCELEROMETER_PARSERS
from .tdr import PARSERS as TDR_PARSERS
from .other_sensor import PARSERS as OTHER_SENSOR_PARSERS

available_parsers = GPS_PARSERS + ACCELEROMETER_PARSERS + TDR_PARSERS + OTHER_SENSOR_PARSERS


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
