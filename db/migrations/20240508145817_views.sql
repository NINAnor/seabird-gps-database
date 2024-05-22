-- migrate:up
create view flat_deployments as (
	select
		d.id as deployment_id,
		d.age,
		d.sample_blood,
		d.breeding_stage_deployment,
		d.breeding_stage_retrieval,
		d.chicks_deployment,
		d.chicks_deployment_extra,
		d.chicks_retrieval,
		d.chicks_retrieval_extra,
		c.name as colony,
		c.geometry as colony_geometry,
		d."comment",
		c.country,
		d.culmen_mm,
		d.data_responsible,
		d.eggs_deployment,
		d.eggs_retrieval,
		r.euring_code,
		d.funding_source,
		d.further_chick_measures_available,
		d.gonys_mm,
		d.mass_deployment_g,
		d.mass_retrieval_g,
		d.more_information_on_breeding_success_available,
		a.morph,
		c.nest_id,
		c.plot,
		r.id as ring_number,
		r.colour_ring_code,
		r.colour_ring_colour,
		d.sample_feather,
		d.sample_notes,
		d.scull_mm,
		d.sex,
		d.sexing_method,
		a.species,
		a.subspecies,
		d.tarsus_mm,
		d.total_logger_mass_all_loggers_g,
		d.wing_mm
	from deployment as d 
	join colony as c on d.colony = c."name"
	join ring as r on r.id = d.ring
	join animal as a on r.animal = a.id
);

create view flat_logger_files as (
   select li.*, l."type", l.model from logger_instrumentation li
   join logger l on li.logger = l.id
);

GRANT SELECT ON public.flat_deployments TO readonly;
GRANT SELECT ON public.flat_logger_files TO readonly;

-- migrate:down

