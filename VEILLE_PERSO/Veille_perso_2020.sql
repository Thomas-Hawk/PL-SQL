CREATE OR REPLACE FUNCTION ti_veilleperso.sp_ti_veille_perso(nbdays integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
declare
  retval int;
	BEGIN


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------- traite les articles et les tags associés aux utilisateurs pour les ACTUALITES----------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DELETE FROM TI_VEILLEPERSO.ARTICLES_TI_VEILLE_PERSO WHERE DATE_CONTENU < CURRENT_DATE-120;


-- on met à jour les contenus existants avec CONTENUS_A_ENVOYER = 0 pour dire qu'ils ne devront pas être envoyés
UPDATE TI_VEILLEPERSO.ARTICLES_TI_VEILLE_PERSO
SET CONTENUS_A_ENVOYER = false
WHERE CONTENUS_A_ENVOYER=true;

--  SELECTION contenu ACTU
INSERT INTO TI_VEILLEPERSO.ARTICLES_TI_VEILLE_PERSO (created_dt, TITRE,LIEN,email_adresse,CONTENU,ACTU_INFOCOLL,IMAGE,TYPE_ARTICLE,TYPE_CONTENU,DATE_CONTENU,ID_ARTICLE,ID_SELLIGENT_CONTENU,CONTENUS_A_ENVOYER)
SELECT distinct
current_timestamp,
	WEKA_MDM.GD_TI_CONTENU_ACTUALITES.TITRE,
	WEKA_MDM.GD_TI_CONTENU_ACTUALITES.LIEN,
	WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS.email_adresse AS MAIL_CODE,
	CONTENU,
	true AS ACTU_INFOCOLL,
	WEKA_MDM.GD_TI_CONTENU_ACTUALITES.IMAGE,
	WEKA_MDM.GD_TI_CONTENU_ACTUALITES.TYPE_ARTICLE,
	WEKA_MDM.GD_TI_CONTENU_ACTUALITES.TYPE_CONTENU,
	WEKA_MDM.GD_TI_CONTENU_ACTUALITES.date_publication,
	WEKA_MDM.GD_TI_CONTENU_ACTUALITES.ID_ARTICLE,
	(SELECT MAX(id_unique) FROM WEKA_MDM.GD_TI_CONTENU_ACTUALITES T1 WHERE T1.ID_ARTICLE = WEKA_MDM.GD_TI_CONTENU_ACTUALITES.ID_ARTICLE),
	true
FROM WEKA_MDM.GD_TI_CONTENU_ACTUALITES
	LEFT JOIN WEKA_MDM.GD_TI_THESAURUS_CONTENUS
		ON cast(WEKA_MDM.GD_TI_CONTENU_ACTUALITES.ID_ARTICLE as text) = WEKA_MDM.GD_TI_THESAURUS_CONTENUS.ID_ARTICLE AND ORIGINE_ARTICLE='1'
		AND WEKA_MDM.GD_TI_THESAURUS_CONTENUS.b_batchid = (select MAX(WEKA_MDM.GD_TI_THESAURUS_CONTENUS.b_batchid) from WEKA_MDM.GD_TI_THESAURUS_CONTENUS)
	LEFT JOIN WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS
		ON WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS.TAG_ID = WEKA_MDM.GD_TI_THESAURUS_CONTENUS.TAG_ID
		AND WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS.b_batchid = (select MAX(WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS.b_batchid) from WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS)
WHERE WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS.TAG_ID is nOT NULL
AND WEKA_MDM.GD_TI_CONTENU_ACTUALITES.STATUT = 'publish'
AND WEKA_MDM.GD_TI_CONTENU_ACTUALITES.date_publication > CURRENT_DATE-nbdays;




---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------- traite les articles et les tags associés aux utilisateurs pour les INFO COLLECTION-----------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO ARTICLES_TI_VEILLE_PERSO (created_dt,TITRE,LIEN,email_adresse,CONTENU,ACTU_INFOCOLL,ID_SELLIGENT_CONTENU,DATE_CONTENU,ID_ARTICLE,AUTEUR,PDF_PRESENT,CONTENUS_A_ENVOYER,NOTE_EDITEUR,EDITOR_COMMENT_DATE)
SELECT distinct
current_timestamp,
	WEKA_MDM.GD_TI_CONTENU_INFO_COLL.TITRE,
	(SELECT LIEN FROM WEKA_MDM.GD_TI_CONTENU_INFO_COLL T1 WHERE T1.ID_ARTICLE = WEKA_MDM.GD_TI_CONTENU_INFO_COLL.ID_ARTICLE limit 1) AS LIEN,
	WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS.email_adresse AS MAIL_CODE,
	CONTENU,
	false AS ACTU_INFOCOLL,
	(SELECT MAX(ID_UNIQUE) FROM WEKA_MDM.GD_TI_CONTENU_INFO_COLL T1 WHERE T1.ID_ARTICLE = WEKA_MDM.GD_TI_CONTENU_INFO_COLL.ID_ARTICLE) AS ID_ARTICLE_SELLIGENT,
	WEKA_MDM.GD_TI_CONTENU_INFO_COLL.date_modification,
	WEKA_MDM.GD_TI_CONTENU_INFO_COLL.ID_ARTICLE,
	WEKA_MDM.GD_TI_CONTENU_INFO_COLL.AUTEUR,
	WEKA_MDM.GD_TI_CONTENU_INFO_COLL.PDF_PRESENT,
	true ,
	WEKA_MDM.GD_TI_CONTENU_INFO_COLL.NOTE_EDITEUR,
	WEKA_MDM.GD_TI_CONTENU_INFO_COLL.EDITEUR_COMMENT_DATE
FROM WEKA_MDM.GD_TI_CONTENU_INFO_COLL
	LEFT JOIN WEKA_MDM.GD_TI_THESAURUS_CONTENUS
		ON cast(WEKA_MDM.GD_TI_CONTENU_INFO_COLL.ID_ARTICLE as text) = WEKA_MDM.GD_TI_THESAURUS_CONTENUS.ID_ARTICLE AND ORIGINE_ARTICLE='0'
		AND WEKA_MDM.GD_TI_THESAURUS_CONTENUS.b_batchid = (select MAX(WEKA_MDM.GD_TI_THESAURUS_CONTENUS.b_batchid) from WEKA_MDM.GD_TI_THESAURUS_CONTENUS)
	LEFT JOIN WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS
		ON WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS.TAG_ID = WEKA_MDM.GD_TI_THESAURUS_CONTENUS.TAG_ID
		AND WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS.b_batchid = (select MAX(WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS.b_batchid) from WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS)
WHERE WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS.TAG_ID is nOT NULL
	AND WEKA_MDM.GD_TI_CONTENU_INFO_COLL.STATUT IN ('published','validated')
	AND WEKA_MDM.GD_TI_CONTENU_INFO_COLL.date_modification > CURRENT_DATE-nbdays;


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------ Permet de récupérer et concatener avec du html tous les tags d'un article par utilisateur --------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
update TI_VEILLEPERSO.ARTICLES_TI_VEILLE_PERSO t1
set modified_dt =current_timestamp , tags = ( select string_agg(distinct '<span style="background-color:#e2e1e1;margin:0 10px 10px 0;display:inline-block;font-size:13px;letter-spacing:0.75px;
font-family:Arial,sans-serif;color:#4d5356;border-top: 5px solid #e2e1e1;border-left: 10px solid #e2e1e1;border-bottom: 5px solid #e2e1e1;border-right: 10px solid #e2e1e1;">'
|| cast (gtt.tag_label as text)|| '</span>', '')
from TI_VEILLEPERSO.ARTICLES_TI_VEILLE_PERSO VP
inner join WEKA_MDM.GD_TI_THESAURUS_CONTENUS TC ON VP.id_article = TC.id_article
	and TC.b_batchid = (select MAX(WEKA_MDM.GD_TI_THESAURUS_CONTENUS.b_batchid) from WEKA_MDM.GD_TI_THESAURUS_CONTENUS)
	and TC.origine_article = cast ( cast(VP.actu_infocoll as integer)as text)
inner JOIN WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS UT ON UT.TAG_ID = TC.tag_id
	and UT.b_batchid = (select MAX(WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS.b_batchid) from WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS)
	and vp.email_adresse = ut.email_adresse
inner join weka_mdm.gd_ti_thesaurus gtt on gtt.tag_id = UT.tag_id
and gtt.b_batchid = (select MAX(WEKA_MDM.GD_TI_THESAURUS.b_batchid) from WEKA_MDM.GD_TI_THESAURUS)
where vp.contenus_a_envoyer =true and vp.id = t1.id)
WHERE CONTENUS_A_ENVOYER=true;



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------ Permet de récupérer tous les tags par utilisateur ------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DELETE FROM TI_VEILLEPERSO.articles_ti_veille_perso_tags WHERE DATE_CONTENU < CURRENT_DATE-120;

-- on met à jour les contenus existants avec CONTENUS_A_ENVOYER = 0 pour dire qu'ils ne devront pas être envoyés
UPDATE TI_VEILLEPERSO.articles_ti_veille_perso_tags
SET CONTENUS_A_ENVOYER = false, modified_dt = current_timestamp
WHERE CONTENUS_A_ENVOYER=true;

insert into TI_VEILLEPERSO.articles_ti_veille_perso_tags  (created_dt,email_adresse,tag_label,date_contenu,contenus_a_envoyer)
select
	current_timestamp,
	vp.email_adresse,
	string_agg(distinct '<span style="background-color:#e2e1e1;margin:0 10px 10px 0;display:inline-block;font-size:13px;letter-spacing:0.75px;
font-family:Arial,sans-serif;color:#4d5356;border-top: 5px solid #e2e1e1;border-left: 10px solid #e2e1e1;border-bottom: 5px solid #e2e1e1;border-right: 10px solid #e2e1e1;">'
|| cast (gtt.tag_label as text)|| '</span>', ''),
	current_date,
	true

from TI_VEILLEPERSO.ARTICLES_TI_VEILLE_PERSO VP
inner join WEKA_MDM.GD_TI_THESAURUS_CONTENUS TC ON VP.id_article = TC.id_article
	and TC.b_batchid = (select MAX(WEKA_MDM.GD_TI_THESAURUS_CONTENUS.b_batchid) from WEKA_MDM.GD_TI_THESAURUS_CONTENUS)
	and TC.origine_article = cast ( cast(VP.actu_infocoll as integer)as text)
inner JOIN WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS UT ON UT.TAG_ID = TC.tag_id
	and vp.email_adresse = ut.email_adresse
	and UT.b_batchid = (select MAX(WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS.b_batchid) from WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS)
inner join weka_mdm.gd_ti_thesaurus gtt on gtt.tag_id = UT.tag_id
WHERE CONTENUS_A_ENVOYER=true
group by 2;

select count(*) into retval
from TI_VEILLEPERSO.ARTICLES_TI_VEILLE_PERSO VP
WHERE CONTENUS_A_ENVOYER=true;
  return retval;

	END;
$function$
;
