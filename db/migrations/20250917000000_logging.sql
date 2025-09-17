-- migrate:up

CREATE OR REPLACE FUNCTION public.import_logger_and_logger_instrumentation(new import, deployment_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $$
declare
    tdr_file text;
    tdr_list text[];
begin
    RAISE LOG 'creating logger instrumentation';

    if new.gps_deployment_date is not null then
        RAISE LOG 'creating gps based on date %', new.gps_deployment_date;

        insert into logger values(
            new.gps_logger_id,
            'gps',
            new.gps_logger_model
        ) on conflict do nothing;
        insert into logger_instrumentation values(
            default,
            new.gps_logger_id,
            deployment_id,
            new.gps_status,
            (new.gps_record_frequency_sec)::decimal,
            (new.gps_logger_mass_g)::decimal,
            new.gps_attachment_method,
            new.gps_mount_method,
            (new.gps_startup_date::date +
             new.gps_startup_time::time) at time zone
             new.gps_deployment_retrieval_time_zone,
            (new.gps_deployment_date::date +
             new.gps_deployment_time::time) at time zone
             new.gps_deployment_retrieval_time_zone,
            case when new.gps_retrieval_date is null then null else
                (new.gps_retrieval_date::date +
                 new.gps_retrieval_time::time) at time zone
                 new.gps_deployment_retrieval_time_zone
            end,
            new.gps_raw_datafile_name,
            null,
            new.gps_comment
        );
    end if;
    if new.gls_deployment_date is not null then
        RAISE LOG 'creating gls based on date %', new.gls_deployment_date;

        insert into logger values(
            new.gls_logger_id,
            'gls',
            new.gls_logger_model
        ) on conflict do nothing;
        insert into logger_instrumentation values(
            default,
            new.gls_logger_id,
            deployment_id,
            new.gls_status,
            (new.gls_record_frequency_sec)::decimal,
            (new.gls_logger_mass_g)::decimal,
            new.gls_attachment_method,
            new.gls_mount_method,
            (new.gls_startup_date::date +
             new.gls_startup_time::time) at time zone
             'UTC',
            (new.gls_deployment_date::date +
             new.gls_deployment_time::time) at time zone
             new.gls_deployment_retrieval_time_zone,
            case when new.gls_retrieval_date is null then null else
                (new.gls_retrieval_date::date +
                 new.gls_retrieval_time::time) at time zone
                 new.gls_deployment_retrieval_time_zone
            end,
            new.gls_raw_datafile_name,
            case when safe_cast_bool(new.logging_for_seatrack) then 'seatrack' else null end,
            new.gls_comment
        );
    end if;
    if new.tdr_deployment_date is not null then
        RAISE LOG 'creating tdr based on date %', new.tdr_deployment_date;

        insert into logger values(
            new.tdr_logger_id,
            'tdr',
            new.tdr_logger_model
        ) on conflict do nothing;
        if new.tdr_raw_datafile_name is not null then
            tdr_list = string_to_array(new.tdr_raw_datafile_name, ';');
        else
            tdr_list = array[null];
        end if;
        foreach tdr_file in array tdr_list loop
            insert into logger_instrumentation values(
                default,
                new.tdr_logger_id,
                deployment_id,
                new.tdr_status,
                (new.tdr_record_frequency_sec)::decimal,
                (new.tdr_logger_mass_g)::decimal,
                new.tdr_attachment_method,
                new.tdr_mount_method,
                (new.tdr_startup_date::date +
                new.tdr_startup_time::time) at time zone
                new.tdr_deployment_retrieval_time_zone,
                (new.tdr_deployment_date::date +
                new.tdr_deployment_time::time) at time zone
                new.tdr_deployment_retrieval_time_zone,
                case when new.tdr_retrieval_date is null then null else
                    (new.tdr_retrieval_date::date +
                    new.tdr_retrieval_time::time) at time zone
                    new.tdr_deployment_retrieval_time_zone
                end,
                tdr_file,
                null,
                new.tdr_comment
            );
        end loop;
    end if;
    if new.other_sensor_deployment_date is not null then
        RAISE LOG 'creating other sensor based on date %', new.other_sensor_deployment_date;
       
        if new.other_sensor_startup_date is not null and not pg_input_is_valid(new.other_sensor_startup_date, 'date') then
        	raise exception 'other_sensor_startup_date is not a valid date';
        end if;
        if new.other_sensor_deployment_date is not null and not pg_input_is_valid(new.other_sensor_deployment_date, 'date') then
        	raise exception 'other_sensor_deployment_date is not a valid date';
        end if;
        if new.other_sensor_retrieval_date is not null and not pg_input_is_valid(new.other_sensor_retrieval_date, 'date') then
        	raise exception 'other_sensor_retrieval_date is not a valid date';
        end if;

        insert into logger values(
            new.other_sensor_logger_id,
            'other_sensor',
            new.other_sensor_logger_model
        ) on conflict do nothing;
        insert into logger_instrumentation values(
            default,
            new.other_sensor_logger_id,
            deployment_id,
            new.other_sensor_status,
            (new.other_sensor_record_frequency_sec)::decimal,
            (new.other_sensor_logger_mass_g)::decimal,
            new.other_sensor_attachment_method,
            new.other_sensor_mount_method,
            (new.other_sensor_startup_date::date +
             new.other_sensor_startup_time::time) at time zone
             new.other_sensor_deployment_retrieval_time_zone,
            (new.other_sensor_deployment_date::date +
             new.other_sensor_deployment_time::time) at time zone
             new.other_sensor_deployment_retrieval_time_zone,
            case when new.other_sensor_retrieval_date is null then null else
                (new.other_sensor_retrieval_date::date +
                 new.other_sensor_retrieval_time::time) at time zone
                 new.other_sensor_deployment_retrieval_time_zone
            end,
            new.other_sensor_raw_datafile_name,
            null,
            new.other_sensor_comment
        );
    end if;
end;
$$;




CREATE OR REPLACE FUNCTION public.import() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    deployment_id integer;
begin
    -- perform some checks
    if safe_cast_bool(new.gps_data_collected) and new.gps_raw_datafile_name is null then
        raise exception 'gps_raw_datafile_name cannot be empty if gps_data_collected is "Yes"';
    end if;

    if safe_cast_bool(new.gls_data_collected) and not safe_cast_bool(new.logging_for_seatrack) and new.gls_raw_datafile_name is null then
        raise exception 'gls_raw_datafile_name cannot be empty if gls_data_collected is "Yes"';
    end if;

    if safe_cast_bool(new.tdr_data_collected) and new.tdr_raw_datafile_name is null then
        raise exception 'tdr_raw_datafile_name cannot be empty if tdr_data_collected is "Yes"';
    end if;

    if safe_cast_bool(new.other_sensor_data_collected) and new.other_sensor_raw_datafile_name is null then
        raise exception 'other_sensor_raw_datafile_name cannot be empty if other_sensor_data_collected is "Yes"';
    end if;

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
    if new.other_sensor_deployment_date is not null and new.other_sensor_logger_id is null then
        new.other_sensor_logger_id = 'AUTO_' || nextval('auto_logger_id_seq')::text;
    end if;
    perform import_animal_and_ring(new);
    perform import_colony(new);
    select import_deployment_and_chick(new) into deployment_id;
    perform import_logger_and_logger_instrumentation(new, deployment_id);
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
