-- migrate:up

create or replace function import() returns trigger language  plpgsql
as $$
begin
    if new.ring_number is null then
        new.ring_number = 'AUTO_' || nextval('auto_ring_id_seq')::text;
    end if;
    if new.gps_deployment_date is not null and new.gps_logger_id is null then
        new.gps_logger_id = 'AUTO_' || nextval('auto_logger_id_seq')::text;
    end if;
    if new.gls_deployment_date is not null and new.gls_logger_id is null then
        new.gls_logger_id = 'AUTO_' || nextval('auto_logger_id_seq')::text;
    end if;
    if new.tdr_deployment_date is not null and new.tdr_logger_id is null then
        new.tdr_logger_id = 'AUTO_' || nextval('auto_logger_id_seq')::text;
    end if;
    if new.accelerometer_deployment_date is not null and new.accelerometer_logger_id is null then
        new.accelerometer_logger_id = 'AUTO_' || nextval('auto_logger_id_seq')::text;
    end if;
    perform import_animal_and_ring(new);
    perform import_colony(new);
    perform import_deployment_and_chick(new);
    perform import_logger_and_logger_instrumentation(new);
    return null;
exception
    when others then
        raise exception using
            errcode = sqlstate,
            message = sqlerrm,
            detail = row_to_json(new);
end;
$$;

create or replace function import_logger_data_gps() returns trigger language plpgsql
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
            detail = row_to_json(new);
end;
$$;

create or replace function import_logger_data_gps_pathtrack() returns trigger language plpgsql
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
            detail = row_to_json(new);
end;
$$;

-- migrate:down

