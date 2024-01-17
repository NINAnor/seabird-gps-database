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
-- Name: import(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.import() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    -- perform some checks
    if new.gps_deployment_date IS NOT NULL AND new.gps_raw_datafile_name IS NULL then
        raise exception 'gps_raw_datafile_name cannot be empty if gps_deployment_date is defined';
    end if;

    if new.gls_deployment_date IS NOT NULL AND new.gls_raw_datafile_name IS NULL then
        raise exception 'gls_raw_datafile_name cannot be empty if gls_deployment_date is defined';
    end if;

    if new.tdr_deployment_date IS NOT NULL AND new.tdr_raw_datafile_name IS NULL then
        raise exception 'tdr_raw_datafile_name cannot be empty if tdr_deployment_date is defined';
    end if;

    if new.accelerometer_deployment_date IS NOT NULL AND new.accelerometer_raw_datafile_name IS NULL then
        raise exception 'accelerometer_raw_datafile_name cannot be empty if accelerometer_deployment_date is defined';
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
    mass_gps_logger_g text,
    gps_attachment_method text,
    gps_mount_method text,
    total_logger_mass_all_loggers_g text,
    gps_logger_comment text,
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
    comments_samples text,
    logging_for_seatrack text,
    gls_logger_model text,
    gls_logger_id text,
    gls_status text,
    gls_data_collected text,
    gls_record_frequency_min text,
    gls_logger_mass_g text,
    gls_attachment_method text,
    gls_mount_method text,
    gls_startup_date_gmt text,
    gls_startup_time_gmt text,
    gls_deployment_date text,
    gls_deployment_time text,
    gls_retrieval_date text,
    gls_retrieval_time text,
    gls_deployment_retrieval_time_zone text,
    gls_time_zone text,
    gls_raw_datafile_name text,
    gls_comments text,
    tdr_logger_model text,
    tdr_logger_id text,
    tdr_status text,
    tdr_data_collected text,
    tdr_record_frequency_sec text,
    tdr_mass_g text,
    tdr_attachment_method text,
    tdr_mount_method text,
    tdr_startup_date text,
    tdr_startup_time text,
    tdr_deployment_date text,
    tdr_deployment_time text,
    tdr_retrieval_date text,
    tdr_retrieval_time text,
    tdr_startup_deployment_retrieval_time_zone text,
    tdr_time_zone text,
    tdr_raw_datafile_name text,
    tdr_comment text,
    accelerometer_logger_model text,
    accelerometer_logger_id text,
    accelerometer_status text,
    accelerometer_data_collected text,
    accelerometer_record_frequency_millisec text,
    accelerometer_mass_g text,
    accelerometer_attachment_method text,
    accelerometer_mount_method text,
    accelerometer_startup_date text,
    accelerometer_startup_time text,
    accelerometer_deployment_date text,
    accelerometer_deployment_time text,
    accelerometer_retrieval_date text,
    accelerometer_retrieval_time text,
    accelerometer_startup_deployment_retrieval_time_zone text,
    accelerometer_time_zone text,
    accelerometer_raw_datafile_name text,
    accelerometer_comment text,
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
    animal text;
begin
    if new.old_ring_number is null then
        animal = new.ring_number;
    else
        select animal into strict animal
          from ring
         where id = new.old_ring_number;
    end if;
    insert into animal values(
        animal,
        new.species,
        new.morph,
        new.subspecies
    ) on conflict do nothing;
    insert into ring values(
        new.ring_number,
        animal,
        new.euring_code,
        new.colour_ring_colour,
        new.colour_ring_code
    ) on conflict do nothing;
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

CREATE FUNCTION public.import_deployment_and_chick(new public.import) RETURNS void
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
        new.accelerometer_deployment_date
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
        new.comments_samples,
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
end;
$$;


--
-- Name: import_logger_and_logger_instrumentation(public.import); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.import_logger_and_logger_instrumentation(new public.import) RETURNS void
    LANGUAGE plpgsql
    AS $$
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


--
-- Name: import_logger_data_gps(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.import_logger_data_gps() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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


--
-- Name: import_logger_data_gps_pathtrack(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.import_logger_data_gps_pathtrack() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
    eggs_deployment_extra boolean
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
-- Name: import_fields; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.import_fields AS
 SELECT column_name,
    is_nullable
   FROM information_schema.columns
  WHERE (((table_schema)::name = 'public'::name) AND ((table_name)::name = 'import'::name))
  WITH NO DATA;


--
-- Name: import_logger_data_gps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.import_logger_data_gps (
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


--
-- Name: import_logger_data_gps_pathtrack; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.import_logger_data_gps_pathtrack (
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


--
-- Name: logger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.logger (
    id text NOT NULL,
    type text NOT NULL,
    model text
);


--
-- Name: logger_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.logger_data (
    filename text,
    invalid boolean,
    datetime timestamp with time zone NOT NULL,
    geometry public.geometry(PointZ),
    satellites integer,
    hdop numeric
);


--
-- Name: logger_instrumentation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.logger_instrumentation (
    id integer NOT NULL,
    logger text NOT NULL,
    ring text NOT NULL,
    status text,
    sampling_freq_s numeric,
    mass_g numeric,
    attachment_method text,
    mount_method text,
    startup timestamp with time zone,
    deployment timestamp with time zone,
    retrieval timestamp with time zone,
    filename text NOT NULL,
    data_stored_externally text,
    comment text
);


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
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(128) NOT NULL
);


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
-- Name: import import; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER import BEFORE INSERT ON public.import FOR EACH ROW EXECUTE FUNCTION public.import();


--
-- Name: import_logger_data_gps import_logger_data_gps; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER import_logger_data_gps BEFORE INSERT ON public.import_logger_data_gps FOR EACH ROW EXECUTE FUNCTION public.import_logger_data_gps();


--
-- Name: import_logger_data_gps_pathtrack import_logger_data_gps_pathtrack; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER import_logger_data_gps_pathtrack BEFORE INSERT ON public.import_logger_data_gps_pathtrack FOR EACH ROW EXECUTE FUNCTION public.import_logger_data_gps_pathtrack();


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
-- Name: logger_data logger_data_filename_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logger_data
    ADD CONSTRAINT logger_data_filename_fkey FOREIGN KEY (filename) REFERENCES public.logger_instrumentation(filename);


--
-- Name: logger_instrumentation logger_instrumentation_logger_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logger_instrumentation
    ADD CONSTRAINT logger_instrumentation_logger_fkey FOREIGN KEY (logger) REFERENCES public.logger(id);


--
-- Name: logger_instrumentation logger_instrumentation_ring_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logger_instrumentation
    ADD CONSTRAINT logger_instrumentation_ring_fkey FOREIGN KEY (ring) REFERENCES public.ring(id);


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
    ('20231122005845'),
    ('20231122021711'),
    ('20240116110423'),
    ('20240117072241'),
    ('20240117081051');
