DELETE FROM gn_commons.t_mobile_apps;
INSERT INTO gn_commons.t_mobile_apps(
    id_mobile_app, app_code, relative_path_apk, url_apk, package, version_code
    )
VALUES
(1, 'OCCTAX', 'https://github.com/PnX-SI/gn_mobile_occtax/releases/download/1.2.0/occtax-1.2.0-generic-debug.apk', '', 'fr.geonature.occtax','2035'),
(2, 'SYNC', 'https://github.com/PnX-SI/gn_mobile_occtax/releases/download/1.2.0/occtax-1.2.0-generic-debug.apk', '', 'fr.geonature.sync','2485')
;
 