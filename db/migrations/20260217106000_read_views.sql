-- migrate:up

GRANT SELECT ON public.flat_deployments TO web_anon;
GRANT SELECT ON public.flat_logger_files TO web_anon;

-- migrate:down
