#!/usr/bin/env bash

nvim_clean() {
	local now=$(date '+%Y/%m/%d %H:%M:%S')
	local pids=$(ps -eo pid,ppid,tty,command | grep '[n]vim' | awk '$2 == 1 && $3 ~ /^\?\??$/ {print $1}')
	if [ -n "$pids" ]; then
		echo "$pids" | xargs kill -9
		echo "[$now] $pids"
	fi
}

nvim_clean
