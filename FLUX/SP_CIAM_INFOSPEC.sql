AS
BEGIN
SET NOCOUNT ON;

MERGE DBO.DATA_TISSOT_CIAM_INFOSPEC AS T
	USING (SELECT
         CIAM_ID AS NUM_CLIENT_CONTACT
        ,DATA_PP_TITLE.ID AS f_fonction_tissot
        ,DATA_PP_DEPARTMENT.ID AS f_service_tissot
        ,DATA_PM_ACTIVITY.ID AS f_secteur_activite_tissot
        ,DATA_PM_ACCOUNT_TYPE.id AS f_typologie_compte
        ,taches_paie
        ,taches_comptabilite
        ,taches_rh
        ,USERS_TISSOT_LUMIO.ID AS USERID
		FROM Tmp_Tissot_Ciam_Utilisateur
        LEFT JOIN DATA_PP_TITLE ON Tmp_Tissot_Ciam_Utilisateur.f_fonction_tissot = DATA_PP_TITLE.CODE
        LEFT JOIN DATA_PP_DEPARTMENT ON Tmp_Tissot_Ciam_Utilisateur.f_service_tissot = DATA_PP_DEPARTMENT.CODE
        LEFT JOIN DATA_PM_ACTIVITY ON Tmp_Tissot_Ciam_Utilisateur.f_secteur_activite_tissot = DATA_PM_ACTIVITY.CODE
        LEFT JOIN DATA_PM_ACCOUNT_TYPE ON Tmp_Tissot_Ciam_Utilisateur.f_typologie_compte = DATA_PM_ACCOUNT_TYPE.CODE
	    INNER JOIN USERS_TISSOT_LUMIO ON Tmp_Tissot_Ciam_Utilisateur.CIAM_ID COLLATE SQL_Latin1_General_CP1_CS_AS = USERS_TISSOT_LUMIO.NUM_CLIENT_CONTACT COLLATE SQL_Latin1_General_CP1_CS_AS
	WHERE NUM_CLIENT_CONTACT is not null
	or f_fonction_tissot is not null
        or f_service_tissot is not null
        or f_secteur_activite_tissot is not null
        or f_typologie_compte is not null
        or taches_paie is not null
        or taches_comptabilite is not null
        or taches_rh is not null

		) AS S
	ON (T.NUM_CLIENT_CONTACT COLLATE SQL_Latin1_General_CP1_CS_AS = S.NUM_CLIENT_CONTACT COLLATE SQL_Latin1_General_CP1_CS_AS)
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT(
            NUM_CLIENT_CONTACT
            ,TITLE
            ,SERVICE
            ,ACTIVITY
            ,ACCOUNT_TYPE
            ,TACHES_PAIE
            ,TACHES_COMPTABILITE
            ,TACHES_RH
            ,USERID)
			VALUES(
            S.NUM_CLIENT_CONTACT
            ,S.f_fonction_tissot
            ,S.f_service_tissot
            ,S.f_secteur_activite_tissot
            ,S.f_typologie_compte
            ,S.taches_paie
            ,S.taches_comptabilite
            ,S.taches_rh
            ,S.USERID)
	WHEN MATCHED
		THEN
			UPDATE SET
            T.TITLE = S.f_fonction_tissot
            ,T.SERVICE = S.f_service_tissot
            ,T.ACTIVITY = S.f_secteur_activite_tissot
            ,T.ACCOUNT_TYPE = S.f_typologie_compte
            ,T.TACHES_PAIE = S.taches_paie
            ,T.TACHES_COMPTABILITE = S.taches_comptabilite
            ,T.TACHES_RH = S.taches_rh;
END