# utf-8, `locale` 查看 LC_* 设置.
export LC_ALL=en_US.UTF-8  # 设置 LC_ALL, 其他 LC_* 强制等于 LC_ALL, 单独设置 LC_* 无效.
#export LANG=en_US.UTF-8   # 设置 LANG, 其他 LC_* 默认值等于 LANG, 但可以单独设置 LC_*.

# homebrew, https://brew.sh/
# brew 命令行工具安装路径 'echo $(brew --prefix)/bin'
# put brew path in front of others, use brew cmd first, if there are different version of same cmd line tool.
export PATH=/usr/local/sbin:$PATH

export EDITOR=nvim
export VISUAL=$EDITOR

# open/edit file
alias o="openFileOrUrl"     # open file/url, openFileOrUrl() 函数定义在下面.
alias e="vimExistFile --"   # edit file, vimExistFile() 函数定义在下面.

# --- [golang setting] ----------------------------------------------------------------------------- {{{
# `go env` 查看
#export GOROOT=/usr/local/go
export GOPATH=$HOME/gopath
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN
export GO111MODULE=on
#export GOPROXY=off  # 默认值 "https://proxy.golang.org,direct"
#export GOSUMDB=off  # Disable the Go checksum database

# DEBUG use only
# export PATH=/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin
# export PATH=/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/go/bin:$GOBIN

# }}}

# --- [other setting] ------------------------------------------------------------------------------ {{{
# python3 different version
# export PATH=/usr/local/opt/python@3.8/bin:$PATH

# vim path
#alias vim=$(brew --prefix)/bin/vim   # brew install vim 路径, 下面设置了 vim() 函数.
#alias vim='/usr/bin/vim'             # macos 内置 vim 路径

# bat 主题颜色, 'bat --list-themes' 查看 theme 样式.
export BAT_THEME="Visual Studio Dark+"
#export BAT_THEME="base16"    # "base16" 使用 0-15 color 兼容性好.
                              # "ansi" 只使用 0-7 color, 兼容性最好.

# firefox chrome ssl key 文件位置, 用于 wireshark 解密 http tls 数据.
# 需要使用 terminal 打开 firefox / chrome 才能生效, 'open -n /Applications/Firefox.app'
export SSLKEYLOGFILE=/tmp/sslkey.log  # /tmp 文件夹会被系统自动清理
alias firefox='open -n /Applications/Firefox.app'  # 使用终端打开 firefox 才会生效

# alias set time zone
alias setny='sudo systemsetup -settimezone America/New_York'
alias setsy='sudo systemsetup -settimezone Australia/Sydney'

# lazygit
# brew info lazygit; https://github.com/jesseduffield/lazygit
# brew info git-delta; https://github.com/dandavison/delta
alias lg=$(brew --prefix)/bin/lazygit

# delta, 需要安装 'brew info git-delta'
alias diff="$(brew --prefix)/bin/delta --dark --line-numbers --side-by-side --syntax-theme=none --line-numbers-minus-style=196"

# man 命令颜色设置
export LESS_TERMCAP_md=$(printf "\e[1;32m")    # md      bold      start bold
export LESS_TERMCAP_me=$(printf "\e[0m")       # me      sgr0      turn off bold, blink and underline
export LESS_TERMCAP_so=$(printf "\e[30;43m")   # so      smso      start standout (eg: search result)
export LESS_TERMCAP_se=$(printf "\e[0m")       # se      rmso      stop standout
export LESS_TERMCAP_us=$(printf "\e[4;34m")    # us      smul      start underline
export LESS_TERMCAP_ue=$(printf "\e[0m")       # ue      rmul      stop underline
#export LESS_TERMCAP_mb=$(printf "\e[1;31m")   # mb      blink     start blink

# }}}

# '~/.oh-my-zsh/lib/directories.zsh' 中定义了 `function d ()`, 相当于 dirs 的作用.
# --- [oh my zsh setting] -------------------------------------------------------------------------- {{{
#
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# custom theme dir: '~/.oh-my-zsh/custom/themes/'
ZSH_THEME="my-final"  # my-gnzh | my-simple | gnzh | af-magic

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	# git  # git 命令的 alias
	extract  # 一个命令解压所有类型的文件. 命令为 `x`, eg: 'x <filepath>'
	z
	wd  # 给常用文件夹做标记
	safe-paste  # Preventing any code from actually running while pasting.

	# 以下第三方插件需要手动安装.
	zsh-syntax-highlighting  # https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md
	zsh-autosuggestions      # https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md
)

