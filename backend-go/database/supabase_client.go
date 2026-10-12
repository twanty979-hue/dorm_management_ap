package database

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"dorm_backend_api/config"
)

type SupabaseClient struct {
	BaseURL    string
	AnonKey    string
	HTTPClient *http.Client
}

var Client *SupabaseClient

func InitSupabaseClient() *SupabaseClient {
	cfg := config.AppConfig
	Client = &SupabaseClient{
		BaseURL: cfg.SupabaseURL,
		AnonKey: cfg.SupabaseAnonKey,
		HTTPClient: &http.Client{
			Timeout: 15 * time.Second,
		},
	}
	return Client
}

// Select query: GET /rest/v1/{table}?{queryParams}
func (s *SupabaseClient) From(table string) *QueryBuilder {
	return &QueryBuilder{
		client: s,
		table:  table,
		params: make(map[string]string),
	}
}

type QueryBuilder struct {
	client *SupabaseClient
	table  string
	params map[string]string
}

func (q *QueryBuilder) Eq(column, value string) *QueryBuilder {
	q.params[column] = "eq." + value
	return q
}

func (q *QueryBuilder) Order(column string, ascending bool) *QueryBuilder {
	order := "asc"
	if !ascending {
		order = "desc"
	}
	q.params["order"] = column + "." + order
	return q
}

func (q *QueryBuilder) Select(columns string) ([]byte, error) {
	if columns == "" {
		columns = "*"
	}
	q.params["select"] = columns

	reqURL := fmt.Sprintf("%s/rest/v1/%s", q.client.BaseURL, q.table)
	req, err := http.NewRequest("GET", reqURL, nil)
	if err != nil {
		return nil, err
	}

	q.setHeaders(req)

	// Add query params
	query := req.URL.Query()
	for k, v := range q.params {
		query.Add(k, v)
	}
	req.URL.RawQuery = query.Encode()

	resp, err := q.client.HTTPClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	if resp.StatusCode >= 400 {
		return nil, fmt.Errorf("supabase error %d: %s", resp.StatusCode, string(body))
	}

	return body, nil
}

func (q *QueryBuilder) Insert(data interface{}) ([]byte, error) {
	jsonData, err := json.Marshal(data)
	if err != nil {
		return nil, err
	}

	reqURL := fmt.Sprintf("%s/rest/v1/%s", q.client.BaseURL, q.table)
	req, err := http.NewRequest("POST", reqURL, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, err
	}

	q.setHeaders(req)
	req.Header.Set("Prefer", "return=representation")

	resp, err := q.client.HTTPClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	if resp.StatusCode >= 400 {
		return nil, fmt.Errorf("supabase error %d: %s", resp.StatusCode, string(body))
	}

	return body, nil
}

func (q *QueryBuilder) Update(data interface{}) ([]byte, error) {
	jsonData, err := json.Marshal(data)
	if err != nil {
		return nil, err
	}

	reqURL := fmt.Sprintf("%s/rest/v1/%s", q.client.BaseURL, q.table)
	req, err := http.NewRequest("PATCH", reqURL, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, err
	}

	q.setHeaders(req)
	req.Header.Set("Prefer", "return=representation")

	query := req.URL.Query()
	for k, v := range q.params {
		query.Add(k, v)
	}
	req.URL.RawQuery = query.Encode()

	resp, err := q.client.HTTPClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	if resp.StatusCode >= 400 {
		return nil, fmt.Errorf("supabase error %d: %s", resp.StatusCode, string(body))
	}

	return body, nil
}

func (q *QueryBuilder) setHeaders(req *http.Request) {
	req.Header.Set("apikey", q.client.AnonKey)
	req.Header.Set("Authorization", "Bearer "+q.client.AnonKey)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
}
