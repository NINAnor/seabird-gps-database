-- migrate:up

alter table deployment add column eggs_deployment_extra bool;

create or replace function import_deployment_and_chick(new import) returns void language plpgsql
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

-- migrate:down
