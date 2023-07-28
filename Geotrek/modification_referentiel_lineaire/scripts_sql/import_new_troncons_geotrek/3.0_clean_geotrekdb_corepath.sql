---------- SUPPRESSION DES TABLES CRÉÉES PENDANT LE PROCESSUS D'IMPORT

DROP TABLE IF EXISTS core_path_wip_new;
DROP TABLE IF EXISTS core_pathaggregation_to_insert;
DROP TABLE IF EXISTS core_pathaggregation_new;
-- DROP TABLE IF EXISTS core_topology_ante; -- à décommenter si on souhaite réellement supprimer la sauvegarde des anciennes topologies
