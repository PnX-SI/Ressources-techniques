--------------------------------- Initialisation des permissions/droits
-----------------------------------------------------------------------

--------------------------------- Droits d'accès aux 3 applications 1UH 2TH 3GN pour les 5 groupes:
	--7/ Grp_en_poste
	--8/ Grp_ext
	--9/ Grp_admin
	--10/ Grp_admin_taxo
	--11/ Grp_valid
-- avant modification:	id_role, id_application, id_profil, is_default_group_for_app
--						7, 		3, 				1, 			true
--						9, 		1, 				6, 			false
--						9, 		2, 				6, 			false
--						9, 		3, 				1, 			false
DELETE FROM utilisateurs.cor_role_app_profil;
INSERT INTO utilisateurs.cor_role_app_profil(id_role, id_application, id_profil, is_default_group_for_app)
	SELECT id_role, 3 as id_application , 1 as id_profil,  -- Tous les groupes peuvent accéder à GN en tant que lecteur
		CASE WHEN id_role = 7 THEN true
			ELSE false
			END	as is_default_group_for_app 
		FROM utilisateurs.t_roles 
		WHERE groupe = true 
	UNION SELECT id_role, 2 as id_application, 6 as id_profil, false as is_default_group_for_app -- les admin et admin_taxo ont droit d'accès à TaxHub...
		FROM utilisateurs.t_roles 
		WHERE groupe = true AND id_role in (9,10)
	UNION SELECT id_role, 2 as id_application, 0 as id_profil, false as is_default_group_for_app -- ...mais pas les autres
		FROM utilisateurs.t_roles 
		WHERE groupe = true AND id_role not in (9,10)
	UNION SELECT id_role, 1 as id_application ,  -- seul des admin ont droit d'accès à userHub
		CASE WHEN id_role = 9 then 6
			ELSE 0 
			END as id_profil, false as is_default_group_for_app 
		FROM utilisateurs.t_roles 
		WHERE groupe = true
		ORDER BY id_role, id_application, id_profil; 
	
--------------------------------- Permissions pour les 3 premiers modules
	--0/ GEONATURE
	--1/ ADMIN
	--2/ METADATA
	--3/ SYNTHESE
	--4/ OCCTAX
	--5/ OCCHAB
	--6/ VALIDATION	

DELETE FROM gn_permissions.cor_role_action_filter_module_object;
SELECT setval('gn_permissions.cor_role_action_filter_module_object_id_permission_seq', 1);

