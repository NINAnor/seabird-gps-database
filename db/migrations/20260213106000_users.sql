-- migrate:up

create role admin nologin;


GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA public 
TO admin;

-- migrate:down
