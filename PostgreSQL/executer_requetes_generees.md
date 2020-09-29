# Execution de sql généré par une requête

idée : écrire une requête qui génère du sql et exécuter ce même sql 


```
-- exemple modification d'un mot de passe des foreigns data wrapper
DO
$$
DECLARE
   rec   record;
BEGIN
   FOR rec IN
      SELECT concat('ALTER USER MAPPING FOR ', usename , ' SERVER ', srvname, ' OPTIONS (SET password ''mon_nouveau_pass'');') AS sql
		FROM pg_user_mappings
		WHERE 'password=mon_ancien_pass' = ANY (umoptions)
   LOOP
      raise notice ' %', rec.sql;
      EXECUTE rec.sql;
   END LOOP;
END
$$;
-- Mise à jour des vm
DO
$$
DECLARE
   rec   record;
BEGIN
   FOR rec IN
      SELECT concat('REFRESH MATERIALIZED VIEW ', schemaname, '.', matviewname, ';') AS sql
		FROM pg_catalog.pg_matviews 
		ORDER BY schemaname, matviewname
   LOOP
      raise notice ' %', rec.sql;
      EXECUTE rec.sql;
   END LOOP;
END
$$;
```
