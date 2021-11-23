AS
BEGIN
SET NOCOUNT ON;

--------------------------------------------------- INSERTION DES CONTACTS vers ARTICLES_TISSOT_CONTENU_ACTU ------------------------------------------------------------
	MERGE DBO.ARTICLES_TISSOT_CONTENU_ACTU AS T
	USING (SELECT
            contenu_id
            ,type
            ,label
            ,url
            ,introduction
            ,theme_champ
            ,theme_label
            ,theme_taxonomie
            ,product_offer_template
            ,is_premium
            ,publication_date
		FROM Tmp_Tissot_Ciam_Webactu_Contenu
		where SIM_PARSELINE_RESULT=1) AS S
	ON (T.CONTENU_ID = S.contenu_id)
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT(
            CONTENU_ID
            ,TYPE
            ,LABEL
            ,URL
            ,INTRODUCTION
            ,THEME_CHAMP
            ,THEME_LABEL
            ,THEME_TAXONOMIE
            ,PRODUCT_OFFER_TEMPLATE
            ,IS_PREMIUM
            ,PUBLICATION_DT
            ,CREATED_DT)
			VALUES(
              S.contenu_id
            ,S.type
            ,S.label
            ,S.url
            ,S.introduction
            ,S.theme_champ
            ,S.theme_label
            ,S.theme_taxonomie
            ,S.product_offer_template
            ,S.is_premium
            ,S.publication_date
            ,GETDATE())
	WHEN MATCHED
		THEN
			UPDATE SET
            T.CONTENU_ID = S.contenu_id
            ,T.TYPE = S.type
            ,T.LABEL = S.label
            ,T.URL = S.url
            ,T.INTRODUCTION = S.introduction
            ,T.THEME_CHAMP = S.theme_champ
            ,T.THEME_LABEL = S.theme_label
            ,T.THEME_TAXONOMIE = S.theme_taxonomie
            ,T.PRODUCT_OFFER_TEMPLATE = S.product_offer_template
            ,T.IS_PREMIUM = S.is_premium
            ,T.PUBLICATION_DT = S.publication_date
            ,T.MODIFIED_DT = GETDATE() ;
---------------------------------------------------------------------MERGE FIN --------------------------------------------------------------------------------------------------------


END