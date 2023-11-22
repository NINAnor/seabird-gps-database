from .helpers import stream_starts_with


class Parser:
    HEAD = ""

    def __init__(self, stream):
        self.stream = stream

    def compatible(self):
        if not self.stream.seekable():
            return False
        if not stream_starts_with(self.stream, self.HEAD):
            return False
        return True

    def parse(self):
        pass
