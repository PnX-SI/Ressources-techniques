#!/bin/bash

# Récupération des variables d'environnement
. ./upload_project_files.ini

TMP_DIR=$QFCLOUD_LOCAL_DIR/tmp
TMP_PRJ_DIR=$TMP_DIR/$QFCLOUD_PRJ_ID

# Création du dossier temporaire
if [ ! -d "$TMP_DIR" ]; then
  mkdir $TMP_DIR
else
  if [ ! -d "$TMP_PRJ_DIR" ]; then
    mkdir $TMP_PRJ_DIR
  else
    rm -rf $TMP_PRJ_DIR/*
  fi
fi

# Récupération de la liste des fichiers du projet via l'option "list-files"
OUTPUT_CLI="$(qfieldcloud-cli -u ${QFCLOUD_USR} -p ${QFCLOUD_PWD} -U ${QFCLOUD_URL} list-files ${QFCLOUD_PRJ_ID} 2>&1)"

# Boucle sur les fichiers pour les télécharger avec wget
while IFS= read -r LINE; do
  FILE=$(echo $LINE | awk -F" " '{print $4}')
  # Test sur la sortie de 'qfieldcloud-cli' pour ne faire un wget que sur les noms de fichier ;-)
  if [[ "$FILE" =~ ^[^/]+(\.[^/]+)+$ ]]; then
    # -q : quiet
    # --show-progress : affiche seulement la barre de progression
    # -P : dossier local ou stocker les fichiers
    wget -q --show-progress -P $TMP_DIR $FILES2DWL_DIR/$FILE
  fi
done <<< "$OUTPUT_CLI"

# Upload des fichiers téléchargés sur le projet
qfieldcloud-cli -u $QFCLOUD_USR -p $QFCLOUD_PWD -U $QFCLOUD_URL upload-files --force $QFCLOUD_PRJ_ID $TMP_DIR --filter "*.*"

# Nettoyage du dossier tmp
rm -r $TMP_PRJ_DIR

echo
echo

