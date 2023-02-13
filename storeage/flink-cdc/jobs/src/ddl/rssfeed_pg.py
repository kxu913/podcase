
pg_rssfeed_cdc_sql = '''
 CREATE TABLE pg_cdc_rssfeed (
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
PRIMARY KEY (id) NOT ENFORCED
 ) WITH (
   'connector' = 'postgres-cdc',
   'hostname' = 'localhost',
   'port' = '5432',
   'username' = 'postgres',
   'password' = 'postgres',
   'database-name' = 'postgres',
   'schema-name' = 'public',
   'slot.name' = '{}',
   'table-name' = 'rssfeed'
 )
'''
