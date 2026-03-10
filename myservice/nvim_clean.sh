#!/usr/bin/env bash

function nvim_clean() {
	local now=$(date '+%Y/%m/%d %H:%M:%S')

	# `ps -eo pid,ppid,tty,command`   获取 pid, ppid, tty, command 这几个属性
	# `grep [n]vim`          避免 grep 进程被杀. grep 进程中不会出现 nvim, 而是 [n]vim
	# `awk $2 == 1`          父进程 ppid == 1 说明是 Orphan Processes
	# `awk $3 ~ /^\?\??$/`   tty 正则匹配 `^?$` or `^??$`. linux 中是一个 ?, macos 中是 ??
	# `awk {print $1}`       只输出 pid list
	# `tr '\n' ' '`          将换行符替换为空格
	local pids=$(ps -eo pid,ppid,tty,command | grep '[n]vim' | awk '$2 == 1 && $3 ~ /^\?\??$/ {print $1}' | tr '\n' ' ')
	if [ -n "$pids" ]; then
		kill -9 $pids
		echo "[$now] $pids" # 输出内容到 plist 中
	fi
}

nvim_clean
