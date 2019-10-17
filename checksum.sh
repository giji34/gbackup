#!/bin/bash

nproc=$(nproc)
num_files=$(ls -1 | grep '^r\.[0-9-]*\.[0-9-]*\.mca$' | wc -l | bc)
file_per_proc=$(echo "$num_files / $nproc" | bc)
if [ $file_per_proc -lt 1 ]; then
	file_per_proc=1
fi
(ls -1 | grep '^r\.[0-9-]*\.[0-9-]*\.mca$' | xargs -P $nproc -n $file_per_proc sha1sum) | awk '{print $2, $1}' | sort
