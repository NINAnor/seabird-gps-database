-- migrate:up
DO
$do$
BEGIN
   IF EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'readonly') THEN

      RAISE NOTICE 'Role "readonly" already exists. Skipping.';
   ELSE
      create role "readonly" WITH LOGIN password 'readonly';
   END IF;
END
$do$;

grant connect on database postgres to readonly;

GRANT USAGE ON SCHEMA public to readonly;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;

GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO readonly;


-- migrate:down

