#!/usr/bin/env bash

function top_recorder() {
	local now=$(date '+%Y/%m/%d %H:%M:%S')
	ps -eo pid=,pcpu=,rss=,command= -r | awk -v time="[$now]" '$2 > 80 {print time, $2, $3, $4}' | head -10
}

top_recorder
