#!/bin/bash
# COLOR CONSTANTES
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
GRAY="\e[90m"
ENDCOLOR="\e[0m"
# This function extracts the latest version number from Github
# One parameter : the repository url
extract_latest () {
local res=$(curl -sL $1 |grep "<title>Release" | grep -oP "(?<=Release ).*(?= . PnX-SI)")
echo $res
}

# CHOIX DES VERSIONS - A ADAPTER MANUELLEMENT
UH_VERSION='2.3.2'
TH_VERSION='1.10.8'
GN_VERSION='2.11.2'
DASHBOARD_VERSION='1.2.1'
IMPORT_VERSION='2.0.4'
EXPORT_VERSION='1.3.0'
MONITORING_VERSION='0.4.1'

echo "************************************************************************************************************"
echo "* This script helps you to prepare geonature migration to new versions of GeoNature apps and/or its modules."
echo "* This script only download, unzip, rename and get old config. Migration needs to be executed manually."
echo "* Read all procedures and release notes before migrating apps and modules."
echo "************************************************************************************************************"
echo ""

# ON SE MET LA OU IL FAUT
cd /home/`whoami`/
echo "Go to the the current user directory"
echo "  cd /home/`whoami`/"
echo ""
echo "DIAGNOSTIC"
echo "=========="

echo 'THE CURRENT VERSIONS OF GEONATURE AND ITS MODULES ARE AS FOLLOWS :'
if [ -d ~/usershub ]; then
    CURRENT_UH="${BLUE}$(cat ~/usershub/VERSION)${ENDCOLOR}";
else
    CURRENT_UH="${GRAY} NOT INSTALLED. UsersHub is not present in the root of the current user directory.${ENDCOLOR}";
fi

if [ -d ~/taxhub ]; then
    CURRENT_TH="${BLUE}$(cat ~/taxhub/VERSION)${ENDCOLOR}";
else
    CURRENT_TH="${GRAY}NOT INSTALLED. TaxHub is not present in the root of the current user directory.${ENDCOLOR}";
fi

if [ -d ~/geonature ]; then
    CURRENT_GN="${BLUE}$(cat ~/geonature/VERSION)${ENDCOLOR}";
else
    CURRENT_GN="${GRAY}NOT INSTALLED. GeoNature is not present in the root of the current user directory.${ENDCOLOR}";
fi

if [ -d ~/gn_module_dashboard ]; then
    CURRENT_DASHBOARD="${BLUE}$(cat ~/gn_module_dashboard/VERSION)${ENDCOLOR}";
else
    CURRENT_DASHBOARD="${GRAY}NOT INSTALLED. This module is not present in the root of the current user directory.${ENDCOLOR}";
fi

if [ -d ~/gn_module_import ]; then
    CURRENT_IMPORT="${BLUE}$(cat ~/gn_module_import/VERSION)${ENDCOLOR}";
else
    CURRENT_IMPORT="${GRAY}NOT INSTALLED. This module is not present in the root of the current user directory.${ENDCOLOR}";
fi

if [ -d ~/gn_module_export ]; then
    CURRENT_EXPORT="${BLUE}$(cat ~/gn_module_export/VERSION)${ENDCOLOR}";
else
    CURRENT_EXPORT="${GRAY}NOT INSTALLED. This module is not present in the root of the current user directory.${ENDCOLOR}";
fi

if [ -d ~/gn_module_monitoring ]; then
    CURRENT_MONITORING="${BLUE}$(cat ~/gn_module_monitoring/VERSION)${ENDCOLOR}";
else
    CURRENT_MONITORING="${GRAY}NOT INSTALLED. This module is not present in the root of the current user directory.${ENDCOLOR}";
fi
echo -e "  UsersHub :" $CURRENT_UH
echo -e "  TaxHub :" $CURRENT_TH
echo -e "  GeoNature :" $CURRENT_GN
echo -e "  Dashboard module :" $CURRENT_DASHBOARD
echo -e "  Import module :" $CURRENT_IMPORT
echo -e "  Export module :" $CURRENT_EXPORT
echo -e "  Monitoring module :" $CURRENT_MONITORING
echo ""

