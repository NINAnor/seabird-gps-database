-- migrate:up

alter table logger_instrumentation alter column filename set not null;
alter table logger_instrumentation add constraint logger_instrumentation_filename_key unique (filename);

create table logger_data(
    filename text references logger_instrumentation(filename),
    invalid bool,
    datetime timestamp with time zone not null,
    geometry geometry(pointz),
    satellites integer,
    hdop decimal
);

grant select on logger_data to web_anon;
grant insert on logger_data to writer;

-- migrate:down
