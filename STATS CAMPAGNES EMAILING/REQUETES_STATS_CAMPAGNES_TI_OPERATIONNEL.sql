

--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------RETOURNENB EMAILS ENVOYES, TX DELiVRES, NB EMAIS BOUNCE, NB CLSIUE UNIQUE, TX OUVERTURESS UNIQUE------------------
----------------------------------------------------------------------------DEBUT-----------------------------------------------------------------------


------------------------------------------------------------DEBUT PARTIE DECLARATIVE--------------------------------------------------------------------
@DELTADAYS INT
AS
BEGIN
SET NOCOUNT ON;

	DECLARE @cDesabo_campagne NVARCHAR(12);
	DECLARE @cLanding_campagne NVARCHAR(12);
	DECLARE @cCampagne_nom NVARCHAR(12);
	DECLARE @cNom NVARCHAR(255);
	DECLARE @cLanding_nb INT = 0;
	DECLARE @cDesabo_nb INT = 0;

	    IF OBJECT_ID('dbo.TI_STATS_CAMPAGNES','U') IS not NULL
	DROP TABLE dbo.TI_STATS_CAMPAGNES;

	IF OBJECT_ID('dbo.TI_STATS_CAMPAGNES','U') IS NULL
	CREATE TABLE [dbo].[TI_STATS_CAMPAGNES](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CAMPAGNE] [VARCHAR](12) NULL,
	[ID_CAMPAGNE] [int] DEFAULT 0 NOT NULL,
	[DT_EXECUTION] [DATE],
	[NOM] [VARCHAR](255) NULL,
	[NB_EMAIL_ENVOYE] [int] DEFAULT 0 NULL,
	[NB_EMAIL_DELIVRE] [int] DEFAULT 0 NULL,
	[NB_EMAIL_EN_BOUNCE] [int] DEFAULT 0 NULL,
	[NB_CLIC_UNIQUE] [int] DEFAULT 0 NULL,
	[NB_OUVERTURE_UNIQUE] [int] DEFAULT 0 NULL,
	[NB_DESABONNE] [int] DEFAULT 0 NULL,
	[NB_CLIC_LANDING] [int] DEFAULT 0 NULL
	) ON [PRIMARY];




--------------------------------------------------------------------------INSERT------------------------------------------------------------------------------

--- modification du 22/02/21 par LC : rajout d'un left pour ne garder que les 11 premiers caractères du code campagne
	INSERT INTO TI_STATS_CAMPAGNES (CAMPAGNE, ID_CAMPAGNE, DT_EXECUTION, NB_EMAIL_ENVOYE, NB_EMAIL_DELIVRE, NB_EMAIL_EN_BOUNCE, NB_CLIC_UNIQUE, NB_OUVERTURE_UNIQUE)
		SELECT
		left(t1.description,11) AS 'CAMPAGNE',
		t1.id AS 'ID_CAMPAGNE',
		t1.RUN_DT AS 'DT_EXECUTION',
		SUM(targetcount) AS 'NB_EMAIL_ENVOYE',
		SUM(deliverycount) AS 'NB_EMAIL_DELIVRE',
		SUM(bouncecount) AS 'NB_EMAIL_EN_BOUNCE',
		SUM(uclickcount) AS 'NB_CLIC_UNIQUE',
		SUM(uviewcount) AS 'NB_OUVERTURE_UNIQUE'
		FROM campaigns t1 WITH (nolock)
		JOIN sim_reporting_flowmetrics t2 WITH (nolock) ON t1.id = t2.campaignid
			WHERE  t1.description like '/72/%' AND t1.RUN_DT >= GETDATE()-@DELTADAYS
		GROUP BY t1.description, t1.id,t1.RUN_DT;

	----------------------------------------------------------------------------DECLARE cursor -----------------------------------------------------------
-----------CURSOR nb desabo------------------------------------------------------------------------------------------
	DECLARE cDesabo CURSOR
	FOR SELECT t2.ID_CAMPAGNE, COUNT(*) AS 'NB_DESABONNE'
	FROM flags t1 WITH (nolock)
	JOIN TI_STATS_CAMPAGNES t2 WITH (nolock) ON t2.ID_CAMPAGNE = t1.campaignid
	WHERE EXISTS( SELECT 1
		FROM campaign_actions t3 WITH (nolock)
		WHERE t3.campaignid = t1.campaignid AND t3.actionid = t1.actionid
			AND EXISTS ( SELECT 1
			FROM mail_probes t4 WITH (nolock)
			WHERE t4.probeid = t1.probeid AND t4.mailid = t3.mailid AND t4.category = 'OPTOUT' AND t4.probeid>0 ))
	GROUP BY t2.ID_CAMPAGNE;

