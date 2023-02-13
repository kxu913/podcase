from pyflink.table import EnvironmentSettings,TableEnvironment
from src.ddl.rssentry_pg import pg_rssentry_cdc_sql
from src.ddl.rssfeed_pg import pg_rssfeed_cdc_sql
from src.ddl.rssentry_es import es_rssentry_cdc_sql
from src.dml.rssentry_es import es_cdc_dml


if __name__ == "__main__":
    
    t_env = TableEnvironment.create(EnvironmentSettings.in_streaming_mode())
    
    t_env.get_config().set("parallelism.default", "1")
    t_env.get_config().set("taskmanager.numberOfTaskSlots", "3")
    
    t_env.execute_sql(str.format(pg_rssentry_cdc_sql,"entry_detail"))
    t_env.execute_sql(str.format(pg_rssfeed_cdc_sql,"entry_feed"))
    t_env.execute_sql(es_rssentry_cdc_sql)
    
    st = t_env.create_statement_set()
    st.add_insert_sql(es_cdc_dml)
    st.execute()


