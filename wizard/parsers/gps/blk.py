import io

import pandas as pd

from parsers.helpers import stream_chunk_contains
from parsers.parser_base import Parser


def signed(val, direction):
    val = float(val)
    if direction in ("S", "W"):
        return -val
    return val


class EarthOcean_mGPS2Parser(Parser):
    """Earth&Ocean mGPS-2 parser."""

    DATATYPE = "gps_earth_ocean_mgps2"

    # Date | Time | Latitude | Direction (N/S) | Longitude | Direction (E/W) | # Satellites | HDOP | Speed | Altitude | True heading
    FIELDS = [
        "UTC_date",
        "UTC_time",
        "Latitude",
        "Latitude_dir",
        "Longitude",
        "Longitude_dir",
        "satcount",
        "hdop",
        "speed_km_h",
        "altitude_m",
        "direction_deg",
    ]

    MAPPINGS = {
        "id": "device_id",
        "date": "UTC_date",
        "time": "UTC_time",
        "latitude": "Latitude",
        "longitude": "Longitude",
        "altitude": "altitude_m",
        "speed_km_h": "speed_km_h",
        "course": "direction_deg",
        "hdop": "hdop",
        "satellites_count": "satcount",
    }

    def __init__(self, parsable):
        super().__init__(parsable)

        with self.file.get_stream(binary=False, errors="backslashreplace") as stream:
            if not stream.seekable():
                self._raise_not_supported("Stream not seekable")

            if not stream_chunk_contains(
                stream, 200, "************* GPS DATA *************"
            ):
                self._raise_not_supported("Not an Earth&Ocean mGPS-2 file")

            text = stream.read()

        lines = text.splitlines()
        asterisks = "************************************"
        try:
            idx = lines.index(asterisks)
        except ValueError:
            self._raise_not_supported("No data block found after header")

        for index, line in enumerate(lines, start=idx + 1):
            if line.strip() == "":
                continue
            break
        else:
            self._raise_not_supported("No data block found after header")

        data_block = "\n".join(lines[index:])

        df = pd.read_csv(
            io.StringIO(data_block),
            header=None,
            names=self.FIELDS,
            sep=r"\s+",
            engine="python",
        )

        df["device_id"] = self.file._file_path.name
        df["Latitude"] = [
            signed(v, d) for v, d in zip(df["Latitude"], df["Latitude_dir"])
        ]
        df["Longitude"] = [
            signed(v, d) for v, d in zip(df["Longitude"], df["Longitude_dir"])
        ]
        df = df.drop(columns=["Latitude_dir", "Longitude_dir"])
        self.data = df


PARSERS = [EarthOcean_mGPS2Parser]
