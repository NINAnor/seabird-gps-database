import pandas as pd
import gpxpy
from .helpers import stream_chunk_contains
from .parser_base import Parser


class GPXParser(Parser):
    DATATYPE = "gps_gpx"
    FIELDS = [
        "latitude",
        "longitude",
        "elevation",
        "time",
        "satellites",
    ]

    def __init__(self, stream):
        super().__init__(stream)

        if not self.stream.seekable():
            self._raise_not_supported('Stream not seekable')

        self.stream.seek(0)

        if not stream_chunk_contains(self.stream, 30, '<?xml'):
            self._raise_not_supported('Stream does not start with <?xml')
        
        gpx = gpxpy.parse(self.stream)
        points = []
        for track in gpx.tracks:
            for segment in track.segments:
                for point in segment.points:
                    points.append((getattr(point, f) for f in self.FIELDS))

        self.data = pd.DataFrame(points, columns=self.FIELDS)

