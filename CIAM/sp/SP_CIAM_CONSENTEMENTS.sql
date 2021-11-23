AS
BEGIN
SET NOCOUNT ON;
--------------------------------------------------- INSERTION DES CONTACTS vers DATA_TISSOT_CIAM_CONSENTEMENTS ------------------------------------------------------------
	MERGE DBO.DATA_TISSOT_CIAM_CONSENTEMENTS AS T
	USING (SELECT
         CIAM_ID AS NUM_CLIENT_CONTACT
        ,MAIL_CODE
        ,lumio_optin_cgu
        ,lumio_optin_cgv
        ,lumio_optin_email_co
        ,lumio_optin_nl_maj
        ,lumio_optin_nl_product
        ,lumio_optin_nl_rh
        ,lumio_optin_tel_co
        ,lumio_optin_print_co
        ,lumio_optin_sms_co
        ,tissot_optin_cgu
        ,tissot_optin_cgv
        ,tissot_optin_email_co
        ,tissot_optin_email_partne
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
            ,LUMIO_OPTIN_CGU
            ,LUMIO_OPTIN_CGV
            ,LUMIO_OPTIN_EMAIL_CO
            ,LUMIO_OPTIN_NL_MAJ
            ,LUMIO_OPTIN_NL_PRODUCT
            ,LUMIO_OPTIN_NL_RH
            ,LUMIO_OPTIN_TEL_CO
            ,LUMIO_OPTIN_PRINT_CO
            ,LUMIO_OPTIN_SMS_CO
            ,TISSOT_OPTIN_CGU
            ,TISSOT_OPTIN_CGV
            ,TISSOT_OPTIN_EMAIL_CO
            ,TISSOT_OPTIN_EMAIL_PARTNE
            ,USERID
            )
			VALUES(
                 S.NUM_CLIENT_CONTACT
                ,S.MAIL_CODE
                ,S.lumio_optin_cgu
                ,S.lumio_optin_cgv
                ,S.lumio_optin_email_co
                ,S.lumio_optin_nl_maj
                ,S.lumio_optin_nl_product
                ,S.lumio_optin_nl_rh
                ,S.lumio_optin_tel_co
                ,S.lumio_optin_print_co
                ,S.lumio_optin_sms_co
                ,S.tissot_optin_cgu
                ,S.tissot_optin_cgv
                ,S.tissot_optin_email_co
                ,S.tissot_optin_email_partne
                ,S.USERID)
	WHEN MATCHED
		THEN
			UPDATE SET
            LUMIO_OPTIN_CGU = S.lumio_optin_cgu
            ,LUMIO_OPTIN_CGV = S.lumio_optin_cgv
            ,LUMIO_OPTIN_EMAIL_CO = S.lumio_optin_email_co
            ,LUMIO_OPTIN_NL_MAJ = S.lumio_optin_nl_maj
            ,LUMIO_OPTIN_NL_PRODUCT = S.lumio_optin_nl_product
            ,LUMIO_OPTIN_NL_RH = S.lumio_optin_nl_rh
            ,LUMIO_OPTIN_TEL_CO = S.lumio_optin_tel_co
            ,LUMIO_OPTIN_PRINT_CO = S.lumio_optin_print_co
            ,LUMIO_OPTIN_SMS_CO = S.lumio_optin_sms_co
            ,TISSOT_OPTIN_CGU = S.tissot_optin_cgu
            ,TISSOT_OPTIN_CGV = S.tissot_optin_cgv
            ,TISSOT_OPTIN_EMAIL_CO = S.tissot_optin_email_co
            ,TISSOT_OPTIN_EMAIL_PARTNE = S.tissot_optin_email_partne;
---------------------------------------------------------------------MERGE FIN --------------------------------------------------------------------------------------------------------
END