## Utilisation des rasters dans PostGIS

Utilisation d'un service `bd_png_new` et création d'une table `mnt` dans le schéma `alti`.

### Création de la table MNT
```sql
CREATE TABLE alti.mnt(rid serial primary key, rast raster);
CREATE INDEX alti_mnt_rast_st_convexhull_idx ON alti.mnt USING gist( ST_ConvexHull(rast) );
```

### Import

```bash
for file in *.asc; do
    [ -e "$file" ] || continue
    raster2pgsql -a -s 2989 -C -x "$file" alti.mnt | PGPASS='PASSWORD' psql "service=png"
done
```

### Function d'altitude

```sql
DROP FUNCTION IF EXISTS altitude(pos geometry) ;
CREATE OR REPLACE FUNCTION altitude(pos geometry) 
  RETURNS float AS
$func$
BEGIN
  RETURN (
    SELECT cast(ST_Value(mnt.rast, ST_Transform(ST_SetSRID(pos,32620),2989)) as integer)
    FROM alti.mnt
    WHERE ST_Intersects(mnt.rast, ST_Transform(ST_SetSRID(pos,32620),2989))
  );
END
$func$ LANGUAGE plpgsql;
```

Usage:
```sql
SELECT altitude(ST_PointFromText('POINT(644943 1777598)', 32620));
```
retourne: `793`
