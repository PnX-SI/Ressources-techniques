alter table utilisateurs.bib_organismes add if not exists cd_organisme VARCHAR;
insert into utilisateurs.bib_organismes (
	cd_organisme,
	nom_organisme,
	adresse_organisme,
	cp_organisme,
	ville_organisme,
	tel_organisme,
	email_organisme,
	url_organisme
)
select
	cd_organisme,
	case when lb_organisme_complet is null then lb_organisme
	else lb_organisme_complet end as nom_organisme,
	TRIM(SUBSTRING(CONCAT(ligne1, ' ',ligne2, ' ',ligne3), 0, 128)) as adresse_organisme,
	TRIM(SUBSTRING(code_postal,0, 5)) as cp_organisme,
	ville as ville_organisme,
	regexp_replace(tel_1, '[\. \-\+]', '', 'g') as tel_organisme,
	case 
		when etiq_texte_1 = 'Mél' then texte_1
		when etiq_texte_2 = 'Mél' then texte_2
	end as email_organisme,
	case 
		when etiq_texte_1 = 'Site' then texte_1
		when etiq_texte_2 = 'Site' then texte_2
	end as url_organisme
from access.organismes
where lb_organisme_complet is not null or lb_organisme is not null
;


insert into utilisateurs.t_roles (
	id_organisme,
	nom_role,
	prenom_role,
	desc_role,
	email,
	remarques	
)
select 
	case when id_organisme is null then -1 else id_organisme end as id_organisme,
	lb_nom as nom_role,
	lb_prenom as prenom_role,
	TRIM(CONCAT(fonction, ' ', fonction_2)),
	case 
		when etiq_texte_1 like '%Mél%' then texte_1
		when etiq_texte_2 like '%Mél%' then texte_2
	end as email,
	commentaire as remarques
		from access.contacts c 
	left join utilisateurs.bib_organismes bo 
		on bo.cd_organisme = c.cd_organisme 
;