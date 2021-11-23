AS
BEGIN
SET NOCOUNT ON;

--------------------------------------------------- INSERTION DES CONTACTS vers TISSOT_CIAM_INFOSPEC ------------------------------------------------------------
	MERGE DBO.DATA_TISSOT_CIAM_NL AS T
	USING (SELECT
         CIAM_ID AS NUM_CLIENT_CONTACT
        ,USERS_TISSOT_LUMIO.MAIL_CODE AS MAIL_CODE
        ,tissot_nl_pme
        ,tissot_nl_btp
        ,tissot_nl_rp
        ,tissot_nl_aije
        ,tissot_nl_st
        ,tissot_nl_metallurgie
        ,tissot_nl_rps
        ,tissot_nl_mgmt
        ,tissot_nl_paie
        ,tissot_nl_sce
        ,tissot_nl_alertes_mc
        ,tissot_nl_alertes_maj
        ,tissot_nl_enquete
        ,tissot_nl_alertes_cn
        ,tissot_nl_triggers_bdes
        ,tissot_nl_triggers_pre
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
            ,TISSOT_NL_PME
            ,TISSOT_NL_BTP
            ,TISSOT_NL_RP
            ,TISSOT_NL_AIJE
            ,TISSOT_NL_ST
            ,TISSOT_NL_METALLURGIE
            ,TISSOT_NL_RPS
            ,TISSOT_NL_MGMT
            ,TISSOT_NL_PAIE
            ,TISSOT_NL_SCE
            ,TISSOT_NL_ALERTES_MC
            ,TISSOT_NL_ALERTES_MAJ
            ,TISSOT_NL_ENQUETE
            ,TISSOT_NL_ALERTES_CN
            ,TISSOT_NL_TRIGGERS_BDES
            ,TISSOT_NL_TRIGGERS_PRE
            ,USERID)
			VALUES(
                 S.NUM_CLIENT_CONTACT
                ,S.MAIL_CODE
                ,S.tissot_nl_pme
                ,S.tissot_nl_btp
                ,S.tissot_nl_rp
                ,S.tissot_nl_aije
                ,S.tissot_nl_st
                ,S.tissot_nl_metallurgie
                ,S.tissot_nl_rps
                ,S.tissot_nl_mgmt
                ,S.tissot_nl_paie
                ,S.tissot_nl_sce
                ,S.tissot_nl_alertes_mc
                ,S.tissot_nl_alertes_maj
                ,S.tissot_nl_enquete
                ,S.tissot_nl_alertes_cn
                ,S.tissot_nl_triggers_bdes
                ,S.tissot_nl_triggers_pre
                ,S.USERID)
	WHEN MATCHED
		THEN
			UPDATE SET
            T.TISSOT_NL_PME = S.tissot_nl_pme
            ,T.TISSOT_NL_BTP = S.tissot_nl_btp
            ,T.TISSOT_NL_RP = S.tissot_nl_rp
            ,T.TISSOT_NL_AIJE = S.tissot_nl_aije
            ,T.TISSOT_NL_ST = S.tissot_nl_st
            ,T.TISSOT_NL_METALLURGIE = S.tissot_nl_metallurgie
            ,T.TISSOT_NL_RPS = S.tissot_nl_rps
            ,T.TISSOT_NL_MGMT = S.tissot_nl_mgmt
            ,T.TISSOT_NL_PAIE = S.tissot_nl_paie
            ,T.TISSOT_NL_SCE = S.tissot_nl_sce
            ,T.TISSOT_NL_ALERTES_MC = S.tissot_nl_alertes_mc
            ,T.TISSOT_NL_ALERTES_MAJ = S.tissot_nl_alertes_maj
            ,T.TISSOT_NL_ENQUETE = S.tissot_nl_enquete
            ,T.TISSOT_NL_ALERTES_CN = S.tissot_nl_alertes_cn
            ,T.TISSOT_NL_TRIGGERS_BDES = S.tissot_nl_triggers_bdes
            ,T.TISSOT_NL_TRIGGERS_PRE =  S. tissot_nl_triggers_pre
	,T.MAIL_CODE=S.MAIL_CODE;
---------------------------------------------------------------------MERGE FIN --------------------------------------------------------------------------------------------------------
END