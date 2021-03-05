DELETE FROM gn_commons.t_mobile_apps;
INSERT INTO gn_commons.t_mobile_apps(
    id_mobile_app, app_code, relative_path_apk, url_apk, package, version_code
    )
VALUES
(1, 'OCCTAX', 'static/mobile/occtax/occtax-1.2.0-generic-debug.apk', '', 'fr.geonature.occtax','2070'),
(2, 'SYNC', 'static/mobile/sync/sync-1.1.4-generic-debug.apk', '', 'fr.geonature.sync','2620')
;
 