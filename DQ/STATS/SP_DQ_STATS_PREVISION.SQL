@SOCIETE NVARCHAR(250)

AS
BEGIN
SET NOCOUNT ON;

DECLARE @counter INT = 1;-- Compteur pour les societes
DECLARE @societe_current varchar(100);-- Variable pour stocker le nom de la societe en cours
DECLARE @LST_SOCIETES TABLE(ID INT IDENTITY, NOM_SOCIETE VARCHAR(100))-- Table temporaire pour stocker le nom des societes � traiter
DECLARE @Sql varchar(1000)-- Variable temporaire pour ecrire une requete SQL executer

-- j'initialise les societes dans ma table temporaire @LST_SOCIETES
INSERT INTO @LST_SOCIETES
    (NOM_SOCIETE)
SELECT * FROM STRING_SPLIT(@SOCIETE, ',')

-- Cette partie permet de realiser des statistiques sur chaqu'une des societes
SET @counter = 1
DECLARE @sql_stats varchar(1000)
DECLARE @NBR_societes int
SET @NBR_societes = (SELECT count(*) FROM @LST_SOCIETES)
-------------------------------------------------------------------------------------------FIN DE LA PARIE DECLARATIVE---------------------------------------------------------------------------------------------

WHILE @counter <= @NBR_societes
BEGIN
	SET @societe_current = (SELECT NOM_SOCIETE FROM @LST_SOCIETES WHERE ID = @counter)

	-- Permet d'afficher le nombre d'emails qui vont etre supprimés par societe
	SET @sql='SELECT ''NB_mail_supprime'',count(*),'''+@societe_current+''',  DATEFROMPARTS ( DATEPART(YEAR, DATEADD(year, 3, '+@societe_current+'_ACTIVITE_DT)), DATEPART(month, '+@societe_current+'_ACTIVITE_DT), 01 )
	FROM DATA_ADMIN_EMAIL_GRP_WEKAFR
	WHERE '+@societe_current+'_ACTIVITE_DT > DATEADD(year, -3, GETDATE())
	GROUP BY DATEFROMPARTS ( DATEPART(YEAR, DATEADD(year, 3, '+@societe_current+'_ACTIVITE_DT)), DATEPART(month, '+@societe_current+'_ACTIVITE_DT), 01 )';

	SET @sql_stats='INSERT INTO STATS_SOCIETES (TYPE_STAT,VALEUR,SOCIETE,DATE_SUPPRESSION) '+@sql+'';
	exec( @sql_stats);

SET @counter += 1
END

 -- Permet d'afficher le nombre d'emails qui vont etre supprimés pour toutes les societes
INSERT INTO STATS_SOCIETES (TYPE_STAT,VALEUR,SOCIETE,DATE_SUPPRESSION)

SELECT 'NB_mail_supprime',count(*),'GLOBAL',  DATEFROMPARTS ( DATEPART(YEAR, DATEADD(year, 3, DERNIERE_ACTIVITE_DT)), DATEPART(month, DERNIERE_ACTIVITE_DT), 01 )
	FROM DATA_ADMIN_EMAIL_GRP_WEKAFR
	WHERE DERNIERE_ACTIVITE_DT > DATEADD(year, -3, GETDATE())
	GROUP BY DATEFROMPARTS ( DATEPART(YEAR, DATEADD(year, 3, DERNIERE_ACTIVITE_DT)), DATEPART(month, DERNIERE_ACTIVITE_DT), 01 );

-- Permet d'afficher pour l'année le nombre de mail créé par semaine
INSERT INTO STATS_SOCIETES (TYPE_STAT,VALEUR,SOCIETE,SEMAINE_CREATION)

SELECT 'NB_mail_cree',count(*),'GLOBAL', DATEADD(day, -1, CAST(getdate() AS date))
	FROM DATA_ADMIN_EMAIL_GRP_WEKAFR
	WHERE PREMIERE_CREATION_DT =  DATEADD(day, -1, CAST(getdate() AS date));

END