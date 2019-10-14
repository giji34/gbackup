package main

import (
	"github.com/lukevers/mcgoquery"
	"fmt"
)

func main() {
	c, err := mcgoquery.Create("localhost", 25565)
	if err != nil {
		panic(err)
	}
	s, err := c.Basic()
	if err != nil {
		panic(err)
	}
	fmt.Println(s.NumPlayers)
}
