-- BASE OO

DROP VIEW IF EXISTS export_gn.v_utilisateurs_bib_organismes CASCADE;
CREATE VIEW export_gn.v_utilisateurs_bib_organismes AS
    SELECT
        id_structure,
        nom_structure AS nom_organisme,
        adresse_1 AS adresse_organisme,
        code_postal AS cp_organisme,
        ville AS ville_organisme,
        tel AS tel_organisme,
        fax AS fax_organisme,
        TRIM(CONCAT(courriel_1, ' ', courriel_2 )) AS email_organisme,
        site_web AS url_organisme
    FROM md.structure
;

DROP VIEW IF EXISTS export_gn.v_utilisateurs_t_roles;
CREATE VIEW export_gn.v_utilisateurs_t_roles AS
    WITH 
        champs_addi AS
            ( SELECT
                    id_personne, 
                    fax,
                    portable,
                    tel_pro,
                    tel_perso,
                    pays,
                    ville,
                    code_postal,
                    adresse_1,
                    role,
                    specialite,
                    titre
                FROM md.personne
            )
    SELECT
        remarque AS remarques,
        prenom AS prenom_role,
        nom AS nom_role,
        email AS identifiant,
        email AS email,
        date_maj::timestamp AS date_insert,
        (CAST(to_json(ca) AS JSONB) - 'id_personne') AS champs_addi,
        id_structure
    FROM md.personne p
    JOIN champs_addi ca ON ca.id_personne = p.id_personne
;
