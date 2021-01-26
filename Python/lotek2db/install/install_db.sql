CREATE SCHEMA bouquetin;

/************/ 
/* t_animal */ 
CREATE TABLE bouquetin.t_animal
(
    ani_id serial NOT NULL ,
    ani_nom character varying(32),
    ani_sexe character(1),
    ani_annee_naissance integer,
    ani_date_relache timestamp without time zone,
    ani_date_mort timestamp without time zone,
    ani_pop_rattach character varying(32),
    ani_marquage_oreille_droite character varying(32),
    ani_marquage_oreille_gauche character varying(32),
    ani_marquage_couleur_collier character varying(32),
    ani_marquage_code_collier character varying(32),
    ani_genetique character varying(32),
    ani_genotype character varying(32),
    ani_commentaire text,
    ani_date_saisie timestamp without time zone DEFAULT now(),
    ani_date_maj timestamp without time zone DEFAULT now(),
    ani_marquage_bande_laterale_collier character varying(32),
    CONSTRAINT pk_t_animal PRIMARY KEY (ani_id)
);

COMMENT ON COLUMN bouquetin.t_animal.ani_id
    IS 'Identifiant unique de l’animal généré automatiquement';

COMMENT ON COLUMN bouquetin.t_animal.ani_nom
    IS 'Nom attribué à l’animal';

COMMENT ON COLUMN bouquetin.t_animal.ani_sexe
    IS 'Indicateur du sexe de l’animal (M/F)';

COMMENT ON COLUMN bouquetin.t_animal.ani_annee_naissance
    IS 'Année  de naissance exact ou approximative de l’animal';

COMMENT ON COLUMN bouquetin.t_animal.ani_date_relache
    IS 'Date et heure de relâché de l’animal';

COMMENT ON COLUMN bouquetin.t_animal.ani_date_mort
    IS 'Date et heure exact ou approximative de mort de l’animal';

COMMENT ON COLUMN bouquetin.t_animal.ani_pop_rattach
    IS 'Population auquel l’animal relâché a été rattaché (Apse, Cauterets, Gèdre)';

COMMENT ON COLUMN bouquetin.t_animal.ani_marquage_oreille_droite
    IS 'Couleur du marquage appliqué sur l’oreille droite';

COMMENT ON COLUMN bouquetin.t_animal.ani_marquage_oreille_gauche
    IS 'Couleur du marquage appliqué sur l’oreille gauche';

COMMENT ON COLUMN bouquetin.t_animal.ani_marquage_couleur_collier
    IS 'Couleur du marquage appliqué sur le collier';

COMMENT ON COLUMN bouquetin.t_animal.ani_marquage_code_collier
    IS 'Lettres d’identification de l’animal inscrites sur le collier';

COMMENT ON COLUMN bouquetin.t_animal.ani_genetique
    IS 'Information génétique (ex : CP-PY-15-1633)';

COMMENT ON COLUMN bouquetin.t_animal.ani_genotype
    IS 'Information sur le génotype (ex : PP-15-1633)';

COMMENT ON COLUMN bouquetin.t_animal.ani_commentaire
    IS 'Commentaire libre sur l’animal (ex : état lors du relâché, condition de mort …)';

COMMENT ON COLUMN bouquetin.t_animal.ani_date_saisie
    IS 'Date et heure d’écriture de la ligne dans la table';

COMMENT ON COLUMN bouquetin.t_animal.ani_date_maj
    IS 'Date et heure de dernière modification de la ligne';

COMMENT ON COLUMN bouquetin.t_animal.ani_marquage_bande_laterale_collier
    IS 'Couleur de la bande latérale du collier';

/*************/ 
/* t_capteur */ 
CREATE TABLE bouquetin.t_capteur
(
    capt_id serial NOT NULL,
    capt_constructeur character varying(32),
    capt_id_constructeur character varying(32),
    capt_type character varying(32),
    capt_frequence character varying(8),
    capt_commentaire text,
    capt_date_saisie timestamp without time zone DEFAULT now(),
    capt_date_maj timestamp without time zone DEFAULT now(),
    capt_actif boolean,
    CONSTRAINT pk_t_capteur PRIMARY KEY (capt_id)
);

