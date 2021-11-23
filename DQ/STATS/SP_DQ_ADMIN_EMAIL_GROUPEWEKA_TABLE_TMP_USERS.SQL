@SOCIETE NVARCHAR(250)	-- email du contact
AS
BEGIN
SET NOCOUNT ON;


	DROP TABLE TMP_USERS_ONLY


	IF OBJECT_ID('dbo.TMP_USERS_ONLY', 'U') IS NULL
		  CREATE TABLE [dbo].[TMP_USERS_ONLY](
		[ID] [int] IDENTITY(1,1) NOT NULL,
		[MAIL] [varchar](255) NULL
	        ) ON [PRIMARY]
	CREATE UNIQUE INDEX IDX_MAIL_TMP_USER_ONLY
		ON TMP_USERS_ONLY(MAIL);

	DECLARE @counter_TABLE INT = 1;-- Compteur pour les tables des users
	DECLARE @table_users varchar(100);-- Variable pour stocker le nom d'une table de USERS
	DECLARE @LST_TABLES_USERS TABLE(ID INT IDENTITY, NOM_TABLE VARCHAR(100))-- Table temporaire pour stocker le nom des tables USERS
	DECLARE @Sql varchar(1000)-- Variable temporaire pour ecrire une requete SQL à executer

	-------------------------------------------------------------------FIN PARTIE DECLARATIVE--------------------------------------------------------------------------

	--  Cherche  toutes les tables de la societe en cours à l'aide de 'information_schema.tables' à inserer dans @LST_TABLES_USERS
	INSERT INTO @LST_TABLES_USERS(NOM_TABLE) SELECT table_name FROM information_schema.tables
	WHERE table_name LIKE CONCAT('USERS_',@SOCIETE,'[_]%') AND  table_name NOT LIKE CONCAT('USERS_',@SOCIETE,'[_]COMPTE');


	-- Cette partie permet de boucler sur chaque table USERS_ afin de selectionner les mails d'une table de façon unique et de les inserer dans la table @LST_TABLES_USERS
	WHILE @counter_TABLE <= (SELECT max(ID) FROM @LST_TABLES_USERS)
	BEGIN
		SET @table_users=(SELECT NOM_TABLE FROM @LST_TABLES_USERS WHERE ID = @counter_TABLE)-- la table sur la quelle la recherche va s'effectuer
			-- Permet d'integrer un mail avec sa societe dans la table TMP_USERS_ONLY
		SET @sql= 'INSERT INTO TMP_USERS_ONLY (MAIL)
			SELECT DISTINCT MAIL
			FROM '+@table_users+' T1 WITH(NOLOCK)
			WHERE MAIL IS NOT NULL AND NOT EXISTS  (
			SELECT 1
			FROM TMP_USERS_ONLY T2
			WHERE T1.MAIL = T2.MAIL
			)';

		EXEC(@sql);
		SET @counter_TABLE += 1 -- passe a la table suivante
	END

END