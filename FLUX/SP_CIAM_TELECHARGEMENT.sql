AS
BEGIN
SET NOCOUNT ON;


-- insertion dans la table des downloads
		INSERT INTO
    DBO.DATA_TISSOT_DOWNLOAD ([EMAIL_ID]
		,[ID_ACTIVITE_WEB]
		,[DATE_ACTIVITE]
		,[TYPE_ACTIVITE]
		,[CODE_ACTION]
		,ID_CONTENU
        ,CIAM_ID
		,USERID)
	SELECT
    USERS_TISSOT_LUMIO.MAIL_CODE
		,Tmp_Tissot_Ciam_Activite_Web.[activite_id]
		,Tmp_Tissot_Ciam_Activite_Web.[activite_date]
		,SUBSTRING(Tmp_Tissot_Ciam_Activite_Web.[activite_type],0,50)
		,SUBSTRING(Tmp_Tissot_Ciam_Activite_Web.[CODE_ACTION],0,50)
		,Tmp_Tissot_Ciam_Activite_Web.[f_tissot_contenu_actu]
        ,Tmp_Tissot_Ciam_Activite_Web.[F_CIAM_ID]
,USERS_TISSOT_LUMIO.ID
	FROM DBO.Tmp_Tissot_Ciam_Activite_Web
        INNER JOIN USERS_TISSOT_LUMIO ON Tmp_Tissot_Ciam_Activite_Web.F_CIAM_ID  COLLATE SQL_Latin1_General_CP1_CS_AS = USERS_TISSOT_LUMIO.NUM_CLIENT_CONTACT  COLLATE SQL_Latin1_General_CP1_CS_AS
WHERE not exists ( SELECT 1 FROM DATA_TISSOT_DOWNLOAD T1 WHERE Tmp_Tissot_Ciam_Activite_Web.activite_id = T1.ID_ACTIVITE_WEB)
AND SIM_PARSELINE_RESULT=1;


DELETE
FROM DATA_TISSOT_DOWNLOAD
WHERE DATE_ACTIVITE < DATEADD(yy,-2,GETDATE());

END