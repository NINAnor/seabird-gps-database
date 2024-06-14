-- migrate:up
DROP VIEW flat_logger_files;

CREATE VIEW flat_logger_files AS (
    WITH has_logger_type AS (
        SELECT
            r.id,
            array_agg(DISTINCT l."type") AS types,
            li.deployment
        FROM
            ring AS r
            JOIN logger_instrumentation AS li ON li.ring = r.id
            JOIN logger AS l ON li.logger = l.id
        GROUP BY
            r.id,
            li.deployment
	)
        SELECT
            li.id,
            li.logger,
            h.types AS related_logger_types,
            li.ring,
            li.status,
            li.sampling_freq_s,
            li.mass_g,
            li.attachment_method,
            li.mount_method,
            li.startup,
            li.deployment,
            li.retrieval,
            li.filename,
            li.data_stored_externally,
            li.comment,
            l.type,
            l.model
        FROM
            logger_instrumentation li
            JOIN has_logger_type h ON h.id = li.ring
                AND h.deployment = li.deployment
            JOIN logger l ON li.logger = l.id
);

GRANT SELECT ON public.flat_logger_files TO readonly;

-- migrate:down
