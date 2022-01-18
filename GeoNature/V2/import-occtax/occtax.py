import requests
import json
import psycopg2
import re
from datetime import date
from datetime import datetime

import sys
'''
OCCTAX.py
    on utilise les donnees synthese pour generer un releve + taxons et la synthese correspondante

    On utilise des lignes identiques à synthese

    - Ajout de releves + synthese à partir de ligne synthese dans table synthese_ajout
    
    Permet la création dans gn_synthese.synthese mais en permettant la modification dans OCCTAX

    2 cas si ligne synthese déjà existantes (import historique), on supprime dans synthese sinon ajout simple (import)
    
    Auteur : Cistude Nature
    Création : 04/01/2022
    Modifications :
    18/01/2022 : ajout colonne dans la comment_ref dans la table ajout ==> change la colonne pour GEOM
                 cette colonne sert seulement de reference. Pas utilisée dans les APIS    
    Entrée : tables dans schéma gn_synthese et utilisateurs
    synthese_ajout : clone des lignes synthese pour ajot ou maj
    synthese_maj   : trace des actions effectuées. Permet de ne pas retraiter les lignes déjà intégrées
    t_roles        : récupération user générique pour l'import : imp_geo

'''

# Coord sous la forme 'POINT(-0.922644 -44.924)'
def getPoints(coord) : # recupere les coordonnees geometriques
    # retour tableau de nombre
    return [float(s) for s in re.findall(r'-?\d+\.?\d*',coord)]

def majSynthese(curMaj,id_synthese,id_grp,id_releve, id_ajout): # Met à jour la table synthese et synthese_maj
    try:
      if (id_synthese is not None):
        action='S'
        curMaj.execute("delete from gn_synthese.synthese where id_synthese = %s",(id_synthese,))
      else:
        action='A'

      curMaj.execute("INSERT INTO gn_synthese.synthese_maj VALUES (%s, %s, %s, %s,%s)", (id_ajout,id_releve,id_grp,action,str(datetime.today())))
    except (Exception, psycopg2.DatabaseError) as error:
        print("ERREUR : id_synthese [" + str(id_synthese) +"] ligne traitee id="+ str(id_ajout) + " id_releve=["+str(id_releve)+"]" )
        print (error)
    
def getUserimport(curMaj):
  # retourne l'id de l'utilisateur import_geo
  curMaj.execute("select id_role from utilisateurs.t_roles where identifiant='imp_geo'")
  
  row = curMaj.fetchone()
  
  if row is not None:
     return row[0]
  else:
    return -1

'''
 *************************************
   DEBUT DU PROGRAMME
   valeurs par defaut du script
 *************************************
'''
#utilisateur connexion base de donnée
str_login='<user base>'
str_password='<password base>'

#Password de geonatadmin
str_dbPass='<password geonatadmin>'

#host : locahost ou adresse ip serveur base de donnée
# valeur modifie par paramétres 1 : host 2: serveur api
str_host='<IP HOST>'
#nom réseau du serveur
str_apiServ='<NOM RESEAU SERVEUR GEONATURE>'

# Récupération des arguments 
if (len(sys.argv) > 1 ):
   if len(sys.argv) <3:
       print('2 arguments : host & serveur Api')
       sys.exit(-1)
   str_host=sys.argv[1]
   str_apiServ=sys.argv[2]
print ('OccTax.py login : ' + str_login + '/' + str_password + ' host : ' + str_host + ' Serveur Api : ' +str_apiServ )

# Faut le faire dans la même session
# Permet d'enregistrer un relevé à partir d'un enregistrement récupéré dans synthése
print("Début à "+str(datetime.today()))

s = requests.Session()

req_login='https://' + str_apiServ+ '/taxhub/api/auth/login'
#
# payload_login=
# {
#  "login": str_login,
#  "password": str_password,
#  "id_application": 3
#}
# login sur geonature
payload_login={"login": "","password": "","id_application": 3}
payload_login['login'] = str_login
payload_login['password'] = str_password


