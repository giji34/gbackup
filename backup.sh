#!/bin/bash

set -ue

mcdir="$1"
gitdir="$2"
queryport="$3"
tooldir="$(cd "$(dirname "$0")"; pwd)"

split_regions_to_chunks="$tooldir/src/split-regions-to-chunks"
checksum="$tooldir/checksum.sh"

last_message=$(cd "$gitdir" && git log --pretty=format:"%s" | grep '^[0-9]*: [0-9]\{8\} [0-9]\{4\}$' | head -1)
last_num_players=$(echo "$last_message" | cut -d: -f1 | bc)
num_players=$(${tooldir}/active_players ${queryport} 2>/dev/null || echo 0)

if [ "$num_players" -eq 0 -a "$num_players" -eq "$last_num_players" ]; then
	exit 0
fi

commit_msg="$num_players: $(date "+%Y%m%d %H%M")"

tmp1=$(mktemp)
tmp2=$(mktemp)

for w in world world_nether/DIM-1 world_the_end/DIM1; do
	(
		cd "$mcdir/$w/region"
		bash "$checksum" > "$tmp1"
	)
	(
		mkdir -p "$gitdir/$w/chunk"
		cd "$gitdir/$w/chunk"
		(cat "$gitdir/$w/chunk/region_checksum.txt"; cat "$tmp1") | sort | uniq -u | awk "{printf \"$mcdir/$w/region/%s\n\", \$1}" | sort | uniq > "$tmp2"
		if [ -s "$tmp2" ]; then
			cat "$tmp2" | xargs "$split_regions_to_chunks"
			cp "$tmp1" ./region_checksum.txt
		fi
	)
done
(
	cd "$gitdir"
	git add -A world world_nether world_the_end
	git commit -m "$commit_msg"
	git push origin master
)
rm -f "$tmp1" "$tmp2"