echo 'ON GITHUB, THE LATEST AVAILABLE VERSIONS OF GEONATURE AND ITS MODULES ARE AS FOLLOWS : '
if [ -d ~/usershub ]; then 
    LATEST_UH=${GREEN}$(extract_latest "https://github.com/PnX-SI/usershub/releases/latest")${ENDCOLOR}
    echo -e "  UsersHub :" $LATEST_UH
fi
if [ -d ~/taxhub ]; then
    LATEST_TH=${GREEN}$(extract_latest "https://github.com/PnX-SI/taxhub/releases/latest")${ENDCOLOR}
    echo -e "  TaxHub :" $LATEST_TH
fi
if [ -d ~/geonature ]; then
    LATEST_GN=${GREEN}$(extract_latest "https://github.com/PnX-SI/geonature/releases/latest")${ENDCOLOR}
    echo -e "  GeoNature :" $LATEST_GN
fi
if [ -d ~/gn_module_dashboard ]; then
    LATEST_DASHBOARD=${GREEN}$(extract_latest "https://github.com/PnX-SI/gn_module_dashboard/releases/latest")${ENDCOLOR}
    echo -e "  Dashboard module :" $LATEST_DASHBOARD
fi
if [ -d ~/gn_module_import ]; then
    LATEST_IMPORT=${GREEN}$(extract_latest "https://github.com/PnX-SI/gn_module_import/releases/latest")${ENDCOLOR}
    echo -e "  Import module :" $LATEST_IMPORT
fi
if [ -d ~/gn_module_export ]; then
    LATEST_EXPORT=${GREEN}$(extract_latest "https://github.com/PnX-SI/gn_module_export/releases/latest")${ENDCOLOR}
    echo -e "  Export module :" $LATEST_EXPORT
fi
if [ -d ~/gn_module_monitoring ]; then
    LATEST_MONITORING=${GREEN}$(extract_latest "https://github.com/PnX-SI/gn_module_monitoring/releases/latest")${ENDCOLOR}
    echo -e "  Monitoring module :" $LATEST_MONITORING
fi

echo ""
echo "SOME QUESTIONS"
echo "=============="


read -p "  Do you want to use latest versions for all apps and modules  (y or n) ?" USE_LATEST
if [ "$USE_LATEST" = "y" ]; then
    UH_VERSION=$LATEST_UH;
    TH_VERSION=$LATEST_TH;
    GN_VERSION=$LATEST_GN;
    DASHBOARD_VERSION=$LATEST_DASHBOARD;
    IMPORT_VERSION=$LATEST_IMPORT;
    EXPORT_VERSION=$LATEST_EXPORT;
    MONITORING_VERSION=$LATEST_MONITORING;
elif [ "$USE_LATEST" = "n" ]; then
    echo "The above versions will be used :"    
      echo "    $UH_VERSION"
      echo "    $TH_VERSION"
      echo "    $GN_VERSION"
      echo "    $DASHBOARD_VERSION"
      echo "    $IMPORT_VERSION"
      echo "    $EXPORT_VERSION"
      echo "    $MONITORING_VERSION"
      echo "      So ! If this is not exactly your plan, exit (ctrl +c), edit this file, manually change its settings at the begining and execute it again.";
fi


read -p "  Do you want to migrate all apps and modules (a) or choice apps or modules that need to be migrated (c) ?" MIGRATE_ALL
if [ "$MIGRATE_ALL" = "a" ]; then
    if [ -d ~/usershub ]; then
        UPDATE_UH='true'      
    else
        UPDATE_UH='false'
    fi

    if [ -d ~/taxhub ]; then
        UPDATE_TH='true'
    else
        UPDATE_TH='false'
    fi

    if [ -d ~/geonature ]; then
        UPDATE_GN='true'
    else
        UPDATE_GN='false'
    fi

    if [ -d ~/gn_module_dashboard ]; then
        UPDATE_DASHBOARD='true'
    else
        UPDATE_DASHBOARD='false'
    fi

    if [ -d ~/gn_module_import ]; then
        UPDATE_IMPORT='true'
    else
        UPDATE_IMPORT='false'
    fi

    if [ -d ~/gn_module_export ]; then
        UPDATE_EXPORT='true'
    else
        UPDATE_EXPORT='false'
    fi

    if [ -d ~/gn_module_monitoring ]; then
        UPDATE_MONITORING='true'
    else
        UPDATE_MONITORING='false'
    fi
