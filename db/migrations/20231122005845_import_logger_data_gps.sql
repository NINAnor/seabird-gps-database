-- migrate:up

create table import_logger_data_gps(
    filename text,
    device_id text,
    "UTC_datetime" text,
    "UTC_date" text,
    "UTC_time" text,
    datatype text,
    satcount text,
    "U_bat_mV" text,
    bat_soc_pct text,
    "solar_I_mA" text,
    hdop text,
    "Latitude" text,
    "Longitude" text,
    "Altitude_m" text,
    speed_km_h text,
    direction_deg text,
    "temperature_C" text,
    mag_x text,
    mag_y text,
    mag_z text,
    acc_x text,
    acc_y text,
    acc_z text,
    depth_m text
);

grant insert on import_logger_data_gps to writer;

create function import_logger_data_gps() returns trigger language plpgsql
as $$
begin
    insert into logger_data values(
        new.filename,
        null,
        (new."UTC_datetime" || ' UTC')::timestamp,
        case when new.hdop = '0.0'
             then null
             else ST_SetSRID(ST_MakePoint(
                      new."Latitude"::float,
                      new."Longitude"::float,
                      new."Altitude_m"::float
                  ), 4326)
        end,
        new.satcount::integer,
        case when new.hdop = '0.0'
             then null
             else new.hdop::decimal
        end
    ) on conflict do nothing;
    return null;
exception
    when others then
        raise exception using
            errcode = sqlstate,
            message = sqlerrm,
            detail = new;
end;
$$;

create trigger import_logger_data_gps
    before insert on import_logger_data_gps
    for each row
    execute function import_logger_data_gps();

-- migrate:down
