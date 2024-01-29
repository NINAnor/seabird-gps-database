-- migrate:up

alter table logger_instrumentation add constraint logger_instrumentation_filename_key unique (filename);

-- migrate:down
