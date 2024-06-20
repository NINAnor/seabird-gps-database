from parsers.parser_base import CSVParser


class EcotoneParser(CSVParser):
    DATATYPE = "gps_ecotone"
    FIELDS = [x for x in range(0,9)]
    SEPARATOR = ";"
    HEADER = 0

    def _check_headers(self, header):
        if len(header) != len(self.FIELDS):
            self._raise_not_supported(f"Stream have a header length different than expected, {len(header)} != {len(self.FIELDS)}")


PARSERS = [
    EcotoneParser,
]