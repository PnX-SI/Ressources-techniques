Etat des lieux des connaissances de biodiversite d'un territoire
================================================================

**Contexte**
Au PAG, on a de gros déficits de connaissance (selon groupes taxo) et de couverture du territoire (selon secteurs).
* Enjeux multiples: identifier secteurs à prospecter et groupes à cibler, localiser zones particulièrement sensibles, ... 
* Besoin d’un état des lieux des efforts de prospections, de la connaissance par groupe taxonomique et de la sensibilité de la biodiv connue. 
Le dashboard de GeoNature permet d'avoir un aperçu du nombre d'observations et du nombre d'espèces par mailles mais 1/ il nécessite de savoir utiliser GeoNature (et d'y avoir un compte) et 2/ il ne permet pas d'avoir un bilan des espèces à statuts, du nombre de jeux de données, etc.

**Processus**
1/ Dans pgAdmin: créer une à plusieurs vues permettant de synthétiser les données de synthèse sous forme de mailles
2/ Dans GeoNature > Administration > Export > Exports: créer un à plusieur exports publics sur la base de cette/ces vue/s
3/ Dans GeoNature > Administration > Export > Planification des exports: programmer les exports geojson
4/ Dans qGis ou LizMap: mobiliser ces geojson pour visualiser ces bilans maillés

**Données sources**
'requete-globale.sql': Permet de créer les requêtes sources dee ces vues maillées.
      -------------------------------------------------------- 
      1/ Vue matérialisée gn_exports.mv_grilles_territoire
      -------------------------------------------------------- 
      ==> grilles ne couvrant que la surface qui nous interresse (afin de soulager les requêtes de bilan si trop de données dans le ref_geo) 
      Pour adapter le script : Adapter l'emprise geo de la vue matérialisée gn_exports.mv_grilles_pag

      -------------------------------------------------------- 
      2/ Vue v_bilan_taxo_maille10x10_territoire et ses déclinaisons 
      -------------------------------------------------------- 
      ==> Informations maillées sur le territoire identifié, par groupe taxo. Statistiques par maille de 10km (total, protégé, etc). Détail selon groupe taxonomique (données validées, probables ou en attente de validation). Tous les jeux de données sont exploités (dont partenariaux). Les colonnes sont commentées (donc ok pour le swagger
      Pour adapter le script :
      - Adapter les filtres des statuts de protection selon les territoires 
      - Adapter le filtre des mailles selon échelle désirée
      - Filtrer par groupe taxonomique, etc

'requete-par-regne.sql' : Déclinaison par règne en 4 requêtes:
      -------------------------------------------------------- 
      Bilan des connaissances naturalistes (10x10km)
      -------------------------------------------------------- 
      Statistiques par maille de 10km (total, protégé, etc). Détail tous groupes taxonomiques confondus (données validées, probables ou en attente de validation). Tous les jeux de données sont exploités (dont partenariaux).
      
      -------------------------------------------------------- 
      Bilan des connaissances Animalia (10x10km)
      -------------------------------------------------------- 
      Statistiques par maille de 10km (total, protégé, etc). Détail selon groupe taxonomique (déclinaison sur group2_inpn pour les chordés, sinon Invertébrés) (données validées, probables ou en attente de validation). Tous les jeux de données sont exploités (dont partenariaux).
      
      -------------------------------------------------------- 
      Bilan des connaissances Plantae (10x10km)
      -------------------------------------------------------- 
      Statistiques par maille de 10km (total, protégé, etc). Détail selon groupe taxonomique (niveau group1_inpn) (données validées, probables ou en attente de validation). Tous les jeux de données sont exploités (dont partenariaux).
      
      -------------------------------------------------------- 
      Bilan des connaissances Fungi (10x10km)
      -------------------------------------------------------- 
      Statistiques par maille de 10km (total, protégé, etc). Détail selon groupe taxonomique (niveau group1_inpn)(données validées, probables ou en attente de validation). Tous les jeux de données sont exploités (dont partenariaux).

***** Exploitation carto ****************************************************************************************************
'dataviz_biostats_PAG.qgz': Exemple de fichier qGis d'exploitation
En utilisant le module "Lizmap" de qgis, les vues sont utilisées pour créer des cartes lizmap diffusables et à jour selon la périodicité des exports maillés.
