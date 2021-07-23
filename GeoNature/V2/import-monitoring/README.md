# gn_suivi_import

Procédures pour insérer les données des protocoles de suivi (oedicnème et cheveches) / PNC / Amandine Sahl

## Chevêches

### FWD depuis la base chevêche

* Faire un dump du schema `cheveches` de la base `faune` du serveur `ip-serveur` dans le schema `import_cheveches`

Les FDW ne marchent pas pour ce schema => A priori si 

`ERROR: column "geo_object_nature" has pseudo-type unknown`

Peut être une modification à apporter au schema `cheveches` pour ne plus avoir cette erreur.

* Exécuter le fichier [fdw.sql ](./cheveches_group/fdw.sql)

Cela génère le schéma `import_vocabulaire_controle` qui contient la table `import_vocabulaire_controle.t_thesaurus`.

Ainsi que la table de correspondance avec les nomenclatures `import_cheveches.cor_nomenclature_resultat`

### Insertion des données dans le schéma gn_monitoring

* Exécuter le fichier [insert.sql ](./cheveches_group/insert.sql)

### Nettoyage : suppression données importées

* Exécuter le fichier [clean_fdw.sql ](./cheveches_group/clean_fdw.sql)

## Oedicnèmes

Veiller à ce que `ip-serveur` soit allumé pour avoir (pwd `toto;`)

### FDW depuis ip-serveur (base: geonature db)

* Exécuter le fichier [fdw.sql ](./oedic/fdw.sql)

### Ajout du dataset pour les oedicnèmes

* Exécuter le fichier [dataset.sql ](./oedic/dataset.sql)
*À déplacer dans l'install du module*

### Insertion des données dans le schéma gn_monitoring

* Executer le fichier [insert.sql ](./oedic/insert.sql)

### Nettoyage : suppression données importées

* Exécuter le fichier [clean_fdw.sql ](./oedic/clean_fdw.sql)
