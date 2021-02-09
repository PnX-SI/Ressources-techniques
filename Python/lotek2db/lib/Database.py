import psycopg2
import psycopg2.extras
import yaml

from .logger import Logger

class Database :

    def __init__(self):
        """ Initialisation de la connexion à la base de données """

        with open("config/config.yml", "r") as config_data:
            config = yaml.load(config_data, Loader=yaml.BaseLoader)

            dbName = config["database"]["dbName"]
            dbPort = str(config["database"]["dbPort"])
            dbUser = config["database"]["dbUser"]
            dbHost = config["database"]["dbHost"]
            dbPassword = config["database"]["dbPassword"]

        """ On ouvre une instance de logger """
        self.logger = Logger()

        try:
            connect_str = "dbname="+dbName+" port="+str(dbPort)+" user="+dbUser+" host="+dbHost+" password="+dbPassword
            """ Etablissement de la connexion """
            self.conn = psycopg2.connect(connect_str)
            """ Création d'un "curseur" permettant l'execution de requête """
            self.cursor = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        
        except Exception as e:
            self.logger.logError(
                code = "000", 
                message = "Impossible de se connecter à la base de données", 
                exception = e
            )

    def close(self):
        """ Fermeture la connexion """

        self.conn.cursor().close()
        self.conn.close()

    def selectCapteurs(self):
        """ Requête de récupération de la liste 
        des capteurs dont les données sont 
        à récupérer 
        Ne récupère que les capteurs LOTEK actif"""

        try:
            # Exécution d'un select
            self.cursor.execute("""SELECT 
                    vall.capt_id,
                    vall.capt_id_constructeur,
                    vall.loc_date_utc + interval '1 second' as loc_date_utc
                FROM 
                    bouquetin.v_animal_last_loc vall
                WHERE
                    vall.capt_constructeur = 'LOTEK'
                    AND vall.capt_actif = true
                """)
        except Exception as e:
            # Ecriture de l'erreur dans les logs
            self.logger.logError(
                code = "001",
                message = "Impossible de récupérer la liste des capteur dont les données doivent être récupéré",
                exception = e
            )
        return self.cursor.fetchall()

    def insertLocData(self, capt_id, loc_long, loc_lat, loc_dop, loc_altitude_capteur, loc_temperature_capteur, loc_date_capteur_utc):
        """ Requête d'insertion des données 
        possédant une localisation 
        longitude/latitude """

        try:
            self.cursor.execute("""
                INSERT INTO bouquetin.t_localisation(
                    capt_id,
                    loc_long,
                    loc_lat,
                    geom,
                    loc_dop,
                    loc_altitude_capteur,
                    loc_temperature_capteur,
                    loc_date_capteur_utc
                ) 
                VALUES (
                    %s, 
                    %s, 
                    %s, 
                    ST_Transform(ST_SetSRID(ST_MakePoint(%s, %s), 4326), 2154), 
                    %s, 
                    %s,
                    %s, 
                    %s
                )
                """, 
                (
                    capt_id,
                    loc_long,
                    loc_lat,
                    loc_long,
                    loc_lat,
                    loc_dop,
                    loc_altitude_capteur,
                    loc_temperature_capteur,
                    loc_date_capteur_utc,
                )
            )
            self.conn.commit()

        except Exception as e:
            # Ecriture de l'erreur dans les logs
            self.logger.logError(
                code = "003",
                message = "Erreur de l'insertion des données en base",
                exception = e
            )

    def insertNoLocData(self, capt_id, loc_dop, loc_altitude_capteur, loc_temperature_capteur, loc_date_capteur_utc, loc_commentaire, loc_anomalie):
        """ Requête d'insertion des données 
        ne possédant pas de localisation 
        longitude/latitude """

        try:
            self.cursor.execute("""
                INSERT INTO bouquetin.t_localisation(
                    capt_id,
                    loc_dop,
                    loc_altitude_capteur,
                    loc_temperature_capteur,
                    loc_date_capteur_utc,
                    loc_commentaire,
                    loc_anomalie
                ) 
                VALUES (
                    %s, 
                    %s, 
                    %s,
                    %s, 
                    %s, 
                    %s, 
                    %s )
                """, 
                (
                    capt_id,
                    loc_dop,
                    loc_altitude_capteur,
                    loc_temperature_capteur,
                    loc_date_capteur_utc,
                    loc_commentaire,
                    loc_anomalie
                )
            )

            self.conn.commit()

        except Exception as e:
            """ Ecriture de l'erreur dans les logs """
            self.logger.logError(
                code = "002",
                message = "Erreur lors de l'insertion des données sans longitude/latitude en base",
                exception = e
            )
    