COMMENT ON COLUMN bouquetin.t_capteur.capt_id
    IS 'Identifiant unique du capteur généré automatiquement';

COMMENT ON COLUMN bouquetin.t_capteur.capt_constructeur
    IS 'Nom du constructeur';

COMMENT ON COLUMN bouquetin.t_capteur.capt_id_constructeur
    IS 'Identifiant du capteur chez le constructeur. Ce champ est très important car il permet de lier les données reçues chez le constructeur à la base de données';

COMMENT ON COLUMN bouquetin.t_capteur.capt_type
    IS 'Type de capteur (GPS/VHF)';

COMMENT ON COLUMN bouquetin.t_capteur.capt_frequence
    IS 'Fréquence émise par le capteur permettant de le localiser sur le terrain';

COMMENT ON COLUMN bouquetin.t_capteur.capt_commentaire
    IS 'Commentaire libre portant sur le capteur';

COMMENT ON COLUMN bouquetin.t_capteur.capt_date_saisie
    IS 'Date et heure d’écriture de la ligne dans la table';

COMMENT ON COLUMN bouquetin.t_capteur.capt_date_maj
    IS 'Date et heure de dernière modification de la ligne';

COMMENT ON COLUMN bouquetin.t_capteur.capt_actif
    IS 'Indique si le capteur est en activité (qu''il est posé sur un animal et qu''il fonctionne) ou non';