INSERT INTO gn_permissions.cor_role_action_filter_module_object (id_role, id_action, id_filter, id_module, id_object)
    VALUES 
        (7, 1, 4, 0, 1),
        (7, 2, 3, 0, 1),
        (7, 3, 2, 0, 1),
        (7, 4, 1, 0, 1),
        (7, 5, 3, 0, 1),
        (7, 6, 2, 0, 1),
        (7, 1, 1, 1, 1),
        (7, 2, 1, 1, 1),
        (7, 3, 1, 1, 1),
        (7, 4, 1, 1, 1),
        (7, 5, 1, 1, 1),
        (7, 6, 1, 1, 1),
        (7, 1, 1, 2, 1),
        (7, 2, 3, 2, 1),
        (7, 3, 1, 2, 1),
        (7, 4, 1, 2, 1),
        (7, 5, 3, 2, 1),
        (7, 6, 1, 2, 1),
        (8, 1, 3, 0, 1),
        (8, 2, 3, 0, 1),
        (8, 3, 2, 0, 1),
        (8, 4, 1, 0, 1),
        (8, 5, 3, 0, 1),
        (8, 6, 2, 0, 1),
        (8, 1, 1, 1, 1),
        (8, 2, 1, 1, 1),
        (8, 3, 1, 1, 1),
        (8, 4, 1, 1, 1),
        (8, 5, 1, 1, 1),
        (8, 6, 1, 1, 1),
        (8, 1, 1, 2, 1),
        (8, 2, 3, 2, 1),
        (8, 3, 1, 2, 1),
        (8, 4, 1, 2, 1),
        (8, 5, 3, 2, 1),
        (8, 6, 1, 2, 1),
        (9, 1, 4, 0, 1),
        (9, 2, 4, 0, 1),
        (9, 3, 4, 0, 1),
        (9, 4, 4, 0, 1),
        (9, 5, 4, 0, 1),
        (9, 6, 4, 0, 1),
        (9, 1, 4, 1, 3),
        (9, 1, 4, 1, 2),
        (9, 1, 4, 1, 1),
        (9, 2, 4, 1, 3),
        (9, 2, 4, 1, 2),
        (9, 2, 4, 1, 1),
        (9, 3, 4, 1, 2),
        (9, 3, 4, 1, 3),
        (9, 3, 4, 1, 1),
        (9, 4, 4, 1, 1),
        (9, 4, 4, 1, 3),
        (9, 4, 4, 1, 2),
        (9, 5, 4, 1, 1),
        (9, 5, 4, 1, 3),
        (9, 5, 4, 1, 2),
        (9, 6, 4, 1, 3),
        (9, 6, 4, 1, 1),
        (9, 6, 4, 1, 2),
        (9, 1, 4, 2, 1),
        (9, 2, 4, 2, 1),
        (9, 3, 4, 2, 1),
        (9, 4, 4, 2, 1),
        (9, 5, 4, 2, 1),
        (9, 6, 4, 2, 1),
        (10, 1, 3, 0, 1),
        (10, 2, 4, 0, 1),
        (10, 3, 3, 0, 1),
        (10, 4, 1, 0, 1),
        (10, 5, 4, 0, 1),
        (10, 6, 3, 0, 1),
        (10, 1, 1, 1, 1),
        (10, 2, 1, 1, 1),
        (10, 3, 1, 1, 1),
        (10, 4, 1, 1, 1),
        (10, 5, 1, 1, 1),
        (10, 6, 1, 1, 1),
        (10, 1, 3, 2, 1),
        (10, 2, 4, 2, 1),
        (10, 3, 3, 2, 1),
        (10, 4, 3, 2, 1),
        (10, 5, 4, 2, 1),
        (10, 6, 3, 2, 1),
        (11, 4, 4, 0, 1)
;
DELETE FROM gn_permissions.cor_filter_type_module;
INSERT INTO gn_permissions.cor_filter_type_module (id_filter_type, id_module)
	SELECT t_filters.id_filter_type, cor_role_action_filter_module_object.id_module
	FROM gn_permissions.cor_role_action_filter_module_object
		INNER JOIN gn_permissions.t_filters on cor_role_action_filter_module_object.id_filter = t_filters.id_filter
			INNER JOIN gn_permissions.bib_filters_type ON t_filters.id_filter_type = bib_filters_type .id_filter_type
		INNER JOIN gn_commons.t_modules on cor_role_action_filter_module_object.id_module = t_modules.id_module
	GROUP BY cor_role_action_filter_module_object.id_module, module_code,
		t_filters.id_filter_type, label_filter_type
	ORDER BY cor_role_action_filter_module_object.id_module,t_filters.id_filter_type;
	
-- checkup_permissions
SELECT cor_role_action_filter_module_object.id_role, nom_role, 
		cor_role_action_filter_module_object.id_action, description_action, 
		cor_role_action_filter_module_object.id_filter, label_filter,
		cor_role_action_filter_module_object.id_module, module_code,
		cor_role_action_filter_module_object.id_object, code_object
	FROM gn_permissions.cor_role_action_filter_module_object
		INNER JOIN utilisateurs.t_roles on cor_role_action_filter_module_object.id_role = t_roles.id_role
		INNER JOIN gn_permissions.t_actions on cor_role_action_filter_module_object.id_action = t_actions.id_action
		INNER JOIN gn_permissions.t_filters on cor_role_action_filter_module_object.id_filter = t_filters.id_filter
		INNER JOIN gn_commons.t_modules on cor_role_action_filter_module_object.id_module = t_modules.id_module
		INNER JOIN gn_permissions.t_objects ON cor_role_action_filter_module_object.id_object = t_objects.id_object
	ORDER BY cor_role_action_filter_module_object.id_role, cor_role_action_filter_module_object.id_module,cor_role_action_filter_module_object.id_action;