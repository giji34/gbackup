package main

import (
	"github.com/lukevers/mcgoquery"
	"fmt"
	"os"
	"strconv"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Printf("Usage: active_users [query port]\n")
		return
	}
	port, err := strconv.Atoi(os.Args[1])
	if err != nil {
		panic(err)
	}
	c, err := mcgoquery.Create("localhost", port)
	if err != nil {
		panic(err)
	}
	s, err := c.Basic()
	if err != nil {
		panic(err)
	}
	fmt.Println(s.NumPlayers)
}
