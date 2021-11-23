@SOCIETE NVARCHAR(250)
AS
BEGIN
SET NOCOUNT ON;


IF OBJECT_ID('dbo.STATS_SOCIETES', 'U') IS NULL
	  CREATE TABLE [dbo].[STATS_SOCIETES](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TYPE_STAT] [varchar](1000)  NULL,
	[VALEUR] [float]  NULL,
	[SOCIETE] [varchar](20)  NULL,
	[DATE_CALCUL] [date]DEFAULT GETDATE() NULL,
	[DATE_SUPPRESSION] [date] NULL,
	[SEMAINE_CREATION] [int] NULL,

) ON [PRIMARY]


DECLARE @counter INT = 1;-- Compteur pour les societes
DECLARE @societe_current varchar(100);-- Variable pour stocker le nom de la societe en cours
DECLARE @LST_SOCIETES TABLE(ID INT IDENTITY, NOM_SOCIETE VARCHAR(100))-- Table temporaire pour stocker le nom des societes � traiter
DECLARE @Sql varchar(1000)-- Variable temporaire pour ecrire une requete SQL � executer

-- j'initialise les societes dans ma table tempoare @LST_SOCIETES
INSERT INTO @LST_SOCIETES
    (NOM_SOCIETE)
SELECT * FROM STRING_SPLIT(@SOCIETE, ',');


-- Cette partie permet de preparer un paterne pour differentes requetes liees au stats d'emails avec la la fonction IIF -->
DECLARE @Sql_maker_IIF varchar(1000) -- Variable pour integrer la requete de suppression d'une ligne
SET @Sql_maker_IIF = NULL
SET @counter = 1
WHILE @counter <= (SELECT count(*) FROM @LST_SOCIETES) -- Tant qu'il y a des societes
BEGIN
	IF @Sql_maker_IIF is NULL -- Cette partie permet d'eviter '+' au debut de la requetes de suppression
		SET @Sql_maker_IIF = 'IIF ('+(SELECT NOM_SOCIETE FROM @LST_SOCIETES WHERE ID = @counter)+'_ACTIVITE_DT IS NOT NULL,1,0)'  -- requette de suppression d'une ligne si toutes les societes sont � null
	ELSE -- Cette partie ajoute une societe is null tant qu'il ya des societe
		SET @Sql_maker_IIF += ' + IIF ('+(SELECT NOM_SOCIETE FROM @LST_SOCIETES WHERE ID = @counter)+'_ACTIVITE_DT IS NOT NULL,1,0)' ;
	SET @counter = @counter + 1
END

----------------------------------------------------------------------------------------FIN DE la PARTIE DECLARATIVE---------------------------------------------------------------------------------------

-- Cette partie permet de relaliser des statistiques sur chaqu'une des societes
SET @counter = 1
DECLARE @sql_stats varchar(1000)
DECLARE @NBR_societes int
SET @NBR_societes = (SELECT count(*) FROM @LST_SOCIETES)

WHILE @counter <= @NBR_societes
BEGIN
	SET @societe_current = (SELECT NOM_SOCIETE FROM @LST_SOCIETES WHERE ID = @counter)

	-- 1 Nombre d'email par societe
	SET @sql='SELECT ''NB_mails_total'', count(*),'''+@societe_current+'''FROM DATA_ADMIN_EMAIL_GRP_WEKAFR WHERE '+@societe_current+'_ACTIVITE_DT IS NOT NULL';
	SET @sql_stats='INSERT INTO STATS_SOCIETES (TYPE_STAT,VALEUR,SOCIETE) '+@sql+'';
	exec( @sql_stats);

	-- 3 Nombre d'email partage pour chaque societe
	SET @sql='SELECT ''NB_ptg_par_cie'',
	SUM (IIF ('+@societe_current+'_ACTIVITE_DT IS NOT NULL,1,0)) ,'''+@societe_current+'''FROM DATA_ADMIN_EMAIL_GRP_WEKAFR
	WHERE '+@Sql_maker_IIF+' > 1';
	SET @sql_stats='INSERT INTO STATS_SOCIETES (TYPE_STAT,VALEUR,SOCIETE) '+@sql+'';
	exec( @sql_stats);

	SET @sql='SELECT ''NB_ptg_par_cie_pc'',
	cast(SUM (IIF ('+@societe_current+'_ACTIVITE_DT IS NOT NULL,1,0))AS FLOAT)*100/cast((SELECT  count(*) FROM DATA_ADMIN_EMAIL_GRP_WEKAFR WHERE '+@societe_current+'_ACTIVITE_DT IS NOT NULL ) as float),'''+@societe_current+'''
	FROM DATA_ADMIN_EMAIL_GRP_WEKAFR
	WHERE '+@Sql_maker_IIF+' > 1 ';
	SET @sql_stats='INSERT INTO STATS_SOCIETES (TYPE_STAT,VALEUR,SOCIETE) '+@sql+'';
	exec( @sql_stats);

	-- 1 Nombre demail qui appartient a une societe par societe
	SET @sql='SELECT ''NB_mail_appartient_une_cie_par_cie'', SUM (IIF ('+@societe_current+'_ACTIVITE_DT IS NOT NULL,1,0)),'''+@societe_current+'''
	FROM DATA_ADMIN_EMAIL_GRP_WEKAFR
	WHERE '+@Sql_maker_IIF+' = 1 ';

	SET @sql_stats='INSERT INTO STATS_SOCIETES (TYPE_STAT,VALEUR,SOCIETE) '+@sql+'';
	exec( @sql_stats);

SET @counter += 1
END

	-- 2 Nombre d'email qui appartient à une societe
	SET @sql='SELECT ''NB_mail_appartient_une_cie'', count(*),''GLOBAL''
	 FROM DATA_ADMIN_EMAIL_GRP_WEKAFR WHERE '+@Sql_maker_IIF+' = 1'
	SET @sql_stats='INSERT INTO STATS_SOCIETES (TYPE_STAT,VALEUR,SOCIETE) '+@sql+''
	exec( @sql_stats)

	-- Nombre d'emails present dans Selligent
	SET @sql='SELECT ''NB_mails_total'', count(*),''GLOBAL''
	 FROM DATA_ADMIN_EMAIL_GRP_WEKAFR'
	SET @sql_stats='INSERT INTO STATS_SOCIETES (TYPE_STAT,VALEUR,SOCIETE) '+@sql+''
	exec( @sql_stats)

	-- 4 Nombre d'email presents dans toutes les societes
	SET @sql='SELECT ''NB_mail_appartient_toutes_cie'',
	COUNT(*) ,''GLOBAL''
	FROM DATA_ADMIN_EMAIL_GRP_WEKAFR WHERE '+@Sql_maker_IIF+' = 4'
	SET @sql_stats='INSERT INTO STATS_SOCIETES (TYPE_STAT,VALEUR,SOCIETE) '+@sql+''
	exec( @sql_stats)


END