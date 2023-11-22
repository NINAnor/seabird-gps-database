#!/usr/bin/env python3

import sys

from parsers import parser

if __name__ == "__main__":
    for line in parser.parse(open(sys.argv[1])):
        print(line)
