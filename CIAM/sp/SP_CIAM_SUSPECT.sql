AS
BEGIN
SET NOCOUNT ON;
--------------------------------------------------- INSERTION DES CONTACTS vers USERS_TISSOT_SUSPECT ------------------------------------------------------------
	MERGE DBO.USERS_TISSOT_SUSPECT AS T
	USING (SELECT DISTINCT
			S1.adresse_email AS EMAIL
			,S1.date_creation AS CREATED_DT
			,S1.civilite AS SALUTATION
			,S1.nom as LAST_NAME
			,SUBSTRING(S1.prenom,0,50) as FIRST_NAME
			,S1.num_telephone AS PHONE_WORK
			,S1.raison_sociale_1 AS RS1
			,S1.f_typologie_compte AS ACCOUNT_TYPE
			,DATA_TISSOT_EMAILS.ID AS MAIL_CODE
			,CASE S1.civilite
				WHEN 'm' THEN 1
				WHEN 'mme' THEN 2
				ELSE 0
			END AS SALUTATION_CODE
			,DATA_PM_ACCOUNT_TYPE.ID AS ACCOUNT_TYPE_CODE
		FROM DBO.Tmp_Tissot_Ciam_Utilisateur S1
		INNER JOIN DATA_TISSOT_EMAILS ON DATA_TISSOT_EMAILS.MAIL=S1.adresse_email
		LEFT OUTER JOIN DATA_PM_ACCOUNT_TYPE ON DATA_PM_ACCOUNT_TYPE.CODE = S1.f_typologie_compte
		WHERE SIM_PARSELINE_RESULT=1 AND not exists (SELECT 1 FROM USERS_TISSOT_CONTACT WITH (NOLOCK) WHERE USERS_TISSOT_CONTACT.MAIL = S1.adresse_email)
		AND S1.adresse_email is not null AND S1.adresse_email <> ' '
		) AS S
	ON (T.MAIL = S.EMAIL)
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT(MAIL
				,CREATED_DT
				,SALUTATION
				,LAST_NAME
				,FIRST_NAME
				,PHONE_WORK
				,RS1
				,ACCOUNT_TYPE
				,MAIL_CODE
				,SALUTATION_CODE
				,ACCOUNT_TYPE_CODE
                )
			VALUES(S.EMAIL
				,S.CREATED_DT
				,S.SALUTATION
				,S.LAST_NAME
				,S.FIRST_NAME
				,S.PHONE_WORK
				,S.RS1
				,S.ACCOUNT_TYPE
				,S.MAIL_CODE
				,S.SALUTATION_CODE
				,S.ACCOUNT_TYPE_CODE)
	WHEN MATCHED
		THEN
			UPDATE SET
				T.MODIFIED_DT = GETDATE()
				,T.SALUTATION = S.SALUTATION
				,T.LAST_NAME = S.LAST_NAME
				,T.FIRST_NAME = S.FIRST_NAME
				,T.PHONE_WORK = S.PHONE_WORK
				,T.RS1 = S.RS1
				,T.ACCOUNT_TYPE = S.ACCOUNT_TYPE
				,T.MAIL_CODE = S.MAIL_CODE
				,T.SALUTATION_CODE=S.SALUTATION_CODE
				,T.ACCOUNT_TYPE_CODE=S.ACCOUNT_TYPE_CODE;


---------------------------------------------------------------------MERGE FIN --------------------------------------------------------------------------------------------------------

UPDATE USERS_TISSOT_EMAILS
SET SUSPECT_ID=(SELECT ID FROM USERS_TISSOT_SUSPECT WHERE USERS_TISSOT_EMAILS.MAIL_CODE = USERS_TISSOT_SUSPECT.MAIL_CODE)
WHERE Exists (SELECT 1 FROM USERS_TISSOT_SUSPECT WHERE USERS_TISSOT_EMAILS.MAIL_CODE = USERS_TISSOT_SUSPECT.MAIL_CODE)
AND SUSPECT_ID iS NULL;
---------------------------------------------------------------------MERGE FIN --------------------------------------------------------------------------------------------------------
END