# NOTE: zsh-autosuggestions plugin 设置
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=242"  # inline 代码提示的颜色. 默认是 8, bold black 颜色.

# oh my zsh 最后一行
source $ZSH/oh-my-zsh.sh

# }}}

# 自定义 LS 颜色显示, 覆盖 ohmyzsh 默认设置. 需要放到 ohmyzsh 后面.
# --- [LSCOLORS & LS_COLORS] ----------------------------------------------------------------------- {{{
# *** 注意: macos 使用 LSCOLORS, linux 使用 LS_COLORS
#
# --- LSCOLORS 设置 --------------------------------------------------------------------------------
# https://www.cyberciti.biz/faq/apple-mac-osx-terminal-color-ls-output-option/
#export LSCOLORS=Gxfxcxdxbxegedabagacad  # 默认值是 'Gxfxcxdxbxegedabagacad'

# --- LS_COLORS 设置 -------------------------------------------------------------------------------
# 注意: 这里设置 LS_COLORS 主要是给 `ohmyzsh`, `fd` 和 `tree` 显示颜色用. Macos 系统不会用到这个设置.
#
# 使用 16 color 设置 LS_COLORS, 但是因为有些颜色 vim 无法识别可能导致有很大偏差.
#export LS_COLORS='rs=0:di=01;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43:'  # 主要设置

# 使用 256 color 设置 LS_COLORS, 和上面的 16 color 使用最相近的颜色.
# 这里主要是为了 vim 中的 fzf.vim 能够使用指定颜色.
#LS_COLORS='rs=0:di=01;38;5;81:ln=38;5;207:so=38;5;42:pi=38;5;191:ex=38;5;167:bd=38;5;75;48;5;81:cd=38;5;75;48;5;191:su=30;48;5;167:sg=30;48;5;81:tw=30;48;5;42:ow=30;48;5;191'  # 主要设置
#LS_COLORS="$LS_COLORS:*.go=38;5;72:*.ts=38;5;72:*.tsx=38;5;72:*.py=38;5;72:*.js=38;5;72:*.jsx=38;5;72"   # 根据文件类型设置.
#export LS_COLORS="$LS_COLORS:*.bak=38;5;242:*.gitignore=38;5;242:*.editorconfig=38;5;242"   # 根据文件类型设置.

# 以下设置是给 oh-my-zsh 代码提示颜色用
#zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
#autoload -Uz compinit
#compinit

# }}}

# `$(brew --prefix)/opt/fzf/install` - 安装 key bindings 和 fuzzy completion.
# --- [ fzf ] -------------------------------------------------------------------------------------- {{{
# --- [ 安装 ] -------------------------------------------------------------------------------------
#
# 安装 fzf 命令行工具及相关工具:
#   - `brew install fzf rg fd bat` - 安装命令行工具, 所有命令行都是 go/rust 开发.
#   - `$(brew --prefix)/opt/fzf/install` - 安装 key bindings 和 fuzzy completion.
#   -  注意: fzf 设置必须放在 .zshrc 文件的最后, 否则很多设置会被覆盖.
#
# --- [ fd flags ] ---------------------------------------------------------------------------------
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
#
# --- [ fzf flags ] --------------------------------------------------------------------------------
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
#      ctrl-e:abort+execute(nvim -- {})   nvim/vim 编辑文件. 这里将 ctrl-e 绑定了两个命令, 命令间用 + 连接.
#                                         先 abort 关闭 fzf 窗口, 然后执行 nvim 操作. 否则 fzf 窗口不会自动关闭.
#      ctrl-o:abort+execute(open {})      打开文件.
#      ctrl-p:change-preview-window(down,border-top|hidden|)'  #滚动切换 preview-window 展示方式, 注意最后有个 |
#
#    --preview'  展示预览, 默认使用 cat.
#      可以设置为:
#        - 如果是文件   [[ -f {} ]] && bat {} 则使用 bat 来预览.
#        - 如果是文件夹 [[ -d {} ]] && tree {} 则使用 tree 来预览.
#
#    fzf 对 stdin 字符串的处理.
#       {}     代表整个 stdin 的 string.
#       {1}    代表 split 后的 str[0]. 和 --delimiter 配合使用. delimiter 默认是空格.
#       {2}    代表 str[1].
#
#    --preview-window '+10'                       scroll preview-window, 将第 10 行放到屏幕最上面.
#    --preview-window '+50/2'                     scroll preview-window, 将第 50 行放到屏幕中间.
#    --preview-window 'right,border-left,+50/2'   preview-window 在右侧, 没有边框, 将第 50 行放到屏幕中间.

