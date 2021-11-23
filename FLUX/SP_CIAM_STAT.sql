AS
BEGIN
SET NOCOUNT ON;
--------------------------------------------------- INSERTION DES CONTACTS vers DATA_TISSOT_CIAM_STAT ------------------------------------------------------------
	MERGE DBO.DATA_TISSOT_CIAM_STAT AS T
	USING (SELECT
         CIAM_ID AS NUM_CLIENT_CONTACT
         ,MAIL_CODE
         ,date_premier_login
        ,date_dernier_login
        ,date_derniere_maj_profil
        ,nombre_logins
        ,lite_only
        ,etape_inscription
        ,USERS_TISSOT_LUMIO.ID AS USERID
		FROM Tmp_Tissot_Ciam_Utilisateur
        INNER JOIN USERS_TISSOT_LUMIO ON Tmp_Tissot_Ciam_Utilisateur.CIAM_ID COLLATE SQL_Latin1_General_CP1_CS_AS = USERS_TISSOT_LUMIO.NUM_CLIENT_CONTACT COLLATE SQL_Latin1_General_CP1_CS_AS
            WHERE SIM_PARSELINE_RESULT = 1 AND OPTI_REJECTED=0
		) AS S
	ON (T.NUM_CLIENT_CONTACT COLLATE SQL_Latin1_General_CP1_CS_AS = S.NUM_CLIENT_CONTACT COLLATE SQL_Latin1_General_CP1_CS_AS)
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT(
            NUM_CLIENT_CONTACT
            ,MAIL_CODE
            ,FIRST_LOGIN_DT
            ,LAST_LOGIN_DT
            ,LAST_MAJ_PROFIL_DT
            ,LOGINS_NOMBERS
            ,LITE_ONLY
            ,STEP_REGISTRATION
            ,USERID)
			VALUES(
            S.NUM_CLIENT_CONTACT
            ,S.MAIL_CODE
            ,S.date_premier_login
            ,S.date_dernier_login
            ,S.date_derniere_maj_profil
            ,S.nombre_logins
            ,S.lite_only
            ,S.etape_inscription
            ,S.USERID)
	WHEN MATCHED
		THEN
			UPDATE SET
           T.MAIL_CODE = S.MAIL_CODE
            ,T.FIRST_LOGIN_DT = S.date_premier_login
            ,T.LAST_LOGIN_DT=  S.date_dernier_login
            ,T.LAST_MAJ_PROFIL_DT = S.date_derniere_maj_profil
            ,T.LOGINS_NOMBERS = S.nombre_logins
            ,T.LITE_ONLY = S.lite_only
            ,T.STEP_REGISTRATION = S.etape_inscription ;
---------------------------------------------------------------------MERGE FIN --------------------------------------------------------------------------------------------------------LAST_MAJ_PROFIL_DT
END