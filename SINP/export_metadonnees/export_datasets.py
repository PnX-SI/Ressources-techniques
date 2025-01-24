import psycopg2
import xlsxwriter

DB_CONNEXION = "dbname=geonature2db user=XXX password=XXX host=XXX"
queries_jdd = {
    "Principal": """WITH selected_dataset AS (
	SELECT *
	FROM tmp_process.export_datasets ed
)
SELECT 
    td.unique_dataset_id AS IdentifiantJeuDonnees, 
    'GeoNature Parc national des Cévennes' AS BaseProduction, 
    td.dataset_name AS Libelle,
    td.keywords AS MotsCles,
    tno.label_default AS Objectifs,
    taf.unique_acquisition_framework_id AS RattachementCadreAcquisition,
    tnt.label_default AS Territoires,
    tntd.label_default AS TypeDonnees,
    td.terrestrial_domain AS estContinental,
    td.marine_domain AS estMarin
    FROM gn_meta.t_datasets td 
    JOIN selected_dataset sd
    ON sd.id_dataset = td.id_dataset
    JOIN gn_meta.t_acquisition_frameworks taf ON taf.id_acquisition_framework = td.id_acquisition_framework
    LEFT OUTER JOIN ref_nomenclatures.t_nomenclatures tno ON tno.id_nomenclature = id_nomenclature_dataset_objectif
    LEFT OUTER JOIN ref_nomenclatures.t_nomenclatures tnt ON tnt.id_nomenclature = id_nomenclature_territorial_level 
    LEFT OUTER JOIN ref_nomenclatures.t_nomenclatures tntd ON tntd.id_nomenclature = td.id_nomenclature_data_type ;""",
    "Contact principal": """SELECT 
        td.unique_dataset_id AS IdentifiantJeuDonnees, 
        CONCAT(tr.nom_role , ' ', tr.prenom_role) AS IdentiteContactPrincipal,
        bo.nom_organisme AS OrganismeContactPrincipal, 
        COALESCE (tr.email , bo.email_organisme) AS MailContactPrincipal,
        bo.uuid_organisme 
    FROM gn_meta.t_datasets td 
    JOIN gn_meta.cor_dataset_actor cda 
    ON td.id_dataset = cda.id_dataset 
    LEFT JOIN utilisateurs.bib_organismes bo 
    ON bo.id_organisme = cda.id_organism 
    LEFT JOIN utilisateurs.t_roles tr 
    ON tr.id_role = cda.id_role 
    WHERE cda.id_nomenclature_actor_role = (SELECT id_nomenclature FROM ref_nomenclatures.t_nomenclatures tn WHERE mnemonique = 'Contact principal')
""",
    "ContactBaseProd": """
    WITH selected_dataset AS (
        SELECT *
        FROM tmp_process.export_datasets ed
    )
    SELECT 
        td.unique_dataset_id AS IdentifiantJeuDonnees, 
        CONCAT(tr.nom_role , ' ', tr.prenom_role) AS IdentiteContactFournisseur,
        bo.nom_organisme AS OrganismeContactFournisseur, 
        COALESCE (tr.email , bo.email_organisme) AS MailContactFournisseur,
        bo.uuid_organisme 
    FROM gn_meta.t_datasets td 
    JOIN selected_dataset sd
    ON sd.id_dataset = td.id_dataset
    JOIN gn_meta.cor_dataset_actor cda 
    ON td.id_dataset = cda.id_dataset 
    LEFT JOIN utilisateurs.bib_organismes bo 
    ON bo.id_organisme = cda.id_organism 
    LEFT JOIN utilisateurs.t_roles tr 
    ON tr.id_role = cda.id_role 
    WHERE cda.id_nomenclature_actor_role = (SELECT id_nomenclature FROM ref_nomenclatures.t_nomenclatures tn WHERE mnemonique = 'Point de contact base de données de production');
""",
    "Fournisseurs": """
    WITH selected_dataset AS (
        SELECT *
        FROM tmp_process.export_datasets ed 
    )
    SELECT 
        td.unique_dataset_id AS IdentifiantJeuDonnees, 
        CONCAT(tr.nom_role , ' ', tr.prenom_role) AS IdentiteContactFournisseur,
        bo.nom_organisme AS OrganismeContactFournisseur, 
        COALESCE (tr.email , bo.email_organisme) AS MailContactFournisseur,
        bo.uuid_organisme 
    FROM gn_meta.t_datasets td 
    JOIN selected_dataset sd
    ON sd.id_dataset = td.id_dataset
    JOIN gn_meta.cor_dataset_actor cda 
    ON td.id_dataset = cda.id_dataset 
    LEFT JOIN utilisateurs.bib_organismes bo 
    ON bo.id_organisme = cda.id_organism 
    LEFT JOIN utilisateurs.t_roles tr 
    ON tr.id_role = cda.id_role 
    WHERE cda.id_nomenclature_actor_role = (SELECT id_nomenclature FROM ref_nomenclatures.t_nomenclatures tn WHERE mnemonique = 'Fournisseur du jeu de données');
""",
    "Producteur": """
    WITH selected_dataset AS (
        SELECT *
        FROM tmp_process.export_datasets ed 
    )
    SELECT 
        td.unique_dataset_id AS IdentifiantJeuDonnees, 
        CONCAT(tr.nom_role , ' ', tr.prenom_role) AS IdentiteContactProducteur,
        bo.nom_organisme AS OrganismeContactProducteur, 
        COALESCE (tr.email , bo.email_organisme) AS MailContactProducteur,
        bo.uuid_organisme 
    FROM gn_meta.t_datasets td 
    JOIN selected_dataset sd
    ON sd.id_dataset = td.id_dataset
    JOIN gn_meta.cor_dataset_actor cda 
    ON td.id_dataset = cda.id_dataset 
    LEFT JOIN utilisateurs.bib_organismes bo 
    ON bo.id_organisme = cda.id_organism 
    LEFT JOIN utilisateurs.t_roles tr 
    ON tr.id_role = cda.id_role 
    WHERE cda.id_nomenclature_actor_role = (SELECT id_nomenclature FROM ref_nomenclatures.t_nomenclatures tn WHERE mnemonique = 'Producteur du jeu de données');
 """,
}


