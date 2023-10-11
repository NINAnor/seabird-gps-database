-- migrate:up

create table deployment(
    id integer primary key generated always as identity,
    ring text references ring(id) not null,
    date date not null,
    total_logger_mass_all_loggers_g int,
    age text,
    sex text,
    sexing_method text,
    mass_deployment_g int,
    mass_retrieval_g int,
    scull_mm decimal,
    tarsus_mm decimal,
    wing_mm decimal,
    culmen_mm decimal,
    gonys_mm decimal,
    breeding_stage_deployment text,
    eggs_deployment text,
    chicks_deployment text,
    breeding_stage_retrieval text,
    eggs_retrieval text,
    chicks_retrieval text,
    further_chick_measures_available text,
    more_information_on_breeding_success_available bool,
    colony text references colony(name),
    sample_blood bool,
    sample_feather bool,
    sample_other bool,
    sample_notes text,
    comment text,
    other text,
    funding_source text,
    data_responsible text,
    unique (date, ring)
);

create table chick(
    id integer primary key generated always as identity,
    deployment int references deployment(id) not null,
    mass_deployment_g int,
    mass_deployment_accurate bool,
    age_deployment_days int,
    mass_retrieval_g int,
    mass_retrieval_accurate bool,
    age_retrieval_days int
);

grant select on deployment, chick to web_anon;
grant select on deployment to writer; -- because of "returning id"
grant insert on deployment, chick to writer;
grant usage, select on sequence deployment_id_seq, chick_id_seq to writer;

create function import_deployment_and_chick(new import) returns void language plpgsql
as $$
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
        (new.eggs_deployment)::int,
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
        new.data_responsible
    ) returning id into deployment_id;
    if new.chick1_mass_retrieval is not null then
        insert into chick values(
            default,
            deployment_id,
            ltrim(new.chick1_mass_deployment, '~')::decimal,
            substring(new.chick1_mass_deployment for 1) != '~',
            (new.chick1_age_deployment_days)::int,
            ltrim(new.chick1_mass_retrieval, '~')::decimal,
            substring(new.chick1_mass_retrieval for 1) != '~',
            (new.chick1_age_retrieval_days)::int
        );
    end if;
    if new.chick2_mass_retrieval is not null then
        insert into chick values(
            default,
            deployment_id,
            ltrim(new.chick2_mass_deployment, '~')::decimal,
            substring(new.chick2_mass_deployment for 1) != '~',
            (new.chick2_age_deployment_days)::int,
            ltrim(new.chick2_mass_retrieval, '~')::decimal,
            substring(new.chick2_mass_retrieval for 1) != '~',
            (new.chick2_age_retrieval_days)::int
        );
    end if;
    if new.chick3_mass_retrieval is not null then
        insert into chick values(
            default,
            deployment_id,
            ltrim(new.chick3_mass_deployment, '~')::decimal,
            substring(new.chick3_mass_deployment for 1) != '~',
            (new.chick3_age_deployment_days)::int,
            ltrim(new.chick3_mass_retrieval, '~')::decimal,
            substring(new.chick3_mass_retrieval for 1) != '~',
            (new.chick3_age_retrieval_days)::int
        );
    end if;
end;
$$;

-- migrate:down