FZF_DEFAULT_COMMAND="fd --color=always --follow --hidden --no-ignore"  # fd 命令
FZF_DEFAULT_COMMAND="$FZF_DEFAULT_COMMAND -E='.DS_Store' -E='.git' -E='*.swp'"  # skip 指定文件(夹)
FZF_DEFAULT_COMMAND="$FZF_DEFAULT_COMMAND -E='**/.*/**'"  # 显示所有隐藏文件夹, 但 skip 隐藏文件夹中的文件
FZF_DEFAULT_COMMAND="$FZF_DEFAULT_COMMAND -E='**/node_modules/**' -E='**/coverage/**'"  # 指定显示某些文件夹, 但 skip 文件夹中的文件
FZF_DEFAULT_COMMAND="$FZF_DEFAULT_COMMAND -E='**/vendor/**' -E='**/dist/**' -E='**/out/**'"  # 同上
export FZF_DEFAULT_COMMAND
# 默认 'fzf' 设置
#export FZF_DEFAULT_COMMAND='find * -type f'  # 默认值 'find * -type f', 不显示隐藏文件.

# --- [ bat flags ] --------------------------------------------------------------------------------
# `man bat`
#    -n   相当于 --style=numbers 只显示 line number 没有其他装饰, eg: file name, header...
#    -H   高亮 line, -H=line_start:line_end; -H=line_start:+number_of_line
#    -r   只显示指定行内容, -r=line_start:line_end; -r=line_start:+number_of_line, line_start 显示在最上方.

FZF_DEFAULT_OPTS="--height=80% --ansi --multi --layout=reverse --border"   # 可以添加 --no-mouse 禁用鼠标操作.
# fzf 多选时, <TAB> 选中的项会出现 mark.
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --marker='✔' --pointer='▸'"
# fzf 颜色主题 - dark; hl,hl+ 搜索匹配字符颜色; border 边框颜色; marker 颜色; pointer > 颜色; gutter 使用默认颜色.
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --color='dark,hl:191:reverse,hl+:191:reverse,border:238,pointer:191,marker:191,gutter:-1'"
# fzf preview 设置: 如果是 dir 则使用 tree; 如果是 file 使用 bat 进行 preview.
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --preview='([[ -d {} ]] && (tree -NC -L 3 {})) || ([[ -f {} ]] && (bat --color=always --style=numbers {}))'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --preview-window='right,border-left'"
# 以下是定义 fzf 快捷键作用
# [XXX] Vim: Warning: Output not to a terminal. 解决方法: `vim/nvim file > /dev/tty`
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind='ctrl-e:abort+execute($EDITOR -- {} > /dev/tty),ctrl-o:abort+execute(open {}),ctrl-a:select-all'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind='ctrl-p:change-preview-window(down,border-top|hidden|)'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind='shift-up:preview-half-page-up,shift-down:preview-half-page-down'"
export FZF_DEFAULT_OPTS

# --------------------------------------------------------------------------------------------------------
# *** 注意:  以下设置需要先使用 '$(brew --prefix)/opt/fzf/install' 安装 key bindings 和 fuzzy completion.
# --------------------------------------------------------------------------------------------------------
# Ctrl+T 快捷键 command 设置
FZF_CTRL_T_COMMAND="fd --type=d --follow --no-ignore --hidden --color=always"  # fd 命令, 这里通过 --type=d 指定只显示 dir
FZF_CTRL_T_COMMAND="$FZF_CTRL_T_COMMAND -E='.git'"  # skip 指定文件夹.
FZF_CTRL_T_COMMAND="$FZF_CTRL_T_COMMAND -E='**/.*/**'"  # 显示所有隐藏文件夹, 但 skip 隐藏文件夹中的文件
FZF_CTRL_T_COMMAND="$FZF_CTRL_T_COMMAND -E='**/node_modules/**' -E='**/coverage/**'"  # 指定显示某些文件夹, 但 skip 文件夹中的文件
FZF_CTRL_T_COMMAND="$FZF_CTRL_T_COMMAND -E='**/vendor/**' -E='**/dist/**' -E='**/out/**'"  # 同上
export FZF_CTRL_T_COMMAND
# 默认设置
#export FZF_CTRL_T_COMMAND='find . -type f'  # 默认值, 'find' 是内置命令行工具, 可使用 'find .' 显示隐藏文件.

