-- migrate:up

create table import_logger_data_gps_pathtrack(
    filename text,
    day text,
    month text,
    year text,
    hour text,
    minute text,
    second text,
    second_of_day text,
    satellites text,
    lat text,
    lon text,
    altitude text,
    clock_offset text,
    accuracy text,
    battery text,
    unknown1 text,
    unknown2 text
);

grant insert on import_logger_data_gps_pathtrack to writer;

create function import_logger_data_gps_pathtrack() returns trigger language plpgsql
as $$
begin
    insert into logger_data values(
        new.filename,
        null,
        make_timestamptz(
            (new.year)::int,
            (new.month)::int,
            (new.day)::int,
            (new.hour)::int,
            (new.minute)::int,
            (new.second)::float,
            'UTC'
        ),
        case when new.accuracy = '9999.999'
             then null
             else ST_SetSRID(ST_MakePoint(
                      new.lat::float,
                      new.lon::float,
                      case when new.altitude = '9999.999'
                           then null
                           else (new.altitude)::float
                      end
                  ), 4326)
        end,
        new.satellites::integer,
        case when new.accuracy = '9999.999'
             then null
             else new.accuracy::decimal
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

create trigger import_logger_data_gps_pathtrack
    before insert on import_logger_data_gps_pathtrack
    for each row
    execute function import_logger_data_gps_pathtrack();

-- migrate:down
