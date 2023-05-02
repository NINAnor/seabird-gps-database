-- migrate:up

create function import_entry() returns trigger language plpgsql
as $$
declare
    animal int;
    year smallint;
    ring int;
begin
    -- Convert empty strings into nulls
    new.species = nullif(new.species, '');
    new.morph = nullif(new.morph, '');
    new.subspecies = nullif(new.subspecies, '');
    new.ring_number = nullif(new.ring_number, '');
    new.euring_code = nullif(new.euring_code, '');
    new.colour_ring_colour = nullif(new.colour_ring_colour, '');
    new.colour_ring_code = nullif(new.colour_ring_code, '');
    new.gps_startup_date = nullif(new.gps_startup_date, '');
    new.gps_startup_time = nullif(new.gps_startup_time, '');
    new.gps_deployment_date = nullif(new.gps_deployment_date, '');
    new.gps_deployment_time = nullif(new.gps_deployment_time, '');
    new.gps_retrieval_date = nullif(new.gps_retrieval_date, '');
    new.gps_retrieval_time = nullif(new.gps_retrieval_time, '');
    new.time_zone_startup_deployment_recapture = nullif(new.time_zone_startup_deployment_recapture, '');
    new.gps_end_date = nullif(new.gps_end_date, '');
    new.gps_end_time = nullif(new.gps_end_time, '');
    new.gps_time_zone = nullif(new.gps_time_zone, '');
    new.logger_status = nullif(new.logger_status, '');
    new.gps_logger_model = nullif(new.gps_logger_model, '');
    new.gps_logger_id = nullif(new.gps_logger_id, '');
    new.gps_data_collected = nullif(new.gps_data_collected, '');
    new.gps_raw_datafile_name = nullif(new.gps_raw_datafile_name, '');
    new.gps_record_frequency_sec = nullif(new.gps_record_frequency_sec, '');
    new.mass_gps_logger_g = nullif(new.mass_gps_logger_g, '');
    new.gps_attachment_method = nullif(new.gps_attachment_method, '');
    new.gps_mount_method = nullif(new.gps_mount_method, '');
    new.total_logger_mass_all_loggers_g = nullif(new.total_logger_mass_all_loggers_g, '');
    new.gps_logger_comment = nullif(new.gps_logger_comment, '');
    new.age = nullif(new.age, '');
    new.sex = nullif(new.sex, '');
    new.sexing_method = nullif(new.sexing_method, '');
    new.mass_deployment = nullif(new.mass_deployment, '');
    new.mass_retrieval = nullif(new.mass_retrieval, '');
    new.scull = nullif(new.scull, '');
    new.tarsus = nullif(new.tarsus, '');
    new.wing = nullif(new.wing, '');
    new.culmen = nullif(new.culmen, '');
    new.gonys = nullif(new.gonys, '');
    new.breeding_stage_deployment = nullif(new.breeding_stage_deployment, '');
    new.eggs_deployment = nullif(new.eggs_deployment, '');
    new.chicks_deployment = nullif(new.chicks_deployment, '');
    new.breeding_stage_retrieval = nullif(new.breeding_stage_retrieval, '');
    new.eggs_retrieval = nullif(new.eggs_retrieval, '');
    new.chicks_retrieval = nullif(new.chicks_retrieval, '');
    new.chick1_age_deployment = nullif(new.chick1_age_deployment, '');
    new.chick2_age_deployment = nullif(new.chick2_age_deployment, '');
    new.chick3_age_deployment = nullif(new.chick3_age_deployment, '');
    new.chick1_mass_deployment = nullif(new.chick1_mass_deployment, '');
    new.chick2_mass_deployment = nullif(new.chick2_mass_deployment, '');
    new.chick3_mass_deployment = nullif(new.chick3_mass_deployment, '');
    new.chick1_age_retrieval = nullif(new.chick1_age_retrieval, '');
    new.chick2_age_retrieval = nullif(new.chick2_age_retrieval, '');
    new.chick3_age_retrieval = nullif(new.chick3_age_retrieval, '');
    new.chick1_mass_retrieval = nullif(new.chick1_mass_retrieval, '');
    new.chick2_mass_retrieval = nullif(new.chick2_mass_retrieval, '');
    new.chick3_mass_retrieval = nullif(new.chick3_mass_retrieval, '');
    new.further_chick_measures_available = nullif(new.further_chick_measures_available, '');
    new.country = nullif(new.country, '');
    new.colony = nullif(new.colony, '');
    new.colony_latitude = nullif(new.colony_latitude, '');
    new.colony_longitude = nullif(new.colony_longitude, '');
    new.plot = nullif(new.plot, '');
    new.nest_id = nullif(new.nest_id, '');
    new.blood_sample = nullif(new.blood_sample, '');
    new.feather_sample = nullif(new.feather_sample, '');
    new.other_samples = nullif(new.other_samples, '');
    new.comments_samples = nullif(new.comments_samples, '');
    new.logging_for_seatrack = nullif(new.logging_for_seatrack, '');
    new.gls_logger_model = nullif(new.gls_logger_model, '');
    new.gls_logger_id = nullif(new.gls_logger_id, '');
    new.gls_record_frequency_min = nullif(new.gls_record_frequency_min, '');
    new.gls_logger_mass_g = nullif(new.gls_logger_mass_g, '');
    new.gls_attachment_method = nullif(new.gls_attachment_method, '');
    new.gls_mount_method = nullif(new.gls_mount_method, '');
    new.gls_startup_date_gmt = nullif(new.gls_startup_date_gmt, '');
    new.gls_startup_time_gmt = nullif(new.gls_startup_time_gmt, '');
    new.gls_deployment_date = nullif(new.gls_deployment_date, '');
    new.gls_deployment_time = nullif(new.gls_deployment_time, '');
    new.gls_retrieval_date = nullif(new.gls_retrieval_date, '');
    new.gls_retrieval_time = nullif(new.gls_retrieval_time, '');
    new.gls_deployment_retrieval_time_zone = nullif(new.gls_deployment_retrieval_time_zone, '');
    new.gls_time_zone = nullif(new.gls_time_zone, '');
    new.gls_raw_datafile_name = nullif(new.gls_raw_datafile_name, '');
    new.gls_comments = nullif(new.gls_comments, '');
    new.tdr_model = nullif(new.tdr_model, '');
    new.tdr_logger_id = nullif(new.tdr_logger_id, '');
    new.tdr_record_frequency_sec = nullif(new.tdr_record_frequency_sec, '');
    new.tdr_mass_g = nullif(new.tdr_mass_g, '');
    new.tdr_attachment_method = nullif(new.tdr_attachment_method, '');
    new.tdr_mount_method = nullif(new.tdr_mount_method, '');
    new.tdr_startup_date = nullif(new.tdr_startup_date, '');
    new.tdr_startup_time = nullif(new.tdr_startup_time, '');
    new.tdr_deployment_date = nullif(new.tdr_deployment_date, '');
    new.tdr_deployment_time = nullif(new.tdr_deployment_time, '');
    new.tdr_retrieval_date = nullif(new.tdr_retrieval_date, '');
    new.tdr_retrieval_time = nullif(new.tdr_retrieval_time, '');
    new.tdr_startup_deployment_retrieval_time_zone = nullif(new.tdr_startup_deployment_retrieval_time_zone, '');
    new.tdr_time_zone = nullif(new.tdr_time_zone, '');
    new.tdr_raw_datafile_name = nullif(new.tdr_raw_datafile_name, '');
    new.tdr_comment = nullif(new.tdr_comment, '');
    new.accelerometer_model = nullif(new.accelerometer_model, '');
    new.accelerometer_logger_id = nullif(new.accelerometer_logger_id, '');
    new.accelerometer_record_frequency_millisec = nullif(new.accelerometer_record_frequency_millisec, '');
    new.accelerometer_mass_g = nullif(new.accelerometer_mass_g, '');
    new.accelerometer_attachment_method = nullif(new.accelerometer_attachment_method, '');
    new.accelerometer_mount_method = nullif(new.accelerometer_mount_method, '');
    new.accelerometer_startup_date = nullif(new.accelerometer_startup_date, '');
    new.accelerometer_startup_time = nullif(new.accelerometer_startup_time, '');
    new.accelerometer_deployment_date = nullif(new.accelerometer_deployment_date, '');
    new.accelerometer_deployment_time = nullif(new.accelerometer_deployment_time, '');
    new.accelerometer_retrieval_date = nullif(new.accelerometer_retrieval_date, '');
    new.accelerometer_retrieval_time = nullif(new.accelerometer_retrieval_time, '');
    new.accelerometer_startup_deployment_retrieval_time_zone = nullif(new.accelerometer_startup_deployment_retrieval_time_zone, '');
    new.accelerometer_time_zone = nullif(new.accelerometer_time_zone, '');
    new.accelerometer_raw_datafile_name = nullif(new.accelerometer_raw_datafile_name, '');
    new.accelerometer_comment = nullif(new.accelerometer_comment, '');
    new.comment = nullif(new.comment, '');
    new.other = nullif(new.other, '');
    new.old_ring_number = nullif(new.old_ring_number, '');
    new.data_responsible = nullif(new.data_responsible, '');
    -- Populate tables
    insert into colony values(
        new.colony,
        ST_SetSRID(ST_MakePoint(
            (new.colony_latitude)::float,
            (new.colony_longitude)::float
            ), 4326),
        new.country,
        new.plot,
        new.nest_id
    ) on conflict do nothing;
    -- TODO: consider multiple changes
    if new.old_ring_number is null then
        animal = (new.ring_number)::int;
    else
        select animal.id into strict animal
          from ring
          join animal on ring.animal = animal.id
         where ring.id = new.old_ring_number;
    end if;
    year = extract(year from date (new.gps_startup_date));
    insert into animal values(
        animal,
        new.species,
        new.morph,
        new.subspecies
    ) on conflict do nothing;
    insert into ring values(
        (new.ring_number)::int,
        new.euring_code,
        new.colour_ring_colour,
        new.colour_ring_code,
        animal
    ) on conflict do nothing;
    insert into survey values(
        animal,
        year,

        (new.total_logger_mass_all_loggers_g)::decimal,

        new.age,
        new.sex,
        new.sexing_method,

        (new.mass_deployment)::int,
        (new.mass_retrieval)::int,
        (new.scull)::decimal,
        (new.tarsus)::decimal,
        (new.wing)::decimal,
        (new.culmen)::decimal,
        (new.gonys)::decimal,

        new.breeding_stage_deployment,
        (new.eggs_deployment)::int,
        (new.chicks_deployment)::int,
        new.breeding_stage_retrieval,
        (new.eggs_retrieval)::int,
        (new.chicks_retrieval)::int,

        new.further_chick_measures_available,

        new.colony,

        (new.blood_sample)::bool,
        (new.feather_sample)::bool,
        (new.other_samples)::bool,
        new.comments_samples,
        (new.logging_for_seatrack)::bool,

        new.comment,
        new.other,
        new.data_responsible
    );

    if new.chick1_mass_retrieval is not null then
        insert into chick values(
            default,
            animal,
            year,
            (new.chick1_mass_deployment)::decimal,
            new.chick1_age_deployment,
            (new.chick1_mass_retrieval)::decimal,
            new.chick1_age_retrieval
        );
    end if;

    if new.chick2_mass_retrieval is not null then
        insert into chick values(
            default,
            animal,
            year,
            (new.chick2_mass_deployment)::decimal,
            new.chick2_age_deployment,
            (new.chick2_mass_retrieval)::decimal,
            new.chick2_age_retrieval
        );
    end if;

    if new.chick3_mass_retrieval is not null then
        insert into chick values(
            default,
            animal,
            year,
            (new.chick3_mass_deployment)::decimal,
            new.chick3_age_deployment,
            (new.chick3_mass_retrieval)::decimal,
            new.chick3_age_retrieval
        );
    end if;

    if new.gps_startup_date is not null then
        insert into logger values(
            new.gps_logger_id,
            'gps',
            new.gps_logger_model
        ) on conflict do nothing;
        insert into deployment values(
            new.gps_logger_id,
            animal,
            new.logger_status,
            (new.gps_record_frequency_sec)::int*1000,
            (new.mass_gps_logger_g)::decimal,
            new.gps_attachment_method,
            new.gps_mount_method,
            concat(
                new.gps_startup_date, ' ',
                new.gps_startup_time, ' ',
                new.time_zone_startup_deployment_recapture
                )::timestamptz,
            concat(
                new.gps_deployment_date, ' ',
                new.gps_deployment_time, ' ',
                new.time_zone_startup_deployment_recapture
                )::timestamptz,
            case when new.gps_retrieval_date is null then null else
                concat(
                    new.gps_retrieval_date, ' ',
                    new.gps_retrieval_time, ' ',
                    new.time_zone_startup_deployment_recapture
                )::timestamptz end,
            new.gps_raw_datafile_name,
            new.gps_logger_comment
        );
    end if;
    if new.gls_startup_date_gmt is not null then
        insert into logger values(
            new.gls_logger_id,
            'gls',
            new.gls_logger_model
        ) on conflict do nothing;
        insert into deployment values(
            new.gls_logger_id,
            animal,
            null, -- no status?
            (new.gls_record_frequency_min)::int*60*1000,
            (new.gls_logger_mass_g)::decimal,
            new.gls_attachment_method,
            new.gls_mount_method,
            concat(
                new.gls_startup_date_gmt, ' ',
                new.gls_startup_time_gmt, ' ',
                'UTC'
            )::timestamptz,
            concat(
                new.gls_deployment_date, ' ',
                new.gls_deployment_time, ' ',
                new.gls_deployment_retrieval_time_zone
            )::timestamptz,
            case when new.gls_retrieval_date is null then null else
                concat(
                    new.gls_retrieval_date, ' ',
                    new.gls_retrieval_time, ' ',
                    new.gls_deployment_retrieval_time_zone
                )::timestamptz end,
            new.gls_raw_datafile_name,
            new.gls_comments
        );
    end if;
    if new.tdr_startup_date is not null then
        insert into logger values(
            new.tdr_logger_id,
            'tdr',
            new.tdr_model
        ) on conflict do nothing;
        insert into deployment values(
            new.tdr_logger_id,
            animal,
            null, -- no status?
            (new.tdr_record_frequency_sec)::int*1000,
            (new.tdr_mass_g)::decimal,
            new.tdr_attachment_method,
            new.tdr_mount_method,
            concat(
                new.tdr_startup_date, ' ',
                new.tdr_startup_time, ' ',
                new.tdr_startup_deployment_retrieval_time_zone
            )::timestamptz,
            concat(
                new.tdr_deployment_date, ' ',
                new.tdr_deployment_time, ' ',
                new.tdr_startup_deployment_retrieval_time_zone
            )::timestamptz,
            case when new.tdr_retrieval_date is null then null else
                concat(
                    new.tdr_retrieval_date, ' ',
                    new.tdr_retrieval_time, ' ',
                    new.tdr_startup_deployment_retrieval_time_zone
                )::timestamptz end,
            new.tdr_raw_datafile_name,
            new.tdr_comment
        );
    end if;
    if new.accelerometer_startup_date is not null then
        insert into logger values(
            new.accelerometer_logger_id,
            'accelerometer',
            new.accelerometer_model
        ) on conflict do nothing;
        insert into deployment values(
            new.accelerometer_logger_id,
            animal,
            null, -- no status?
            (new.accelerometer_record_frequency_millisec)::int,
            (new.accelerometer_mass_g)::decimal,
            new.accelerometer_attachment_method,
            new.accelerometer_mount_method,
            concat(
                new.accelerometer_startup_date, ' ',
                new.accelerometer_startup_time, ' ',
                new.accelerometer_startup_deployment_retrieval_time_zone
            )::timestamptz,
            concat(
                new.accelerometer_deployment_date, ' ',
                new.accelerometer_deployment_time, ' ',
                new.accelerometer_startup_deployment_retrieval_time_zone
            )::timestamptz,
            case when new.accelerometer_retrieval_date is null then null else
                concat(
                    new.accelerometer_retrieval_date, ' ',
                    new.accelerometer_retrieval_time, ' ',
                    new.accelerometer_startup_deployment_retrieval_time_zone
                )::timestamptz end,
            new.accelerometer_raw_datafile_name,
            new.accelerometer_comment
        );
    end if;
    return null;
