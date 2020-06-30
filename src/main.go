package main

import (
	"log"
	"net/http"
	"os"
)

func main() {
	err := http.ListenAndServe(":"+os.Getenv("APPPORT"), &App{})

	if err != nil {
		log.Fatalf("Could not start server: %s\n", err.Error())
	}
}
