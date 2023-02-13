
es_rssentry_cdc_sql = '''
CREATE TABLE  es_cdc_rssentry(
`feed_id` STRING,
feed_title STRING,
feed_subtitle STRING,
feed_summary STRING,
feed_author STRING,
feed_email STRING,
feed_logo STRING,
feed_url STRING,
terms STRING,
labels STRING,
entry_type STRING,
entry_title STRING,
entry_url STRING,
entry_summary STRING,
entry_image STRING,
entry_author STRING,
feedentry_duration STRING,
entry_publish_at TIMESTAMP(3),
PRIMARY KEY (entry_url) NOT ENFORCED
)WITH (
  'connector' = 'elasticsearch-7',
  'hosts' = 'http://localhost:9200',
  'index' = 'idx_rssentry'
)
'''
es_rssfeed_cdc_sql = '''
CREATE TABLE  es_cdc_rssfeed(
`id` STRING,
`title` STRING,
`subtitle` STRING,
`summary` STRING,
`author` STRING,
`email` STRING,
`image` STRING,
`url` STRING,
`terms` STRING,
`labels` STRING,
`last_updated_time` TIMESTAMP(3),
PRIMARY KEY (id) NOT ENFORCED
)WITH (
  'connector' = 'elasticsearch-7',
  'hosts' = 'http://localhost:9200',
  'index' = 'idx_rssfeed'
)
'''