exception
    when others then
        raise exception using
            errcode = sqlstate,
            message = sqlerrm,
            detail = new;
end;
$$;

create table import_entry(
    species text null,
    morph text null,
    subspecies text null,
    ring_number text null,
    euring_code text null,
    colour_ring_colour text null,
    colour_ring_code text null,
    gps_startup_date text null,
    gps_startup_time text null,
    gps_deployment_date text null,
    gps_deployment_time text null,
    gps_retrieval_date text null,
    gps_retrieval_time text null,
    time_zone_startup_deployment_recapture text null,
    gps_end_date text null,
    gps_end_time text null,
    gps_time_zone text null,
    logger_status text null,
    gps_logger_model text null,
    gps_logger_id text null,
    gps_data_collected text null,
    gps_raw_datafile_name text null,
    gps_record_frequency_sec text null,
    mass_gps_logger_g text null,
    gps_attachment_method text null,
    gps_mount_method text null,
    total_logger_mass_all_loggers_g text null,
    gps_logger_comment text null,
    age text null,
    sex text null,
    sexing_method text null,
    mass_deployment text null,
    mass_retrieval text null,
    scull text null,
    tarsus text null,
    wing text null,
    culmen text null,
    gonys text null,
    breeding_stage_deployment text null,
    eggs_deployment text null,
    chicks_deployment text null,
    breeding_stage_retrieval text null,
    eggs_retrieval text null,
    chicks_retrieval text null,
    chick1_age_deployment text null,
    chick2_age_deployment text null,
    chick3_age_deployment text null,
    chick1_mass_deployment text null,
    chick2_mass_deployment text null,
    chick3_mass_deployment text null,
    chick1_age_retrieval text null,
    chick2_age_retrieval text null,
    chick3_age_retrieval text null,
    chick1_mass_retrieval text null,
    chick2_mass_retrieval text null,
    chick3_mass_retrieval text null,
    further_chick_measures_available text null,
    country text null,
    colony text null,
    colony_latitude text null,
    colony_longitude text null,
    plot text null,
    nest_id text null,
    blood_sample text null,
    feather_sample text null,
    other_samples text null,
    comments_samples text null,
    logging_for_seatrack text null,
    gls_logger_model text null,
    gls_logger_id text null,
    gls_record_frequency_min text null,
    gls_logger_mass_g text null,
    gls_attachment_method text null,
    gls_mount_method text null,
    gls_startup_date_gmt text null,
    gls_startup_time_gmt text null,
    gls_deployment_date text null,
    gls_deployment_time text null,
    gls_retrieval_date text null,
    gls_retrieval_time text null,
    gls_deployment_retrieval_time_zone text null,
    gls_time_zone text null,
    gls_raw_datafile_name text null,
    gls_comments text null,
    tdr_model text null,
    tdr_logger_id text null,
    tdr_record_frequency_sec text null,
    tdr_mass_g text null,
    tdr_attachment_method text null,
    tdr_mount_method text null,
    tdr_startup_date text null,
    tdr_startup_time text null,
    tdr_deployment_date text null,
    tdr_deployment_time text null,
    tdr_retrieval_date text null,
    tdr_retrieval_time text null,
    tdr_startup_deployment_retrieval_time_zone text null,
    tdr_time_zone text null,
    tdr_raw_datafile_name text null,
    tdr_comment text null,
    accelerometer_model text null,
    accelerometer_logger_id text null,
    accelerometer_record_frequency_millisec text null,
    accelerometer_mass_g text null,
    accelerometer_attachment_method text null,
    accelerometer_mount_method text null,
    accelerometer_startup_date text null,
    accelerometer_startup_time text null,
    accelerometer_deployment_date text null,
    accelerometer_deployment_time text null,
    accelerometer_retrieval_date text null,
    accelerometer_retrieval_time text null,
    accelerometer_startup_deployment_retrieval_time_zone text null,
    accelerometer_time_zone text null,
    accelerometer_raw_datafile_name text null,
    accelerometer_comment text null,
    comment text null,
    other text null,
    old_ring_number text null,
    data_responsible text null
);

create trigger import_entry
    before insert on import_entry
    for each row
    execute function import_entry();

-- migrate:down

