-- occtax occurrences

with sensi_occtax as (
select gn_sensitivity.get_id_nomenclature_sensitivity(tro.date_min::date, too.cd_nom, tro.geom_local, null::jsonb) as id_nomenclature_sensitivity, too.id_occurrence_occtax from 
pr_occtax.t_occurrences_occtax too
join pr_occtax.t_releves_occtax tro on tro.id_releve_occtax  = too.id_releve_occtax 
), sensi_diff_occtax as (
select id_nomenclature_sensitivity, id_occurrence_occtax, n2.id_nomenclature as id_nomenclature_diffusion_level
from sensi_occtax
join ref_nomenclatures.t_nomenclatures n1 on n1.id_nomenclature=id_nomenclature_sensitivity
join ref_nomenclatures.t_nomenclatures n2
on n2.cd_nomenclature = '0'
join ref_nomenclatures.bib_nomenclatures_types t1 on n1.id_type = t1.id_type and t1.mnemonique = 'SENSIBILITE'
join ref_nomenclatures.bib_nomenclatures_types t2 on n2.id_type = t2.id_type and t2.mnemonique = 'NIV_PRECIS'
)
update pr_occtax.t_occurrences_occtax o set  id_nomenclature_diffusion_level = 
(select id_nomenclature_diffusion_level 
from sensi_diff_occtax 
where sensi_diff_occtax.id_occurrence_occtax = o.id_occurrence_occtax)
;

-- synthese


with sensi as (
select 
s.id_synthese, 
gn_sensitivity.get_id_nomenclature_sensitivity(s.date_min::date, s.cd_nom, s.the_geom_local , null::JSONB) as id_nomenclature_sensitivity
from gn_synthese.synthese s
), sensi_diff as (
select id_nomenclature_sensitivity, id_synthese, n2.id_nomenclature as id_nomenclature_diffusion_level
from sensi
join ref_nomenclatures.t_nomenclatures n1 on n1.id_nomenclature=id_nomenclature_sensitivity
join ref_nomenclatures.t_nomenclatures n2
on n2.cd_nomenclature = '0'
join ref_nomenclatures.bib_nomenclatures_types t1 on n1.id_type = t1.id_type and t1.mnemonique = 'SENSIBILITE'
join ref_nomenclatures.bib_nomenclatures_types t2 on n2.id_type = t2.id_type and t2.mnemonique = 'NIV_PRECIS'
)
update gn_synthese.synthese s set (id_nomenclature_diffusion_level, id_nomenclature_sensitivity) = (
select 
id_nomenclature_diffusion_level, id_nomenclature_sensitivity
from sensi_diff sd
where sd.id_synthese = s.id_synthese)