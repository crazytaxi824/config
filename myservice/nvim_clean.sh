#!/usr/bin/env bash

# 主要是清理 nvim --embed 进程, 如果 lsp 变成孤儿则需要另外的清理手段
function nvim_clean() {
	local now=$(date '+%Y/%m/%d %H:%M:%S')

	# `ps -eo pid,ppid,tty,command`   获取 pid, ppid, tty, command 这几个属性
	# `grep [n]vim`          避免 grep 进程被杀. grep 进程中不会出现 nvim, 而是 [n]vim
	# `awk $2 == 1`          父进程 ppid == 1 说明是 Orphan Processes
	# `awk $3 ~ /^\?\??$/`   tty 正则匹配 `^?$` or `^??$`. linux 中是一个 ?, macos 中是 ??
	# `awk {print $1}`       只输出 pid list
	local now=$(date '+%Y/%m/%d %H:%M:%S')
	local process=$(ps -eo pid=,ppid=,tty=,command= | grep '[n]vim' | awk '$2 == 1 && $3 ~ /^\?\??$/')

	# 只输出 pids
	# xargs 将换行转成 list
	local pids=$(echo "$process" | awk '{print $1}' | xargs)
	if [ -n "$pids" ]; then
		kill -9 $pids
		echo "[$now]:"
		echo "$process"
	fi
}

nvim_clean
