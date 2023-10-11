-- migrate:up

create role web_anon nologin;
create role writer nologin;

-- migrate:down