elif [ "$MIGRATE_ALL" = "c" ]; then
    echo "  So ! a few more questions"
    if [ -d ~/usershub ]; then
        while true; do
            read -p "    Do you want to migrate USERSHUB (y or n) ?" yn
            case $yn in
                [Yy]* ) UPDATE_UH='true'; break;;
                [Nn]* ) UPDATE_UH="false"; break;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi
    if [ -d ~/taxhub ]; then
        while true; do
            read -p "    Do you want to migrate TAXHUB (y or n) ?" yn
            case $yn in
                [Yy]* ) UPDATE_TH='true'; break;;
                [Nn]* ) UPDATE_TH="false"; break;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi
    if [ -d ~/geonature ]; then
        while true; do
            read -p "    Do you want to migrate GEONATURE (y or n) ?" yn
            case $yn in
                [Yy]* ) UPDATE_GN='true'; break;;
                [Nn]* ) UPDATE_GN="false"; break;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi
    if [ -d ~/gn_module_dashboard ]; then
        while true; do
            read -p "    Do you want to migrate DASHBOARD MODULE (y or n) ?" yn
            case $yn in
                [Yy]* ) UPDATE_DASHBOARD='true'; break;;
                [Nn]* ) UPDATE_DASHBOARD="false"; break;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi
    if [ -d ~/gn_module_import ]; then
        while true; do
            read -p "    Do you want to migrate IMPORT MODULE (y or n) ?" yn
            case $yn in
                [Yy]* ) UPDATE_IMPORT='true'; break;;
                [Nn]* ) UPDATE_IMPORT="false"; break;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi
    if [ -d ~/gn_module_export ]; then
        while true; do
            read -p "    Do you want to migrate EXPORT MODULE (y or n) ?" yn
            case $yn in
                [Yy]* ) UPDATE_EXPORT='true'; break;;
                [Nn]* ) UPDATE_EXPORT="false"; break;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi
    if [ -d ~/gn_module_monitoring ]; then
        while true; do
            read -p "    Do you want to migrate MONITORING MODULE (y or n) ?" yn
            case $yn in
                [Yy]* ) UPDATE_MONITORING='true'; break;;
                [Nn]* ) UPDATE_MONITORING="false"; break;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi
else
    echo -e "${RED}bad answer. Prompt a (all) or c (choice) only. Try Again.${ENDCOLOR}"
    exit;
fi

echo ""
echo "GOOD ! LET'S SEE WHAT WILL HAPPEN NOW"
echo "====================================="
if [ "$UPDATE_UH" == "true" ]; then
    echo -e "  UsersHub app will be updated FROM $CURRENT_UH TO $UH_VERSION"
elif [ ! -d ~/usershub ]; then
    echo -e "  ${GRAY}UsersHub app is not installed${ENDCOLOR}"
elif [ "$UPDATE_UH" == "false" ]; then
    echo -e "  UsersHub app will be kept in current version $CURRENT_UH"
fi

if [ "$UPDATE_TH" == "true" ]; then
    echo -e "  TaxHub app will be updated FROM $CURRENT_TH TO $TH_VERSION"
elif [ ! -d ~/taxhub ]; then
    echo -e "  ${GRAY}TaxHub app is not installed${ENDCOLOR}"
elif [ "$UPDATE_TH" == "false" ]; then
    echo -e "  TaxHub app will be kept in current version $CURRENT_TH"
fi


if [ "$UPDATE_GN" == "true" ]; then
    echo -e "  GeoNature app will be updated FROM $CURRENT_GN TO $GN_VERSION"
elif [ ! -d ~/geonature ]; then
    echo -e "  ${GRAY}GeoNature app is not installed${ENDCOLOR}"
elif [ "$UPDATE_GN" == "false" ]; then
    echo -e "  GeoNature app will be kept in current version $CURRENT_GN"
fi

if [ "$UPDATE_DASHBOARD" == "true" ]; then
    echo -e "  Dashboard module will be updated FROM $CURRENT_DASHBOARD TO $DASHBOARD_VERSION"
elif [ ! -d ~/gn_module_dashboard ]; then
    echo -e "  ${GRAY}Dashboard module is not installed${ENDCOLOR}"
elif [ "$UPDATE_DASHBOARD" == "false" ]; then
    echo -e "  Dashboard module will be kept in current version $CURRENT_DASHBOARD"
fi

