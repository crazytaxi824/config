# 禁止使用 `rm`
function rm() {
	echo '\e[33muse "trash" instead\e[0m'
	return 2   # exit code
}

# 加载自定义 zsh 函数 ------------------------------------------------------------------------------
fpath=(~/.config/zsh_config/funcs $fpath)
autoload -Uz 256color
autoload -Uz check_brew_dep
autoload -Uz backup_config
autoload -Uz e
autoload -Uz Rg
autoload -Uz Fd
autoload -Uz diff



