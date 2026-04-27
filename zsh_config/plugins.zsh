# --- [ antidote ] plugins manager -----------------------------------------------------------------
# `$ antidote update` 更新插件
() {
	# antidote 安装地址
	# local ANTIDOTE_DIR="$(brew --prefix antidote)/share/antidote"
	local ANTIDOTE_DIR="/opt/homebrew/opt/antidote/share/antidote"   # 节省性能, 不用执行 (brew --prefix antidote)

	local zsh_plugins_txt="$XDG_CONFIG_HOME/antidote/zsh_plugins.txt"   # antidote 配置文件
	local zsh_plugins_static="$HOME/.antidote_plugins.zsh"   # antidote 生成的静态文件

	if [[ -f "$ANTIDOTE_DIR/functions/antidote" && -f "$ANTIDOTE_DIR/antidote.zsh" ]]; then
		# Lazy-load antidote from its functions directory.
		# NOTE: 这里使用 autoload 而没用 source $ANTIDOTE_DIR/antidote.zsh, 因为外部需要
		# `antidote update` 命令来更新 plugins, 但又不用每次都 source zsh 文件, 节约性能.
		fpath=($ANTIDOTE_DIR/functions $fpath)
		autoload -Uz antidote
		# source "$ANTIDOTE_DIR/antidote.zsh"

		# 确保配置文件存在
		[[ -f "$zsh_plugins_txt" ]] || touch "$zsh_plugins_txt"

		# 生成静态 zsh 文件
		# "$zsh_plugins_txt" -nt "$zsh_plugins_static" A 比 B 更新
		if [[ ! -f "$zsh_plugins_static" || "$zsh_plugins_txt" -nt "$zsh_plugins_static" ]]; then
			antidote bundle < "$zsh_plugins_txt" > "$zsh_plugins_static"
		fi

		# 加载编译好的静态脚本
		source "$zsh_plugins_static"
	fi
}

# VVI: 加载 zsh-completions 后再使用 `compinit`
autoload -Uz compinit && compinit

# zsh-autosuggestions inline 代码提示的颜色. 默认是 8, bold black 颜色
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=240"

# --- [ fzf ] --------------------------------------------------------------------------------------
# VVI: 必须放在 `compinit` 之后
source "$HOME/.config/zsh_config/plugins/fzf.zsh"

# ---[ bat ] ---------------------------------------------------------------------------------------
### bat 主题颜色, 'bat --list-themes' 查看 theme 样式.
# "base16" 使用 0-15 color 兼容性好.
# "ansi" 只使用 0-7 color, 兼容性最好.
export BAT_THEME="Dracula"

# --- [ starship ] --------------------------------------------------------------------------------
# export STARSHIP_CONFIG=~/.config/starship.toml  # 配置文件位置
eval "$(starship init zsh)"

# --- [ zoxide ] -----------------------------------------------------------------------------------
# VVI: 必须放在 `compinit` 之后
# eval "$(zoxide init zsh)"



