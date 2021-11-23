@SOCIETE NVARCHAR(250)

AS
BEGIN
SET NOCOUNT ON;

-- Variable temporaire pour ecrire une requete SQL à executer
DECLARE @sql varchar(1000)

-- Table temporaire pour stocker le nom des societes à traiter
DECLARE @LST_SOCIETES TABLE(ID INT IDENTITY, NOM_SOCIETE VARCHAR(100))

-- Compteur pour les societes
DECLARE @counter INT

-- j'initialise les societes dans ma table temporaire @LST_SOCIETES
INSERT INTO @LST_SOCIETES
    (NOM_SOCIETE)
SELECT * FROM STRING_SPLIT(@SOCIETE, ',')

-- Cette partie permet de preparer un paterne pour la mise à jour de 'DATE_DERNIERE_ACTIVITE -->
DECLARE @Sql_maker_societe_activite varchar(1000)
DECLARE @Sql_maker_societe_creation varchar(1000)

SET @Sql_maker_societe_activite = NULL
SET @Sql_maker_societe_creation = NULL
SET @counter = 1
WHILE @counter <= (SELECT count(*) FROM @LST_SOCIETES)

BEGIN
	IF @Sql_maker_societe_creation is NULL -- Cette partie permet d'eviter ',' en debut
		BEGIN
			SET @Sql_maker_societe_activite = '('+(SELECT NOM_SOCIETE FROM @LST_SOCIETES WHERE ID = @counter)+'_ACTIVITE_DT)'
			SET @Sql_maker_societe_creation = '('+(SELECT NOM_SOCIETE FROM @LST_SOCIETES WHERE ID = @counter)+'_CREATION_DT)'
		END
	ELSE
		BEGIN
			SET @Sql_maker_societe_activite += ',('+(SELECT NOM_SOCIETE FROM @LST_SOCIETES WHERE ID = @counter)+'_ACTIVITE_DT)'
			SET @Sql_maker_societe_creation += ',('+(SELECT NOM_SOCIETE FROM @LST_SOCIETES WHERE ID = @counter)+'_CREATION_DT)'
		END
	SET @counter +=  1
END;


-------------------------------------------------------------------FIN PARTIE DECLARATIVE---------------------------------------------------------------


-- Permet de mettre a jour la colonne 'DATE_DERNIERE_ACTIVITE'
SET @sql='UPDATE DATA_ADMIN_EMAIL_GRP_WEKAFR
SET DERNIERE_ACTIVITE_DT = (SELECT Max(v) FROM (VALUES '+@Sql_maker_societe_activite+') AS value(v))';
EXEC(@sql); -- Execute la requete


-- Permet de mettre a jour la colonne 'PREMIERE_CREATION_DT'
SET @sql='UPDATE DATA_ADMIN_EMAIL_GRP_WEKAFR
SET PREMIERE_CREATION_DT = (SELECT Max(v) FROM (VALUES '+@Sql_maker_societe_creation+') AS value(v))';
EXEC(@sql); -- Execute la requete

END