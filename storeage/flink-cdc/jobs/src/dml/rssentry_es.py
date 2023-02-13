
es_cml_tmp = '''
insert into {} 
select
f.id as feed_id,
f.title as feed_title, 
f.subtitle as feed_subtitle,
f.summary as feed_summary,
f.author as feed_author,
f.email as feed_email,
f.image as feed_logo,
f.url as feed_url,
f.terms as terms,
f.labels as labels,
e.type as entry_type,
e.title as entry_title,
e.url as entry_url,
e.summary as entry_summary,
e.image as entry_image,
e.author as entry_author,
e.duration as entry_duration,
e.publish_at as entry_publish_at
from {} e 
inner join {} f on e.feed_id = f.id
'''


es_dml  = str.format(es_cml_tmp,"es_rssentry","pg_rssentry","pg_rssfeed")
es_cdc_dml = str.format(es_cml_tmp,"es_cdc_rssentry","pg_cdc_rssentry","pg_cdc_rssfeed")

es_feed_cdc_dml = '''
insert into es_cdc_rssfeed 
select a.*,
b.last_updated_time from pg_cdc_rssfeed as a 
inner join 
(select feed_id, max(publish_at) last_updated_time from pg_cdc_rssentry group by feed_id) b on a.id = b.feed_id
'''