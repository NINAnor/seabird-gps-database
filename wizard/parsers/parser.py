from .parser_gps import GPSParser
from .parser_pathtrack import PathtrackParser

available_parsers = [
    GPSParser,
    PathtrackParser,
]


def detect(stream):
    for parser in available_parsers:
        parser_instance = parser(stream)
        if parser_instance.compatible():
            return parser
    else:
        raise NotImplementedError("File not supported")


def parse(stream):
    parser = detect(stream)
    parser_instance = parser(stream)
    result = parser_instance.parse()
    header = next(result)
    yield "filename," + ",".join(header)
    for line in result:
        yield stream.name + "," + ",".join(line)
