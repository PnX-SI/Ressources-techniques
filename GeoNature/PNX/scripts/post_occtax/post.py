import requests
import json
from pathlib import Path
from config import URL_API_GEONATURE, LOGIN, PASSWORD, RELEVE_PATH

response = requests.post(URL_API_GEONATURE+ "/auth/login", json={"login": LOGIN, "password": PASSWORD})
if response.status_code != 200:
    raise Exception("Fail to authenticate" + str(response))
token = response.json()["token"]

headers = {"Authorization": f"Bearer {token}"}
response = requests.get(URL_API_GEONATURE + "/gn_commons/modules", headers=headers)
print(response.status_code)

pathlist = Path(RELEVE_PATH).glob('**/*.json')
for file in pathlist:
    with open(file) as f:
        releve = json.load(f)
        print(releve["id"])
        response = requests.post(URL_API_GEONATURE+"/occtax/releve", json=releve, headers=headers)
        print(response.status_code)
