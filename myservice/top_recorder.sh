#!/usr/bin/env bash

function top_recorder() {
	local now=$(date '+%Y/%m/%d %H:%M:%S')

	# 内容会被输出到 plist 中
	ps -eo pid=,pcpu=,rss=,command= -r | head -n 10 | awk -v time="[$now]" '$2 > 80 {print time, $2, $3, $4}'
}

top_recorder
