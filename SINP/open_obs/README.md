## Récupération des données à la maille de 10 km

L'url `https://odata-inpn.mnhn.fr/geometries/grids/taxon/${cd_ref}` permet de récupérer les données d'observation à la maille de 10km.

Exemple de script permettant de récupérer les données dans un fichier geojson à partir d'une liste de cd_ref et de les concaténer dans un gpkg

```sh
mkdir -p /tmp/data_oobs
#rm -r /tmp/data_oobs/*
rm /tmp/data_oobs_cd_ref.gpkg

while read p; do
  echo "Get $p"
  ogr2ogr -f GEOJSON /tmp/data_oobs/${p}.geojson https://odata-inpn.mnhn.fr/geometries/grids/taxon/${p}
  ogr2ogr -f GPKG -append -s_srs EPSG:2154 -t_srs EPSG:2154 /tmp/data_oobs_cd_ref.gpkg -nln data -sql "SELECT *, ${p} as cd_ref FROM \"${p}\"" /tmp/data_oobs/${p}.geojson
done <cd_ref.txt 

```
