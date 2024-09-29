package main

import (
	"devel/greetings"
	"fmt"
	"log"
)

func main() {
	// Set props of the predefined logger
	log.SetPrefix("greetings: ")
	log.SetFlags(0)
	fmt.Println("hey")
	var name string

	// Request a greeting message
	fmt.Print("Your name: ")
	fmt.Scan(&name)

	message, err := greetings.Hello(name)
	// If an error was returned, print it to the console and exit.
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(message)
}
