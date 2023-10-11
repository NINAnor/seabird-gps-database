-- migrate:up

create table logger(
    id text primary key,
    type text not null,
    model text
);

create table logger_instrumentation(
    id integer primary key generated always as identity,
    logger text references logger(id) not null,
    ring text references ring(id) not null,
    status text,
    sampling_freq_s decimal,
    mass_g decimal,
    attachment_method text,
    mount_method text,
    startup timestamp with time zone,
    deployment timestamp with time zone,
    retrieval timestamp with time zone,
    filename text,
    data_stored_externally text,
    comment text
);

grant select on logger, logger_instrumentation to web_anon;
grant insert on logger, logger_instrumentation to writer;
grant usage, select on sequence logger_instrumentation_id_seq to writer;

create function import_logger_and_logger_instrumentation(new import) returns void language plpgsql
as $$
begin
    if new.gps_deployment_date is not null then
        insert into logger values(
            new.gps_logger_id,
            'gps',
            new.gps_logger_model
        ) on conflict do nothing;
        insert into logger_instrumentation values(
            default,
            new.gps_logger_id,
            new.ring_number,
            new.gps_status,
            (new.gps_record_frequency_sec)::decimal,
            (new.mass_gps_logger_g)::decimal,
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
            new.gps_logger_comment
        );
    end if;
    if new.gls_deployment_date is not null then
        insert into logger values(
            new.gls_logger_id,
            'gls',
            new.gls_logger_model
        ) on conflict do nothing;
        insert into logger_instrumentation values(
            default,
            new.gls_logger_id,
            new.ring_number,
            new.gls_status,
            (new.gls_record_frequency_min)::decimal*60,
            (new.gls_logger_mass_g)::decimal,
            new.gls_attachment_method,
            new.gls_mount_method,
            (new.gls_startup_date_gmt::date +
             new.gls_startup_time_gmt::time) at time zone
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
            case when logging_for_seatrack::bool then 'seatrack' else null end,
            new.gls_comments
        );
    end if;
    if new.tdr_deployment_date is not null then
        insert into logger values(
            new.tdr_logger_id,
            'tdr',
            new.tdr_logger_model
        ) on conflict do nothing;
        insert into logger_instrumentation values(
            default,
            new.tdr_logger_id,
            new.ring_number,
            new.tdr_status,
            (new.tdr_record_frequency_sec)::decimal,
            (new.tdr_mass_g)::decimal,
            new.tdr_attachment_method,
            new.tdr_mount_method,
            (new.tdr_startup_date::date +
             new.tdr_startup_time::time) at time zone
             new.tdr_startup_deployment_retrieval_time_zone,
            (new.tdr_deployment_date::date +
             new.tdr_deployment_time::time) at time zone
             new.tdr_startup_deployment_retrieval_time_zone,
            case when new.tdr_retrieval_date is null then null else
                (new.tdr_retrieval_date::date +
                 new.tdr_retrieval_time::time) at time zone
                 new.tdr_startup_deployment_retrieval_time_zone
            end,
            new.tdr_raw_datafile_name,
            null,
            new.tdr_comment
        );
    end if;
    if new.accelerometer_deployment_date is not null then
        insert into logger values(
            new.accelerometer_logger_id,
            'accelerometer',
            new.accelerometer_logger_model
        ) on conflict do nothing;
        insert into deployment values(
            default,
            new.accelerometer_logger_id,
            new.ring_number,
            new.accelerometer_status,
            (new.accelerometer_record_frequency_millisec)::decimal/1000,
            (new.accelerometer_mass_g)::decimal,
            new.accelerometer_attachment_method,
            new.accelerometer_mount_method,
            (new.accelerometer_startup_date::date +
             new.accelerometer_startup_time::time) at time zone
             new.accelerometer_startup_deployment_retrieval_time_zone,
            (new.accelerometer_deployment_time::date +
             new.accelerometer_deployment_time::time) at time zone
             new.accelerometer_startup_deployment_retrieval_time_zone,
            case when new.accelerometer_retrieval_date is null then null else
                (new.accelerometer_retrieval_date::date +
                 new.accelerometer_retrieval_time::time) at time zone
                 new.accelerometer_startup_deployment_retrieval_time_zone
            end,
            new.accelerometer_raw_datafile_name,
            null,
            new.accelerometer_comment
        );
    end if;
end;
$$;

-- migrate:down
