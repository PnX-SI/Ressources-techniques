-- synthese

ALTER TABLE gn_synthese.synthese DISABLE TRIGGER tri_del_area_synt_maj_corarea_tax;



DELETE FROM gn_synthese.synthese s
    USING export_oo.v_synthese vs
    WHERE vs.id_synthese = s.id_synthese;

ALTER TABLE gn_synthese.synthese ENABLE TRIGGER tri_del_area_synt_maj_corarea_tax;

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
DELETE FROM gn_meta.t_datasets d 
    USING export_oo.v_datasets vd WHERE vd.id_dataset = d.id_dataset;
;

-- ca
DELETE FROM gn_meta.t_acquisition_frameworks a 
    USING export_oo.v_acquisition_frameworks va
    WHERE va.id_acquisition_framework = a.id_acquisition_framework;
;

-- user (patch constraint sinon 20s pour 700 roles...)
ALTER TABLE gn_commons.t_validations DROP CONSTRAINT fk_t_validations_t_roles;

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

