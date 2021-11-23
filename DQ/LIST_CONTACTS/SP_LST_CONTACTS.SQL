@CURRENT_SOCIETE NVARCHAR(250),
@CURRENT_MAIl NVARCHAR(250)	-- société en cours
AS
BEGIN
SET NOCOUNT ON;


DECLARE @LST_TABLES_USERS TABLE(ID INT IDENTITY, NOM_TABLE VARCHAR(100));-- Table temporaire pour stocker le nom des tables USERS
DECLARE @counter_TABLE INT = 1;-- Compteur pour les tables des users
DECLARE @table_users varchar(100);-- Variable pour stocker le nom d'une table de USERS
DECLARE @sql varchar(3000);-- Variable temporaire pour ecrire une requete SQL à executer
SET @sql = NULL
-------------------------------------------------------------------FIN PARTIE DECLARATIVE--------------------------------------------------------------------------

--  Cherche  toutes les tables de la societe en cours à l'aide de 'information_schema.tables' à inserer dans @LST_TABLES_USERS
INSERT INTO @LST_TABLES_USERS(NOM_TABLE) SELECT table_name FROM information_schema.tables
	WHERE table_name LIKE CONCAT('USERS_',@CURRENT_SOCIETE,'[_]%');


-- Cette partie permet de boucler sur chaque table USERS_ afin de selectionner les mails d'une table de façon unique et de les inserer dans la table @LST_TABLES_USERS
	WHILE @counter_TABLE <= (SELECT max(ID) FROM @LST_TABLES_USERS)
	BEGIN
		SET @table_users=(SELECT NOM_TABLE FROM @LST_TABLES_USERS WHERE ID = @counter_TABLE)-- la table sur la quelle la recherche va s'effectuer
		IF @sql IS NULL
			BEGIN
				SET @sql= 'SELECT  '''+@table_users+''' AS NOM_TABLE,
					ID = STUFF((SELECT N'','' + CAST (ID AS varchar)
					FROM '+@table_users+' AS T2
					WHERE T2.MAIL= T.MAIL
					ORDER BY ID
					FOR XML PATH(N'''')), 1, 1, N'''')
					FROM '+@table_users+' AS T
					WHERE MAIL like '''+@CURRENT_MAIl+'''
					GROUP BY MAIL ';
			END
		ELSE
			BEGIN
				SET @sql += ' UNION
				        SELECT  '''+@table_users+''' AS NOM_TABLE,
					ID = STUFF((SELECT N'','' + CAST (ID AS varchar)
					FROM '+@table_users+' AS T2
					WHERE T2.MAIL= T.MAIL
					ORDER BY ID
					FOR XML PATH(N'''')), 1, 1, N'''')
					FROM '+@table_users+' AS T
					WHERE MAIL like '''+@CURRENT_MAIl+'''
					GROUP BY MAIL ';
			END
		SET @counter_TABLE += 1 -- passe a la table suivante

	END;

EXEC (@sql);


    END