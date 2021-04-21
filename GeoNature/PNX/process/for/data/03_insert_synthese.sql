-- table correction taxons (correspondance sur le lb nom)
drop table if exists access.tmp_taxons;
create table access.tmp_taxons as
with 
taxons_wrong as (
	s a.cd_taxon, ta.lb_nom
--	from access.releves r
--	join access.especes e on e.cd_releve = r.cd_releve
	from access.taxons ta --on ta.cd_taxon =e.cd_taxon 
	left join taxonomie.taxref t on t.cd_nom = ta.cd_taxon::int
	where t.cd_nom is null
),
taxons_corrected as (
	select cd_nom, tw.cd_taxon
	from taxons_wrong tw
	join taxonomie.taxref t on t.lb_nom = tw.lb_nom
)
select cd_taxon::int, cd_nom from taxons_corrected
;


-- table temp counting
drop table access.tmp_counting;
create table access.tmp_counting as
select cd_espece, nb_fem as nb, '2' as cd_nomenclature_sex, '2' as cd_nomenclature_life_stage from access.especes where nb_fem is not null
union 
select cd_espece, nb_mal as nb, '3' as cd_nomenclature_sex, '2' as cd_nomenclature_life_stage from access.especes where nb_mal is not null
union 
select cd_espece, nb_ad as nb, '0' as cd_nomenclature_sex, '2' as cd_nomenclature_life_stage from access.especes where nb_ad is not null and nb_fem is null and nb_mal is null
union
select cd_espece, nb_juv as nb, '0' as cd_nomenclature_sex, '3' as cd_nomenclature_life_stage from access.especes where nb_juv is not null
union
select cd_espece, nb_immat as nb, '0' as cd_nomenclature_sex, '4' as cd_nomenclature_life_stage from access.especes where nb_immat is not null
union
select cd_espece, nb_larv as nb, '0' as cd_nomenclature_sex, '6' as cd_nomenclature_life_stage from access.especes where nb_larv is not null
union 
select cd_espece, nb_oeuf as nb, '0' as cd_nomenclature_sex, '9' as cd_nomenclature_life_stage from access.especes where nb_oeuf is not null
union 
select cd_espece, nb_ind as nb, '0' as cd_nomenclature_sex, '0' as cd_nomenclature_life_stage from access.especes where true
		and nb_ind is not null
		and nb_ad is null
		and nb_mal is null
		and nb_fem is null
		and nb_juv is null
		and nb_immat is null
		and nb_larv is null
		and nb_pont is null
		and nb_oeuf is null
union
select cd_espece, '1' as nb, '0' as cd_nomenclature_sex, '0' as cd_nomenclature_life_stage  from access.especes where true
		and nb_ind is null
		and nb_ad is null
		and nb_mal is null
		and nb_fem is null
		and nb_juv is null
		and nb_immat is null
		and nb_larv is null
		and nb_pont is null
		and nb_oeuf is null;

	insert into gn_synthese.synthese (
cd_nom,
comment_context,
comment_description,
count_min,
count_max,
id_nomenclature_life_stage,
id_nomenclature_sex,
)


select 
	coalesce(t.cd_nom, tt.cd_nom),
	r.commentaire,
	e.commentaire,
	tc.nb as count_min,
	tc.nb as count_max,
	ref_nomenclatures.get_id_nomenclature('STADE_VIE', tc.cd_nomenclature_life_stage) as id_nomenclature_life_stage,
	ref_nomenclatures.get_id_nomenclature('STADE_VIE', tc.cd_nomenclature_sex) as id_nomenclature_sex
from access.releves r
	join access.especes e on e.cd_releve = r.cd_releve
	LEFT JOIN access.tmp_taxons tt  ON e.cd_taxon::int = tt.cd_taxon
	LEFT JOIN taxonomie.taxref t ON t.cd_nom = e.cd_taxon::int
	join access.tmp_counting tc on tc.cd_espece = e.cd_espece 
	WHERE coalesce(t.cd_nom, tt.cd_nom) IS NOT null






