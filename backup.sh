#!/bin/bash

last_message=$(git log --pretty=format:"%s" | head -1)
last_num_players=$(echo "$last_message" | cut -d: -f1 | bc)
num_players=$(./active_players 2>/dev/null)

if [ "$num_players" -gt 0 -o "$num_players" -ne "$last_num_players" ]; then
	commit_msg="$num_players: $(date "+%Y%m%d %H%M")"
	sh ./git-add.sh
	git commit -m "$commit_msg"
fi
