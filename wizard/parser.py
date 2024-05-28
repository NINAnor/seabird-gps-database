#!/usr/bin/env python3

import sys

from parsers.parser import detect_file

if __name__ == "__main__":
    parser = detect_file(sys.argv[1])
    if len(sys.argv) > 2:
        parser.write_csv(sys.argv[2])