# Ctrl+T 快捷键 options 设置. 这里会继承 default 设置, 只需要覆盖设置.
# export FZF_CTRL_T_OPTS="--bind='ctrl-e:abort+execute($EDITOR -- {} > /dev/tty)'"

# Ctrl+R 快捷键 options 设置, Ctrl+R 不能设置 Command.
# 这里会继承 default 设置, 只需要覆盖设置. default 中 --bind ctrl-e, ctrl-o 会导致编辑报错.
export FZF_CTRL_R_OPTS="--height=24 --preview-window=hidden --bind='ctrl-e:accept,ctrl-o:accept'"

# fzf auto completion 的设置 -----------------------------------------------------------------------------
# *** 注意: fzf 的 auto completion 是智能触发的. 使用不同的前置命令会得到不同的结果.
#      - '$ vim **<tab>' 这里会触发文件(filepath)查找命令;
#      - '$ cd **<tab>' 会触发文件夹(dir)查找命令.
# --------------------------------------------------------------------------------------------------------
# 使用 '\\<tab>' 触发 fzf. 默认值是 '**<tab>'.
export FZF_COMPLETION_TRIGGER='\\'

# 这里会继承 default 设置, 只需要覆盖设置.
# export FZF_COMPLETION_OPTS="--bind='ctrl-e:abort+execute($EDITOR -- {} > /dev/tty)'"

# 定义 fzf autocomplete 文件路径(filepath)的 command.
# eg: 'vim **<tab>'; '$ vim src/**<tab>'; '$ cat ~/**<tab>'
_fzf_compgen_path() {
	# find "$1" -type f
	# "$1" 代表输入的前置路径; "." 表示名字匹配
	# 使用 FZF_DEFAULT_COMMAND 命令.
	eval "$FZF_DEFAULT_COMMAND . $1"
}

# 定义 fzf autocomplete 文件夹路径(dir)的时候的 command. "$1" 代表输入的前置路径.
# eg: '$ cd **<tab>'; 'cd ~/**<tab>'
_fzf_compgen_dir() {
	# find "$1" -type d
	# 使用 FZF_CTRL_T_COMMAND 命令.
	eval "$FZF_CTRL_T_COMMAND . $1"
}

# *** 该行必须放在整个文件的最后 ***
# 下面 shell script 的意思是, 如果 ~/.fzf.zsh 文件存在, source it.
# -f 指定是 file, -d 指定是 dir
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# }}}

# the followings are core shell script functions, to make sure this `zshrc` working properly.
# do not move these functions to other places!!!
# --- [core shell script functions] ---------------------------------------------------------------- {{{

# 设置 'vimExistFile -- [filepath]' 命令, 不打开不存在的文件 --------------- {{{
# 'vim --'   Arguments after this will be handled as a file name.
#            This can be used to edit a filename that starts with a '-'.
#            默认 '--' 后的所有 args 都会被认为是 file. eg: vim -- foo.sh -n, 'foo.sh' & '-n' 会被当成两个文件.
# 使用方法:
#	`vimExistFile file`                # 一般用法不检查文件是否存在.
#   `vimExistFile -- file`             # 检查 file 是否存在.
#   `vimExistFile +[num] -- file`      # 检查 file 是否存在. 同时传入 flags.
#   `vimExistFile +{command} -- file`  # 同上
function vimExistFile() {
	local dashdash=0         # 1 = using '--'
	local notexistfiles=''   # 不存在的文件, 报错用.
	local notexistmark=0     # 1 = 有不存在的文件; 0 = 文件都存在

	# 遍历所有 args 查看是否有 '--', 如果有则将 '--' 后面不存在的文件存入 notexistfiles.
	for arg in $@
	do
		if (( $dashdash )) && [[ ! -f $arg ]] && [[ ! -d $arg ]]; then
			# '--' 后的所有 args 都会被认为是 file.
			notexistfiles+="'$arg' "   # concat string
			notexistmark=1
		fi

		if [[ $arg == '--' ]]; then
			dashdash=1
		fi
	done

	# 如果 notexistmark 是 true, 则中止操作.
	if  (( notexistmark )); then
		echo "no such file or directory: \e[33m$notexistfiles\e[0m"
		return 2  # return error code
	fi

	# 执行, 这里不能使用 eval 因为文件名里面的空格都被 escape 了.
	nvim $@
}

