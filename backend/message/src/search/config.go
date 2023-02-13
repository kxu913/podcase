package search

var (
	hosts = []string{"http://172.28.0.1:9200"}
)

// debug the query in http://localhost:5601/app/kibana#/dev_tools/console?load_from=https:%2F%2Fwww.elastic.co%2Fguide%2Fen%2Felasticsearch%2Freference%2Fcurrent%2Fsnippets%2F873.console
const (
	FeedTpl = `
	{
		"sort" : [
		  { "last_updated_time.keyword": {"missing" : "_last","order": "desc"} }
		
		],
		"size": 100
	  }
	`

	WithFiledTpl = `
	{
		"_source": {"includes": [%s]},
		"sort" : [
		  { "entry_publish_at.keyword": {"missing" : "_last","order": "desc"} }
		],
		"query" : {
		  "wildcard": { "%s" : "%s" }
		},
			"from": %s,
			  "size": %s
	  }
	`

	WithoutFieldTpl = `
	{
		"_source": {"includes": [%s]},
		"sort" : [
		  { "entry_publish_at.keyword": {"missing" : "_last","order": "desc"} }
		],
		"query": {
			"query_string": {
			  "query": "%s"
			}
		  },
		"from": %s,
		"size": %s
	  }
	`
	CountEntryByFeedId = `
{
	"query": {
	  "match_all": {}
	},
	"_source": {"includes":["feed_id"]}, 
  
		"aggs": {
		  "groupByFeed": {
			  "terms": {
				  "field": "feed_id.keyword",
				  "size": 100
			  }
		  }
	  }
  }
`

	SearchFeedByTermTpl = `
{
	"_source": "feed_id", 
	 "query": {
		"wildcard": {
		  "terms.keyword": "*%s*"
		}
	 },
	 "size": 100
  
  }
  
`
	SearchByFeedIdsTpl = `
  {
	"_source": {"includes": [%s]},
	   "query": {
		  "bool": {
			"must": {
			  "bool":{
				"should":[
					%s
				  ]
			  }
			}
		  }
	   },
	   "sort" : [
			  { "entry_publish_at.keyword": {"missing" : "_last","order": "desc"} }
			],
			"from": %s,
			"size": %s
	
	} 
  `

	IdSearchTpl = `
  {
	"match":{
	"feed_id":"%s"
	}
  }
  `
)
