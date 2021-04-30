-- organismes
INSERT INTO utilisateurs.bib_organismes(
  nom_organisme, adresse_organisme, cp_organisme, ville_organisme, tel_organisme, fax_organisme, email_organisme, id_organisme ) 
  SELECT nom_organisme, adresse_organisme, cp_organisme, ville_organisme, tel_organisme, fax_organisme, email_organisme, id_organisme
  FROM v1_compat.bib_organismes;


-- utilisateur
WITH champs_addi AS (
    SELECT id_role, nom_unite
    FROM v1_compat.t_roles r
    LEFT JOIN  v1_compat.bib_unites u
        ON r.id_unite = u.id_unite)

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
    champs_addi ) 
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


---- Ajout de qq utilisateurs utiles pour l'insertion des données
INSERT INTO utilisateurs.t_roles values 
	(false, 1000055, uuid_generate_v4(), 'omorillas', 'Morillas', 'Olivier', null, null, null, null, 3, 'Ajout pour historique Contact Faune', false, null,now(), now()),
	(false, 1000056, uuid_generate_v4(), 'seda', 'Eda', 'Steven', null, null, null, null, 3, 'Ajout pour historique Contact Faune', false, null,now(), now()),
	(false, 1000057, uuid_generate_v4(), 'ajenge', 'Jenge', 'August', null, null, null, null, 3, 'Ajout pour historique Contact Faune', false, null,now(), now()),
	(false, 1000058, uuid_generate_v4(), 'fponsmoreau', 'Pons-Moreau', 'Fabien', null, null, null, null, 3, 'Ajout pour historique Contact Faune', false, null,now(), now()),
	(false, 1000059, uuid_generate_v4(), 'dbagadi', 'Bagadi', 'Daniel', null, null, null, null, 3, 'Ajout pour historique Contact Faune', true, null,now(), now()),
	(true, 8, uuid_generate_v4(), 		null, 		'Grp_ext', null, 'Personnes extérieures', null, null, null, null, 'Personnes extérieures ayant les droits de saisie', true, null,now(), now()),
	(true, 11, uuid_generate_v4(), 		null, 		'Grp_valid', null, 'Groupe restreint de validateurs', null, null, null, null, 'Groupe à droits restreints pour la validation des données', true, null,now(), now())
;
DELETE FROM utilisateurs.t_roles WHERE id_role in (20002, 1000042, 1000043);
UPDATE utilisateurs.t_roles SET nom_role = 'Scellier' where nom_role = 'Mathoulin-Scellier';
UPDATE utilisateurs.t_roles SET id_role = 10, nom_role = 'Grp_admin_taxo', id_organisme = 3  where nom_role = 'grp_admin_taxo';
UPDATE utilisateurs.t_roles SET id_organisme = 3  where id_role in (7,9,10);
UPDATE utilisateurs.bib_organismes SET nom_organisme = 'Divers' where nom_organisme = 'ALL';

--- tri
DELETE FROM utilisateurs.bib_organismes where id_organisme in (1,2,99);
SELECT setval('utilisateurs.bib_organismes_id_organisme_seq', (SELECT MAX(id_organisme) FROM utilisateurs.bib_organismes)+1);
INSERT INTO utilisateurs.bib_organismes(nom_organisme)
	VALUES ('Asso GEPOG'),
		('DEAL de Guyane'),
		('LabEx CEBA'),
		('CNRS-ISEM'),
		('ONCFS');
		
-- groupe en poste
INSERT INTO utilisateurs.cor_roles (id_role_groupe,id_role_utilisateur)
	SELECT 7, id_role FROM utilisateurs.t_roles WHERE (id_role >= 1000000 and id_organisme = 3) OR id_role = 2  -- le groupe en poste
	UNION SELECT 8, id_role FROM utilisateurs.t_roles WHERE id_role = 3 -- les partenaires
	UNION SELECT 9, id_role FROM utilisateurs.t_roles WHERE id_role in (1,1000052) -- les admin: administrateur + audrey
	UNION SELECT 10, id_role FROM utilisateurs.t_roles WHERE id_role in (1,1000052,1000016) -- les admin taxo: administrateur + audrey + seb
	UNION SELECT 11, id_role FROM utilisateurs.t_roles WHERE id_role in (1,1000052,5); -- les valdateurs: administrateur + audrey + validateur