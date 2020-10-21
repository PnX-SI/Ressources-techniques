-- vue observations cd_nom valid

CREATE OR REPLACE VIEW export_oo.v_saisie_observation_cd_nom_valid AS
    SELECT s.*,
    COALESCE(t.cd_nom, st.cd_nom_valid) AS cd_nom_valid
    FROM export_oo.saisie_observation s
    LEFT JOIN export_oo.t_taxonomie_synonymes st
            ON st.cd_nom_invalid = s.cd_nom
        LEFT JOIN taxonomie.taxref t
            ON t.cd_nom = s.cd_nom OR t.cd_nom = st.cd_nom_valid
        WHERE COALESCE(t.cd_nom, st.cd_nom_valid) IS NOT NULL
;


-- acquistion

CREATE OR REPLACE VIEW export_oo.v_acquisition_frameworks AS
    SELECT a.* 
    FROM gn_meta.t_acquisition_frameworks a
    WHERE a.acquisition_framework_desc LIKE CONCAT('%', :'db_oo_name', '%')
;

-- dataset

CREATE OR REPLACE VIEW export_oo.v_datasets AS
    SELECT d.* FROM gn_meta.t_datasets d
    JOIN export_oo.v_acquisition_frameworks va
        ON va.id_acquisition_framework = d.id_acquisition_framework
;

-- synthese

CREATE OR REPLACE VIEW export_oo.v_synthese AS
    SELECT s.* 
    FROM gn_synthese.synthese s
    JOIN export_oo.v_datasets vd
        ON vd.id_dataset = s.id_dataset
;

-- releve

CREATE OR REPLACE VIEW export_oo.v_releves_occtax AS
    SELECT r.*
    FROM pr_occtax.t_releves_occtax r
    JOIN export_oo.v_datasets vd
        ON vd.id_dataset = r.id_dataset
;

-- occurrence

CREATE OR REPLACE VIEW export_oo.v_occurrences_occtax AS
    SELECT o.*
    FROM pr_occtax.t_occurrences_occtax o
    JOIN export_oo.v_releves_occtax vr
        ON vr.id_releve_occtax = o.id_releve_occtax
;

-- counting

CREATE OR REPLACE VIEW export_oo.v_counting_occtax AS
    SELECT c.*
    FROM pr_occtax.cor_counting_occtax c
    JOIN export_oo.v_occurrences_occtax vo
        ON vo.id_occurrence_occtax = c.id_occurrence_occtax
;

-- cor_role_releves_occtax 

CREATE OR REPLACE VIEW export_oo.v_role_releves_occtax AS
SELECT c.*
FROM pr_occtax.cor_role_releves_occtax c 
    JOIN export_oo.v_releves_occtax vo 
        ON vo.id_releve_occtax = c.id_releve_occtax
;

-- organisme

CREATE OR REPLACE VIEW export_oo.v_organismes AS
SELECT o.*
    FROM utilisateurs.bib_organismes o
    WHERE o.url_logo LIKE CONCAT('%', :'db_oo_name', '%')
;

-- utilisateur

CREATE OR REPLACE VIEW export_oo.v_roles AS
    SELECT r.*
        FROM utilisateurs.t_roles r
        JOIN export_oo.v_organismes vo
            ON vo.id_organisme = r.id_organisme
;