if [ "$UPDATE_IMPORT" == "true" ]; then
    echo -e "  Import module will be updated FROM $CURRENT_IMPORT TO $IMPORT_VERSION"
elif [ ! -d ~/gn_module_import ]; then
    echo -e "  ${GRAY}Import module is not installed${ENDCOLOR}"
elif [ "$UPDATE_IMPORT" == "false" ]; then
    echo -e "  Import module will be kept in current version $CURRENT_IMPORT"
fi

if [ "$UPDATE_EXPORT" == "true" ]; then
    echo -e "  Export module will be updated FROM $CURRENT_EXPORT TO $EXPORT_VERSION"
elif [ ! -d ~/gn_module_export ]; then
    echo -e "  ${GRAY}Export module is not installed${ENDCOLOR}"
elif [ "$UPDATE_EXPORT" == "false" ]; then
    echo -e "  Export module will be kept in current version $CURRENT_EXPORT"
fi

if [ "$UPDATE_MONITORING" == "true" ]; then
    echo -e " Monitoring module will be updated FROM $CURRENT_MONITORING TO $MONITORING_VERSION"
elif [ ! -d ~/gn_module_monitoring ]; then
    echo -e "  ${GRAY}Monitoring module is not installed${ENDCOLOR}"
elif [ "$UPDATE_MONITORING" == "false" ]; then
    echo -e "   Monitoring module will be kept in current version $CURRENT_MONITORING"
fi

