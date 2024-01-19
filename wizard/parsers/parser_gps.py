from .parser_base import CSVParser


class GPSParser(CSVParser):
    DATATYPE = "gps"
    FIELDS = [
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
    

class GPSCSVParser(CSVParser):
    DATATYPE = "gps_csv"
    FIELDS = [
            "Date", "Time", "Latitude", "Longitude", "Altitude", "Speed", "Course", "Type", "Distance", "Essential"
        ]
