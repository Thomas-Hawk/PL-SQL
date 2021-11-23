
--MODIF 08/02 : on arrete de tronquer la table pour garder un historique
--TRUNCATE TABLE ARTICLES_TI_VEILLE_PERSO;
-- a la place on efface les contenus qui ont plus de 4 semaines
DELETE FROM ARTICLES_TI_VEILLE_PERSO WHERE DATE_CONTENU < GETDATE()-31;

-- AJOUT du 08/02
-- on met à jour les contenus existants avec CONTENUS_A_ENVOYER = 0 pour dire qu'ils ne devront pas être envoyés
UPDATE ARTICLES_TI_VEILLE_PERSO
SET CONTENUS_A_ENVOYER = 0
WHERE CONTENUS_A_ENVOYER=1;

--  Insertion des contenus calculés
INSERT INTO ARTICLES_TI_VEILLE_PERSO (
	created_dt
	,modified_dt
	,titre
	,lien
	,thematique_label
	,tags
	,MAIL_CODE
	,contenu
	,actu_infocoll
	,treaty_label
	,image
	,type_article
	,type_contenu
	,date_contenu
	,auteur
	,pdf_present
	,id_article
	,contenus_a_envoyer
	,editor_comment_date
	,note_editeur)

SELECT
T1.created_dt,T1.modified_dt,titre,lien,thematique_label,tags,TA.ID,contenu,
actu_infocoll,treaty_label,image,TB.ID,TC.ID,date_contenu,auteur,pdf_present,id_article,1,editor_comment_date,note_editeur
 FROM TMP_TI_VEILLEPERSO_CONTENUS T1
INNER JOIN USERS_TI_EMAILS TA WITH (nolock) ON T1.EMAIL_ADRESSE = TA.MAIL
LEFT JOIN DATA_TI_LST_TYPE_ARTICLE TB ON TB.FR=T1.TYPE_ARTICLE
LEFT JOIN DATA_TI_LST_TYPE_CONTENU TC ON TC.FR=T1.TYPE_CONTENU
AND exists (select 1 from DATA_TI_NL TZ WHERE TA.ID=TZ.MAIL_CODE AND TITRE_CODE=699 AND STATUT_ABONNEMENT=1)
AND T1.SIM_PARSELINE_RESULT=1;


----- TRAITEMENT DES TAGS
-- a la place on efface les contenus qui ont plus de 4 semaines
DELETE FROM ARTICLES_TI_VEILLE_PERSO_TAGS WHERE DATE_CONTENU < GETDATE()-31;

-- AJOUT du 08/02
-- on met à jour les contenus existants avec CONTENUS_A_ENVOYER = 0 pour dire qu'ils ne devront pas être envoyés
UPDATE ARTICLES_TI_VEILLE_PERSO_TAGS
SET CONTENUS_A_ENVOYER = 0
WHERE CONTENUS_A_ENVOYER=1;



-- insertion des tags calculés
INSERT INTO ARTICLES_TI_VEILLE_PERSO_TAGS (
	created_dt
	,TAG_LABEL
	,DATE_CONTENU
	,MAIL_CODE
	,contenus_a_envoyer)

SELECT
T1.created_dt,TAG_LABEL,DATE_CONTENU,TA.ID,1
 FROM TMP_TI_VEILLEPERSO_CONTENUS_TAGS T1
INNER JOIN USERS_TI_EMAILS TA WITH (nolock) ON T1.EMAIL_ADRESSE = TA.MAIL
AND exists (select 1 from DATA_TI_NL TZ WHERE TA.ID=TZ.MAIL_CODE AND TITRE_CODE=699 AND STATUT_ABONNEMENT=1)
AND T1.SIM_PARSELINE_RESULT=1

--- MIse à jour du mois en cours
UPDATE  ENVIRONMENT_VARIABLES
SET VALUE = (SELECT
CASE MONTH(GETDATE())
	WHEN 1 THEN 'janvier'
	WHEN 2 THEN 'février'
	WHEN 3 THEN 'mars'
	WHEN 4 THEN 'avril'
	WHEN 5 THEN 'mai'
	WHEN 6 THEN 'juin'
	WHEN 7 THEN 'juillet'
	WHEN 8 THEN 'aout'
	WHEN 9 THEN 'septembre'
	WHEN 10 THEN 'octobre'
	WHEN 11 THEN 'novembre'
	WHEN 12 THEN 'décembre'
END AS [Mois_En_Cours])
WHERE NAME='SYSTEM.ENV_MOIS_FR';


-- insertion du prochain trigger d'envoi à une heure après le traitement
INSERT INTO CAMPAIGNTRIGGERFLAGS (CAMPAIGNID,START_DT,ENABLED,REQCONFIRM,STATE)
VALUES (2845,DATEADD(HOUR,4,GETDATE()),1,0,0);

-- purge des triggers programmés qui ont plus de 2 mois
DELETE FROM CAMPAIGNTRIGGERFLAGS WHERE START_DT < GETDATE()-60;
