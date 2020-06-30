package main

import (
	"io"
	"net/http"
)

func ApplicationHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	io.WriteString(w, r.URL.Path[1:])
}
