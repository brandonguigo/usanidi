package main

import (
	"os"
)

func main() {
	if err := app.New().Run(os.Args); err != nil {
		panic(err)
	}
}