/**********************/ 
/* cor_animal_capteur */ 
CREATE TABLE bouquetin.cor_animal_capteur
(
    cor_id serial NOT NULL,
    ani_id integer NOT NULL,
    capt_id integer NOT NULL,
    cor_date_debut timestamp without time zone,
    cor_date_fin timestamp without time zone,
    cor_commentaire text,
    cor_date_saisie timestamp without time zone DEFAULT now(),
    cor_date_maj timestamp without time zone DEFAULT now(),
    CONSTRAINT pk_cor_animal_capteur PRIMARY KEY (cor_id),
    CONSTRAINT fk_cor_animal_capteur_ani_id FOREIGN KEY (ani_id)
        REFERENCES bouquetin.t_animal (ani_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fk_cor_animal_capteur_capt_id FOREIGN KEY (capt_id)
        REFERENCES bouquetin.t_capteur (capt_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

COMMENT ON COLUMN bouquetin.cor_animal_capteur.cor_id
    IS 'Identifiant unique du lien animal-capteur généré automatiquement';

COMMENT ON COLUMN bouquetin.cor_animal_capteur.ani_id
    IS 'Identifiant de l’animal';

COMMENT ON COLUMN bouquetin.cor_animal_capteur.capt_id
    IS 'Identifiant du capteur';

COMMENT ON COLUMN bouquetin.cor_animal_capteur.cor_date_debut
    IS 'Date et heure où le capteur est déposé sur l’animal';

COMMENT ON COLUMN bouquetin.cor_animal_capteur.cor_date_fin
    IS 'Date et heure où le capteur est retiré de l’animal';

COMMENT ON COLUMN bouquetin.cor_animal_capteur.cor_commentaire
    IS 'Commentaire libre';

COMMENT ON COLUMN bouquetin.cor_animal_capteur.cor_date_saisie
    IS 'Date et heure d’écriture de la ligne dans la table';

COMMENT ON COLUMN bouquetin.cor_animal_capteur.cor_date_maj
    IS 'Date et heure de dernière modification de la ligne';

/******************/ 
/* t_localisation */ 
CREATE TABLE bouquetin.t_localisation
(
    loc_id serial NOT NULL,
    capt_id integer,
    loc_long numeric,
    loc_lat numeric,
    geom geometry(Point,2154),
    loc_dop numeric,
    loc_altitude_capteur numeric,
    loc_anomalie boolean,
    loc_temperature_capteur numeric,
    loc_date_capteur_utc timestamp without time zone,
    loc_commentaire text,
    loc_date_saisie timestamp without time zone DEFAULT now(),
    loc_date_maj timestamp without time zone DEFAULT now(),
    CONSTRAINT pk_t_localisation PRIMARY KEY (loc_id),
    CONSTRAINT fk_t_localisation_capt_id FOREIGN KEY (capt_id)
        REFERENCES bouquetin.t_capteur (capt_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

COMMENT ON COLUMN bouquetin.t_localisation.loc_id
    IS 'Identifiant unique de la localisation';

COMMENT ON COLUMN bouquetin.t_localisation.capt_id
    IS 'Identifiant du capteur';

COMMENT ON COLUMN bouquetin.t_localisation.loc_long
    IS 'Longitude émise par le capteur';

COMMENT ON COLUMN bouquetin.t_localisation.loc_lat
    IS 'Latitude émise par le capteur';

COMMENT ON COLUMN bouquetin.t_localisation.geom
    IS 'Géométrie de la localisation projetée en Lambert93';

COMMENT ON COLUMN bouquetin.t_localisation.loc_dop
    IS 'Indication sur la qualité de la localisation (plus la valeur est élevé moins la localisation est bonne)';

COMMENT ON COLUMN bouquetin.t_localisation.loc_altitude_capteur
    IS 'Altitude indiquée par le capteur';

COMMENT ON COLUMN bouquetin.t_localisation.loc_anomalie
    IS 'Flag indiquant si le point est potentiellement aberrant au regard des autres localisations de ce capteur pour un animal spécifique';

COMMENT ON COLUMN bouquetin.t_localisation.loc_temperature_capteur
    IS 'Température extérieure indiquée par le capteur';

COMMENT ON COLUMN bouquetin.t_localisation.loc_date_capteur_utc
    IS 'Date et heure UTC d’émission de la localisation du capteur';

COMMENT ON COLUMN bouquetin.t_localisation.loc_commentaire
    IS 'Commentaire libre sur la localisation';

COMMENT ON COLUMN bouquetin.t_localisation.loc_date_saisie
    IS 'Date et heure d’écriture de la ligne dans la table';

COMMENT ON COLUMN bouquetin.t_localisation.loc_date_maj
    IS 'Date et heure de dernière modification de la ligne';

/************/ 
/* t_alerte */ 
CREATE TABLE bouquetin.t_alerte
(
    alert_id serial NOT NULL,
    capt_id integer,
    alert_type character varying(32),
    alert_long numeric,
    alert_lat numeric,
    geom geometry(Point,2154),
    alert_date timestamp without time zone,
    alert_commentaire text,
    alert_date_saisie timestamp without time zone DEFAULT now(),
    alert_date_maj timestamp without time zone DEFAULT now(),
    CONSTRAINT pk_t_alerte PRIMARY KEY (alert_id),
    CONSTRAINT fk_t_alert_capt_id FOREIGN KEY (capt_id)
        REFERENCES bouquetin.t_capteur (capt_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

COMMENT ON COLUMN bouquetin.t_alerte.alert_id
    IS 'Identifiant unique de l’alerte';

COMMENT ON COLUMN bouquetin.t_alerte.capt_id
    IS 'Identifiant du capteur';

COMMENT ON COLUMN bouquetin.t_alerte.alert_type
    IS 'Type d’alerte remonté par le capteur';

COMMENT ON COLUMN bouquetin.t_alerte.alert_long
    IS 'Longitude émise par le capteur au moment de l’alerte';

COMMENT ON COLUMN bouquetin.t_alerte.alert_lat
    IS 'Latitude émise par le capteur au moment de l’alerte';

COMMENT ON COLUMN bouquetin.t_alerte.geom
    IS 'Géométrie de la localisation au moment de l’alerte projeté en Lambert93';

COMMENT ON COLUMN bouquetin.t_alerte.alert_date
    IS 'Date et heure de l’alerte';

COMMENT ON COLUMN bouquetin.t_alerte.alert_commentaire
    IS 'Commentaire libre sur l’alerte';

COMMENT ON COLUMN bouquetin.t_alerte.alert_date_saisie
    IS 'Date et heure d’écriture de la ligne dans la table';

COMMENT ON COLUMN bouquetin.t_alerte.alert_date_maj
    IS 'Date et heure de dernière modification de la ligne';

/*********************/ 
/* v_animal_last_loc */ 
CREATE VIEW bouquetin.v_animal_last_loc
 AS
 SELECT DISTINCT ON (ani.ani_id) loc.loc_id,
    ani.ani_id,
    ani.ani_nom,
    ani.ani_pop_rattach,
    capt.capt_id,
    capt.capt_actif,
    capt.capt_frequence,
    capt.capt_constructeur,
    capt.capt_id_constructeur,
    loc.geom,
    loc.loc_dop,
    loc.loc_anomalie,
    loc.loc_altitude_capteur,
    loc.loc_temperature_capteur,
    timezone('Europe/Paris'::text, timezone('utc'::text, loc.loc_date_capteur_utc)) AS loc_date_local,
    loc.loc_date_capteur_utc AS loc_date_utc,
    loc.loc_commentaire
   FROM (((bouquetin.t_animal ani
     LEFT JOIN bouquetin.cor_animal_capteur cor ON ((ani.ani_id = cor.ani_id)))
     LEFT JOIN bouquetin.t_capteur capt ON ((cor.capt_id = capt.capt_id)))
     LEFT JOIN bouquetin.t_localisation loc ON (((capt.capt_id = loc.capt_id) AND (timezone('Europe/Paris'::text, timezone('utc'::text, loc.loc_date_capteur_utc)) >= cor.cor_date_debut) AND ((cor.cor_date_fin IS NULL) OR (timezone('Europe/Paris'::text, timezone('utc'::text, loc.loc_date_capteur_utc)) <= cor.cor_date_fin)))))
  ORDER BY ani.ani_id, loc.loc_date_capteur_utc DESC NULLS LAST;

/******************/ 
/* v_localisation */ 
CREATE OR REPLACE VIEW bouquetin.v_localisation
 AS
 SELECT loc.loc_id,
    ani.ani_id,
    ani.ani_nom,
    ani.ani_pop_rattach,
    capt.capt_id,
    capt.capt_actif,
    capt.capt_frequence,
    capt.capt_constructeur,
    capt.capt_id_constructeur,
    loc.geom,
    loc.loc_dop,
    loc.loc_anomalie,
    loc.loc_altitude_capteur,
    loc.loc_temperature_capteur,
    timezone('Europe/Paris'::text, timezone('utc'::text, loc.loc_date_capteur_utc)) AS loc_datetime_local,
    date(timezone('Europe/Paris'::text, timezone('utc'::text, loc.loc_date_capteur_utc))) AS loc_date_local,
    loc.loc_commentaire
   FROM (((bouquetin.t_animal ani
     LEFT JOIN bouquetin.cor_animal_capteur cor ON ((ani.ani_id = cor.ani_id)))
     LEFT JOIN bouquetin.t_capteur capt ON ((cor.capt_id = capt.capt_id)))
     LEFT JOIN bouquetin.t_localisation loc ON (((capt.capt_id = loc.capt_id) AND (timezone('Europe/Paris'::text, timezone('utc'::text, loc.loc_date_capteur_utc)) >= cor.cor_date_debut) AND ((cor.cor_date_fin IS NULL) OR (timezone('Europe/Paris'::text, timezone('utc'::text, loc.loc_date_capteur_utc)) <= cor.cor_date_fin)))))
  ORDER BY ani.ani_id, (timezone('Europe/Paris'::text, timezone('utc'::text, loc.loc_date_capteur_utc)));