echo ""
printf "EVERYTHING LOOKS LIKE IN YOUR PLAN ? LET'S GO? (y/n) "
old_stty_cfg=$(stty -g)
stty raw -echo
answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
stty $old_stty_cfg
if echo "$answer" | grep -iq "^y" ; then
    echo ""
    echo "  C'est parti !"
    exit ;
    if [ "$UPDATE_UH" == "true" ]; then
        echo "LOADIND NEW usershub-$UH_VERSION RELEASE AND UNZIP IT"
        wget https://github.com/PnX-SI/UsersHub/archive/$UH_VERSION.zip
        unzip /home/`whoami`/$UH_VERSION.zip
        rm /home/`whoami`/$UH_VERSION.zip
        echo "RENAME CURRENT VERSION TO "usershub_old" AND RENAME NEW RELEASES TO 'usershub'"
        sudo rm -r /home/`whoami`/usershub_old
        mv /home/`whoami`/usershub /home/`whoami`/usershub_old
        mv /home/`whoami`/UsersHub-$UH_VERSION /home/`whoami`/usershub/
    fi
    if [ "$UPDATE_TH" == "true" ]; then
        echo "LOADIND NEW taxhub-$TH_VERSION RELEASE AND UNZIP IT"
        wget https://github.com/PnX-SI/TaxHub/archive/$TH_VERSION.zip
        unzip /home/`whoami`/$TH_VERSION.zip
        rm /home/`whoami`/$TH_VERSION.zip
        echo 'RENAME CURRENT VERSION TO "taxhub_old" AND RENAME NEW RELEASES TO "taxhub"'
        sudo rm -r /home/`whoami`/taxhub_old
        mv /home/`whoami`/taxhub /home/`whoami`/taxhub_old
        mv /home/`whoami`/TaxHub-$TH_VERSION/ /home/`whoami`/taxhub/
        
    fi
    if [ "$UPDATE_GN" == "true" ]; then
        echo "LOADIND NEW geonature-$GN_VERSION RELEASE AND UNZIP IT"
        wget https://github.com/PnX-SI/GeoNature/archive/$GN_VERSION.zip
        unzip /home/`whoami`/$GN_VERSION.zip  
        rm /home/`whoami`/$GN_VERSION.zip
        echo 'RENAME CURRENT VERSION TO "geonature_old" AND RENAME NEW RELEASES TO "geonature"'
        sudo -r rm /home/`whoami`/geonature_old
        mv /home/`whoami`/geonature /home/`whoami`/geonature_old
        mv /home/`whoami`/GeoNature-$GN_VERSION /home/`whoami`/geonature/
    fi
    if [ "$UPDATE_DASHBOARD" == "true" ]; then
        echo "LOADIND NEW gn_module_dashboard-$DASHBOARD_VERSION RELEASE AND UNZIP IT"
        wget https://github.com/PnX-SI/gn_module_dashboard/archive/$DASHBOARD_VERSION.zip
        unzip /home/`whoami`/$DASHBOARD_VERSION.zip  
        rm /home/`whoami`/$DASHBOARD_VERSION.zip
        echo 'RENAME CURRENT VERSION TO "gn_module_dashboard_old" AND RENAME NEW RELEASES TO "gn_module_dashboard"'
        sudo rm -r /home/`whoami`/gn_module_dashboard_old
        mv /home/`whoami`/gn_module_dashboard /home/`whoami`/gn_module_dashboard_old
        mv /home/`whoami`/gn_module_dashboard-$DASHBOARD_VERSION /home/`whoami`/gn_module_dashboard/
    fi
    if [ "$UPDATE_IMPORT" == "true" ]; then
        echo "LOADIND NEW gn_module_import-$IMPORT_VERSION RELEASE AND UNZIP IT"
        wget https://github.com/PnX-SI/gn_module_import/archive/$IMPORT_VERSION.zip
        unzip /home/`whoami`/$IMPORT_VERSION.zip  
        rm /home/`whoami`/$IMPORT_VERSION.zip
        echo 'RENAME CURRENT VERSION TO "gn_module_import_old" AND RENAME NEW RELEASES TO "gn_module_import"'
        sudo rm -r /home/`whoami`/gn_module_import_old
        mv /home/`whoami`/gn_module_import /home/`whoami`/gn_module_import_old
        mv /home/`whoami`/gn_module_import-$IMPORT_VERSION /home/`whoami`/gn_module_import/
    fi
    if [ "$UPDATE_EXPORT" == "true" ]; then
        echo "LOADIND NEW gn_module_export-$EXPORT_VERSION RELEASE AND UNZIP IT"
        wget https://github.com/PnX-SI/gn_module_export/archive/$EXPORT_VERSION.zip
        unzip /home/`whoami`/$EXPORT_VERSION.zip  
        rm /home/`whoami`/$EXPORT_VERSION.zip
        echo 'RENAME CURRENT VERSION TO "gn_module_export_old" AND RENAME NEW RELEASES TO "gn_module_export"'
        sudo rm -r /home/`whoami`/gn_module_export_old
        mv /home/`whoami`/gn_module_export /home/`whoami`/gn_module_export_old
        mv /home/`whoami`/gn_module_export-$EXPORT_VERSION /home/`whoami`/gn_module_export/
    fi
    if [ "$UPDATE_MONITORING" == "true" ]; then
        echo "LOADIND NEW gn_module_monitoring-$MONITORING_VERSION RELEASE AND UNZIP IT"
        wget https://github.com/PnX-SI/gn_module_monitoring/archive/$MONITORING_VERSION.zip
        unzip /home/`whoami`/$MONITORING_VERSION.zip  
        rm /home/`whoami`/$MONITORING_VERSION.zip
        echo 'RENAME CURRENT VERSION TO "gn_module_monitoring_old" AND RENAME NEW RELEASES TO "gn_module_monitoring"'
        sudo rm -r /home/`whoami`/gn_module_monitoring_old
        mv /home/`whoami`/gn_module_monitoring /home/`whoami`/gn_module_monitoring_old
        mv /home/`whoami`/gn_module_monitoring-$MONITORING_VERSION /home/`whoami`/gn_module_monitoring/
    fi

        echo 'COPY OLD CONFIG FILES INTO NEW RELEASES FOLDERS'
    if [ "$UPDATE_UH" == "true" ]; then
        cp /home/`whoami`/usershub_old/config/config.py /home/`whoami`/usershub/config/config.py
        cp /home/`whoami`/usershub_old/config/settings.ini /home/`whoami`/usershub/config/settings.ini
        echo "NEW usershub-$UH_VERSION IS READY FOR UPDATE - CHECK CONFIG FILE BEFORE EXECUTING './install_app.sh'"
    fi
    if [ "$UPDATE_TH" == "true" ]; then
        cp /home/`whoami`/taxhub_old/settings.ini /home/`whoami`/taxhub/settings.ini
        cp /home/`whoami`/taxhub_old/apptax/config.py /home/`whoami`/taxhub/apptax/config.py
        cp /home/`whoami`/taxhub_old/static/app/constants.js /home/`whoami`/taxhub/static/app/constants.js
        cp -aR /home/`whoami`/taxhub_old/static/medias/ /home/`whoami`/taxhub/static/
        echo "NEW taxhub-$TH_VERSION IS READY FOR UPDATE - CHECK CONFIG FILE BEFORE EXECUTING './install_app.sh'"
    fi
    if [ "$UPDATE_GN" == "true" ]; then
        echo "NEW geonature-$GN_VERSION IS READY FOR UPDATE - CHECK RELEASE NOTES BEFORE EXECUTING './install/migration/migration.sh'"
        echo "DO NOT FORGOT TO UPDATE geonature database WITH 'geonature db update' COMMAND"
    fi
    if [ "$UPDATE_DASHBOARD" == "true" ]; then
        cp /home/`whoami`/gn_module_dashboard_old/config/conf_gn_module.toml /home/`whoami`/gn_module_dashboard/config/conf_gn_module.toml
        echo "NEW gn_module_dashboard-$DASHBOARD_VERSION IS READY FOR UPDATE - CHECK RELEASE NOTES AND CONFIG FILE BEFORE EXECUTING 'geonature install-gn-module ~/gn_module_dashboard DASHBOARD'"
    fi
    if [ "$UPDATE_IMPORT" == "true" ]; then
        cp /home/`whoami`/gn_module_import_old/config/conf_gn_module.toml  /home/`whoami`/gn_module_import/config/conf_gn_module.toml
        echo "NEW gn_module_import-$IMPORT_VERSION IS READY FOR UPDATE - CHECK RELEASE NOTES AND CONFIG FILE BEFORE EXECUTING 'geonature install-gn-module ~/gn_module_import IMPORT'"
    fi
    if [ "$UPDATE_EXPORT" == "true" ]; then
        cp /home/`whoami`/gn_module_export_old/config/conf_gn_module.toml  /home/`whoami`/gn_module_export/config/conf_gn_module.toml
        echo "NEW gn_module_export-$EXPORT_VERSION IS READY FOR UPDATE - CHECK RELEASE NOTES AND CONFIG FILE BEFORE EXECUTING 'geonature install-gn-module ~/gn_module_export EXPORTS'"
    fi
    if [ "$UPDATE_MONITORING" == "true" ]; then
        echo "NEW gn_module_monitoring-$MONITORING_VERSION IS READY FOR UPDATE - CHECK RELEASE NOTES AND CONFIG FILE BEFORE EXECUTING 'geonature install-gn-module ~/gn_module_monitoring MONITORINGS'"
        echo "THIS SCRIPT DO NOT MIGRATE YOUR SUBMODULES'"
    fi
