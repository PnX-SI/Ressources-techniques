path_modules=/geonature/

git clone https://github.com/PnX-SI/gn_module_import /geonature/import
git clone https://github.com/PnX-SI/gn_module_export /geonature/export
git clone https://github.com/PnX-SI/gn_module_monitoring /geonature/monitoring

source /geonature/geonature/backend/venv/bin/activate

geonature install_gn_module /geonature/import "import" --build=false

geonature install_gn_module /geonature/export "export" --build=false

geonature install_gn_module /geonature/monitoring "monitoring"
# à faire seulement pour la recette?
flask monitorings install /geonature/monitoring/contrib/test

deactivate