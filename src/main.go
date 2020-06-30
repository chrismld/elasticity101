package main

import (
	"log"
	"net/http"
)

func main() {
	err := http.ListenAndServe(":3000", &App{})

	if err != nil {
		log.Fatalf("Could not start server: %s\n", err.Error())
	}
}
