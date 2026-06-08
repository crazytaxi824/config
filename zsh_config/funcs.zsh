# 禁止使用 `rm`
function rm() {
	printf "\e[33m%s\e[0m\n" 'use "trash" instead'
	return 2   # exit code
}

# macos 会自动启动 ssh-agent, 如果手动再次启动会导致创建 `~/.ssh/agent/xxx` socket 文件.
function ssh-agent() {
	if [ -S "$SSH_AUTH_SOCK" ]; then
		printf "\e[33m%s\e[0m\n" '"ssh-agent" is running, use "ssh-add" directly'
		return 2   # exit code
	else
		# command 关键字跳过函数，直接调用二进制
		command ssh-agent "$@"
	fi
}

# 加载自定义 zsh 函数 ------------------------------------------------------------------------------
fpath=($XDG_CONFIG_HOME/zsh_config/funcs $fpath)
autoload -Uz 256color
autoload -Uz backup_config
autoload -Uz e
autoload -Uz Rg
autoload -Uz Fd



