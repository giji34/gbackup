#!/bin/bash

(
	cd "$(dirname "$0")"
	last_message=$(git log --pretty=format:"%s" | grep '^[0-9]*: [0-9]\{8\} [0-9]\{4\}$' | head -1)
	last_num_players=$(echo "$last_message" | cut -d: -f1 | bc)
	num_players=$(./active_players 2>/dev/null || echo 0)

	if [ "$num_players" -gt 0 -o "$num_players" -ne "$last_num_players" ]; then
		commit_msg="$num_players: $(TZ=Asia/Tokyo date "+%Y%m%d %H%M")"
		sh ./git-add.sh
		git commit -m "$commit_msg"
		git push backup master
	fi
)