# }}}

# 设置 'open' 命令, 在打开的文件不存在时, 打开当作 URL 打开 ---------------- {{{
function openFileOrUrl() {
	# `2>/dev/null` 不打印 error msg
	# `echo $?` 返回上一个命令的 exitcode

	for file in $@
	do
		echo $file
		local exitcode=$(open $file 2>/dev/null; echo $?)

		if (( $exitcode != 0 )); then
			open -u "https://$file"
		fi
	done

	return 0   # 手动返回 0, 否则会返回 1.
}

# }}}

# Ripgrep 文件内容查找 ----------------------------------------------------- {{{
# --- [ rg bat 使用说明 ] --------------------------------------- {{{
### 需要安装 ripgrep, fzf, bat, nvim - 'brew install rg fzf bat nvim' 命令行工具
# --- [ rg flags ] ---------------------------------------------------------------------------------
# 'man rg' 查看命令行工具使用方法
#   -l  --files-with-matches     只打印文件名.
#   -H  --with-filename          在行内显示 filepath
#   --vimgrep                    行内显示 line numbers and column numbers
#
#
#   -L  --follow     软链接文件
#   -.  --hidden     搜索隐藏文件和文件夹.
#   -U  --multiline  多行查找, 配合 --multiline-dotall 一起使用.
#
#   -g    include/exclude files
#         -g 'xxx' include filepath
#         -g '!xxx' exclude filepath
#         -g 'src/**' 表示只搜索 'src/' 文件夹
#
#   --no-ignore    不要忽略 .gitignore 排除的文件
#                  默认不搜索 '.gitignore' 忽略的文件(夹), 但是必须是在 `git init` 之后.
#                  如果只有 '.gitignore' 而没有 `git init` 则, 则搜索不会忽略 '.gitignore' 忽略的文件.
#
#   -P  --pcre2    允许 rg 使用更复杂的 regexp 表达式, eg: '^\s(?!//)' 排除 // 开头的行.
#                  但是需要 rg 在编译时启用该选项, 否则使用时报错.
#
#   -i  --ignore-case   忽略大小写.
#   -e  --regexp        正则匹配查找内容.
#   -w  --word-regexp   匹配整个单词.
#   --                  -- 后不能再设置其他 flag. eg: rg -- "foo" -g "bar.md" 这是错误的.
#
#   -color          auto(default), never, always
#   -colors         {type}:{attribute}:{value}
#                   style:      path 文件路径, line 行号, column 列号, match 匹配到的字符.
#                   attribute:  fg, bg, style 三种属性.
#                       style 有 nobold, bold, nointense, intense, nounderline or underline.
#                       fg / bg 设置 fg:yellow - 16 color, fg:x - 256 color, fg:x,x,x - 24bit color.
#                   eg: rg --colors="path:fg:4" --colors="match:fg:5" --colors="match:style:underline"
#
#   -C3             只显示前后3行内容.
#   -o              只显示匹配的部分内容, 不显示整行内容
#   --trim          不显示内容前后的空白
#
# rg 指定文件后不会显示文件(名)路径, 所以 fzf 中 preview 中不会显示文件名.
#
# --- [ bat flags ] --------------------------------------------------------------------------------
# 'man bat'
#   --color=always         显示 syntax 颜色, theme 根据上面设置的 BAT_THEME 显示.
#   -n / --style=numbers   显示行号.
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
# --- [ vim flags ] --------------------------------------------------------------------------------
# 'man vim'
#   vim +10 -- file                      # 打开文件时 cursor 移动到第 10 行.
#   vim '+call cursor(10,6)' -- file     # 打开文件时执行 :call cursor(ln,col), 即 cursor 移动到指定 line, column.
# --------------------------------------------------------------------------------------------------
#
# }}}

