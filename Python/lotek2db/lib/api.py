from datetime import datetime
import json
import requests
import yaml

from .logger import Logger


class Api:


    def __init__(self):
        """ Requete d'authentification à l'API
        Sauvearde du token sous la forme d'un header http """
        with open("config/config.yml", "r") as config_data:
            config = yaml.load(config_data, Loader=yaml.BaseLoader)

            apiUser = config["api"]["apiUser"]
            apiPassword = config["api"]["apiPassword"]

        # On ouvre une instance de logger
        self.logger = Logger()

        # Authentificartion 'LOTEK'
        bodyContent = {'grant_type': 'password', 'username' : apiUser, 'password': apiPassword}
        response = requests.post("https://webservice.lotek.com/API/user/login", data = bodyContent)

        if response.status_code != 200:
            self.logger.logError(
                code = "100",
                message = "Erreur lors de l'authentification sur l'API LOTEK",
                exception = response.json()
            )

        # Récupération du Token et construction du header
        token = response.json()['access_token']
        self.headers = {'Authorization': 'bearer ' + token}


    def getlocalisation(self, deviceId, dtStart):
        """ Récupération des localisations via l'API
        pour un capteur donné (device_id) et de la date de 
        dernière localisation (dtStart)""" 
        responses = requests.get('https://webservice.lotek.com/API/gps?deviceId=' + deviceId + '&dtStart=' + dtStart, headers = self.headers)
        if responses.status_code != 200:
            self.logError(
                code = "100",
                message = "Erreur lors de l'authentification sur l'API LOTEK",
                exception = response.json()
            )
        return responses.json()