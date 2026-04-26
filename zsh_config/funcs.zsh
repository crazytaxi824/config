# 禁止使用 `rm`
function rm() {
	echo '\e[33muse "trash" instead\e[0m'
	return 2   # exit code
}

# macos 会自动启动 ssh-agent, 如果手动再次启动会导致创建 `~/.ssh/agent/xxx` socket 文件.
function ssh-agent() {
	if [ -S "$SSH_AUTH_SOCK" ]; then
		echo '\e[33m"ssh-agent" is running, use "ssh-add" directly\e[0m'
		return 2   # exit code
	else
		# command 关键字跳过函数，直接调用二进制
		command ssh-agent "$@"
	fi
}

# 加载自定义 zsh 函数 ------------------------------------------------------------------------------
fpath=(~/.config/zsh_config/funcs $fpath)
autoload -Uz 256color
autoload -Uz backup_config
autoload -Uz e
autoload -Uz Rg
autoload -Uz Fd



