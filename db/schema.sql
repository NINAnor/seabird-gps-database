SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: tiger; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA tiger;


--
-- Name: tiger_data; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA tiger_data;


--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA topology;


--
-- Name: SCHEMA topology; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: postgis_tiger_geocoder; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder WITH SCHEMA tiger;


--
-- Name: EXTENSION postgis_tiger_geocoder; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis_tiger_geocoder IS 'PostGIS tiger geocoder and reverse geocoder';


--
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


--
-- Name: procrastinate_job_event_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.procrastinate_job_event_type AS ENUM (
    'deferred',
    'started',
    'deferred_for_retry',
    'failed',
    'succeeded',
    'cancelled',
    'scheduled'
);


--
-- Name: procrastinate_job_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.procrastinate_job_status AS ENUM (
    'todo',
    'doing',
    'succeeded',
    'failed'
);


--
-- Name: import(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.import() RETURNS trigger
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


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: import; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.import (
    species text,
    morph text,
    subspecies text,
    ring_number text,
    euring_code text,
    colour_ring_colour text,
    colour_ring_code text,
    gps_startup_date text,
    gps_startup_time text,
    gps_deployment_date text,
    gps_deployment_time text,
    gps_retrieval_date text,
    gps_retrieval_time text,
    gps_deployment_retrieval_time_zone text,
    gps_time_zone text,
    gps_logger_model text,
    gps_logger_id text,
    gps_status text,
    gps_data_collected text,
    gps_raw_datafile_name text,
    gps_record_frequency_sec text,
    gps_logger_mass_g text,
    gps_attachment_method text,
    gps_mount_method text,
    total_logger_mass_all_loggers_g text,
    gps_comment text,
    age text,
    sex text,
    sexing_method text,
    mass_deployment text,
    mass_retrieval text,
    scull text,
    tarsus text,
    wing text,
    culmen text,
    gonys text,
    breeding_stage_deployment text,
    eggs_deployment text,
    chicks_deployment text,
    breeding_stage_retrieval text,
    eggs_retrieval text,
    chicks_retrieval text,
    chick1_age_deployment_days text,
    chick2_age_deployment_days text,
    chick3_age_deployment_days text,
    chick1_mass_deployment text,
    chick2_mass_deployment text,
    chick3_mass_deployment text,
    chick1_age_retrieval_days text,
    chick2_age_retrieval_days text,
    chick3_age_retrieval_days text,
    chick1_mass_retrieval text,
    chick2_mass_retrieval text,
    chick3_mass_retrieval text,
    further_chick_measures_available text,
    more_information_on_breeding_success_available text,
    country text,
    colony text,
    colony_latitude text,
    colony_longitude text,
    plot text,
    nest_id text,
    blood_sample text,
    feather_sample text,
    other_samples text,
    samples_comment text,
    logging_for_seatrack text,
    gls_logger_model text,
    gls_logger_id text,
    gls_status text,
    gls_data_collected text,
    gls_record_frequency_sec text,
    gls_logger_mass_g text,
    gls_attachment_method text,
    gls_mount_method text,
    gls_startup_date text,
    gls_startup_time text,
    gls_deployment_date text,
    gls_deployment_time text,
    gls_retrieval_date text,
    gls_retrieval_time text,
    gls_deployment_retrieval_time_zone text,
    gls_time_zone text,
    gls_raw_datafile_name text,
    gls_comment text,
    tdr_logger_model text,
    tdr_logger_id text,
    tdr_status text,
    tdr_data_collected text,
    tdr_record_frequency_sec text,
    tdr_logger_mass_g text,
    tdr_attachment_method text,
    tdr_mount_method text,
    tdr_startup_date text,
    tdr_startup_time text,
    tdr_deployment_date text,
    tdr_deployment_time text,
    tdr_retrieval_date text,
    tdr_retrieval_time text,
    tdr_deployment_retrieval_time_zone text,
    tdr_time_zone text,
    tdr_raw_datafile_name text,
    tdr_comment text,
    other_sensor_logger_model text,
    other_sensor_logger_id text,
    other_sensor_status text,
    other_sensor_data_collected text,
    other_sensor_record_frequency_sec text,
    other_sensor_logger_mass_g text,
    other_sensor_attachment_method text,
    other_sensor_mount_method text,
    other_sensor_startup_date text,
    other_sensor_startup_time text,
    other_sensor_deployment_date text,
    other_sensor_deployment_time text,
    other_sensor_retrieval_date text,
    other_sensor_retrieval_time text,
    other_sensor_deployment_retrieval_time_zone text,
    other_sensor_time_zone text,
    other_sensor_raw_datafile_name text,
    other_sensor_comment text,
    comment text,
    other text,
    old_ring_number text,
    funding_source text,
    data_responsible text
);


--
-- Name: import_animal_and_ring(public.import); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.import_animal_and_ring(new public.import) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
    animal_id text;
begin
    if new.old_ring_number is null then
        animal_id = new.ring_number;
    else
        select animal into strict animal_id
        from ring
        where id = new.old_ring_number;
    end if;
    insert into animal values(
        animal_id,
        new.species,
        new.morph,
        new.subspecies
    ) on conflict do nothing;
    insert into ring values(
        new.ring_number,
        animal_id,
        new.euring_code,
        new.colour_ring_colour,
        new.colour_ring_code
    ) on conflict do nothing;
exception
    when no_data_found then raise exception using
        errcode = '22000',
        message = 'Old ring number specified, but not present in the database';
end;
$$;


--
-- Name: import_colony(public.import); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.import_colony(new public.import) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    insert into colony values(
        new.colony,
        ST_SetSRID(ST_MakePoint(
            new.colony_latitude::float,
            new.colony_longitude::float
        ), 4326),
        new.country,
        new.plot,
        new.nest_id
    ) on conflict do nothing;
end;
$$;


--
-- Name: import_deployment_and_chick(public.import); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.import_deployment_and_chick(new public.import) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
    deployment_id int;
    date date;
begin
    date = coalesce(
        new.gps_deployment_date,
        new.gls_deployment_date,
        new.tdr_deployment_date,
        new.other_sensor_deployment_date
    )::date;
    insert into deployment values(
        default,
        new.ring_number,
        date,
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
        rtrim(new.eggs_deployment, '+')::int,
        (new.chicks_deployment)::int,
        new.breeding_stage_retrieval,
        (new.eggs_retrieval)::int,
        (new.chicks_retrieval)::int,
        new.further_chick_measures_available,
        (new.more_information_on_breeding_success_available)::bool,
        new.colony,
        (new.blood_sample)::bool,
        (new.feather_sample)::bool,
        (new.other_samples)::bool,
        new.samples_comment,
        new.comment,
        new.other,
        new.funding_source,
        new.data_responsible,
        right(new.eggs_deployment, 1) = '+'
    ) returning id into deployment_id;
    if new.chick1_mass_retrieval is not null then
        insert into chick values(
            default,
            deployment_id,
            ltrim(new.chick1_mass_deployment, '~')::decimal,
            left(new.chick1_mass_deployment, 1) != '~',
            (new.chick1_age_deployment_days)::int,
            ltrim(new.chick1_mass_retrieval, '~')::decimal,
            left(new.chick1_mass_retrieval, 1) != '~',
            (new.chick1_age_retrieval_days)::int
        );
    end if;
    if new.chick2_mass_retrieval is not null then
        insert into chick values(
            default,
            deployment_id,
            ltrim(new.chick2_mass_deployment, '~')::decimal,
            left(new.chick2_mass_deployment, 1) != '~',
            (new.chick2_age_deployment_days)::int,
            ltrim(new.chick2_mass_retrieval, '~')::decimal,
            left(new.chick2_mass_retrieval, 1) != '~',
            (new.chick2_age_retrieval_days)::int
        );
    end if;
    if new.chick3_mass_retrieval is not null then
        insert into chick values(
            default,
            deployment_id,
            ltrim(new.chick3_mass_deployment, '~')::decimal,
            left(new.chick3_mass_deployment, 1) != '~',
            (new.chick3_age_deployment_days)::int,
            ltrim(new.chick3_mass_retrieval, '~')::decimal,
            left(new.chick3_mass_retrieval, 1) != '~',
            (new.chick3_age_retrieval_days)::int
        );
    end if;
    return deployment_id;
end;
$$;


--
-- Name: import_logger_and_logger_instrumentation(public.import); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.import_logger_and_logger_instrumentation(new public.import) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
    tdr_file text;
    tdr_list text[];
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
                new.ring_number,
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
        insert into logger values(
            new.other_sensor_logger_id,
            'other_sensor',
            new.other_sensor_logger_model
        ) on conflict do nothing;
        insert into deployment values(
            default,
            new.other_sensor_logger_id,
            new.ring_number,
            new.other_sensor_status,
            (new.other_sensor_record_frequency_sec)::decimal,
            (new.other_sensor_logger_mass_g)::decimal,
            new.other_sensor_attachment_method,
            new.other_sensor_mount_method,
            (new.other_sensor_startup_date::date +
             new.other_sensor_startup_time::time) at time zone
             new.other_sensor_deployment_retrieval_time_zone,
            (new.other_sensor_deployment_time::date +
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


--
-- Name: import_logger_and_logger_instrumentation(public.import, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.import_logger_and_logger_instrumentation(new public.import, deployment_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
    tdr_file text;
    tdr_list text[];
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
        insert into logger values(
            new.other_sensor_logger_id,
            'other_sensor',
            new.other_sensor_logger_model
        ) on conflict do nothing;
        insert into deployment values(
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
            (new.other_sensor_deployment_time::date +
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


--
-- Name: procrastinate_defer_job(character varying, character varying, text, text, jsonb, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.procrastinate_defer_job(queue_name character varying, task_name character varying, lock text, queueing_lock text, args jsonb, scheduled_at timestamp with time zone) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
	job_id bigint;
BEGIN
    INSERT INTO procrastinate_jobs (queue_name, task_name, lock, queueing_lock, args, scheduled_at)
    VALUES (queue_name, task_name, lock, queueing_lock, args, scheduled_at)
    RETURNING id INTO job_id;

    RETURN job_id;
END;
$$;


--
-- Name: procrastinate_defer_periodic_job(character varying, character varying, character varying, character varying, character varying, bigint, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.procrastinate_defer_periodic_job(_queue_name character varying, _lock character varying, _queueing_lock character varying, _task_name character varying, _periodic_id character varying, _defer_timestamp bigint, _args jsonb) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
	_job_id bigint;
	_defer_id bigint;
BEGIN

    INSERT
        INTO procrastinate_periodic_defers (task_name, periodic_id, defer_timestamp)
        VALUES (_task_name, _periodic_id, _defer_timestamp)
        ON CONFLICT DO NOTHING
        RETURNING id into _defer_id;

    IF _defer_id IS NULL THEN
        RETURN NULL;
    END IF;

    UPDATE procrastinate_periodic_defers
        SET job_id = procrastinate_defer_job(
                _queue_name,
                _task_name,
                _lock,
                _queueing_lock,
                _args,
                NULL
            )
        WHERE id = _defer_id
        RETURNING job_id INTO _job_id;

    DELETE
        FROM procrastinate_periodic_defers
        USING (
            SELECT id
            FROM procrastinate_periodic_defers
            WHERE procrastinate_periodic_defers.task_name = _task_name
            AND procrastinate_periodic_defers.periodic_id = _periodic_id
            AND procrastinate_periodic_defers.defer_timestamp < _defer_timestamp
            ORDER BY id
            FOR UPDATE
        ) to_delete
        WHERE procrastinate_periodic_defers.id = to_delete.id;

    RETURN _job_id;
END;
$$;


--
-- Name: procrastinate_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.procrastinate_jobs (
    id bigint NOT NULL,
    queue_name character varying(128) NOT NULL,
    task_name character varying(128) NOT NULL,
    lock text,
    queueing_lock text,
    args jsonb DEFAULT '{}'::jsonb NOT NULL,
    status public.procrastinate_job_status DEFAULT 'todo'::public.procrastinate_job_status NOT NULL,
    scheduled_at timestamp with time zone,
    attempts integer DEFAULT 0 NOT NULL
);


--
-- Name: procrastinate_fetch_job(character varying[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.procrastinate_fetch_job(target_queue_names character varying[]) RETURNS public.procrastinate_jobs
    LANGUAGE plpgsql
    AS $$
DECLARE
	found_jobs procrastinate_jobs;
BEGIN
    WITH candidate AS (
        SELECT jobs.*
            FROM procrastinate_jobs AS jobs
            WHERE
                -- reject the job if its lock has earlier jobs
                NOT EXISTS (
                    SELECT 1
                        FROM procrastinate_jobs AS earlier_jobs
                        WHERE
                            jobs.lock IS NOT NULL
                            AND earlier_jobs.lock = jobs.lock
                            AND earlier_jobs.status IN ('todo', 'doing')
                            AND earlier_jobs.id < jobs.id)
                AND jobs.status = 'todo'
                AND (target_queue_names IS NULL OR jobs.queue_name = ANY( target_queue_names ))
                AND (jobs.scheduled_at IS NULL OR jobs.scheduled_at <= now())
            ORDER BY jobs.id ASC LIMIT 1
            FOR UPDATE OF jobs SKIP LOCKED
    )
    UPDATE procrastinate_jobs
        SET status = 'doing'
        FROM candidate
        WHERE procrastinate_jobs.id = candidate.id
        RETURNING procrastinate_jobs.* INTO found_jobs;

	RETURN found_jobs;
END;
$$;


--
-- Name: procrastinate_finish_job(bigint, public.procrastinate_job_status, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.procrastinate_finish_job(job_id bigint, end_status public.procrastinate_job_status, delete_job boolean) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    _job_id bigint;
BEGIN
    IF end_status NOT IN ('succeeded', 'failed') THEN
        RAISE 'End status should be either "succeeded" or "failed" (job id: %)', job_id;
    END IF;
    IF delete_job THEN
        DELETE FROM procrastinate_jobs
        WHERE id = job_id AND status IN ('todo', 'doing')
        RETURNING id INTO _job_id;
    ELSE
        UPDATE procrastinate_jobs
        SET status = end_status,
            attempts =
                CASE
                    WHEN status = 'doing' THEN attempts + 1
                    ELSE attempts
                END
        WHERE id = job_id AND status IN ('todo', 'doing')
        RETURNING id INTO _job_id;
    END IF;
    IF _job_id IS NULL THEN
        RAISE 'Job was not found or not in "doing" or "todo" status (job id: %)', job_id;
    END IF;
END;
$$;


--
-- Name: procrastinate_finish_job(integer, public.procrastinate_job_status, timestamp with time zone, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.procrastinate_finish_job(job_id integer, end_status public.procrastinate_job_status, next_scheduled_at timestamp with time zone, delete_job boolean) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    _job_id bigint;
BEGIN
    IF end_status NOT IN ('succeeded', 'failed') THEN
        RAISE 'End status should be either "succeeded" or "failed" (job id: %)', job_id;
    END IF;
    IF delete_job THEN
        DELETE FROM procrastinate_jobs
        WHERE id = job_id AND status IN ('todo', 'doing')
        RETURNING id INTO _job_id;
    ELSE
        UPDATE procrastinate_jobs
        SET status = end_status,
            attempts =
                CASE
                    WHEN status = 'doing' THEN attempts + 1
                    ELSE attempts
                END
        WHERE id = job_id AND status IN ('todo', 'doing')
        RETURNING id INTO _job_id;
    END IF;
    IF _job_id IS NULL THEN
        RAISE 'Job was not found or not in "doing" or "todo" status (job id: %)', job_id;
    END IF;
END;
$$;


--
-- Name: procrastinate_notify_queue(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.procrastinate_notify_queue() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	PERFORM pg_notify('procrastinate_queue#' || NEW.queue_name, NEW.task_name);
	PERFORM pg_notify('procrastinate_any_queue', NEW.task_name);
	RETURN NEW;
END;
$$;


--
-- Name: procrastinate_retry_job(bigint, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.procrastinate_retry_job(job_id bigint, retry_at timestamp with time zone) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    _job_id bigint;
BEGIN
    UPDATE procrastinate_jobs
    SET status = 'todo',
        attempts = attempts + 1,
        scheduled_at = retry_at
    WHERE id = job_id AND status = 'doing'
    RETURNING id INTO _job_id;
    IF _job_id IS NULL THEN
        RAISE 'Job was not found or not in "doing" status (job id: %)', job_id;
    END IF;
END;
$$;


--
-- Name: procrastinate_trigger_scheduled_events_procedure(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.procrastinate_trigger_scheduled_events_procedure() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO procrastinate_events(job_id, type, at)
        VALUES (NEW.id, 'scheduled'::procrastinate_job_event_type, NEW.scheduled_at);

	RETURN NEW;
END;
$$;


--
-- Name: procrastinate_trigger_status_events_procedure_insert(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.procrastinate_trigger_status_events_procedure_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO procrastinate_events(job_id, type)
        VALUES (NEW.id, 'deferred'::procrastinate_job_event_type);
	RETURN NEW;
END;
$$;


--
-- Name: procrastinate_trigger_status_events_procedure_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.procrastinate_trigger_status_events_procedure_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    WITH t AS (
        SELECT CASE
            WHEN OLD.status = 'todo'::procrastinate_job_status
                AND NEW.status = 'doing'::procrastinate_job_status
                THEN 'started'::procrastinate_job_event_type
            WHEN OLD.status = 'doing'::procrastinate_job_status
                AND NEW.status = 'todo'::procrastinate_job_status
                THEN 'deferred_for_retry'::procrastinate_job_event_type
            WHEN OLD.status = 'doing'::procrastinate_job_status
                AND NEW.status = 'failed'::procrastinate_job_status
                THEN 'failed'::procrastinate_job_event_type
            WHEN OLD.status = 'doing'::procrastinate_job_status
                AND NEW.status = 'succeeded'::procrastinate_job_status
                THEN 'succeeded'::procrastinate_job_event_type
            WHEN OLD.status = 'todo'::procrastinate_job_status
                AND (
                    NEW.status = 'failed'::procrastinate_job_status
                    OR NEW.status = 'succeeded'::procrastinate_job_status
                )
                THEN 'cancelled'::procrastinate_job_event_type
            ELSE NULL
        END as event_type
    )
    INSERT INTO procrastinate_events(job_id, type)
        SELECT NEW.id, t.event_type
        FROM t
        WHERE t.event_type IS NOT NULL;
	RETURN NEW;
END;
$$;


--
-- Name: procrastinate_unlink_periodic_defers(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.procrastinate_unlink_periodic_defers() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE procrastinate_periodic_defers
    SET job_id = NULL
    WHERE job_id = OLD.id;
    RETURN OLD;
END;
$$;


--
-- Name: safe_cast_bool(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.safe_cast_bool(p_in text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
begin
  begin
    return $1::bool;
  exception
    when others then
       return null;
  end;
end;
$_$;


--
-- Name: animal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.animal (
    id text NOT NULL,
    species text NOT NULL,
    morph text,
    subspecies text
);


--
-- Name: auto_logger_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.auto_logger_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: auto_ring_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.auto_ring_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chick; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chick (
    id integer NOT NULL,
    deployment integer NOT NULL,
    mass_deployment_g integer,
    mass_deployment_accurate boolean,
    age_deployment_days integer,
    mass_retrieval_g integer,
    mass_retrieval_accurate boolean,
    age_retrieval_days integer
);


--
-- Name: chick_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.chick ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.chick_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: colony; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.colony (
    name text NOT NULL,
    geometry public.geometry(Point,4326),
    country text,
    plot text,
    nest_id text
);


--
-- Name: deployment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deployment (
    id integer NOT NULL,
    ring text NOT NULL,
    date date NOT NULL,
    total_logger_mass_all_loggers_g integer,
    age text,
    sex text,
    sexing_method text,
    mass_deployment_g integer,
    mass_retrieval_g integer,
    scull_mm numeric,
    tarsus_mm numeric,
    wing_mm numeric,
    culmen_mm numeric,
    gonys_mm numeric,
    breeding_stage_deployment text,
    eggs_deployment text,
    chicks_deployment text,
    breeding_stage_retrieval text,
    eggs_retrieval text,
    chicks_retrieval text,
    further_chick_measures_available text,
    more_information_on_breeding_success_available boolean,
    colony text,
    sample_blood boolean,
    sample_feather boolean,
    sample_other boolean,
    sample_notes text,
    comment text,
    other text,
    funding_source text,
    data_responsible text,
    eggs_deployment_extra boolean,
    chicks_deployment_extra boolean,
    eggs_retrieval_extra boolean,
    chicks_retrieval_extra boolean
);


--
-- Name: deployment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.deployment ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.deployment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: ring; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ring (
    id text NOT NULL,
    animal text NOT NULL,
    euring_code text,
    colour_ring_colour text,
    colour_ring_code text
);


--
-- Name: flat_deployments; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.flat_deployments AS
 SELECT d.id AS deployment_id,
    d.age,
    d.sample_blood,
    d.breeding_stage_deployment,
    d.breeding_stage_retrieval,
    d.chicks_deployment,
    d.chicks_deployment_extra,
    d.chicks_retrieval,
    d.chicks_retrieval_extra,
    c.name AS colony,
    c.geometry AS colony_geometry,
    d.comment,
    c.country,
    d.culmen_mm,
    d.data_responsible,
    d.eggs_deployment,
    d.eggs_retrieval,
    r.euring_code,
    d.funding_source,
    d.further_chick_measures_available,
    d.gonys_mm,
    d.mass_deployment_g,
    d.mass_retrieval_g,
    d.more_information_on_breeding_success_available,
    a.morph,
    c.nest_id,
    c.plot,
    r.id AS ring_number,
    r.colour_ring_code,
    r.colour_ring_colour,
    d.sample_feather,
    d.sample_notes,
    d.scull_mm,
    d.sex,
    d.sexing_method,
    a.species,
    a.subspecies,
    d.tarsus_mm,
    d.total_logger_mass_all_loggers_g,
    d.wing_mm
   FROM (((public.deployment d
     JOIN public.colony c ON ((d.colony = c.name)))
     JOIN public.ring r ON ((r.id = d.ring)))
     JOIN public.animal a ON ((r.animal = a.id)));


--
-- Name: logger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.logger (
    id text NOT NULL,
    type text NOT NULL,
    model text
);


--
-- Name: logger_instrumentation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.logger_instrumentation (
    id integer NOT NULL,
    logger text NOT NULL,
    deployment_id integer NOT NULL,
    status text,
    sampling_freq_s numeric,
    mass_g numeric,
    attachment_method text,
    mount_method text,
    startup timestamp with time zone,
    deployment timestamp with time zone,
    retrieval timestamp with time zone,
    filename text,
    data_stored_externally text,
    comment text
);


--
-- Name: flat_logger_files; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.flat_logger_files AS
 WITH has_logger_type AS (
         SELECT d.id,
            array_agg(DISTINCT l_1.type) AS types
           FROM ((public.deployment d
             JOIN public.logger_instrumentation li_1 ON ((li_1.deployment_id = d.id)))
             JOIN public.logger l_1 ON ((li_1.logger = l_1.id)))
          GROUP BY d.id
        )
 SELECT li.id,
    li.logger,
    h.types AS related_logger_types,
    li.deployment_id,
    li.status,
    li.sampling_freq_s,
    li.mass_g,
    li.attachment_method,
    li.mount_method,
    li.startup,
    li.deployment,
    li.retrieval,
    li.filename,
    li.data_stored_externally,
    li.comment,
    l.type,
    l.model
   FROM ((public.logger_instrumentation li
     JOIN has_logger_type h ON ((h.id = li.deployment_id)))
     JOIN public.logger l ON ((li.logger = l.id)));


--
-- Name: import_fields; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.import_fields AS
 SELECT column_name,
    is_nullable
   FROM information_schema.columns
  WHERE (((table_schema)::name = 'public'::name) AND ((table_name)::name = 'import'::name))
  WITH NO DATA;


--
-- Name: logger_instrumentation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.logger_instrumentation ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.logger_instrumentation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: procrastinate_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.procrastinate_events (
    id bigint NOT NULL,
    job_id bigint NOT NULL,
    type public.procrastinate_job_event_type,
    at timestamp with time zone DEFAULT now()
);


--
-- Name: procrastinate_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.procrastinate_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: procrastinate_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.procrastinate_events_id_seq OWNED BY public.procrastinate_events.id;


--
-- Name: procrastinate_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.procrastinate_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: procrastinate_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.procrastinate_jobs_id_seq OWNED BY public.procrastinate_jobs.id;


--
-- Name: procrastinate_periodic_defers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.procrastinate_periodic_defers (
    id bigint NOT NULL,
    task_name character varying(128) NOT NULL,
    defer_timestamp bigint,
    job_id bigint,
    periodic_id character varying(128) DEFAULT ''::character varying NOT NULL
);


--
-- Name: procrastinate_periodic_defers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.procrastinate_periodic_defers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: procrastinate_periodic_defers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.procrastinate_periodic_defers_id_seq OWNED BY public.procrastinate_periodic_defers.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(128) NOT NULL
);


--
-- Name: procrastinate_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.procrastinate_events ALTER COLUMN id SET DEFAULT nextval('public.procrastinate_events_id_seq'::regclass);


--
-- Name: procrastinate_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.procrastinate_jobs ALTER COLUMN id SET DEFAULT nextval('public.procrastinate_jobs_id_seq'::regclass);


--
-- Name: procrastinate_periodic_defers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.procrastinate_periodic_defers ALTER COLUMN id SET DEFAULT nextval('public.procrastinate_periodic_defers_id_seq'::regclass);


--
-- Name: animal animal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT animal_pkey PRIMARY KEY (id);


--
-- Name: chick chick_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chick
    ADD CONSTRAINT chick_pkey PRIMARY KEY (id);


--
-- Name: colony colony_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.colony
    ADD CONSTRAINT colony_pkey PRIMARY KEY (name);


--
-- Name: deployment deployment_date_ring_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deployment
    ADD CONSTRAINT deployment_date_ring_key UNIQUE (date, ring);


--
-- Name: deployment deployment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deployment
    ADD CONSTRAINT deployment_pkey PRIMARY KEY (id);


--
-- Name: logger_instrumentation logger_instrumentation_filename_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logger_instrumentation
    ADD CONSTRAINT logger_instrumentation_filename_key UNIQUE (filename);


--
-- Name: logger_instrumentation logger_instrumentation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logger_instrumentation
    ADD CONSTRAINT logger_instrumentation_pkey PRIMARY KEY (id);


--
-- Name: logger logger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logger
    ADD CONSTRAINT logger_pkey PRIMARY KEY (id);


--
-- Name: procrastinate_events procrastinate_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.procrastinate_events
    ADD CONSTRAINT procrastinate_events_pkey PRIMARY KEY (id);


--
-- Name: procrastinate_jobs procrastinate_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.procrastinate_jobs
    ADD CONSTRAINT procrastinate_jobs_pkey PRIMARY KEY (id);


--
-- Name: procrastinate_periodic_defers procrastinate_periodic_defers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.procrastinate_periodic_defers
    ADD CONSTRAINT procrastinate_periodic_defers_pkey PRIMARY KEY (id);


--
-- Name: procrastinate_periodic_defers procrastinate_periodic_defers_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.procrastinate_periodic_defers
    ADD CONSTRAINT procrastinate_periodic_defers_unique UNIQUE (task_name, periodic_id, defer_timestamp);


--
-- Name: ring ring_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ring
    ADD CONSTRAINT ring_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: procrastinate_events_job_id_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX procrastinate_events_job_id_fkey ON public.procrastinate_events USING btree (job_id);


--
-- Name: procrastinate_jobs_id_lock_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX procrastinate_jobs_id_lock_idx ON public.procrastinate_jobs USING btree (id, lock) WHERE (status = ANY (ARRAY['todo'::public.procrastinate_job_status, 'doing'::public.procrastinate_job_status]));


--
-- Name: procrastinate_jobs_lock_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX procrastinate_jobs_lock_idx ON public.procrastinate_jobs USING btree (lock) WHERE (status = 'doing'::public.procrastinate_job_status);


--
-- Name: procrastinate_jobs_queue_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX procrastinate_jobs_queue_name_idx ON public.procrastinate_jobs USING btree (queue_name);


--
-- Name: procrastinate_jobs_queueing_lock_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX procrastinate_jobs_queueing_lock_idx ON public.procrastinate_jobs USING btree (queueing_lock) WHERE (status = 'todo'::public.procrastinate_job_status);


--
-- Name: procrastinate_periodic_defers_job_id_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX procrastinate_periodic_defers_job_id_fkey ON public.procrastinate_periodic_defers USING btree (job_id);


--
-- Name: import import; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER import BEFORE INSERT ON public.import FOR EACH ROW EXECUTE FUNCTION public.import();


--
-- Name: procrastinate_jobs procrastinate_jobs_notify_queue; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER procrastinate_jobs_notify_queue AFTER INSERT ON public.procrastinate_jobs FOR EACH ROW WHEN ((new.status = 'todo'::public.procrastinate_job_status)) EXECUTE FUNCTION public.procrastinate_notify_queue();


--
-- Name: procrastinate_jobs procrastinate_trigger_delete_jobs; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER procrastinate_trigger_delete_jobs BEFORE DELETE ON public.procrastinate_jobs FOR EACH ROW EXECUTE FUNCTION public.procrastinate_unlink_periodic_defers();


--
-- Name: procrastinate_jobs procrastinate_trigger_scheduled_events; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER procrastinate_trigger_scheduled_events AFTER INSERT OR UPDATE ON public.procrastinate_jobs FOR EACH ROW WHEN (((new.scheduled_at IS NOT NULL) AND (new.status = 'todo'::public.procrastinate_job_status))) EXECUTE FUNCTION public.procrastinate_trigger_scheduled_events_procedure();


--
-- Name: procrastinate_jobs procrastinate_trigger_status_events_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER procrastinate_trigger_status_events_insert AFTER INSERT ON public.procrastinate_jobs FOR EACH ROW WHEN ((new.status = 'todo'::public.procrastinate_job_status)) EXECUTE FUNCTION public.procrastinate_trigger_status_events_procedure_insert();


--
-- Name: procrastinate_jobs procrastinate_trigger_status_events_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER procrastinate_trigger_status_events_update AFTER UPDATE OF status ON public.procrastinate_jobs FOR EACH ROW EXECUTE FUNCTION public.procrastinate_trigger_status_events_procedure_update();


--
-- Name: chick chick_deployment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chick
    ADD CONSTRAINT chick_deployment_fkey FOREIGN KEY (deployment) REFERENCES public.deployment(id);


--
-- Name: deployment deployment_colony_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deployment
    ADD CONSTRAINT deployment_colony_fkey FOREIGN KEY (colony) REFERENCES public.colony(name);


--
-- Name: deployment deployment_ring_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deployment
    ADD CONSTRAINT deployment_ring_fkey FOREIGN KEY (ring) REFERENCES public.ring(id);


--
-- Name: logger_instrumentation logger_instrumentation_deployment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logger_instrumentation
    ADD CONSTRAINT logger_instrumentation_deployment_id_fkey FOREIGN KEY (deployment_id) REFERENCES public.deployment(id);


--
-- Name: logger_instrumentation logger_instrumentation_logger_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logger_instrumentation
    ADD CONSTRAINT logger_instrumentation_logger_fkey FOREIGN KEY (logger) REFERENCES public.logger(id);


--
-- Name: procrastinate_events procrastinate_events_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.procrastinate_events
    ADD CONSTRAINT procrastinate_events_job_id_fkey FOREIGN KEY (job_id) REFERENCES public.procrastinate_jobs(id) ON DELETE CASCADE;


--
-- Name: procrastinate_periodic_defers procrastinate_periodic_defers_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.procrastinate_periodic_defers
    ADD CONSTRAINT procrastinate_periodic_defers_job_id_fkey FOREIGN KEY (job_id) REFERENCES public.procrastinate_jobs(id);


--
-- Name: ring ring_animal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ring
    ADD CONSTRAINT ring_animal_fkey FOREIGN KEY (animal) REFERENCES public.animal(id);


--
-- PostgreSQL database dump complete
--


--
-- Dbmate schema migrations
--

INSERT INTO public.schema_migrations (version) VALUES
    ('20231011105311'),
    ('20231011106000'),
    ('20231011107000'),
    ('20231011110157'),
    ('20231011110410'),
    ('20231011111640'),
    ('20231011112823'),
    ('20231012191628'),
    ('20231020141034'),
    ('20231102100501'),
    ('20231122005008'),
    ('20240116110423'),
    ('20240117072241'),
    ('20240117081051'),
    ('20240117093556'),
    ('20240117105114'),
    ('20240223120820'),
    ('20240314143212'),
    ('20240314145815'),
    ('20240314145816'),
    ('20240508145816'),
    ('20240508145817'),
    ('20240508145818'),
    ('20240508145820');
