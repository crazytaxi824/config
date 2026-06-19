# 禁止使用 `rm`
function rm() {
	printf "\e[33m%s\e[0m\n" 'use "trash" instead'
	return 2   # exit code
}


# 加载自定义 zsh 函数 ------------------------------------------------------------------------------
fpath=($XDG_CONFIG_HOME/zsh_config/funcs $fpath)
autoload -Uz 256color
autoload -Uz backup_config
autoload -Uz e
autoload -Uz Rg
autoload -Uz Fd