else
    echo ""
    echo "  OK ! On en reste là"
fi
echo 'Quelques ressources :'
echo "  DOC USERSHUB : https://github.com/PnX-SI/UsersHub/blob/master/docs/installation.rst"
echo "  RELEASES USERSHUB : https://github.com/PnX-SI/UsersHub/releases"
echo ""
echo "  DOC TAXHUB : https://github.com/PnX-SI/TaxHub/blob/master/docs/installation.rst"
echo "  RELEASES TAXHUB : https://github.com/PnX-SI/TaxHub/releases"
echo ""
echo "  DOC GEONATURE : https://github.com/PnX-SI/GeoNature/blob/master/docs/installation.rst"
echo "  RELEASES GEONATURE : https://github.com/PnX-SI/GeoNature/releases"
echo ""
echo "  DOC DASHBOAD : https://github.com/PnX-SI/gn_module_dashboard#mise-%C3%A0-jour-du-module"
echo "  RELEASES DASHBOAD : https://github.com/PnX-SI/gn_module_dashboard/releases"
echo ""
echo "  DOC MODULE IMPORT : https://github.com/PnX-SI/gn_module_import#mise-%C3%A0-jour-du-module"
echo "  RELEASES MODULE IMPORT : https://github.com/PnX-SI/gn_module_import/releases"
echo ""
echo "  DOC MODULE EXPORT : https://github.com/PnX-SI/gn_module_export#mise-%C3%A0-jour-du-module"
echo "  RELEASES MODULE EXPORT : https://github.com/PnX-SI/gn_module_export/releases"
echo ""
echo "  DOC MODULE MONITORING : https://github.com/PnX-SI/gn_module_monitoring#installation"
echo "  RELEASES MODULE MONITORING : https://github.com/PnX-SI/gn_module_monitoring/releases"
