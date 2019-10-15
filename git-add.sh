#!/bin/bash

(
	cd "$(dirname "$0")"
	(
		cd world
		mkdir -p chunk
		cd chunk
		../../split-regions-to-chunks ..
	)
	(
		cd world_nether/DIM-1
		mkdir -p chunk
		cd chunk
		../../../split-regions-to-chunks ..
	)
	(
		cd world_the_end/DIM1
		mkdir -p chunk
		cd chunk
		../../../split-regions-to-chunks ..
	)
	git add -A world world_nether world_the_end
)
