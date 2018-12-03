--nbre de données PNE produites
SELECT COUNT(*) FROM synthese.syntheseff 
WHERE id_organisme = 2 AND supprime = false
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

-- nb d'obs par lot de donnees
SELECT count(*) nb_data, l.nom_lot
FROM synthese.syntheseff s
JOIN meta.bib_lots l ON l.id_lot = s.id_lot
WHERE supprime = false
GROUP BY l.nom_lot
ORDER BY nb_data desc;

-- nb d'obs par programme
SELECT count(*) nb_data, p.nom_programme, p.actif
FROM synthese.syntheseff s
JOIN meta.bib_lots l ON l.id_lot = s.id_lot
JOIN meta.bib_programmes p ON p.id_programme = l.id_programme
WHERE supprime = false
GROUP BY p.nom_programme, p.actif
ORDER BY nb_data desc;

-- nb d'obs par regne
SELECT count(*) nb_data, t.regne
FROM synthese.syntheseff s
JOIN taxonomie.taxref t ON t.cd_nom = s.cd_nom
WHERE s.supprime = false
GROUP BY t.regne;

-- nb de taxons par regne
SELECT count(*), a.regne FROM(
SELECT count(*) nb_data, t.regne, t.cd_nom
FROM synthese.syntheseff s
JOIN taxonomie.taxref t ON t.cd_nom = s.cd_nom
WHERE s.supprime = false
GROUP BY t.regne, t.cd_nom) a
GROUP BY a.regne;
