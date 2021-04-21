-- media
--delete from gn_commons.t_medias
;
delete from gn_commons.t_medias m using export_oo.v_synthese s where m.uuid_attached_row = s.unique_id_sinp
;           

--
-- delete from gn_synthese.cor_area_taxon;

-- synthese
-- ALTER TABLE gn_synthese.synthese DISABLE TRIGGER tri_del_area_synt_maj_corarea_tax;

--DELETE FROM gn_monitoring.t_base_sites;

DELETE FROM gn_synthese.synthese s
--    USING export_oo.v_synthese vs
--    WHERE vs.id_synthese = s.id_synthese
;

DELETE FROM gn_synthese.cor_observer_synthese;

DELETE FROM gn_synthese.cor_area_synthese;


-- ALTER TABLE gn_synthese.synthese ENABLE TRIGGER tri_del_area_synt_maj_corarea_tax;

--validation
DELETE FROM gn_commons.t_validations v
    USING export_oo.v_counting_occtax co
        WHERE co.unique_id_sinp_occtax = v.uuid_attached_row
;

-- cor role releves
DELETE FROM pr_occtax.cor_role_releves_occtax c 
    USING export_oo.v_role_releves_occtax vc
    WHERE vc.id_releve_occtax = c.id_releve_occtax
;

-- releves
DELETE FROM pr_occtax.t_releves_occtax r 
    USING export_oo.v_releves_occtax vr 
    WHERE vr.id_releve_occtax = r.id_releve_occtax
;

-- jdd

DELETE FROM gn_commons.cor_module_dataset c
USING export_oo.v_datasets d
JOIN gn_commons.t_modules m ON m.module_code = 'OCCTAX'
WHERE m.id_module= c.id_module
;

DELETE FROM gn_meta.cor_dataset_actor c 
    USING export_oo.v_datasets vd WHERE vd.id_dataset = c.id_dataset;


SELECT 'DELETE JDD!!!';
SELECT * FROM export_oo.v_datasets vd;
DELETE FROM gn_meta.t_datasets d 
    USING export_oo.v_datasets vd WHERE vd.id_dataset = d.id_dataset;
;



-- ca
SELECT 'DELETE CA!!!';
DELETE FROM gn_meta.t_acquisition_frameworks a 
    USING export_oo.v_acquisition_frameworks va
    WHERE va.id_acquisition_framework = a.id_acquisition_framework;
;

-- user (patch constraint sinon 20s pour 700 roles...)
ALTER TABLE gn_commons.t_validations DROP CONSTRAINT IF EXISTS fk_t_validations_t_roles;

DELETE FROM utilisateurs.t_roles r
    USING export_oo.v_roles vr
    WHERE vr.id_role = r.id_role;
;

ALTER TABLE ONLY gn_commons.t_validations ADD CONSTRAINT fk_t_validations_t_roles FOREIGN KEY (id_validator) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE;


--organismes
DELETE FROM utilisateurs.bib_organismes o
    USING export_oo.v_organismes vo
    WHERE vo.id_organisme = o.id_organisme;
;