# 查找文件中同一行内同时包括 'Foo.*Bar'
# 每个文件不只会出现一次, 如果一个文件中有多行都能匹配上则会出现多次.
#
# 例子: 如果要使用正则表达式, 则需要使用 '' OR "" OR \(escape), 否则报错 zsh: no matches found.
#   Rg foo\ bar == Rg 'foo bar' == Rg "foo bar" == Rg foo\ bar ./         # 在当前文件夹搜索
#   Rg 'foo.*bar' == Rg "foo.*bar" == Rg foo.\*bar == Rg 'foo.*bar' ./    # 同上
#
# 搜索指定文件(夹)
#   Rg 'foo bar'  ./src/main.go    # 在 main.go 文件中搜索 'foo bar'
#   Rg 'foo bar'  ./src            # 在 src 文件夹下搜索 'foo bar'
#   Rg 'foo.*bar' ./src ./tmp      # 在 ./src 和 ./tmp 两个文件夹下搜索 'foo.*bar'
#
# 搜索条件: -w -i -s ...
#   Rg -w 'foo'   # 匹配整个单词, 而不是部分匹配. 类似 '\bWord\b'
#   Rg -i 'foo'   # ignore case
#   Rg -s 'foo'   # case sensitive
#   Rg -S 'foo'   # --smart-case, 如果全小写则 ignore case, 如果有大写字母则 case sensitive.
#
#   Rg -wi 'foo' ./
#   Rg -ws 'foo' ./src
#   Rg -wS 'foo' ./src /tmp

function Rg() {
	# 注意: fzf 的设置会从 FZF_DEFAULT_OPTS 继承过来, 这里不需要重复设置.
	rg --colors="path:fg:81" --colors="line:fg:241" --colors="column:fg:241" \
		--colors="match:fg:207" --colors="match:style:nobold" --colors="match:style:underline" \
		--color=always -L --crlf --vimgrep --trim --smart-case $* | \
	fzf --delimiter=':' \
		--preview "bat --color=always --style=numbers --highlight-line={2} {1}" \
		--preview-window '+{2}/2' \
		--bind "ctrl-e:abort+execute($EDITOR '+call cursor({2},{3})' -- {1})" \
		--bind "ctrl-o:abort+execute(open {1})"
}

# }}}