headers_login = {'content-type': 'application/json'}
#r = requests.post(req_login,data=json.dumps(payload_login),headers=headers_login)
r = s.post(req_login,data=json.dumps(payload_login),headers=headers_login)
#print(r)
#user_cookies= r.cookies
# A priori c'est le même 
user_cookies= s.cookies
#print (user_cookies)
"""
payload pour le releve
{
  "geometry": {
    "type": "Point",
    "coordinates": [                                     CISTUDE
      -0.6785774230957031,
      44.892722731914844
    ]
  },
  "properties": {
    "id_dataset": 3,                                     TOUT VENANT
    "id_digitiser": 51,                                  christian Bièche
    "date_min": "2021-12-07",
    "date_max": "2021-12-07",
    "hour_min": null,
    "hour_max": null,
    "altitude_min": 11,
    "altitude_max": 11,
    "depth_min": null,
    "depth_max": null,
    "place_name": null,
    "meta_device_entry": "web",                          ==> AJOUT_AUTO
    "comment": "AJOUT_AUTO",                             sera le commentaire de la synthèse
    "cd_hab": 27092,                                     peut être null
    "id_nomenclature_tech_collect_campanule": 317,       ???    on laise cette valeur
    "observers": [
      51
    ],
    "observers_txt": null,
    "id_nomenclature_grp_typ": 133,                      ??? on laisse cette valeur
    "grp_method": null,
    "id_nomenclature_geo_object_nature": 174,            ??? on laisse cette valeur
    "precision": null
  }
}

"""
# Coordonnees par defaut = coordonnees de Cistude = on remplace par la synthese
payload={
"geometry": {
    "type": "Point",
    "coordinates": [                                     
      -0.6785774230957031,
      44.892722731914844
    ]
  },
  "properties": {
    "id_dataset": 3,   #tout venant                                  
    "id_digitiser": 51,                                  
    "date_min": str(date.today()),
    "date_max": str(date.today()),
    "hour_min": None,
    "hour_max": None,
    "altitude_min": None,
    "altitude_max": None,
    "depth_min": None,
    "depth_max": None,
    "place_name": None,
    "meta_device_entry": "AJOUT_AUTO API",                          
    "comment": "AJOUT_AUTO CISTUDE",                             
    "cd_hab":  None,                                         
    "observers": [
      51
    ],
    "observers_txt": None,
    "id_nomenclature_grp_typ": 133,                      
    "grp_method": None,
    "id_nomenclature_geo_object_nature": 174,            
    "precision": None
  }

}
#print(payload)
#valeurs par defaut non mise à jour par l'import dans synthese
occurence = {
      "id_nomenclature_obs_technique": 62, # val = inconnu
      "id_nomenclature_bio_condition": 157,
      "id_nomenclature_bio_status": 29,
      "id_nomenclature_naturalness": 160,
      "id_nomenclature_exist_proof": 81,
      "id_nomenclature_behaviour": 553, # val = inconnu 
      "id_nomenclature_observation_status": 88,
      "id_nomenclature_blurring": 176,
      "id_nomenclature_source_status": 74,
      "determiner": "Bièche christian",
      "id_nomenclature_determination_method": 446, # ? quelle colonne
      "nom_cite": "AJOUT CISTUDE",
      "cd_nom": 3000001,
      "meta_v_taxref": None,
      "sample_number_proof": None,
      "digital_proof": None,
      "non_digital_proof": None,
      "comment": None,
      "cor_counting_occtax": [
        {
          "id_counting_occtax": None,
          "id_nomenclature_life_stage": 1,
          "id_nomenclature_sex": 172,
          "id_nomenclature_obj_count": 146,
          "id_nomenclature_type_count": 95,
          "count_min": 1,
          "count_max": 1,
          "medias": []
        }
      ]
    }  

#  On boucle sur les lignes pour ajouter 1 releve et une occurence
conn=None

