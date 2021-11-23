AS
BEGIN
SET NOCOUNT ON;
--------------------------------------------------- INSERTION DES CONTACTS vers DATA_TISSOT_CIAM_LUMIO ------------------------------------------------------------
	MERGE DBO.DATA_TISSOT_CIAM_LUMIO AS T
	USING (SELECT
         CIAM_ID AS NUM_CLIENT_CONTACT
         ,USERS_TISSOT_LUMIO.ID AS MAIL_CODE
        ,client_lumio_id
        ,lumio_etape_inscription
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
            ,CLIENT_LUMIO_ID
            ,LUMIO_STEP_REGISTRATION
	    ,USERID)
			VALUES(
            S.NUM_CLIENT_CONTACT
            ,S.MAIL_CODE
            ,S.client_lumio_id
            ,S.lumio_etape_inscription
	    ,S.USERID)
	WHEN MATCHED
		THEN
			UPDATE SET
            T.CLIENT_LUMIO_ID = S.client_lumio_id
            ,T.LUMIO_STEP_REGISTRATION=  S.lumio_etape_inscription;
---------------------------------------------------------------------MERGE FIN --------------------------------------------------------------------------------------------------------
END