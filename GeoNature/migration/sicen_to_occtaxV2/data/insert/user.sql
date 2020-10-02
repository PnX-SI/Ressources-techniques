-- BASE GN


-- add columns to keep information

ALTER TABLE utilisateurs.bib_organismes ADD id_structure INTEGER;


-- utilisateur.bib_organismes

INSERT INTO utilisateurs.bib_organismes (
        id_structure,
        nom_organisme,
        adresse_organisme,
        cp_organisme,
        ville_organisme,
        tel_organisme,
        fax_organisme,
        email_organisme,
        url_organisme
    )
    SELECT
        vo.id_structure,
        vo.nom_organisme,
        vo.adresse_organisme,
        vo.cp_organisme,
        vo.ville_organisme,
        vo.tel_organisme,
        vo.fax_organisme,
        vo.email_organisme,
        vo.url_organisme
    FROM import_oo.v_utilisateurs_bib_organismes vo
    LEFT JOIN utilisateurs.bib_organismes o
        ON vo.nom_organisme = o.nom_organisme
    WHERE o.nom_organisme IS NULL 
;

-- utilisateurs.t_roles
-- pas 2 utilisateurs qui s'appellent pareil.


INSERT INTO utilisateurs.t_roles(
        remarques,
        prenom_role,
        nom_role,
        identifiant,
        email,
        date_insert,
        champs_addi,
        id_organisme,
        groupe
    )
    SELECT
        vr.remarques,
        vr.prenom_role,
        vr.nom_role,
        vr.identifiant,
        vr.email,
        vr.date_insert,
        vr.champs_addi,
        o.id_organisme,
        FALSE
    FROM import_oo.v_utilisateurs_t_roles vr
    JOIN utilisateurs.bib_organismes o 
        ON vr.id_structure = o.id_structure
    LEFT JOIN import_oo.v_utilisateurs_t_roles r
        ON r.nom_role = vr.nom_role 
            AND r.prenom_role = vr.prenom_role
    WHERE r.nom_role IS NULL
;

-- gestion des droits (TODO affiner)

-- creation groupe Grp_observateur

--  - expert, amateur -> Grp_en_poste
--  - admin -> Grp_admin
--  - observ -> Grp_observateur

INSERT INTO utilisateurs.t_roles(
    groupe,
    nom_role,
    desc_role,
    remarques
    )
    VALUES (TRUE, 'Grp_observateurs', 'Tous les observateurs', 'Groupe sans droit (pour les listes)')
;


INSERT INTO utilisateurs.cor_roles
(
    id_role_utilisateur,
    id_role_groupe
)
SELECT 
	r.id_role,
	CASE 
		WHEN champs_addi->>'role' IN ('expert', 'amateur') THEN (SELECT id_role FROM utilisateurs.t_roles r WHERE r.nom_role = 'Grp_en_poste') 
		WHEN champs_addi->>'role' = 'admin' THEN (SELECT id_role FROM utilisateurs.t_roles r WHERE r.nom_role = 'Grp_admin') 
		WHEN champs_addi->>'role' = 'observ' THEN (SELECT id_role FROM utilisateurs.t_roles r WHERE r.nom_role = 'Grp_observateurs') 
	END
	FROM utilisateurs.t_roles r
	WHERE champs_addi->>'role' IS NOT NULL
;


-- create list occtax ??

-- drop additional column

ALTER TABLE utilisateurs.bib_organismes DROP id_structure;
