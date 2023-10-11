-- migrate:up

create function import() returns trigger language plpgsql
as $$
begin
    perform import_animal_and_ring(new);
    perform import_colony(new);
    perform import_deployment_and_chick(new);
    perform import_logger_and_logger_instrumentation(new);
    return null;
exception
    when others then
        raise exception using
            errcode = sqlstate,
            message = sqlerrm,
            detail = new;
end;
$$;

create trigger import
    before insert on import
    for each row
    execute function import();

-- migrate:down
