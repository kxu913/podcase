package model

import (
	"fmt"
	"strings"
	"time"
)

const timeTemplate = "2006-01-02 15:04:05"

// easyjson
type FeedEntry struct {
	EntryAuthor    string `json:"entry_author,omitempty"`
	EntryImage     string `json:"entry_image,omitempty"`
	EntryPublishAt CTime  `json:"entry_publish_at,omitempty"`
	EntrySummary   string `json:"entry_summary,omitempty"`
	EntryTitle     string `json:"entry_title,omitempty"`
	EntryType      string `json:"entry_type,omitempty"`
	EntryUrl       string `json:"entry_url,omitempty"`
	FeedEmail      string `json:"feed_email,omitempty"`
	FeedLogo       string `json:"feed_logo,omitempty"`
	FeedSubtitle   string `json:"feed_subtitle,omitempty"`
	FeedSummary    string `json:"feed_summary,omitempty"`
	FeedTitle      string `json:"feed_title,omitempty"`
	FeedUrl        string `json:"feed_url,omitempty"`
	EntryDuration  string `json:"feedentry_duration,omitempty"`
	Id             string `json:"id,omitempty"`
	Terms          Terms  `json:"terms,omitempty"`
}
type CTime struct {
	EntryPublishAt time.Time `json:"entry_publish_at,omitempty"`
}

type Feed struct {
	FeedEmail    string          `json:"email,omitempty"`
	FeedSubtitle string          `json:"subtitle,omitempty"`
	FeedSummary  string          `json:"summary,omitempty"`
	FeedTitle    string          `json:"title,omitempty"`
	FeedUrl      string          `json:"url,omitempty"`
	Id           string          `json:"id,omitempty"`
	Auhtor       string          `json:"author,omitempty"`
	FeedLogo     string          `json:"image,omitempty"`
	Count        int             `json:"count,omitempty"`
	LastUpdated  LastUpdatedTime `json:"last_updated_time,omitempty"`
	Terms        Terms           `json:"terms,omitempty"`
}

type LastUpdatedTime struct {
	LastUpdated time.Time
}

type Terms struct {
	Terms []string
}

func (terms *Terms) UnmarshalJSON(b []byte) error {
	s := string(b)
	if s == "" {
		return nil
	}

	ss := string(s[1 : len(s)-1])
	terms.Terms = strings.Split(ss, ",")

	return nil
}

func (ct *LastUpdatedTime) UnmarshalJSON(b []byte) error {
	s := string(b)
	if s == "null" {
		return nil
	}
	ss := strings.ReplaceAll(s, "\"", "")
	tt, err := time.Parse(timeTemplate, ss)
	if err != nil {
		fmt.Println(err)
		return nil
	}
	ct.LastUpdated = tt

	return nil

}

func (ct *CTime) UnmarshalJSON(b []byte) error {
	s := string(b)
	if s == "null" {
		return nil
	}

	ss := strings.ReplaceAll(s, "\"", "")
	tt, err := time.Parse(timeTemplate, ss)
	if err != nil {
		fmt.Println(err)
		return nil
	}
	ct.EntryPublishAt = tt

	return nil

}