----------CURSOR nom campagne------------------------------------------------------------------------------------------
	DECLARE cCampagneName CURSOR
	FOR SELECT t1.description, t1.name
	FROM campaigns t1 WITH (nolock)
	JOIN TI_STATS_CAMPAGNES t2 WITH (nolock) ON t1.id = t2.ID_CAMPAGNE
	GROUP BY t1.description, t1.name
	HAVING t1.name not like 'Relance%';

----------CURSOR nb landing------------------------------------------------------------------------------------------
	DECLARE cLanding CURSOR
	FOR SELECT t2.ID_CAMPAGNE, COUNT(*) AS 'NB_CLIC_LANDING'
	FROM flags t1 WITH (nolock)
	JOIN TI_STATS_CAMPAGNES t2 WITH (nolock) ON t2.ID_CAMPAGNE = t1.campaignid
		AND EXISTS( SELECT 1
		FROM campaign_actions t3 WITH (nolock)
		WHERE t3.campaignid = t1.campaignid AND t3.actionid = t1.actionid
		AND EXISTS ( SELECT 1
			FROM mail_probes t4 WITH (nolock)
			WHERE t4.probeid = t1.probeid AND t4.mailid = t3.mailid AND t4.category = 'TI_LANDING' AND t4.probeid>0 ))
	GROUP BY t2.ID_CAMPAGNE;
	---------------------------------------------------------------FIN PARTIE DECLARATIVE---------------------------------------------------------------------



-------------------------------------------------------------------------UPDATE avec cursor 1 nb desabo--------------------------------------------------------------------
	OPEN cDesabo;
	FETCH NEXT FROM cDesabo INTO @cDesabo_campagne, @cDesabo_nb;

	WHILE @@FETCH_STATUS = 0

		BEGIN
			UPDATE TI_STATS_CAMPAGNES
			SET NB_DESABONNE = @cDesabo_nb
			WHERE @cDesabo_campagne = TI_STATS_CAMPAGNES.ID_CAMPAGNE ;
			FETCH NEXT FROM cDesabo INTO @cDesabo_campagne, @cDesabo_nb;

	END


	CLOSE cDesabo;
	DEALLOCATE cDesabo;
	-------------------------------------------------------------------------UPDATE avec cursor 2 name--------------------------------------------------------------------
		OPEN cCampagneName;
	FETCH NEXT FROM cCampagneName INTO @cCampagne_nom, @cNom;


	WHILE @@FETCH_STATUS = 0

		BEGIN
			UPDATE TI_STATS_CAMPAGNES
			SET NOM = @cNom
			WHERE @cCampagne_nom = TI_STATS_CAMPAGNES.CAMPAGNE ;
			FETCH NEXT FROM cCampagneName INTO @cCampagne_nom, @cNom;

	END


	CLOSE cCampagneName;
	DEALLOCATE cCampagneName;

-------------------------------------------------------------------------UPDATE avec cursor 3 nb landing--------------------------------------------------------------------
	OPEN cLanding;
	FETCH NEXT FROM cLanding INTO @cLanding_campagne, @cLanding_nb;

	WHILE @@FETCH_STATUS = 0

		BEGIN

			UPDATE TI_STATS_CAMPAGNES
			SET NB_CLIC_LANDING = @cLanding_nb
			WHERE @cLanding_campagne = TI_STATS_CAMPAGNES.ID_CAMPAGNE ;
			FETCH NEXT FROM cLanding INTO @cLanding_campagne, @cLanding_nb;
	END



	CLOSE cLanding;
	DEALLOCATE cLanding;


END

------------------------------------------------------------------------FIN-----------------------------------------------------------------------------
--///////////////////////////////////////////////////////////////PARTIE SELLIGENT/////////////////////////////////////////////////////////////////////--
--------------------------------------------------------------------------------------------------------------------------------------------------------






--------------------------------------------------------------------------------------------------------------------------------------------------------
--////////////////////////////////////////////////////////////////PARTIE ATHENA///////////////////////////////////////////////////////////////////////--
---------------------------------------------------------------------DEBUT------------------------------------------------------------------------------

