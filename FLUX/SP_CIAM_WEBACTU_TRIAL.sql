AS
BEGIN
SET NOCOUNT ON;
--------------------------------------------------- INSERTION DES CONTACTS vers DATA_TISSOT_WEBACTU_TRIAL ------------------------------------------------------------
	MERGE DBO.DATA_TISSOT_WEBACTU_TRIAL AS T
	USING (SELECT
         trial_id
        ,f_ciam_id
        ,date_debut
        ,date_fin
        ,date_subscription
        ,USERS_TISSOT_LUMIO.ID AS USERID
	,cact
		FROM Tmp_Tissot_Ciam_Trial T1
         INNER JOIN USERS_TISSOT_LUMIO ON T1.f_ciam_id COLLATE SQL_Latin1_General_CP1_CS_AS = USERS_TISSOT_LUMIO.NUM_CLIENT_CONTACT COLLATE SQL_Latin1_General_CP1_CS_AS
	WHERE SIM_PARSELINE_RESULT=1

	) AS S
	ON (T.ID_TRIAL = S.trial_id)
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT(
            ID_TRIAL
            ,CIAM_ID
            ,DATE_DEBUT
            ,DATE_FIN
            ,DATE_SOUSCRIPTION
            ,USERID
	    ,CACT)
			VALUES(
            S.trial_id
            ,S.f_ciam_id
            ,S.date_debut
            ,S.date_fin
            ,S.date_subscription
	    ,S.USERID
	    ,S.CACT)
	WHEN MATCHED
		THEN
			UPDATE SET
            T.DATE_DEBUT = S.date_debut
            ,T.DATE_FIN = S.date_fin
            ,T.DATE_SOUSCRIPTION = S.date_subscription;
---------------------------------------------------------------------MERGE FIN --------------------------------------------------------------------------------------------------------
END