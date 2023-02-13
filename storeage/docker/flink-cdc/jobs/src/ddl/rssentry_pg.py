pg_rssentry_cdc_sql = '''
 CREATE TABLE pg_cdc_rssentry (
`feed_id` STRING,
`publish_at` TIMESTAMP(3),
`title` STRING,
`url` STRING,
`summary` STRING,
`image` STRING,
`author` STRING,
`duration` STRING,
`type` STRING,
PRIMARY KEY (url) NOT ENFORCED
 ) WITH (
   'connector' = 'postgres-cdc',
   'hostname' = 'localhost',
   'port' = '5432',
   'username' = 'postgres',
   'password' = 'postgres',
   'database-name' = 'postgres',
   'slot.name' = 'flinkcdcentry',
   'schema-name' = 'public',
   'slot.name' = '{}',
   'table-name' = 'rssentry'
 )
'''