queries_ca = {
    "Principal": """
    WITH objectifs AS (
        SELECT c.id_acquisition_framework , string_agg(tn.label_default, ',') AS objectifs
        FROM   gn_meta.cor_acquisition_framework_objectif  c  
        JOIN ref_nomenclatures.t_nomenclatures tn ON tn.id_nomenclature = c.id_nomenclature_objectif 
        GROUP BY c.id_acquisition_framework 
    ), VoletSINP AS (
        SELECT c.id_acquisition_framework , string_agg(tn.label_default, ',') AS VoletSINP
        FROM   gn_meta.cor_acquisition_framework_objectif  c  
        JOIN ref_nomenclatures.t_nomenclatures tn ON tn.id_nomenclature = c.id_nomenclature_objectif 
        GROUP BY c.id_acquisition_framework 
    ), selected_dataset AS (
		SELECT DISTINCT id_acquisition_framework
		FROM tmp_process.export_datasets ed 
	)
    SELECT taf.unique_acquisition_framework_id AS IdentifiantCadreAcquisition,
    taf.acquisition_framework_end_date AS DateCloture ,
    taf.acquisition_framework_start_date AS DateLancement, 
    taf.acquisition_framework_desc as  DescriptionCadreAcquisition, 
    concat_ws(', ', taf.target_description, taf.ecologic_or_geologic_target) AS DescriptionCibleTaxo, 
    'Non' AS FichierJointOuiNon, 
    NULL AS IdentifiantProcedureDepot, 
    taf.acquisition_framework_name AS LibelleCadreAcquisition, 
    NULL AS StatutAvancement, 
    tnt.label_default  AS NiveauTerritorial, 
    NULL AS NomFichierTaxonomique, 
    o.objectifs AS Objectifs, 
    taf.territory_desc AS PrecisionGeographique, 
    meta.unique_acquisition_framework_id AS ReferenceMetacadre, 
    taf.territory_desc AS  Territoires, 
    tnf.label_default AS TypeFinancement, 
    v.VoletSINP AS VoletSINP, 
    taf.is_parent  AS estMetaCadre
    FROM gn_meta.t_acquisition_frameworks taf 
    JOIN selected_dataset sd
    ON sd.id_acquisition_framework = taf.id_acquisition_framework
    LEFT JOIN gn_meta.t_acquisition_frameworks meta  ON meta.id_acquisition_framework = taf.acquisition_framework_parent_id
    LEFT JOIN ref_nomenclatures.t_nomenclatures tnt ON tnt.id_nomenclature = taf.id_nomenclature_territorial_level 
    LEFT JOIN ref_nomenclatures.t_nomenclatures tnf ON tnf.id_nomenclature = taf.id_nomenclature_financing_type 
    LEFT JOIN objectifs o ON taf.id_acquisition_framework = o.id_acquisition_framework
    LEFT JOIN VoletSINP v ON taf.id_acquisition_framework = v.id_acquisition_framework;
    """,
    "ContactPrincipal": """
    WITH selected_dataset AS (
		SELECT DISTINCT id_acquisition_framework
		FROM tmp_process.export_datasets ed 
	)
    SELECT 
        taf.id_acquisition_framework AS IdentifiantCadreAcquisition, 
        CONCAT(tr.nom_role , ' ', tr.prenom_role) AS IdentiteContactPrincipal,
        bo.nom_organisme AS OrganismeContactPrincipal, 
        COALESCE (tr.email , bo.email_organisme) AS MailContactPrincipal,
        bo.uuid_organisme 
    FROM gn_meta.t_acquisition_frameworks taf 
    JOIN selected_dataset sd
    ON sd.id_acquisition_framework = taf.id_acquisition_framework
    JOIN gn_meta.cor_acquisition_framework_actor cda 
    ON taf.id_acquisition_framework = cda.id_acquisition_framework 
    LEFT JOIN utilisateurs.bib_organismes bo 
    ON bo.id_organisme = cda.id_organism 
    LEFT JOIN utilisateurs.t_roles tr 
    ON tr.id_role = cda.id_role 
    WHERE cda.id_nomenclature_actor_role = (SELECT id_nomenclature FROM ref_nomenclatures.t_nomenclatures tn WHERE mnemonique = 'Contact principal');
    """,
    "Financeur": """
    WITH selected_dataset AS (
		SELECT DISTINCT id_acquisition_framework
		FROM tmp_process.export_datasets ed 
	)
    SELECT 
        taf.id_acquisition_framework AS IdentifiantCadreAcquisition, 
        CONCAT(tr.nom_role , ' ', tr.prenom_role) AS IdentiteFinanceur,
        bo.nom_organisme AS OrganismeFinanceur, 
        COALESCE (tr.email , bo.email_organisme) AS MailFinanceur,
        bo.uuid_organisme 
    FROM gn_meta.t_acquisition_frameworks taf 
    JOIN selected_dataset sd
    ON sd.id_acquisition_framework = taf.id_acquisition_framework
    JOIN gn_meta.cor_acquisition_framework_actor cda 
    ON taf.id_acquisition_framework = cda.id_acquisition_framework 
    LEFT JOIN utilisateurs.bib_organismes bo 
    ON bo.id_organisme = cda.id_organism 
    LEFT JOIN utilisateurs.t_roles tr 
    ON tr.id_role = cda.id_role 
    WHERE cda.id_nomenclature_actor_role = (SELECT id_nomenclature FROM ref_nomenclatures.t_nomenclatures tn WHERE mnemonique = 'Financeur');
    """,
    "MaitriseOeuvre": """
    WITH selected_dataset AS (
		SELECT DISTINCT id_acquisition_framework
		FROM tmp_process.export_datasets ed 
	)
    SELECT 
        taf.id_acquisition_framework AS IdentifiantCadreAcquisition, 
        CONCAT(tr.nom_role , ' ', tr.prenom_role) AS IdentiteMaitreOeuvre,
        bo.nom_organisme AS OrganismeMaitreOeuvre, 
        COALESCE (tr.email , bo.email_organisme) AS MailMaitreOeuvre,
        bo.uuid_organisme 
    FROM gn_meta.t_acquisition_frameworks taf 
    JOIN selected_dataset sd
    ON sd.id_acquisition_framework = taf.id_acquisition_framework
    JOIN gn_meta.cor_acquisition_framework_actor cda 
    ON taf.id_acquisition_framework = cda.id_acquisition_framework 
    LEFT JOIN utilisateurs.bib_organismes bo 
    ON bo.id_organisme = cda.id_organism 
    LEFT JOIN utilisateurs.t_roles tr 
    ON tr.id_role = cda.id_role 
    WHERE cda.id_nomenclature_actor_role = (SELECT id_nomenclature FROM ref_nomenclatures.t_nomenclatures tn WHERE mnemonique = 'Maître d''oeuvre');
    """,
    "MaitriseOuvrage": """
    WITH selected_dataset AS (
		SELECT DISTINCT id_acquisition_framework
		FROM tmp_process.export_datasets ed 
	)
    SELECT 
        taf.id_acquisition_framework AS IdentifiantCadreAcquisition, 
        CONCAT(tr.nom_role , ' ', tr.prenom_role) AS IdentiteMaitreOuvrage,
        bo.nom_organisme AS OrganismeMaitreOuvrage, 
        COALESCE (tr.email , bo.email_organisme) AS MailMaitreOuvrage,
        bo.uuid_organisme 
    FROM gn_meta.t_acquisition_frameworks taf 
    JOIN selected_dataset sd
    ON sd.id_acquisition_framework = taf.id_acquisition_framework
    JOIN gn_meta.cor_acquisition_framework_actor cda 
    ON taf.id_acquisition_framework = cda.id_acquisition_framework 
    LEFT JOIN utilisateurs.bib_organismes bo 
    ON bo.id_organisme = cda.id_organism 
    LEFT JOIN utilisateurs.t_roles tr 
    ON tr.id_role = cda.id_role 
    WHERE cda.id_nomenclature_actor_role = (SELECT id_nomenclature FROM ref_nomenclatures.t_nomenclatures tn WHERE mnemonique = 'Maître d''ouvrage');
    """,
    "MaitriseOuvrage": """
    WITH selected_dataset AS (
		SELECT DISTINCT id_acquisition_framework
		FROM tmp_process.export_datasets ed 
	)
    SELECT 
        taf.id_acquisition_framework AS IdentifiantCadreAcquisition, 
        CONCAT(tr.nom_role , ' ', tr.prenom_role) AS IdentiteMaitreOuvrage,
        bo.nom_organisme AS OrganismeMaitreOuvrage, 
        COALESCE (tr.email , bo.email_organisme) AS MailMaitreOuvrage,
        bo.uuid_organisme 
    FROM gn_meta.t_acquisition_frameworks taf 
    JOIN selected_dataset sd
    ON sd.id_acquisition_framework = taf.id_acquisition_framework
    JOIN gn_meta.cor_acquisition_framework_actor cda 
    ON taf.id_acquisition_framework = cda.id_acquisition_framework 
    LEFT JOIN utilisateurs.bib_organismes bo 
    ON bo.id_organisme = cda.id_organism 
    LEFT JOIN utilisateurs.t_roles tr 
    ON tr.id_role = cda.id_role 
    WHERE cda.id_nomenclature_actor_role = (SELECT id_nomenclature FROM ref_nomenclatures.t_nomenclatures tn WHERE mnemonique = 'Maître d''ouvrage');
    """,
}


def create_worksheet(name, query, workbook, conn):
    worksheet = workbook.add_worksheet(name)

    cur = conn.cursor()
    cur.execute(query)

    # Write in xlsx
    row = 0
    col = 0

    for desc in cur.description:
        worksheet.write(row, col, desc.name)
        col += 1

    data = cur.fetchall()
    row = 1
    for d in data:
        col = 0
        for desc in cur.description:
            worksheet.write(row, col, d[col])
            col += 1
        row += 1
    cur.close()


###################################################
conn = psycopg2.connect(DB_CONNEXION)

workbook = xlsxwriter.Workbook("MTD_1_3_10_JDD_BDD_PNC.xlsx")

for name, query in queries_jdd.items():
    print("Create worksheet", name)
    create_worksheet(name, query, workbook, conn)

workbook.close()


workbook = xlsxwriter.Workbook("MTD_1_3_10_CA_BDD_PNC.xlsx")

for name, query in queries_ca.items():
    print("Create worksheet", name)
    create_worksheet(name, query, workbook, conn)

workbook.close()
conn.close()
