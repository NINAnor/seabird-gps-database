-- migrate:up

create materialized view import_fields as 
(SELECT column_name, is_nullable
  FROM information_schema.columns
 WHERE table_schema = 'public'
   AND table_name   = 'import');

grant select on import_fields to web_anon;


-- migrate:down