--------------------------------------------------------NB DI-----------------------------------------------
SELECT substring(t2.sap_project, 1,12) AS CAMPAGNE, count(*) AS NB_DI, CURDATE() AS DATE_CALCUL
FROM capsp_customerrelationrequests t1
JOIN campaigns t2
ON t1.campaign_id = t2.id
WHERE t2.date_entered >= CURDATE() - INTERVAL "+context.deltadays+" DAY AND t2.deleted = 0 AND t2.sap_project like '/72/%'
GROUP BY substring(t2.sap_project, 1, 12)

SELECT  count(*) AS NB_DI
FROM capsp_customerrelationrequests t1
JOIN campaigns t2
ON t1.campaign_id = t2.id
WHERE  t1.deleted = 0 AND t2.sap_project like  '"+  ((String)globalMap.get("myKey1"))  +"%'
-----------------------------------------------------------------------------------------------------------


---------------------------------------NB appel/rdv----------------------------------------------------------
SELECT SUM(NB_RDV_APPEL)
FROM (
    SELECT  count(*) AS NB_RDV_APPEL
    FROM calls t1
    JOIN campaigns t2 ON t1.campaign_id = t2.id
    JOIN users t3 on t1.assigned_user_id = t3.id
    WHERE t1.deleted = 0 AND t2.sap_project like '"+ ((String)globalMap.get("myKey1")) +"%' AND t3.id = '850ba435-4c33-7442-6a27-55ca057fb0c8' -- id de Kristel Donjon
    GROUP BY substring(t2.sap_project, 1, 12)
    UNION
    SELECT  count(*) AS NB_RDV_APPEL
    FROM meetings t1
    JOIN campaigns t2 ON t1.campaign_id = t2.id
    JOIN users t3 on t1.assigned_user_id = t3.id
    WHERE t1.deleted = 0 AND t2.sap_project like '"+ ((String)globalMap.get("myKey1")) +"%'  AND t3.id = '850ba435-4c33-7442-6a27-55ca057fb0c8' -- id de Kristel Donjon
	) as total

----------------------------------------------------------------------------------------------------------

--------------------------------------------NB AFFAIRE TOTAL---------------------------------------------------
SELECT  COUNT(*) AS NB_AFFAIRE_TOTAL
FROM opportunities t1
JOIN campaigns t2
ON t1.campaign_id = t2.id
WHERE t1.deleted = 0 AND t2.sap_project like '"+ ((String)globalMap.get("myKey1")) +"%'
------------------------------------------------------------------------------------------------------------------

-----------------------------------------------NB AFFAIRE GAGNE--------------------------------------------------------------
SELECT

 (SELECT COUNT(*)
FROM opportunities t1
JOIN campaigns t2
ON t1.campaign_id = t2.id
WHERE t1.deleted = 0 AND t2.sap_project like '"+  ((String)globalMap.get("myKey1"))  +"%' AND t1.sales_stage like 'in_process'
) AS NB_AFFAIRES_EN_COURS,

(SELECT COUNT(*)
FROM opportunities t1
JOIN campaigns t2
ON t1.campaign_id = t2.id
WHERE t1.deleted = 0 AND t2.sap_project like '"+ ((String)globalMap.get("myKey1")) +"%' AND t1.sales_stage like 'Closed Won'
) AS NB_AFFAIRES_GAGNE,

(SELECT COUNT(*)
FROM opportunities t1
JOIN campaigns t2
ON t1.campaign_id = t2.id
WHERE  t1.deleted = 0 AND t2.sap_project like '"+  ((String)globalMap.get("myKey1"))  +"%' AND t1.sales_stage like 'Closed Lost'
) AS NB_AFFAIRES_PERDUE,

(SELECT  SUM(t1.amount)
FROM opportunities t1
JOIN campaigns t2
ON t1.campaign_id = t2.id
WHERE  t1.deleted = 0 AND t2.sap_project like '"+  ((String)globalMap.get("myKey1"))  +"%'
) AS CA_TOTAL

------------------------------------------------------------------------FIN-----------------------------------------------------------------------------
--//////////////////////////////////////////////////////////////////PARTIE ATHENA/////////////////////////////////////////////////////////////////////--
--------------------------------------------------------------------------------------------------------------------------------------------------------