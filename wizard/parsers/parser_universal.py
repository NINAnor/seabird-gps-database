from .parser_gps import GPSParser
from .parser_pathtrack import PathtrackParser

PARSERS = [
    GPSParser,
    PathtrackParser,
]


def universal_parser(stream):
    for parser in PARSERS:
        parser_instance = parser(stream)
        if parser_instance.compatible():
            result = parser_instance.parse()
            break
    else:
        raise NotImplementedError("File not supported")
    header = next(result)
    print("filename," + ",".join(header))
    for line in result:
        print(stream.name + "," + ",".join(line))
