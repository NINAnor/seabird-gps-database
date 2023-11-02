-- migrate:up

create sequence auto_ring_id_seq;
grant usage, select on sequence auto_ring_id_seq to writer;

create sequence auto_logger_id_seq;
grant usage, select on sequence auto_logger_id_seq to writer;

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
            detail = new;
end;
$$;

-- migrate:down
