#!/bin/bash

set -ue

mcdir="$1"
gitdir="$2"
controller_port="$3"
tooldir="$(cd "$(dirname "$0")"; pwd)"

split_regions_to_chunks="$tooldir/src/split-regions-to-chunks"
checksum="$tooldir/checksum.sh"
lockfile="$tooldir/lock.pid"

(
	flock -w 10 -x 200 || {
		echo "backup.sh already running"
		exit
	}

	needs_backup=$(curl http://localhost:$controller_port/statistics/needs_backup)

	if [ "$needs_backup" == "none" ]; then
		rm -f "$tooldir/lock.pid"
		exit 0
	fi

	commit_msg="$needs_backup: $(date "+%Y%m%d %H%M")"

	tmp1=$(mktemp)
	tmp2=$(mktemp)

	curl -XPOST http://localhost:$controller_port/autosave/increment_suspention_ticket

	for w in world world_nether/DIM-1 world_the_end/DIM1; do
		(
			if [ -d "$mcdir/$w/region" ]; then
				cd "$mcdir/$w/region"
				bash "$checksum" > "$tmp1"
			fi
		)
		(
			mkdir -p "$gitdir/$w/chunk"
			cd "$gitdir/$w/chunk"
			touch "$gitdir/$w/chunk/region_checksum.txt"
			(cat "$gitdir/$w/chunk/region_checksum.txt"; cat "$tmp1") | sort | uniq -u | awk "{printf \"$mcdir/$w/region/%s\n\", \$1}" | sort | uniq > "$tmp2"
			if [ -s "$tmp2" ]; then
				cat "$tmp2" | xargs "$split_regions_to_chunks"
				cp "$tmp1" ./region_checksum.txt
			fi
		)
		mkdir -p "$gitdir/$w/data"
		if [ -d "$mcdir/$w/data" ]; then
			rsync -av --delete "$mcdir/$w/data/" "$gitdir/$w/data/"
		fi
		mkdir -p "$gitdir/$w/entities"
		if [ -d "$mcdir/$w/entities" ]; then
			rsync -av --delete "$mcdir/$w/entities/" "$gitdir/$w/entities/"
		fi
	done

	curl -XPOST http://localhost:$controller_port/autosave/decrement_suspention_ticket

	(
		cd "$gitdir"
		git add -A world world_nether world_the_end
		git commit -m "$commit_msg"
	)
	rm -f "$tmp1" "$tmp2"

	curl -XPOST http://localhost:$controller_port/statistics/clear_needs_backup_flag

) 200> "$lockfile"

