#!/bin/bash

(
	cd "$(dirname "$0")"
	split_regions_to_chunks="$(pwd)/split-regions-to-chunks"
	checksum="$(pwd)/checksum.sh"

	tmp1=$(mktemp)
	tmp2=$(mktemp)

	for w in world world_nether/DIM-1 world_the_end/DIM1; do
		(
			cd "$w/region"
			bash "$checksum" > "$tmp1"
		)
		(
			cd $w
			mkdir -p chunk
			cd chunk
			(cat region_checksum.txt; cat "$tmp1") | sort | uniq -u | awk '{printf "../region/%s\n", $1}' > "$tmp2"
			if [ -s "$tmp2" ]; then
				cat "$tmp2" | xargs "$split_regions_to_chunks"
				cp "$tmp1" ./region_checksum.txt
				git add region_checksum.txt
			fi
		)
	done
	git add -A world world_nether world_the_end
	rm -f "$tmp1" "$tmp2"
)
