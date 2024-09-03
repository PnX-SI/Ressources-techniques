Fonction permettant de transformer une chane de caractère structurée en LineString.

Exemple d'utilisation :
```
select postgis.coordinates_in_text_array_to_linestring ('[[0.178628,43.058271,0],[0.179017,43.059808,0],[0.178811,43.061006,0],[0.17873,43.062122,0],[0.177398,43.06347,0],[0.176011,43.065702,0],[0.17541,43.067678,0],[0.175497,43.068869,0],[0.176441,43.069715,0],[0.175188,43.071057,0],[0.17448,43.072656,0],[0.174896,43.074261,0],[0.175124,43.075697,0],[0.176719,43.076376,0]]')
```

Usage : 
Avec ODK, la géométrie d'une ligne récupérée par central2pg est sous un format textuel [[x1, y1, z1], [x2, y2, z2], [x3, y3, z3], ...]
Cette fonction permet de traduire ce texte en ligne postgis
