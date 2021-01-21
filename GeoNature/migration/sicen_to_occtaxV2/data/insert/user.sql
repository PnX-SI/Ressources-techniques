-- BASE GN



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
        url_organisme,
        url_logo
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
        vo.url_organisme,
        vo.url_logo

    FROM export_oo.v_utilisateurs_bib_organismes vo
    LEFT JOIN export_oo.v_organismes vo2
        ON vo2.nom_organisme = vo.nom_organisme
    WHERE vo2.nom_organisme IS NULL
;

-- refaire la vue pour avoir id_structure
CREATE OR REPLACE VIEW export_oo.v_organismes AS
SELECT o.*
    FROM utilisateurs.bib_organismes o
    WHERE o.url_logo LIKE CONCAT('%', :'db_oo_name', '%')
;
-- utilisateurs.t_roles
-- pas 2 utilisateurs qui s'appellent pareil. ??


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
        vo.id_organisme,
        FALSE

    FROM export_oo.v_utilisateurs_t_roles vr
    JOIN export_oo.v_organismes vo 
        ON (vr.champs_addi->>'id_structure')::int = vo.id_structure
    LEFT JOIN export_oo.v_roles vr2
        ON vr2.nom_role = vr.nom_role 
            AND vr2.prenom_role = vr.prenom_role
    WHERE vr2.nom_role IS NULL
;


-- gestion des droits (TODO affiner)

-- creation groupe Grp_observateur

--  - expert, amateur -> Grp_en_poste
--  - admin -> Grp_admin
--  - observ -> Grp_observateur


-- il y surement plus simple pour eviter d'ecrire 2 fois cette ligne.
-- mais il n'est pas possbile d'uiliser ON CONFLIT DO NOTHING en l'état.

INSERT INTO utilisateurs.t_roles(
    groupe,
    nom_role,
    identifiant,
    desc_role,
    remarques
    )
    SELECT TRUE, 'Grp_observateurs', 'Grp_observateurs', 'Tous les observateurs', 'Groupe d''observateurs sans droit (pour les listes)'
        FROM utilisateurs.t_roles r, (
		SELECT COUNT(*) AS cpt 
			FROM utilisateurs.t_roles r
			WHERE nom_role = 'Grp_observateurs'
	)a
     WHERE a.cpt = 0
     LIMIT 1;
;



INSERT INTO utilisateurs.cor_roles
(
    id_role_utilisateur,
    id_role_groupe
)
SELECT 
	r.id_role,
	CASE 
		WHEN champs_addi->>'role' IN ('expert', 'amateur', 'consult') THEN (SELECT id_role FROM utilisateurs.t_roles r WHERE r.nom_role = 'Grp_en_poste') 
		WHEN champs_addi->>'role' = 'admin' THEN (SELECT id_role FROM utilisateurs.t_roles r WHERE r.nom_role = 'Grp_admin') 
		WHEN champs_addi->>'role' = 'observ' THEN (SELECT id_role FROM utilisateurs.t_roles r WHERE r.nom_role = 'Grp_observateurs') 
	END
	FROM utilisateurs.t_roles r
	WHERE champs_addi->>'role' IS NOT NULL
ON CONFLICT DO NOTHING;
;



-- cor_actor_dataset
-- on met en production les organismes rencontrés dans exp

INSERT INTO gn_meta.cor_dataset_actor (id_dataset, id_organism, id_nomenclature_actor_role) 
SELECT id_dataset, o.id_organisme, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '6')
FROM export_oo.cor_dataset c
JOIN  utilisateurs.bib_organismes o
ON o.id_structure::text =  ANY(STRING_TO_ARRAY(c.ids_structure, '&'))
;


-- create list occtax ??

-- drop additional column
