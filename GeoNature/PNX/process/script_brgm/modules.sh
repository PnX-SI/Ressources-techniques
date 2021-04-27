# le module export nécessite une configuration OK pour les mails
# dans geonature_config.toml
#
#
# [MAIL_CONFIG]
#         MAIL_SERVER = "mail.brgm.fr"
#         MAIL_PORT = 25
#         MAIL_USE_TLS = false
#         MAIL_USE_SSL = false
#         MAIL_USERNAME = ""
#         MAIL_PASSWORD = ""
#         MAIL_DEFAULT_SENDER = "brunolafage@parcnational.fr"



git clone https://github.com/PnX-SI/gn_module_import /geonature/import
git clone https://github.com/PnX-SI/gn_module_export /geonature/export
git clone https://github.com/PnX-SI/gn_module_monitoring /geonature/monitoring

source /geonature/geonature/backend/venv/bin/activate

geonature install_gn_module /geonature/import "import" --build=false
geonature install_gn_module /geonature/export "export" --build=false
geonature install_gn_module /geonature/monitoring "monitoring"

# à faire seulement pour la recette
flask monitorings install /geonature/monitoring/contrib/test

deactivate