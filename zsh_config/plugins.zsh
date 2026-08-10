# --- [ antidote ] plugins manager -----------------------------------------------------------------
# DOCS: https://antidote.sh/install, `Ultra high performance install`
# `$ antidote update` 更新插件
() {
	local antidote_install_dir=$(brew --prefix antidote 2>/dev/null)
	if [[ -z "$antidote_install_dir" ]]; then
		printf "\e[33m%s\e[0m\n" "antidote is not installed, 'brew install antidote'"
		return 1
	fi

	# antidote 安装地址
	local ANTIDOTE_DIR="$antidote_install_dir/share/antidote"

	# antidote 文件是否完整
	if [[ ! -f "$ANTIDOTE_DIR/functions/antidote" || ! -f "$ANTIDOTE_DIR/antidote.zsh" ]]; then
		printf "\e[1;31m%s\e[0m\n" "antidote components error"
		return 1
	fi

	# 确保 antidote 配置文件(夹)存在
	local zsh_plugins_dir="$XDG_CONFIG_HOME/antidote"
	[[ -d "$zsh_plugins_dir" ]] || mkdir -p "$zsh_plugins_dir"

	local zsh_plugins_txt="$zsh_plugins_dir/zsh_plugins.txt"
	[[ -f "$zsh_plugins_txt" ]] || touch "$zsh_plugins_txt"

	# antidote 生成的静态文件地址
	local zsh_plugins_static="$HOME/.antidote_plugins.zsh"

	# Lazy-load antidote from its functions directory.
	# NOTE: 这里使用 autoload 而没用 source $ANTIDOTE_DIR/antidote.zsh, 因为外部需要
	# `antidote update` 命令来更新 plugins, 但又不用每次都 source zsh 文件, 节约性能.
	fpath=($ANTIDOTE_DIR/functions $fpath)
	autoload -Uz antidote

	# 自动更新 antidote update plugins -----------------------------------------
	if [[ -f "$zsh_plugins_static" ]]; then
		local last_modify

		# Mac/BSD 用 -f '%m'; Linux/GNU 用 -c '%Y'
		if last_modify=$(stat -f '%m' "$zsh_plugins_static" 2>/dev/null) ||
		  last_modify=$(stat -c '%Y' "$zsh_plugins_static" 2>/dev/null); then
			# time now
			local time_now=$(date +%s)

			# N 秒后 update 一次
			if (( time_now - last_modify > 7 * 86400 )); then
				if read -q "?antidote update? [y/N] "; then
					# 换行
					echo
					# 更新 antidote plugins
					antidote update
					# 利用 mtime 强制 antidote bundle 更新
					touch "$zsh_plugins_txt"
				else
					printf "\n\e[33m%s\e[0m\n" "antidote update cancelled"
					# 利用 mtime 推迟下次 antidote update 检查
					touch "$zsh_plugins_static"
				fi
			fi
		fi
	fi

	# 生成静态 zsh 文件 --------------------------------------------------------
	# -nt  "newer than"
	if [[ ! "$zsh_plugins_static" -nt "$zsh_plugins_txt" ]]; then
		# >|  强制覆盖 (Force Clobber)
		antidote bundle < "$zsh_plugins_txt" >| "$zsh_plugins_static"
	fi

	# zsh-autosuggestions inline 代码提示的颜色. 默认是 8, bold black 颜色
	ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=240"

	# 加载编译好的静态脚本
	source "$zsh_plugins_static"
}

# VVI: 加载 zsh-completions 后再使用 `compinit`
autoload -Uz compinit
autoload -Uz zrecompile
() {
	# 检查 .zcompdump 是否存在，且它的最后修改时间是否在 n 小时以内
	local dump=(~/.zcompdump(N.mh-12))
	if (( $#dump )); then
		# 缓存很新，开启 -C 参数盲读(读取 xxx.zwc 文件)，不作任何磁盘扫描 (实现终端秒开)
		compinit -C -d ~/.zcompdump
	else
		print "compinit && zrecompile -p ~/.zcompdump"
		# 缓存不存在或超时未更新，执行常规扫描并静默生成/更新缓存
		compinit -d ~/.zcompdump
		# 强制更新 mtime
		touch ~/.zcompdump
		# 可选：将文本缓存自动编译为二进制 .zwc 文件，下一次读取速度再翻倍
		zrecompile -p ~/.zcompdump >/dev/null 2>&1
	fi
}

# --- [ fzf ] --------------------------------------------------------------------------------------
# VVI: 必须放在 `compinit` 之后
source "$XDG_CONFIG_HOME/zsh_config/plugins/fzf.zsh"

# ---[ bat ] ---------------------------------------------------------------------------------------
### bat 主题颜色, 'bat --list-themes' 查看 theme 样式.
# "base16" 使用 0-15 color 兼容性好.
# "ansi" 只使用 0-7 color, 兼容性最好.
export BAT_THEME="Dracula"

# --- [ starship ] --------------------------------------------------------------------------------
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"  # 配置文件位置
eval "$(starship init zsh)"

# --- [ zoxide ] -----------------------------------------------------------------------------------
# VVI: 必须放在 `compinit` 之后
eval "$(zoxide init zsh)"
# 必须放在 eval "$(zoxide init zsh)" 后面, 避免 zoxide 自带 z 函数会在多个 path 之间循环跳转
function z() {
	local target=$(zoxide query "$@" 2>/dev/null)
	cd "$target"  # 如果 target 为 "", 则 cd "" 会留在原地
}



