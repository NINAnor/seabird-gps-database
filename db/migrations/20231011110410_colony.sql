-- migrate:up

create table colony(
    name text primary key,
    geometry geometry(point, 4326),
    country text,
    plot text,
    nest_id text
);

grant select on colony to web_anon;
grant insert on colony to writer;

create function import_colony(new import) returns void language plpgsql
as $$
begin
    insert into colony values(
        new.colony,
        ST_SetSRID(ST_MakePoint(
            new.colony_latitude::float,
            new.colony_longitude::float
        ), 4326),
        new.country,
        new.plot,
        new.nest_id
    ) on conflict do nothing;
end;
$$;

-- migrate:down
