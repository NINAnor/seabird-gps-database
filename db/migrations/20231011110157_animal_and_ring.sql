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
grant insert on animal, ring to writer;

create function import_animal_and_ring(new import) returns void language plpgsql
as $$
declare
    animal text;
begin
    if new.old_ring_number is null then
        animal = new.ring_number;
    else
        select animal into strict animal
          from ring
         where id = new.old_ring_number;
    end if;
    insert into animal values(
        animal,
        new.species,
        new.morph,
        new.subspecies
    ) on conflict do nothing;
    insert into ring values(
        new.ring_number,
        animal,
        new.euring_code,
        new.colour_ring_colour,
        new.colour_ring_code
    ) on conflict do nothing;
end;
$$;

-- migrate:down
