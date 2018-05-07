-- Geotrek dispose de sa propre gestion interne des utilisateurs. Mais il est aussi capable de se connecter à une BDD externe 
-- pour récupérer les utilisateurs, leurs compte et mots de passe et leur niveau de droit. 
-- Voir la documentation sur le sujet : http://geotrek.readthedocs.io/en/master/advanced-configuration.html#external-authent
-- Voici la vue mise en place dans notre BDD mère de UsersHub à laquelle se connecte Geotrek pour la gestion des utilisateurs
-- Elle récupère les droits des utilisateurs et groupes qui ont des droits dans l'application Geotrek (id_application = 21 dans 
-- notre cas) et garde les droits maximaux trouvés. Elle associe aussi quelques utilisateurs partenaires à leur structure.

CREATE OR REPLACE VIEW utilisateurs.v_droits_sentiers AS 
 SELECT a.id_role,
    a.identifiant AS username,
    a.pass AS password,
    a.email,
    a.structure,
    a.lang,
    a.nom_role AS last_name,
    a.prenom_role AS first_name,
    max(a.id_droit) AS level,
    a.id_application,
    a.id_unite
   FROM ( SELECT u.id_role,
            u.identifiant,
            u.pass,
            u.email,
                CASE
                    WHEN u.id_role = ANY (ARRAY[1255, 1256]) THEN 'Maison-Tourisme-CHP-VLG'::text
                    WHEN u.id_role = ANY (ARRAY[1329, 1339, 1340]) THEN 'Pays des Ecrins (ComCom)'::text
                    ELSE 'PNE'::text
                END AS structure,
            'fr'::text AS lang,
            u.nom_role,
            u.prenom_role,
            c.id_droit,
            c.id_application,
            u.id_unite
           FROM utilisateurs.t_roles u
             JOIN utilisateurs.cor_role_droit_application c ON c.id_role = u.id_role
          WHERE c.id_application = 21 AND u.groupe = false
        UNION
         SELECT g.id_role_utilisateur,
            u.identifiant,
            u.pass,
            u.email,
                CASE
                    WHEN u.id_role = ANY (ARRAY[1255, 1256]) THEN 'Maison-Tourisme-CHP-VLG'::text
                    WHEN u.id_role = ANY (ARRAY[1329, 1339, 1340]) THEN 'Pays des Ecrins (ComCom)'::text
                    ELSE 'PNE'::text
                END AS structure,
            'fr'::text AS lang,
            u.nom_role,
            u.prenom_role,
            c.id_droit,
            c.id_application,
            u.id_unite
           FROM utilisateurs.t_roles u
             JOIN utilisateurs.cor_roles g ON g.id_role_utilisateur = u.id_role
             JOIN utilisateurs.cor_role_droit_application c ON c.id_role = g.id_role_groupe
          WHERE c.id_application = 21 AND u.groupe = false) a
  GROUP BY a.id_role, a.identifiant, a.email, a.pass, a.structure, a.lang, a.nom_role, a.prenom_role, a.id_application, a.id_unite;

GRANT SELECT ON TABLE utilisateurs.v_droits_sentiers TO mon-user-geotrek-lecteur;
