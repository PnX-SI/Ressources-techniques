-- clean data

-- user


DELETE FROM utilisateurs.t_roles WHERE id_role > 100;

DELETE FROM gn_meta.cor_dataset_actor WHERE id_organism > 0;

-- on garde autre (-1) et all (0)
DELETE FROM utilisateurs.bib_organismes WHERE id_organisme > 0;