# --- [ antidote ] plugins manager -----------------------------------------------------------------
# `$ antidote update` 更新插件
() {
	# antidote 安装地址
	# local ANTIDOTE_DIR="$(brew --prefix antidote)/share/antidote"
	local ANTIDOTE_DIR="/opt/homebrew/opt/antidote/share/antidote"   # 节省性能, 不用执行 (brew --prefix antidote)

	local zsh_plugins_txt="$XDG_CONFIG_HOME/antidote/zsh_plugins.txt"   # antidote 配置文件
	local zsh_plugins_static="$HOME/.antidote_plugins.zsh"   # antidote 生成的静态文件

	if [[ -f "$ANTIDOTE_DIR/antidote.zsh" ]]; then
		# 确保配置文件存在
		[[ -f "$zsh_plugins_txt" ]] || touch "$zsh_plugins_txt"

		if [[ ! -f "$zsh_plugins_static" || "$zsh_plugins_txt" -nt "$zsh_plugins_static" ]]; then
			# 加载 antidote 命令
            source "$ANTIDOTE_DIR/antidote.zsh"

			# 生成静态 zsh 文件
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
# --- [ fzf fd bat 使用说明 ] -------------------------------------------------- {{{
#
# 安装 fzf 命令行工具及相关工具:
#   - `brew install fzf rg fd bat` - 安装命令行工具, 所有命令行都是 go/rust 开发.
#   - `$(brew --prefix)/opt/fzf/install` - 安装 key bindings 和 fuzzy completion.
#   -  注意: fzf 设置必须放在 .zshrc 文件的最后, 否则很多设置会被覆盖.
#
# --- [ fd flags ] -------------------------------------------------------------
# fd 命令行工具在这里是 find 文件的作用.
# `man fd`
#    -L, --follow      可以显示 ln 软链接的文件.
#
#    -c, --color       never, always, auto(default)
#                      如果需要打印颜色则输出中会有 \e[XXm 的字符, fzf 需要使用 --ansi 来显示颜色.
#                      如果要定义 fd 的颜色, 需要 export LS_COLORS, 注意这里不是 LSCOLORS.
#
#    -H, --hidden      显示隐藏文件.
#
#    -I, --no-ignore   显示 '.gitignore' 忽略的文件.
#                      默认不显示 '.gitignore' 忽略的文件(夹), 但是必须是在 `git init` 之后.
#                      如果只有 '.gitignore' 而没有 `git init` 则, 则搜索不会忽略 '.gitignore' 忽略的文件.
#
#    -E, --exclude     exclude 规则和 git 一样. https://git-scm.com/docs/gitignore
#                     -E="out"        不显示 out 的文件(夹), 任何 path 下.
#                     -E="out*"       不显示 out 开头的文件(夹), 任何 path 下.
#                     -E="**/out/**"  显示 out 的文件夹, 但不显示 out 文件夹内的文件(夹), 任何 path 下.
#                     -E="out/**"     显示 ./out 的文件夹, 不显示 ./out 文件夹内的文件(夹), 但是显示 foo/out/... 文件.
#                     -E='**/.*/**'   只显示隐藏文件夹名称，不显示隐藏文件夹中的文件.
#                                     其中包括了 '.git' '.vscode' '.mypy_cache' '.vim' '.assest' ...
#                     -E=".git"       不显示任何路径下名为 .git 的 file & dir.
#                     -E="/foo"       不显示当前 pwd 的根路径下名为 foo 的 file & dir;
#                                     但如果 foo 不在当前根目录下, 而在子文件夹内则会显示出来. eg: `./bar/foo` 会显示.
#
#    --max-results 99999   限制搜索结果, 如果结果超出该值则立即停止继续搜索.
#
# fd 需要排除的常用文件和文件夹.
#     .DS_Store       - macos 文件.
#     *.swp           - vim 缓存文件.
#     .git            - git 记录文件.
#     .mypy_cache     - python mypy 的缓存文件.
#     .assets         - typora 图片文件.
#     vendor          - vendor 文件.
#     coverage        - coverage test 生成的文件. 包括 go test -cover 和 jest --coverage
#     node_modules    - node dependencies 文件.
#     dist            - typescript tsc 自动生成的文件. 根据 tsconfig.json 文件中 "outDir" 指定位置.
#     out             - typescript tsc 自动生成的文件. 同上.

# --- [ bat flags ] ------------------------------------------------------------
# `man bat`
#   -H   高亮 line, -H=line_start:line_end; -H=line_start:+number_of_line
#   -n / --style=numbers   显示行号, 没有其他装饰, eg: file name, header...
#   -r   只显示指定行内容, -r=line_start:line_end; -r=line_start:+number_of_line, line_start 显示在最上方.
#
#   --color=always         显示 syntax 颜色, theme 根据上面设置的 BAT_THEME 显示.
#
#   --line-range=30        只显示第 30 行的内容.
#   --line-range 30:       显示第 30 ~ end 行内容.
#   --line-range=30:40     只显示 30 ~ 40 行的内容.
#   --line-range=:40       显示 1 ~ 40 行的内容.
#   --line-range 30:+5     只显示第 30 行和后面的 5 行.
#
#   --highlight-line=n            高亮第 n 行.
#   --highlight-line=start:end    高亮 start ~ end 行.
#   ...                           后面和 --line-range 相同.
#
# --- [ fzf flags ] ------------------------------------------------------------
# `man fzf`
#    --height=80%      窗口为屏幕的 80%
#    --height=20       窗口为 20 行 (包括上下边框 2 行, 窗口顶部搜索和条目 2 行)
#
#    --multi    fzf 显示的 item 可以多选, 使用 <tab> 多选.
#    --ansi     打印 color 字符, \e[XXm ..., 默认会将 color 字符当作字符串打印出来.
#
#    --no-mouse    不使用鼠标.
#
#    -d, --delimiter   定义分隔符, 默认分隔符是空格.
#      eg:  -d: 或者 --delimiter=':', 这里是定义分隔符为 ':'. 注意 -d 后面不要 =, 否则报错.
#
#    --color    调整颜色 fzf 显示, 可以在同一个标记上使用多个颜色/属性.
#      eg:  --color="hl:3:reverse" 在 fzf 搜索时, 匹配文字颜色为 3(黄色)+reverse 显示. 顺序不能错.
#
#    --bind     key binding 设置.
#      eg:  --bind='shift-up:preview-half-page-up,shift-down:preview-half-page-down'" 绑定多个 key 用 , 分隔.
#      shift-up/down                      可以上下滚动 preview-window 内容.
#
#      ctrl-e:become(...)                 become(...) 相当于 abort+execute(...)
#      ctrl-e:abort+execute(nvim -- {})   nvim/vim 编辑文件. 这里将 ctrl-e 绑定了两个命令, 命令间用 + 连接.
#                                         先 abort 关闭 fzf 窗口, 然后执行 nvim 操作. 否则 fzf 窗口不会自动关闭.
#      ctrl-o:abort+execute(open -R {})   在 finder 中显示文件.
#
#      btab:change-preview-window(down,border-top|hidden|)'  # <Shift-Tab> 滚动切换 preview-window 展示方式,
#                                                            # NOTE: 注意最后有个 '|'
#
#    --preview'  展示预览, 默认使用 cat.
#      可以设置为:
#        - 如果是文件   [[ -f {} ]] && bat {} 则使用 bat 来预览.
#        - 如果是文件夹 [[ -d {} ]] && tree {} 则使用 tree 来预览.
#
#    fzf 对 stdin 字符串的处理.
#       {}    代表光标所在行的 string.
#       {1}   代表光标所在行按照 --delimiter (默认空格) 分隔后的 str[0]
#       {2}   代表光标所在行 str[1].
#
#       {-1}     光标所在行 split string 中的最后一个.
#       {1..3}   光标所在行 str[0:3]
#       {-4..-2} 光标所在行 split string 中倒数第4个 ~ 倒数第2个. eg: ls -l | fzf --preview="echo user={3} when={-4..-2}; cat {-1}"
#
#       {+}   NOTE: 表示多个 <tab> selected items.
#                   如果没有 selected items 则返回当前 item, 即: {}
#                   如果有 selected items 则返回 selected items.
#
#       {+1}  NOTE: 是 {+} 和 {1} 的结合
#                   表示多个 <tab> selected items 中每一个 item 的 str[0] 组成的 list
#                   结果是 []string{item1[0], item2[0], ...}
#
#       {+f}  NOTE: 是 {+} 和 {f} 的结合
#                   创建一个临时文件, 然后将多选 items 写入其中. 可用其他程序读取该文件.
#                   {+f} 临时文件的路径通常是固定的, 不会无限创建新文件. 只是每次多选后 replace 该文件中的内容.
#                   如果是 fd 选择的结果, 则临时文件中记录的是 filepath|dir.
#                   如果是 rg 返回的结果, 则临时文件中记录的是 <filepath:line:col:content>
#                   结论: {+f} 临时文件中记录的是 fzf 中(单选/多选)的结果.
#
#       eg:
#         `nvim -- {}`  表示 edit 当前行的 file.
#         `nvim -- {+}` 表示 edit selected file, 如果没有 selected file 则编辑当前行 file.
#
#    --preview-window '+10'                       将第 10 行放到 preview-window 最上面.
#    --preview-window '+50/2'                     将第 50 行放到 preview-window 中间.
#    --preview-window 'right,70%,border-left,+50/2'   preview-window 在右侧占 70%, 左边框, 将第 50 行放到屏幕中间.
# }}}

# Set up fzf key bindings and fuzzy completion.
# VVI: 必须放在 `compinit` 之后
eval "$(fzf --zsh)"

# FZF_DEFAULT_COMMAND & FZF_DEFAULT_OPTS ---------------------------------------
() {
	# -E='**/.*/**' 显示所有隐藏文件夹, 但 exclude 隐藏文件夹中的文件.
	local fzf_cmd="fd --color=always --follow --hidden --no-ignore \
		-E='.DS_Store' -E='.git' -E='*.swp' -E='**/.*/**' -E='**/node_modules/**' -E='**/coverage/**' \
		-E='**/vendor/**' -E='**/dist/**' -E='**/out/**'"

	# 'fzf' 文件搜索设置
	export FZF_DEFAULT_COMMAND="$fzf_cmd"

	# NOTE: The $'…' quoting syntax, which expands ANSI-C backslash-escaped characters in the text between
	# the single quotes, is supported (see ANSI-C Quoting).
	local fzf_header=$'--header="<C-e>:Edit; <C-o>:Sys-Open; <Tab>:Select; <S-Tab>:Preview-win\n'
	fzf_header=$fzf_header$'<C-l>:Line-wrap; <C-a>:Select-ALL; <C-d>:Deselect-ALL\n'
	fzf_header=$fzf_header$'<C-k>:Raw; <C-n>:Next-match; <C-p>:Prev-match"'
	
	local fzf_opts=" --height=80% --ansi --multi --layout=reverse --border --scrollbar='▌▐' \
		--marker='✔' --pointer='▸' --info='inline-right' --gutter=' ' --gutter-raw='▎' \
		--color='dark,hl:191:reverse,hl+:191:reverse,fg+:underline,bg+:238:bold,border:240' \
		--color='scrollbar:240,pointer:191,marker:191,gutter:191,header:71:italic:underline' \
		--preview='([[ -d {} ]] && (tree -NC -L 1 {})) || ([[ -f {} ]] && (bat --color=always --style=numbers {}))' \
		--preview-window='right,60%,border-left'"

	local fzf_keybind=" --bind='btab:change-preview-window(top,70%,border-bottom|hidden|)' \
		--bind='ctrl-l:toggle-preview-wrap+toggle-wrap' \
		--bind='ctrl-k:toggle-raw' \
		--bind='shift-up:half-page-up,shift-down:half-page-down' \
		--bind='pgup:preview-half-page-up,pgdn:preview-half-page-down' \
		--bind='ctrl-a:select-all,ctrl-d:deselect-all' \
		--bind='ctrl-e:become($EDITOR \"+lua FZF_selected([[{+f}]])\" > /dev/tty)' \
		--bind='ctrl-o:execute(open -R {})'"

	export FZF_DEFAULT_OPTS="$fzf_header $fzf_opts $fzf_keybind"

	# FZF_CTRL_T_COMMAND & FZF_CTRL_T_OPTS -----------------------------------------
	export FZF_CTRL_T_COMMAND="$fzf_cmd --type=directory"

	# Ctrl+T 快捷键 options 设置. 这里会继承 default 设置, 只需要覆盖设置.
	export FZF_CTRL_T_OPTS="--bind='start:unbind(ctrl-e)+unbind(ctrl-o)'"

	# FZF_CTRL_R_OPTS, Ctrl+R 不能设置 Command. ------------------------------------
	# NOTE: Ctrl+R 不能设置 Command.
	# NOTE: CTRL+R 强制 --no-multi 禁止 <tab> multi select.
	export FZF_CTRL_R_OPTS="--bind='start:unbind(ctrl-e)+unbind(ctrl-o)' \
		--preview-window=hidden \
		--header='<Enter>:accept; <Esc>:cancel'"

	# fzf auto completion 的设置 --------------------------------------------------
	# NOTE: fzf 的 auto completion 是智能触发的. 使用不同的前置命令会得到不同的结果.
	#   - '$ vim **<tab>' 这里会触发文件(filepath)查找命令;
	#   - '$ cd **<tab>' 会触发文件夹(dir)查找命令.
	# 使用 '\\<tab>' 触发 fzf. 默认值是 '**<tab>'.
	export FZF_COMPLETION_TRIGGER='\\'

	# 这里会继承 default 设置, 需要 unbind.
	export FZF_COMPLETION_OPTS="--bind='start:unbind(ctrl-e)+unbind(ctrl-o)' \
		--header='<Enter>:accept; <Esc>:cancel'"

	# 让文件路径补全带颜色
	_fzf_compgen_path() {
		fd --color=always --follow --hidden --no-ignore \
			-E='.DS_Store' -E='.git' -E='*.swp' -E='**/.*/**' -E='**/node_modules/**' -E='**/coverage/**' \
			-E='**/vendor/**' -E='**/dist/**' -E='**/out/**' . "$1"
	}

	# 让目录补全带颜色
	_fzf_compgen_dir() {
		fd --color=always --follow --hidden --no-ignore --type=directory \
			-E='.DS_Store' -E='.git' -E='*.swp' -E='**/.*/**' -E='**/node_modules/**' -E='**/coverage/**' \
			-E='**/vendor/**' -E='**/dist/**' -E='**/out/**' . "$1"
	}

	# Advanced customization of fzf options via _fzf_comprun function ---------- {{{
	# - The first argument to the function is the name of the command.
	# - You should make sure to pass the rest of the arguments to fzf.
	# _fzf_comprun() {
	#   local command=$1
	#   shift
	#
	#   case "$command" in
	#     cd)           fzf --preview 'tree -C {} | head -200'   "$@" ;;
	#     export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
	#     ssh)          fzf --preview 'dig {}'                   "$@" ;;
	#     *)            fzf --preview 'bat -n --color=always {}' "$@" ;;
	#   esac
	# }
	# }}}
}

# ---[ bat ] ---------------------------------------------------------------------------------------
### bat 主题颜色, 'bat --list-themes' 查看 theme 样式.
# "base16" 使用 0-15 color 兼容性好.
# "ansi" 只使用 0-7 color, 兼容性最好.
export BAT_THEME="Dracula"

# --- [ starship ] --------------------------------------------------------------------------------
# export STARSHIP_CONFIG=~/.config/starship.toml  # 配置文件位置
eval "$(starship init zsh)"

# --- [ zoxide ] -----------------------------------------------------------------------------------
# VVI: 在运行 `compinit` 命令之后再加载 zoxide
# eval "$(zoxide init zsh)"



