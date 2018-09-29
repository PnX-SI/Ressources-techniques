Script de migration de données de SICEN/Obs Occ vers GeoNature V2
-----------------------------------------------------------------

--- Lancement du script

- Les scripts doivent être lancés dans l'ordre
- Les scripts préfixés par obs_occ doivent être lancés dans la BDD obs_occ
- Les scripts préfixés par gn2 doivent être lancés dans la base

--- Modifications à réaliser

- ``1.0_gn2_create_fdw_obs_occ.sql`` : Modifier les paramètres de connexion à la BDD PostgreSQK d'obs_occ/SICEN
- ``1.1_gn2_mapping_nomenclature.sql`` : Si les types de valeurs ont été modifiées dans obs_occ/SICEN => modifier/adapter le script au besoin
- ``2.1_gn2_import_obs_occ_data.sql`` : Modifier le calcul de la bounding box (pour le moment périmètre du PN). Modifier les données créées dans ``gn_synthese.t_sources``

Ligne 118 : modifier le nom de la source si elle à été modifiée précédement par défaut ``name_source= 'obs_occ'``

Si les utilisateurs ne sont pas déjà importés dans le schéma utilisateurs et/ou que les identifiants ne sont pas les mêmes entre obs_occ et la BDD UsersHub, désactiver les lignes : 112 -> 122
