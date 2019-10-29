#!/bin/bash

if type nproc 2>&1 >/dev/null; then
  NPROC=$(nproc)
else
  NPROC=$(getconf _NPROCESSORS_ONLN)
fi

num_files=$(ls -1 | grep '^r\.[0-9-]*\.[0-9-]*\.mca$' | wc -l | bc)
file_per_proc=$(echo "$num_files / $NPROC" | bc)
if [ $file_per_proc -lt 1 ]; then
  file_per_proc=1
fi
(ls -1 | grep '^r\.[0-9-]*\.[0-9-]*\.mca$' | xargs -P $NPROC -n $file_per_proc openssl sha1 -r) | tr -d '*' | awk '{print $2, $1}' | sort
