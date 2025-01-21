# Etat des lieux des connaissances de biodiversite d'un territoire

## Contexte

Au PAG, on a de gros déficits de connaissance (selon groupes taxos) et de couverture du territoire (selon secteurs).
* Enjeux multiples : identifier secteurs à prospecter et groupes à cibler, localiser zones particulièrement sensibles, ... 
* Besoin d’un état des lieux des efforts de prospections, de la connaissance par groupe taxonomique et de la sensibilité de la biodiversité connue.
  
Le module Dashboard de GeoNature permet d'avoir un aperçu du nombre d'observations et du nombre d'espèces par mailles mais 1/ il nécessite de savoir utiliser GeoNature (et d'y avoir un compte) et 2/ il ne permet pas d'avoir un bilan des espèces à statuts, du nombre de jeux de données, etc.

On va donc utiliser le module Export de GeoNature, pour créer des exports de synthèse par maille sur mesure, et les générer automatiquement chaque nuit pour que le fichier GeoJSON disponible sur une URL fixe soit mis à jour quotidiennement (https://github.com/PnX-SI/gn_module_export?tab=readme-ov-file#export-planifi%C3%A9).  
On va ensuite créer des projets carto avec QGIS, Lizmap ou autre qui interrogent directement ce fichier GeoJSON distant mis à jour automatiquement chaque nuit.  
On aurait pu aussi interroger directement les vues de la BDD de PostgreSQL avec QGIS et/ou Lizmap, mais dans notre cas, on préfère s'appuyer sur des fichiers distants et ne pas interroger directement la BDD.

## Processus

1. Dans pgAdmin : créer une à plusieurs vues permettant de synthétiser les données de synthèse sous forme de mailles
2. Dans GeoNature > Administration > Export > Exports : créer un à plusieurs exports publics sur la base de cette/ces vue/s
3. Dans GeoNature > Administration > Export > Planification des exports : programmer les exports GeoJSON pour que le fichier soit regénéré et mis à jour automatiquement chaque nuit
4. Dans QGIS ou LizMap : mobiliser ces fichiers GeoJSON pour visualiser ces bilans maillés

![image](https://github.com/user-attachments/assets/3f8dc3f2-b966-4541-8771-58d990721b70)

## Données sources

`requete-globale.sql` : Permet de créer les requêtes sources de ces vues maillées.

1. Vue matérialisée `gn_exports.mv_grilles_territoire`  
   ==> grilles ne couvrant que la partie du territoire qui nous interresse (afin de soulager les requêtes de bilan si trop de données dans le ref_geo)  
   Pour adapter le script : Adapter l'emprise geo de la vue matérialisée `gn_exports.mv_grilles_territoire`

2. Vue `v_bilan_taxo_maille10x10_territoire` et ses déclinaisons  
   ==> Informations maillées sur le territoire identifié, par groupe taxo. Statistiques par maille de 10km (total, protégé, etc). Détail selon groupe taxonomique (données validées, probables ou en attente de validation). Tous les jeux de données sont exploités (dont partenariaux). Les colonnes sont commentées (donc OK pour le swagger)  
   Pour adapter le script :  
   - Adapter les filtres des statuts de protection selon les territoires
   - Adapter le filtre des mailles selon échelle désirée
   - Filtrer par groupe taxonomique, par organisme, JDD, etc

`requete-par-regne.sql` : Déclinaison par règne en 4 requêtes :

1. Bilan des connaissances naturalistes (10x10km)  
   Statistiques par maille de 10km (total, protégé, etc). Détail tous groupes taxonomiques confondus (données validées, probables ou en attente de validation). Tous les jeux de données sont exploités (dont partenariaux).
      
2. Bilan des connaissances Animalia (10x10km)  
   Statistiques par maille de 10km (total, protégé, etc). Détail selon groupe taxonomique (déclinaison sur group2_inpn pour les chordés, sinon Invertébrés) (données validées, probables ou en attente de validation). Tous les jeux de données sont exploités (dont partenariaux).

3. Bilan des connaissances Plantae (10x10km)  
   Statistiques par maille de 10km (total, protégé, etc). Détail selon groupe taxonomique (niveau group1_inpn) (données validées, probables ou en attente de validation). Tous les jeux de données sont exploités (dont partenariaux).
      
4. Bilan des connaissances Fungi (10x10km)  
   Statistiques par maille de 10km (total, protégé, etc). Détail selon groupe taxonomique (niveau group1_inpn)(données validées, probables ou en attente de validation). Tous les jeux de données sont exploités (dont partenariaux).

## Exploitation carto

`dataviz_biostats_PAG.qgz` : Exemple de fichier QGIS d'exploitation.  
En utilisant le module "Lizmap" de QGIS, on va interroger directement les fichiers GeoJSON générés automatiquement à partir des vues dans la BDD GeoNature. Et ainsi créer des cartes Lizmap diffusables et à jour selon la périodicité des exports maillés.

Exemple de projet QGIS/Lizmap interrogeant le GeoNature du PAG (consultable sur le Lizmap https://cartotheque.guyane-parcnational.fr).

![image](https://github.com/user-attachments/assets/ef37004f-09d1-4af2-b5e7-153bb7e11c11)

_Global : nb jours où données (approche « effort d’inventaire »)_
![image](https://github.com/user-attachments/assets/3a1b8065-02cb-45be-a1cd-b4d6fd0801e4)

_Mammifères : nb espèces_
![image](https://github.com/user-attachments/assets/1a81ae0b-bc60-4674-b541-5398823fab98)

_Plantes vasculaires :  ratio nb espèces protégées/nb espèces_
![image](https://github.com/user-attachments/assets/05df2ff9-879b-4ab1-974a-c9aab56ebafb)

Cela fonctionne en lançant les requêtes de création des vues (un peu adaptées) sur une autre BDD GeoNature : exemple au PNE en interrogeant le fichier GeoJSON distant et mis à jour automatiquement chaque nuit (https://geonature.ecrins-parcnational.fr/api/media/exports/schedules/Bilans_mailles_1010.geojson)

![image](https://github.com/user-attachments/assets/ac778445-2b5b-4191-93f8-45f2e67a4035)
