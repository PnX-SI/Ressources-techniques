Plugin Qgis
 - API : https://qgis.org/pyqgis/3.4/
 - https://docs.qgis.org/testing/en/docs/pyqgis_developer_cookbook/plugins/plugins.html
 - Plugins :
    * Plugin builder
    * Plugin reloader

Traduction:
 - Génération fichier ts de traduction :
        `lupdate your_plugin_dialog_base.ui -ts your_plugin_en.ts`
 - Génération fichier qm:
        `lrelease your_plugin_en.ts`

Ressources:

 `pyrcc5 -o resources.py resources.qrc`