try:
    conn = psycopg2.connect(
    host=str_host,
    database="geonature2db",
    user="geonatadmin",
    password=str_dbPass)
    #Curseur general
    cur = conn.cursor()
    #curseur pour la MAJ
    curMaj= conn.cursor()
    #recupere l'utilisateur pour les imports de données dans geonature
    id_user = getUserimport(curMaj)
    if id_user == -1 :
       print ('Utilisateur imp_geo inexistant en base !')
       sys.exit(-1)

    cur.execute("select *,substring(ST_AsEWKT(the_geom_4326) , 'POINT\(.*') from gn_synthese.synthese_ajout s where s.unique_id_sinp_grp is null \
    and s.id_ajout not in (select id_ajout from gn_synthese.synthese_maj) LIMIT 10000")
    row = cur.fetchone()
    cpt=0
    while row is not None:

    #Récupère les coordonnées de l'observation
        coord= getPoints(row[65])
    #Ajoute les coordonnees au releve
        payload['geometry']['coordinates'][0] = coord[0]
        payload['geometry']['coordinates'][1] = coord[1]
    #dataset ou Tout Venant
        if (row[7] is not None):
          payload['properties']['id_dataset'] = row[7]
    #commentaire recupere
        if (row[51] is not None):
             payload['properties']['comment'] = row[51]
    #Maj des dates
        if (row[39] is not None):
             payload['properties']['date_min'] = str(row[39])
        if (row[40] is not None):
             payload['properties']['date_max'] = str(row[40])
     #Liste des observateurs
        if (row[43] is not None):  
          payload['properties']['observers_txt']= row[43]
     #Maj altitude
        if (row[34] is not None): 
          payload['properties']['altitude_min']=row [34]
        if (row[35] is not None): 
          payload['properties']['altitude_max']=row[35]
     #Utilisateur de l'observation : imp_geo
        payload['properties']['observers'][0] = id_user 
        payload['properties']['id_digitiser'] = id_user
        
        req='https://' + str_apiServ+ '/geonature/api/occtax/only/releve'
        r = requests.post(req,data = json.dumps(payload),cookies=user_cookies,headers=headers_login)
#        print(r)
        #recupere la reponse
        response_dict = json.loads(r.text)
        '''
          Pour affichage valeur
        for i in response_dict:
            print("key: ", i, "val: ", response_dict[i])
        '''
        sinp_grp= response_dict['properties']['unique_id_sinp_grp']
        id= response_dict['id']
#       print (id)
#       print (sinp_grp)

    

        req_occ='https://' + str_apiServ+ '/geonature/api/occtax/releve/' +str(id) + '/occurrence'


    # Attention on commence à row[0]
    # En commentaires les zones qui de toute façon sont par défaut 
       # occurence['id_nomenclature_obs_technique'] = row[10]
       # occurence['id_nomenclature_bio_condition'] = row[12]
       # occurence['id_nomenclature_bio_status'] = row[13]
       # occurence['id_nomenclature_naturalness'] = row[14]
       # occurence['id_nomenclature_exist_proof'] = row[15]
       # occurence['id_nomenclature_behaviour'] = row[57]
       # occurence['id_nomenclature_observation_status'] = row[22]
       # occurence['id_nomenclature_blurring'] = row[23]
       # occurence['id_nomenclature_source_status'] = row[24]
       # occurence['id_nomenclature_determination_method'] = row[46]
        occurence['nom_cite'] = row[29]
        occurence['cd_nom'] = row[28]
        occurence['comment'] = "AJOUT_AUTO CISTUDE"
        occurence['determiner']=row[43] #A priori liste des observateurs de synthese
        #occurence['cor_counting_occtax'][0]['id_nomenclature_life_stage']= row[17]
        #occurence['cor_counting_occtax'][0]['id_nomenclature_sex']= row[18]
        #occurence['cor_counting_occtax'][0]['id_nomenclature_obj_count']= row[19]
        occurence['cor_counting_occtax'][0]['count_min']= row[26]
        occurence['cor_counting_occtax'][0]['count_max']= row[27]
        #Appel API Occurence
#       print ("Appel API OCCURENCE ")
       
        r = requests.post(req_occ,data = json.dumps(occurence),cookies=user_cookies,headers=headers_login)
#       print(r)
        #On supprime dans synthese si necessaire et on met à jour synthese_maj
        majSynthese(curMaj,row[1],sinp_grp,id,row[0])
        #Valide les maj base
        conn.commit()

        cpt = cpt +1
        #next
        row = cur.fetchone()
    cur.close
    curMaj.close
except (Exception, psycopg2.DatabaseError) as error:
        print("ERREUR :")
        print (error)
        print(row)


print("Fin à   "+str(datetime.today()))
print ("Lignes traitées : " + str(cpt))

#A la fin on clos la connexion 
if conn is not None:
            conn.commit()
            conn.close()
            print('Database connection closed.')
