--nbre de données PNE produites
SELECT COUNT(*) FROM synthese.syntheseff WHERE id_organisme = 2
--par an
AND EXTRACT('year' FROM dateobs) = 2017
--limitation à un département
AND LEFT(insee,2) = '05'

--nb de taxons (cd_ref) observés par année par le PNE
SELECT y , count(*)
FROM (SELECT DISTINCT EXTRACT('year' FROM dateobs) as y, taxonomie.find_cdref(s.cd_nom) as cd_ref
 FROM synthese.syntheseff s 
 WHERE s.id_organisme = 2 
 AND supprime = false
 ORDER BY y
 ) a
GROUP BY y

-- nb de taxons connus pour une année n
WITH nby AS
(
 SELECT DISTINCT taxonomie.find_cdref(s.cd_nom) 
 FROM synthese.syntheseff s 
 WHERE s.id_organisme = 2 
 AND supprime = false
 AND EXTRACT('year' FROM dateobs) < 2012
) 
SELECT count(*) FROM nby
