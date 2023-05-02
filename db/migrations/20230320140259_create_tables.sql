-- migrate:up

create table colony(
    name text primary key,
    geometry geometry(point, 4326),
    country text,
    plot text,
    nest_id text
);

create table animal(
    id int primary key,
    species text not null,
    morph text,
    subspecies text
);

create table ring(
    id int primary key,
    euring_code text,
    colour_ring_colour text,
    colour_ring_code text,
    animal int references animal(id) not null
);

create table survey(
    ring int references ring(id),
    year smallint not null,

    total_mass_g int,

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

    colony text references colony(name),

    sample_blood bool,
    sample_feather bool,
    sample_other bool,
    sample_notes text,
    logging_for_seatrack bool,

    notes text,
    other text,
    data_responsible text,

    primary key (year, ring)
);

create table logger(
    id text primary key,
    type text not null,
    model text
);

create table deployment(
    logger text references logger(id) not null,
    animal int references animal(id) not null,

    status text,

    sampling_freq_s decimal,
    mass_g decimal,
    attachment_method text,
    mount_method text,
    startup timestamp with time zone,
    deployment timestamp with time zone,
    retrieval timestamp with time zone,
    filename text,
    notes text
);

create table chick(
    id integer primary key generated always as identity,

    animal int references animal(id) not null,
    year smallint not null,

    mass_deployment int,
    age_deployment text,
    mass_retrieval int,
    age_retrieval text
);

-- migrate:down

