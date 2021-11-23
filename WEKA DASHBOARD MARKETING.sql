SELECT *

FROM capsp_customerrelationrequests T1

WHERE T1.brand='weka' AND T1.date_entered >= '2018-01-01'  AND T1.deleted = 0

---------------------Les DI---------------------------------

SELECT T1.ID,
T1.contact_id AS ID_CONTACT,
T1.account_id AS ID_COMPTE,
CONCAT(T2.FIRST_NAME,' ', T2.LAST_NAME) AS NOM_CONTACT,
(CASE
    WHEN
 		(T1.type IN('essai','webinar')) AND (T1.description NOT LIKE '%A propos du produit :%')
 		THEN T1.description
 	WHEN
 		(T1.type = 'white_paper') AND (T1.description NOT LIKE '%Livre blanc :%')
 		THEN T1.description

    WHEN (T1.type IN('essai','webinar')) AND (T1.description  like '%A propos du produit :%')
        THEN SUBSTRING(T1.description,POSITION('A propos du produit :' in T1.description)+22)

    WHEN (T1.type = 'white_paper') AND (T1.description  like '%Livre blanc :%')
        THEN SUBSTRING(T1.description,POSITION('Livre blanc :' in T1.description)+13)

    ELSE null
END) AS DESCRIPTION,
CONCAT(T4.FIRST_NAME,' ', T4.LAST_NAME) AS NOM_UTILISATEUR,
T1.date_entered AS DATE,
T1.salutation as CIVILITE,
T1.departments AS SERVICE,
T1.weka_title AS FONCTION,
T1.type AS TYPE,
T2.primary_address_postalcode AS CP,
T1.weka_activity AS ACTIVITE,
T3.NAME AS COMPTE,
T3.account_type AS TYPE_COMPTE,
T5.sap_project  AS PROJET_SAP,
(CASE
    WHEN T1.status = 'doing' THEN "en cours"
    WHEN T1.status = 'done' THEN "fait"
    WHEN T1.status = 'todo' THEN "a faire"
    ELSE T1.status
END) AS STATUT_DI,
T1.name AS NOM_DI,
T6.name AS STATUT_RESULTAT,
T7.name AS NOM_PRODUIT,
T1.weka_activity AS SECTEUR_ACTIVITE,
T7.giftcode AS CODE_OFFRE
FROM capsp_customerrelationrequests T1
LEFT JOIN contacts T2 on T1.contact_id = T2.id
LEFT JOIN accounts T3 on T1.account_id = T3.id
LEFT JOIN users T4 on T1.assigned_user_id = T4.id
LEFT JOIN campaigns T5 on T1.campaign_id = T5.id
LEFT JOIN capsp_logtypes T6 on T1.logtype_id = T6.id
LEFT JOIN product_templates T7 on T1.product_id = T7.id
WHERE T1.brand='weka' AND T1.date_entered >= CONCAT(DATE_FORMAT(CURRENT_DATE,'%Y')-3,DATE_FORMAT(CURRENT_DATE,'-%m-%d')) AND T1.deleted = 0


---------------------------------Les Affaires--------------------------------------


SELECT T1.ID,
T1.NAME AS NOM,
T1.date_entered AS DATE,
T1.code_action AS CODE_ACTION,
T1.billing_label AS RAISON_SOCIALE_FACTURATION,
T1.amount AS TOTAL_HT,
T2.giftcode CODE_OFFRE,
CONCAT(T3.FIRST_NAME,' ', T3.LAST_NAME) AS VENDEUR,
T4.sap_project  AS PROJET_SAP,
T5.weka_title AS FONCTION_MARKETING,
T7.weka_activity AS SECTEUR_ACTIVITE,
T5.weka_department AS SERVICE,
T7.billing_address_postalcode AS CODE_POSTALE,
T1.sales_stage AS STATUT_AFFAIRE,
T1.opportunity_type AS TYPE
FROM opportunities T1
LEFT JOIN products T2 ON T1.id = T2.opportunity_id
LEFT JOIN users T3 ON T1.seller_id = T3.id
LEFT JOIN campaigns T4 on T1.campaign_id = T4.id
LEFT JOIN contacts T5 on T1.billed_id = T5.id
LEFT JOIN accounts_opportunities T6 on T1.id  = T6.opportunity_id
LEFT JOIN accounts T7 on T6.account_id = T7.id

WHERE T1.brand='weka' AND T1.date_entered >= CONCAT(DATE_FORMAT(CURRENT_DATE,'%Y')-3,DATE_FORMAT(CURRENT_DATE,'-%m-%d')) AND T1.deleted = 0