# NOTE:
# `cp -r src dst/`   注意 src 后面没有 /   copy src 整个文件夹到 dst 文件夹内, 结果: dst/src/...
# `cp -r src/ dst/`  注意 src 后面有 /     copy src 内所有 file/dir 到 dst 内, 包括隐藏文件.
# `cp -r src/* dst/` 注意 src 后面有 /*    copy src 内 file/dir 到 dst 内, 不包括隐藏文件.
# backup - vimrc zshrc coc-setting lazygit snippets alacritty vscode ------- {{{
function backupConfigFiles() {
	# 多个备份文件夹地址
	# ~/Library/Mobile\ Documents/com~apple~CloudDocs/myautobak  # icloud drive 文件夹
	# 不能用单/双引号 '~/xxx' "~/xxx", 否则无法解析 ~/ 路径.
	local backup_folder_list=(
		~/.config/backup
	)

	# mark 是否有备份文件夹不存在
	local backupFoldersExist=true

	# for 循环
	for backup_folder in $backup_folder_list
	do
		# 判断备份文件夹是否存在
		if [[ -d $backup_folder ]]; then
			echo -e "\e[32m - $backup_folder ✔\e[0m"
		else
			echo -e "\e[31m - $backup_folder ✗\e[0m"
			backupFoldersExist=false
		fi
	done

	if [[ $backupFoldersExist == false ]]; then
		echo -e "\e[31m请手动创建 Backup 文件夹, Backup Canceled!\e[0m"
		return 2
	fi

	# copy files
	for backup_folder in $backup_folder_list
	do
		# 创建子文件夹
		# 'mkdir -p' 如果文件夹不存在则创建, 递归创建所有文件夹.
		mkdir -p $backup_folder/HOME/.oh-my-zsh/custom   # ~/, ~/.oh-my-zsh/custom/theme/
		mkdir -p $backup_folder/HOME/.ssh      # ~/.ssh/
		mkdir -p $backup_folder/lazygit        # ~/Library/Application\ Support/lazygit/
		mkdir -p $backup_folder/vscode         # ~/Library/Application\ Support/Code/User/

		# zshrc
		cp ~/.zshrc $backup_folder/HOME/
		cp -r ~/.my_shell_functions $backup_folder/HOME/  # 自定义 sh 函数文件

		# oh-my-zsh custom themes
		cp -r ~/.oh-my-zsh/custom/themes $backup_folder/HOME/.oh-my-zsh/custom/

		# ~/.ssh/config
		cp ~/.ssh/config $backup_folder/HOME/.ssh/

		# git setting
		# NOTE: '~/.gitconfig' is a private file, SHOULD NOT be uploaded to internet.
		cp ~/.gitignore_global $backup_folder/HOME/

		# tmux
		cp ~/.tmux.conf $backup_folder/HOME/

		# lazygit ~/Library/Application Support/lazygit/config.yml
		cp ~/Library/Application\ Support/lazygit/config.yml $backup_folder/lazygit/

		# vscode settings.json keybindings.json & snippets
		cp ~/Library/Application\ Support/Code/User/*.json $backup_folder/vscode/
		cp -r ~/Library/Application\ Support/Code/User/snippets $backup_folder/vscode/
	done

	echo -e "\e[32mBackup Done! Happy Coding!\e[0m"
}

# }}}

# restore config files ----------------------------------------------------- {{{
function restoreConfigFiles() {
	# 备份文件夹地址
	local backup_folder=~/.config/backup
	if [[ ! -d $backup_folder ]]; then
		echo -e "\e[31mBackup folder '$backup_folder' is not exist ✗\e[0m"
		return 2
	fi

	# Restore 文件夹
	local restore_folder_list=(
		~/.oh-my-zsh/    # 这里只是为了确保 oh-my-zsh 已经安装.
		~/Library/Application\ Support/Code/User/
		~/Library/Application\ Support/lazygit/
	)

	# mark 是否有 Restore 文件夹不存在
	local restoreFolderExists=true

	# for 循环
	for restore_folder in $restore_folder_list
	do
		# 判断 Restore 文件夹是否存在
		if [[ -d $restore_folder ]]; then
			echo -e "\e[32m - $restore_folder ✔\e[0m"
		else
			echo -e "\e[31m - $restore_folder ✗\e[0m"
			restoreFolderExists=false
		fi
	done

	if [[ $restoreFolderExists == false ]]; then
		echo -e "\e[31m有些 Restore 文件夹不存在, Restore Canceled!\e[0m"
		return 2
	fi

	# ask before restore all the config files!
	# echo -n 最后不换行
	echo -n "\e[33mThis action will overwrite all config files. Restore All Config Files? [Yes/no]:\e[0m "
	read restore
	# echo $restore  # 打印 input

	case $restore in
		"yes"|"Yes")
			# .zshrc .my_shell_functions/ .oh-my-zsh/custom/themes/ .tmux.conf .ssh/config .gitignore_global ...
			cp -r $backup_folder/HOME/ ~/
			# NOTE: restore 之后需要设置 ~/.gitconfig 文件.
			echo -e "\e[35m!!! please SETUP restored file '~/gitconfig_needs_setup' !!!\e[0m"

			# lazygit ~/Library/Application Support/lazygit/config.yml
			cp $backup_folder/lazygit/config.yml ~/Library/Application\ Support/lazygit/

			# vscode settings.json keybindings.json & snippets
			cp -r $backup_folder/vscode/ ~/Library/Application\ Support/Code/User/

			echo -e "\e[32mRestore all Done! Happy Coding!\e[0m"
			;;
		*)
			echo -e "\e[31mRestore Canceled!\e[0m"
	esac
}

# }}}

# 检查 command tools 是否安装 ---------------------------------------------- {{{
function checkZshTools() {
	echo -e "\e[32mcheck homebrew installation:\e[0m"
	if [[ -x "$(which brew)" ]]; then
		echo -e "\e[32m - brew ✔\e[0m"
	else
		echo -e "\e[31m - brew ✗, https://brew.sh/\e[0m"
		echo -e "\e[33mplease install 'homebrew' first before continue.\e[0m"
		return 2  # return error code
	fi
	printf "\n"

	local brew_path=$(brew --prefix)/bin

	echo -e "\e[32mcheck zsh environment:\e[0m"
	[ -x "$(which zsh)" ] && echo -e "\e[32m - zsh ✔\e[0m" || echo -e "\e[31m - zsh ✗, 'brew info zsh'\e[0m"
	[ -f $ZSH/oh-my-zsh.sh ] && echo -e "\e[32m - oh-my-zsh ✔\e[0m" || echo -e "\e[31m - oh-my-zsh ✗, https://ohmyz.sh/\e[0m"
	[ -x $brew_path/tmux ] && echo -e "\e[32m - tmux ✔\e[0m" || echo -e "\e[31m - tmux ✗, 'brew info tmux'\e[0m"
	printf "\n"

	echo -e "\e[32mcheck git environment:\e[0m"
	[ -x $brew_path/git ] && echo -e "\e[32m - git ✔\e[0m" || echo -e "\e[31m - git ✗, 'brew info git git-flow'\e[0m"
	[ -x $brew_path/lazygit ] && echo -e "\e[32m - lazygit ✔\e[0m" || echo -e "\e[31m - lazygit ✗, 'brew info lazygit'\e[0m"
	[ -x $brew_path/delta ] && echo -e "\e[32m - delta (git-delta) ✔\e[0m" || echo -e "\e[31m - delta (git-delta) ✗, 'brew info git-delta'\e[0m"
	printf "\n"

	echo -e "\e[32mcheck fzf environment:\e[0m"
	[ -x $brew_path/fzf ] && echo -e "\e[32m - fzf ✔\e[0m" || echo -e "\e[31m - fzf ✗, 'brew info fzf', and run: '"'$(brew --prefix)/opt/fzf/install'"'\e[0m"
	[ -x $brew_path/fd ] && echo -e "\e[32m - fd ✔\e[0m" || echo -e "\e[31m - fd ✗, 'brew info fd'\e[0m"
	[ -x $brew_path/rg ] && echo -e "\e[32m - rg (ripgrep) ✔\e[0m" || echo -e "\e[31m - rg (ripgrep) ✗, 'brew info rg'\e[0m"
	[ -x $brew_path/bat ] && echo -e "\e[32m - bat ✔\e[0m" || echo -e "\e[31m - bat ✗, 'brew info bat'\e[0m"
	[ -x $brew_path/tree ] && echo -e "\e[32m - tree ✔\e[0m" || echo -e "\e[31m - tree ✗, 'brew info tree'\e[0m"
	printf "\n"

	echo -e "\e[32mcheck nvim environment:\e[0m"
	# 如果 brew install neovim, 会安装依赖: gettext, libtermkey, libuv, luajit, luv, msgpack, tree-sitter, unibilium
	# node & python3 是 neovim 某些 plugin 的依赖. NOTE: python3 有可能需要 v3.9.x 版本
	[ -x $brew_path/nvim ] && echo -e "\e[32m - nvim ✔\e[0m" || echo -e "\e[31m - nvim ✗, 'brew info nvim'\e[0m"
	[ -x $brew_path/node ] && echo -e "\e[32m - node ✔\e[0m" || echo -e "\e[31m - node ✗, 'brew info node'\e[0m"
	[ -x $brew_path/python3 ] && echo -e "\e[32m - python3 ✔\e[0m" || echo -e "\e[31m - python3 ✗, 'brew info python3'\e[0m"
	[ -x $brew_path/pandoc ] && echo -e "\e[32m - pandoc ✔\e[0m" || echo -e "\e[31m - pandoc ✗, 'brew info pandoc'\e[0m"
	[ -x $brew_path/prettier ] && echo -e "\e[32m - prettier ✔\e[0m" || echo -e "\e[31m - prettier ✗, 'brew info prettier'\e[0m"
	[ -x $brew_path/ctags ] && echo -e "\e[32m - ctags (universal-ctags) ✔\e[0m" || echo -e "\e[31m - ctags (universal-ctags) ✗, 'brew info universal-ctags'\e[0m"
	printf "\n"
}

# }}}

# 检查 terminal 是否支持 256-color
# 256color [fg | bg | all]
# 256color 可以直接 sh / bash 执行, 语法兼容.
alias 256color="sh ~/.my_shell_functions/256color.sh"

# 检查 vscode 开发环境.
# checkDevelopEnv [go | js | ts | react | py]
# 只能使用 zsh 执行, 语法不兼容 sh & bash.
alias checkDevEnv="zsh ~/.my_shell_functions/check_dev_env.sh"

# 检查 brew / npm / pip3 包.
# packages [outdated | clean]
# 只能使用 zsh 执行, 语法不兼容 sh & bash.
alias packages="zsh ~/.my_shell_functions/packages.sh"

# 检查 brew 中所有不属于任何别的包依赖的包.
alias checkBrewRootFormula="zsh ~/.my_shell_functions/brew_root_formula.sh"
# 检查 brew dependency 属于哪个包
alias checkBrewDependency="zsh ~/.my_shell_functions/brew_dep_check.sh"

# cleanup vim undofiles
# alias cleanVimUndoFiles="zsh ~/.my_shell_functions/clean_vim_undofiles.sh"

# my test functions
source ~/.my_shell_functions/zshrc_custom_functions

# }}}

# 各种命令行工具的 autocomplete 文件路径 `/usr/local/share/zsh/site-functions`

# ------------------ todo / test function  --------------------------





