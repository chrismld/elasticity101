package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestApplicationHandler(t *testing.T) {
	req, err := http.NewRequest("GET", "/", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(ApplicationHandler)

	handler.ServeHTTP(rr, req)

	expected := ""
	if rr.Body.String() != expected {
		t.Errorf("Sorry, the ApplicationHandler is not working, got response %v and should have %v",
			rr.Body.String(), expected)
	}
}

func TestApplicationHandlerCustom(t *testing.T) {
	req, err := http.NewRequest("GET", "/hello", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(ApplicationHandler)

	handler.ServeHTTP(rr, req)

	expected := "hello"
	if rr.Body.String() != expected {
		t.Errorf("Sorry, the ApplicationHandler is not working, got response %v and should have %v",
			rr.Body.String(), expected)
	}
}
