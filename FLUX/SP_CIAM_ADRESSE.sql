AS
BEGIN
SET NOCOUNT ON;

--------------------------------------------------- INSERTION DES CONTACTS vers DATA_TISSOT_CIAM_ADRESSE ------------------------------------------------------------
	MERGE DBO.DATA_TISSOT_CIAM_ADRESSE AS T
	USING (SELECT
         CIAM_ID AS NUM_CLIENT_CONTACT
        ,adresse
        ,complement_adresse
        ,lieu_dit
        ,Tmp_Tissot_Ciam_Utilisateur.code_postal
        ,Tmp_Tissot_Ciam_Utilisateur.ville
        ,f_pays
	,USERS_TISSOT_LUMIO.ID AS USERID
		FROM Tmp_Tissot_Ciam_Utilisateur
        INNER JOIN USERS_TISSOT_LUMIO ON Tmp_Tissot_Ciam_Utilisateur.CIAM_ID COLLATE SQL_Latin1_General_CP1_CS_AS = USERS_TISSOT_LUMIO.NUM_CLIENT_CONTACT COLLATE SQL_Latin1_General_CP1_CS_AS
        WHERE SIM_PARSELINE_RESULT=1
		) AS S
	ON (T.NUM_CLIENT_CONTACT COLLATE SQL_Latin1_General_CP1_CS_AS = S.NUM_CLIENT_CONTACT COLLATE SQL_Latin1_General_CP1_CS_AS)
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT(
            NUM_CLIENT_CONTACT
            ,ADRESSE_LIGNE2
            ,ADRESSE_LIGNE1
            ,ADRESSE_LIGNE3
            ,CODE_POSTAL
            ,VILLE
            ,PAYS
            ,USERID)
			VALUES(
            S.NUM_CLIENT_CONTACT
            ,S.adresse
            ,S.complement_adresse
            ,S.lieu_dit
            ,S.code_postal
            ,S.ville
            ,S.f_pays
	    ,S.USERID)
	WHEN MATCHED
		THEN
			UPDATE SET
            T.ADRESSE_LIGNE2 = S.adresse
            ,T.ADRESSE_LIGNE1 = S.complement_adresse
            ,T.ADRESSE_LIGNE3 = S.lieu_dit
            ,T.CODE_POSTAL = S.code_postal
            ,T.VILLE = S.ville
            ,T.PAYS = S.f_pays ;
---------------------------------------------------------------------MERGE FIN --------------------------------------------------------------------------------------------------------

END