--nb DI


SELECT T2.first_name AS DR, STR_TO_DATE(concat(year(CURRENT_DATE),MONTHNAME(T1.date_entered),'01'),'%Y %M %d') AS DATE, 'NB_DI' AS TYPE_STAT, T1.status AS STATUT,
(CASE
WHEN T3.name like 'non%' THEN 'non'
WHEN T3.name like 'oui%' THEN 'oui'
WHEN T3.name like 'peut%' THEN 'peut-etre'
END) AS TRAITEMENT,count(*) AS VALEUR
FROM capsp_customerrelationrequests T1
INNER JOIN users T2 ON T2.id = T1.assigned_user_id AND T2.reports_to_id='826b5196-281f-bb6e-2672-55c998ff5e4d' and T2.status='Active'
LEFT JOIN capsp_logtypes T3 ON T3.id = T1.logtype_id AND (T3.name LIKE 'non%' OR T3.name LIKE 'oui%' OR T3.name LIKE 'peut%')
WHERE T1.brand='weka'
AND T1.date_entered >= CONCAT(DATE_FORMAT(CURRENT_DATE,'%Y'),'-01-01')  AND T1.deleted = 0 AND T1.status not like 'pour_adv'
GROUP by T2.first_name, STR_TO_DATE(concat(year(CURRENT_DATE),MONTHNAME(T1.date_entered),'01'),'%Y %M %d'), T1.status, TRAITEMENT,T2.id

--------------------------------------------------------------------------------------------------------------------------------------------


--nb RDV

SELECT T3.first_name AS DR,STR_TO_DATE(concat(year(CURRENT_DATE),MONTHNAME(T1.date_start),'01'),'%Y %M %d') AS DATE,'NB_RDV' AS TYPE_STAT, count(*) AS VALEUR
FROM `meetings` T1
INNER join users T3 on T3.id = T1.assigned_user_id and T3.reports_to_id='826b5196-281f-bb6e-2672-55c998ff5e4d' and T3.status='Active'
WHERE T1.brand='weka'
AND T1.date_start BETWEEN CONCAT(DATE_FORMAT(CURRENT_DATE,'%Y'),'-01-01') AND CONCAT(DATE_FORMAT(CURRENT_DATE,'%Y'),'-12-31') AND T1.deleted = 0 AND
GROUP by T3.first_name, STR_TO_DATE(concat(year(CURRENT_DATE),MONTHNAME(T1.date_start),'01'),'%Y %M %d'), T3.id

SELECT T3.first_name AS DR,MONTH(T1.date_start) AS MOIS, count(*) AS Valeur,'RDV_PERIODE' AS NOM_STAT
FROM `meetings` T1
INNER join users T3 on T3.id = T1.assigned_user_id and T3.reports_to_id='826b5196-281f-bb6e-2672-55c998ff5e4d' and T3.status='Active'
WHERE T1.brand='weka'
AND T1.date_start >= '2021-01-01' AND T1.deleted = 0
GROUP by T3.first_name, MONTH(T1.date_start)


--nb RDV a venir

SELECT T3.first_name,'NB_RDV_A_VENIR' AS TYPE_STAT, count(*) AS VALEUR
FROM `meetings` T1
inner join users T3 on T3.id = T1.assigned_user_id and T3.reports_to_id='826b5196-281f-bb6e-2672-55c998ff5e4d' and T3.status='Active'
WHERE T1.brand='weka' AND T1.deleted = 0  AND T1.date_start > CURRENT_DATE AND T1.status='Planned'
GROUP BY T3.first_name, T3.id

---------------------------------------------------------------------------------------------------------------------------------------------

--NB_AFFAIRE
SELECT T3.first_name AS DR,STR_TO_DATE(concat(year(CURRENT_DATE),MONTHNAME(T1.date_entered),'01'),'%Y %M %d') AS MOIS,'NB_AFFAIRE' AS NOM_STAT,T1.sales_stage AS STATUT, count(*) AS VALEUR
FROM opportunities T1
inner join users T3 on T3.id = T1.seller_id and T3.reports_to_id='826b5196-281f-bb6e-2672-55c998ff5e4d' and T3.status='Active'
WHERE T1.brand='weka'and T1.date_entered >= CONCAT(DATE_FORMAT(CURRENT_DATE,'%Y'),'-01-01') AND  T1.deleted = 0
group by T3.first_name, STR_TO_DATE(concat(year(CURRENT_DATE),MONTHNAME(T1.date_entered),'01'),'%Y %M %d') , T1.sales_stage, T3.id


---------------------------------------------------------------------------------------------------------------------------------------------

--quantit� et somme des devis

SELECT T3.first_name AS DR,STR_TO_DATE(concat(year(CURRENT_DATE),MONTHNAME(T1.date_entered),'01'),'%Y %M %d') AS DATE,'NB_PIPE' AS TYPE_STAT,T1.sales_stage AS STATUT,count(*) AS VALEUR
FROM `quotes` T1
inner join users T3 on T3.id = T1.seller_id and T3.reports_to_id='826b5196-281f-bb6e-2672-55c998ff5e4d' and T3.status='Active'
WHERE
T1.brand='weka'
and T1.reportable_quote IN ( 'y', 'o' )
and T1.date_entered >= CONCAT(DATE_FORMAT(CURRENT_DATE,'%Y'),'-01-01') AND  T1.deleted = 0
group by T3.first_name, STR_TO_DATE(concat(year(CURRENT_DATE),MONTHNAME(T1.date_entered),'01'),'%Y %M %d'), T1.sales_stage,T3.id

UNION

SELECT T3.first_name AS DR,STR_TO_DATE(concat(year(CURRENT_DATE),MONTHNAME(T1.date_entered),'01'),'%Y %M %d') AS DATE,'EURO_PIPE' AS TYPE_STAT, T1.sales_stage AS STATUT,SUM(T1.new_sub) AS VALEUR
FROM `quotes` T1
inner join users T3 on T3.id = T1.seller_id and T3.reports_to_id='826b5196-281f-bb6e-2672-55c998ff5e4d' and T3.status='Active'
WHERE
T1.brand='weka'
and T1.reportable_quote IN ( 'y','o' )
and T1.date_entered >= CONCAT(DATE_FORMAT(CURRENT_DATE,'%Y'),'-01-01') AND  T1.deleted = 0
group by T3.first_name, STR_TO_DATE(concat(year(CURRENT_DATE),MONTHNAME(T1.date_entered),'01'),'%Y %M %d'), T1.sales_stage,T3.id



