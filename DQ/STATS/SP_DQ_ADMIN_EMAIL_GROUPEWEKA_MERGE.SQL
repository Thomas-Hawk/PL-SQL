@SOCIETE NVARCHAR(250)	-- email du contact
AS
BEGIN
SET NOCOUNT ON;


DECLARE @Sql varchar(1000)-- Variable temporaire pour ecrire une requete SQL à executer


-------------------------------------------------------------------FIN PARTIE DECLARATIVE--------------------------------------------------------------------------

-- Cette partie permet sur la table DATA_ADMIN_EMAIL_GRP_WEKAFR:
-- 1 ajouter un mail si il n'est pas present
-- 2 mettre a jour les date de derniere activite pour les mail present par entreprise
-- 3 supprimer une date de derniere activite si l'mail de la societe concernee n'est plus presente
SET @sql= 'MERGE INTO DATA_ADMIN_EMAIL_GRP_WEKAFR T -- table à cible (target)
	USING (SELECT
			TA.MAIL,
			IIF(MAIL_CODE IS NULL, 0,MAIL_CODE) AS MAIL_CODE,
			CASE
				WHEN DERNIERE_ACTIVITE_DT IS NULL THEN GETDATE()
				ELSE DERNIERE_ACTIVITE_DT
			END AS DERNIERE_ACTIVITE_DT,
			TB.CREATED_DT
		FROM TMP_USERS_ONLY TA
		LEFT JOIN USERS_'+@SOCIETE+'_EMAILS TB WITH (NOLOCK) ON TA.MAIL = TB.MAIL) S -- table (source)
	ON (T.MAIL = S.MAIL) -- condition d un email identique
	WHEN MATCHED THEN -- quand ça match
		UPDATE SET T.'+@SOCIETE+'_ACTIVITE_DT = S.DERNIERE_ACTIVITE_DT , T.'+@SOCIETE+'_MAIL_CODE = S.MAIL_CODE , T.'+@SOCIETE+'_CREATION_DT = S.CREATED_DT -- il met à jour
	WHEN NOT MATCHED BY TARGET THEN --  quand il n y a pas de match
		INSERT (
		MAIL,
		'+@SOCIETE+'_MAIL_CODE,
		'+@SOCIETE+'_ACTIVITE_DT,
		'+@SOCIETE+'_CREATION_DT) -- on insert la ligne
		VALUES (
		S.MAIL,
		S.MAIL_CODE,
		S.DERNIERE_ACTIVITE_DT,
		S.CREATED_DT )-- avec les valeurs concernees
	   ;'

EXEC(@sql); -- Execute la requete merge








END