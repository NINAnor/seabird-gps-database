from .helpers import read_csv
from .parser_base import Parser


class GPSParser(Parser):
    DATATYPE = "gps"
    HEAD = ",".join(
        [
            "device_id",
            "UTC_datetime",
            "UTC_date",
            "UTC_time",
            "datatype",
            "satcount",
            "U_bat_mV",
            "bat_soc_pct",
            "solar_I_mA",
            "hdop",
            "Latitude",
            "Longitude",
            "Altitude_m",
            "speed_km_h",
            "direction_deg",
            "temperature_C",
            "mag_x",
            "mag_y",
            "mag_z",
            "acc_x",
            "acc_y",
            "acc_z",
            "depth_m",
            "",
        ]
    )

    def parse(self):
        for line in read_csv(self.stream.read(), trailing=","):
            assert len(line) == 23
            yield line
