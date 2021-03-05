IMPORT FOREIGN SCHEMA utilisateurs FROM SERVER geonature1server INTO v1_compat;


-- organismes

INSERT INTO utilisateurs.bib_organismes(
  nom_organisme,
  adresse_organisme,
  cp_organisme,
  ville_organisme,
  tel_organisme,
  fax_organisme,
  email_organisme,
  id_organisme
  ) 
  SELECT
  nom_organisme,
  adresse_organisme,
  cp_organisme,
  ville_organisme,
  tel_organisme,
  fax_organisme,
  email_organisme,
  id_organisme
  FROM v1_compat.bib_organismes;


-- utilisateur

WITH champs_addi AS (
    SELECT id_role, nom_unite
    FROM v1_compat.t_roles r
    LEFT JOIN  v1_compat.bib_unites u
        ON r.id_unite = u.id_unite
)

INSERT INTO utilisateurs.t_roles (
    groupe,
    id_role,
    identifiant,
    nom_role,
    prenom_role,
    desc_role,
    pass,
	pass_plus,
    email,
    id_organisme,
    remarques,
    date_insert,
    date_update,
    uuid_role,
    champs_addi
    ) 
	SELECT
		groupe,
		r.id_role,
		identifiant,
		nom_role,
		prenom_role,
		desc_role,
		pass,
		pass,
		email,
		id_organisme,
		remarques,
		date_insert,
		date_update,
        uuid_generate_v4(),
        (CAST(to_json(ca) AS JSONB)) - 'id_role' AS champs_addi
    FROM v1_compat.t_roles r
    JOIN champs_addi ca ON ca.id_role = r.id_role  
    WHERE r.id_role NOT IN (1,2,3) -- partenaire, agent off
;

-- groupe en poste
WITH role_group AS (
SELECT 
    id_role AS id_role_utilisateur,
    CASE 
		WHEN r.id_role = 1 THEN (SELECT id_role FROM utilisateurs.t_roles r2 WHERE r2.nom_role = 'Grp_admin') 
		ELSE (SELECT id_role FROM utilisateurs.t_roles r2 WHERE r2.nom_role = 'Grp_en_poste') 
    END AS id_role_groupe
    FROM utilisateurs.t_roles r
)
INSERT INTO utilisateurs.cor_roles
(
    id_role_utilisateur,
    id_role_groupe
)
SELECT 
    id_role AS id_role_utilisateur,
     (SELECT id_role FROM utilisateurs.t_roles r2 WHERE r2.nom_role = 'Grp_en_poste') AS id_role_groupe
    FROM utilisateurs.t_roles r
    WHERE id_role > 100    
;
