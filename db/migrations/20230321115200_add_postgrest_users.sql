-- migrate:up

create role web_anon nologin;
grant select on colony, animal, ring, survey, logger, deployment, chick to web_anon;

create role writer nologin;
grant insert on colony, animal, ring, survey, logger, deployment, chick, import_entry to writer;
grant usage, select on sequence chick_id_seq to writer;

-- migrate:down

