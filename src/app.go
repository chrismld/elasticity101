package main

import (
	"io"
	"net/http"
)

type App struct{}

func (a *App) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	ApplicationHandler(w, r)
}

func ApplicationHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	io.WriteString(w, r.URL.Path[1:])
}
