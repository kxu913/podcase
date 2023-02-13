package model

// type ErrorResponse struct {
// 	Info *ErrorInfo `json:"error,omitempty"`
// }

// type ErrorInfo struct {
// 	RootCause []*ErrorInfo
// 	Type      string
// 	Reason    string
// 	Phase     string
// }

// type IndexResponse struct {
// 	Index   string `json:"_index"`
// 	ID      string `json:"_id"`
// 	Version int    `json:"_version"`
// 	Result  string
// }

type EntryResponse struct {
	Took int64
	Hits struct {
		Total struct {
			Value int64
		}
		Hits []EntryHit
	}
}

type EntryHit struct {
	Score  float64   `json:"_score"`
	Index  string    `json:"_index"`
	Type   string    `json:"_type"`
	Source FeedEntry `json:"_source"`
}

type FeedResponse struct {
	Took int64
	Hits struct {
		Total struct {
			Value int64
		}
		Hits []FeedHit
	}
}

type FeedHit struct {
	Score  float64 `json:"_score"`
	Index  string  `json:"_index"`
	Type   string  `json:"_type"`
	Id     string  `json:"_id"`
	Source Feed    `json:"_source"`
}

type AggregationsResponse struct {
	Aggregations struct {
		GroupByFeed struct {
			Buckets []struct {
				Key   string
				Count int `json:"doc_count"`
			}
		}
	}
}
