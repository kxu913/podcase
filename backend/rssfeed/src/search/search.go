package search

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"kevin_913/rssfeed/model"
	"log"
	"strings"

	elasticsearch "github.com/elastic/go-elasticsearch/v7"
	"github.com/elastic/go-elasticsearch/v7/esapi"
)

func SearchEntry(field string, keyword string, includes []string, from int, size int) []model.EntryHit {
	if "term" == strings.ToLower(field) {
		return searchEntryByTerm(keyword, includes, from, size)
	}
	client := newClient()
	_includes := handleInclude(includes)
	_keyword := handleKeyword(keyword)
	var sc string
	if field != "" {
		sc = fmt.Sprintf(WithFiledTpl, _includes, fmt.Sprintf("%s.keyword", field), fmt.Sprintf("*%s*", _keyword), fmt.Sprintf("%d", from), fmt.Sprintf("%d", size))

	} else {
		sc = fmt.Sprintf(WithoutFieldTpl, _includes, _keyword, fmt.Sprintf("%d", from), fmt.Sprintf("%d", size))

	}
	res := _search(client, "idx_rssentry", sc)
	defer res.Body.Close()
	var sr model.EntryResponse
	json.NewDecoder(res.Body).Decode(&sr)
	return sr.Hits.Hits

}

func searchEntryByTerm(keyword string, includes []string, from, size int) []model.EntryHit {
	client := newClient()
	res := _search(client, "idx_rssfeed", fmt.Sprintf(SearchFeedByTermTpl, keyword))
	defer res.Body.Close()
	var sr model.FeedResponse
	json.NewDecoder(res.Body).Decode(&sr)
	var _idCondtion bytes.Buffer
	for index, f := range sr.Hits.Hits {
		_idCondtion.WriteString(fmt.Sprintf(IdSearchTpl, f.Id))
		if index < len(sr.Hits.Hits)-1 {
			_idCondtion.WriteString(",")
		}

	}
	sc := fmt.Sprintf(SearchByFeedIdsTpl, handleInclude(includes), _idCondtion.String(), fmt.Sprintf("%d", from), fmt.Sprintf("%d", size))

	eres := _search(client, "idx_rssentry", sc)
	defer eres.Body.Close()
	var esr model.EntryResponse
	json.NewDecoder(eres.Body).Decode(&esr)
	return esr.Hits.Hits

}

func handleKeyword(keyword string) string {
	if keyword == "最近更新" {
		return "*"
	}
	return keyword
}

func SearchFeed() []model.Feed {
	client := newClient()
	res := _search(client, "idx_rssfeed", FeedTpl)
	defer res.Body.Close()
	var sr model.FeedResponse
	json.NewDecoder(res.Body).Decode(&sr)
	counts := feedCount()
	hits := sr.Hits.Hits
	var r []model.Feed
	for _, h := range hits {
		h.Source.Count = counts[h.Source.Id]
		r = append(r, h.Source)

	}
	return r

}

func feedCount() map[string]int {
	client := newClient()
	res := _search(client, "*", CountEntryByFeedId)
	defer res.Body.Close()
	var ar model.AggregationsResponse
	json.NewDecoder(res.Body).Decode(&ar)
	m := make(map[string]int, 100)
	for _, y := range ar.Aggregations.GroupByFeed.Buckets {
		m[y.Key] = y.Count
	}
	return m

}

func newClient() *elasticsearch.Client {
	cfg := elasticsearch.Config{
		Addresses: hosts,
	}
	client, err := elasticsearch.NewClient(cfg)
	if err != nil {
		panic(err)
	}
	return client
}

func _search(client *elasticsearch.Client, index string, b string) *esapi.Response {
	body := &bytes.Buffer{}

	body.WriteString(b)

	if index == "*" {
		res, err := client.Search(
			client.Search.WithContext(context.Background()),
			client.Search.WithBody(body),
			client.Search.WithTrackTotalHits(true),
			client.Search.WithPretty(),
		)
		if err != nil {
			log.Fatalf("Error getting response: %s", err)
		}
		return res
	} else {
		res, err := client.Search(
			client.Search.WithContext(context.Background()),
			client.Search.WithIndex(index),
			client.Search.WithBody(body),
			client.Search.WithTrackTotalHits(true),
			client.Search.WithPretty(),
		)
		if err != nil {
			log.Fatalf("Error getting response: %s", err)
		}
		return res
	}

}

func handleInclude(excludes []string) string {
	var _excludes string
	if excludes != nil && len(excludes) > 0 {
		var _ex bytes.Buffer
		for i, f := range excludes {
			_ex.WriteString("\"")
			_ex.WriteString(f)
			_ex.WriteString("\"")
			if i < len(excludes)-1 {
				_ex.WriteString(",")
			}
		}
		_excludes = _ex.String()

	} else {
		_excludes = "\"*\""
	}
	return _excludes
}
