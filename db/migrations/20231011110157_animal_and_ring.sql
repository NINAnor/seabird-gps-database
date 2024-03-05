-- migrate:up

create table animal(
    id text primary key,
    species text not null,
    morph text,
    subspecies text
);

create table ring(
    id text primary key,
    animal text references animal(id) not null,
    euring_code text,
    colour_ring_colour text,
    colour_ring_code text
);

grant select on animal, ring to web_anon;
grant select, insert on animal, ring to writer;

create function import_animal_and_ring(new import) returns void language plpgsql
as $$
declare
    animal_id text;
begin
    if new.old_ring_number is null then
        animal_id = new.ring_number;
    else
        select animal into strict animal_id
        from ring
        where id = new.old_ring_number;
    end if;
    insert into animal values(
        animal_id,
        new.species,
        new.morph,
        new.subspecies
    ) on conflict do nothing;
    insert into ring values(
        new.ring_number,
        animal_id,
        new.euring_code,
        new.colour_ring_colour,
        new.colour_ring_code
    ) on conflict do nothing;
exception 
    when no_data_found then raise exception using
        errcode = '22000',
        message = 'Old ring number specified, but not present in the database';
end;
$$;

-- migrate:down
