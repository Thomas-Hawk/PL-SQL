
-- supprimer les lignes trop vieilles
delete from ti_veilleperso.utilisateurs_articles_ti_veille_perso where DATE_CONTENU < CURRENT_DATE-120;



-- mettre à jour les lignes à ne plus envoyer
update ti_veilleperso.utilisateurs_articles_ti_veille_perso
set CONTENUS_A_ENVOYER = false
where CONTENUS_A_ENVOYER=true;



-- supprimer et créer la table tmp_user_infocoll
drop table if exists tmp_user_infocoll;
create table tmp_user_infocoll (
mail varchar(255) NOT null,
id_unique_infocoll varchar (50) NOT null,
date_contenu date not null,
tag varchar (15) NOT null,
id_article  varchar (50) NOT null
) ;


-- inserer pour chaque utilisateur trouvés dans la table gd_ti_utilisateurs_thesaurus les id _articles de type infocoll dans la table tmp_user_infocoll
insert into tmp_user_infocoll (mail, id_unique_infocoll, date_contenu, tag, id_article)
select distinct gtut.email_adresse ,gtca.id_unique, gtca.date_modification, gtut.tag_id, gtca.id_article
from weka_mdm.gd_ti_utilisateurs_thesaurus gtut
	inner join weka_mdm.gd_ti_thesaurus_contenus gttc on gtut.TAG_ID = gttc.tag_id and gttc.origine_article = '0'
	and gttc.b_batchid = (select MAX(WEKA_MDM.GD_TI_THESAURUS_CONTENUS.b_batchid) from WEKA_MDM.GD_TI_THESAURUS_CONTENUS)
	inner join weka_mdm.gd_ti_contenu_info_coll gtca on gttc.id_article  = cast(gtca.id_article as text) and gtca.statut  IN ('published','validated') and gtca.id_article is not null
where gtut.tag_id is not null and gtut.b_batchid = (select MAX(WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS.b_batchid) from WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS)
and gtca.date_modification > CURRENT_DATE-8;


CREATE INDEX user_infocoll_idx
  ON "tmp_user_infocoll" (mail,id_article);


-- supprimer et créer la table tmp_user_actu
drop table if exists tmp_user_actu;
create  table tmp_user_actu (
mail varchar(255) NOT null,
id_unique_actu varchar (50) NOT null,
date_contenu date not null,
tag varchar (15) NOT null,
id_article  varchar (50) NOT null

) ;



-- insert pour chaque utilisateur trouvés dans la table gd_ti_utilisateurs_thesaurus id les articles de type actu dans la table tmp_user_actu
insert into tmp_user_actu (mail, id_unique_actu,date_contenu, tag, id_article)
select distinct gtut.email_adresse, gtca.id_unique, gtca.date_publication, gtut.tag_id,  gtca.id_article
from weka_mdm.gd_ti_utilisateurs_thesaurus gtut
	inner join weka_mdm.gd_ti_thesaurus_contenus gttc on gtut.TAG_ID = gttc.tag_id and gttc.origine_article = '1'
	and gttc.b_batchid = (select MAX(WEKA_MDM.GD_TI_THESAURUS_CONTENUS.b_batchid) from WEKA_MDM.GD_TI_THESAURUS_CONTENUS)
	inner join weka_mdm.gd_ti_contenu_actualites gtca on gttc.id_article  = cast(gtca.id_article as text) and gtca.statut = 'publish' and gtca.id_article is not null
where gtut.tag_id is not null and gtut.b_batchid = (select MAX(WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS.b_batchid) from WEKA_MDM.GD_TI_UTILISATEURS_THESAURUS)
and gtca.date_publication > CURRENT_DATE-8;



CREATE INDEX unique_email_idx
  ON "tmp_user_actu" (mail, id_article);

-- supprimer et créer la table tmp_user_tag
drop table if exists tmp_user_tag;
create table tmp_user_tag (
mail varchar(255) NOT null,
tag varchar (15) NOT null
);


-- Insérer les mails et id tag provenant des 2 tables tmp_user_actu et tmp_user_tag dans la table tmp_user_tag, cela permet d'avoir une liste tag/ utilisateur
insert into tmp_user_tag (mail, tag)
select mail, tag
from tmp_user_infocoll
group by mail, tag
union
select mail, tag
from tmp_user_actu
group by mail, tag;

CREATE INDEX user_email_idx
  ON "tmp_user_tag" (mail);

-- Insérer pour chaque utilisateur trouvé les id_articles de type infocoll agrégés de la table tmp_user_infocoll dans la table utilisateurs articles Ti veille perso
insert into ti_veilleperso.utilisateurs_articles_ti_veille_perso (created_dt,utilisateur,id_unique_infocoll,contenus_a_envoyer,date_contenu)
select current_timestamp, t1.mail as utilisateur ,
string_agg( distinct cast(t1.id_unique_infocoll as text), ',') as id_unique_infocoll, true, max(t1.date_contenu)
from tmp_user_infocoll t1
where t1.id_unique_infocoll = (select max(t2.id_unique_infocoll) from tmp_user_infocoll t2 where t1.mail = t2.mail and t1.id_article =t2.id_article )
group by mail
;


-- mettre à jour la colonne id de la table utilisateurs articles Ti veille perso avec la colonne actu agrégée de la table tmp_user_actu pour chaque utilisateur t1 utilisateur = t2 mails
update ti_veilleperso.utilisateurs_articles_ti_veille_perso as t1 set (modified_dt,id_unique_actu) =
(select current_timestamp,
string_agg( distinct cast(t2.id_unique_actu as text), ',') as id_unique_actu
from tmp_user_actu t2
where  t1.utilisateur = t2.mail and t2.id_unique_actu = (select max(t3.id_unique_actu) from tmp_user_actu t3 where t3.mail = t2.mail and t3.id_article =t2.id_article )
group by t2.mail);



-- insert pour chaque utilisateur trouvés les id_articles agrégés de type actu de la table tmp_user_actu dans la table utilisateurs_articles_ti_veille_perso  ou le utilisateur ne sont pas t1.utilisateur =  t2.mail
insert into ti_veilleperso.utilisateurs_articles_ti_veille_perso (created_dt,utilisateur,id_unique_actu,contenus_a_envoyer,date_contenu)
select current_timestamp, t1.mail as utilisateur,
string_agg( distinct cast(t1.id_unique_actu as text), ',') as id_unique_actu, true, max(t1.date_contenu)
from tmp_user_actu t1
left join ti_veilleperso.utilisateurs_articles_ti_veille_perso t2 on t1.mail = t2.utilisateur
where t2.utilisateur is null
and t1.id_unique_actu = (select max(t3.id_unique_actu) from tmp_user_actu t3 where t3.mail = t1.mail and t3.id_article =t1.id_article )
group by t1.mail ;



-- mettre à jour la colonne label tag de la table utilisateurs articles Ti veille perso avec les données tags agrégés de la table tmp_user_tag
update ti_veilleperso.utilisateurs_articles_ti_veille_perso as t1 set (modified_dt,tag_label) =
(select current_timestamp, string_agg(distinct '<span class= "nuage_tags">'
|| cast (t3.tag_label as text)|| '</span>', '')
from  tmp_user_tag t2
inner join weka_mdm.gd_ti_thesaurus t3 on t2.tag = cast (t3.tag_id as text)
where t1.utilisateur = t2.mail
group by t2.mail)
;

commit;

