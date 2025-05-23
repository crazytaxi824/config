### UTF-8, `locale` 查看 LC_* 设置.
# NOTE: MacOS 中最好不要设置 LC_ALL. It breaks on some version of MacOS.
# 设置了 LC_ALL 后, 其他 LC_* 强制等于 LC_ALL, 单独设置其他 LC_* 无效.
unset LC_ALL  # 清除 LC_ALL 设置
export LANG=en_US.UTF-8 # 设置了 LANG, 但是没有设置 LC_ALL 的情况下, 其他 LC_* 默认等于 LANG, 但可以单独设置其他 LC_*.

# NOTE: 手动安装 https://github.com/neovim/neovim/releases/
# Run: `xattr -c ./nvim-macos-arm64.tar.gz` (to avoid "unknown developer" warning)
# Extract: `tar xzvf nvim-macos-arm64.tar.gz`
#export PATH=$HOME/nvim-macos-arm64/bin:$PATH

# $VISUAL is a more capable and interactive preference over $EDITOR.
#  - EDITOR editor should be able to work without use of "advanced" terminal functionality.
#  - VISUAL editor could be a full screen editor as vi or emacs.
export EDITOR=nvim
export VISUAL=$EDITOR

# --- [ oh my zsh ] -------------------------------------------------------------------------------- {{{
# ohmyzsh #12257 #12328 async problem.
# https://github.com/ohmyzsh/ohmyzsh/issues/12328
# set before `source oh-my-zsh.sh`
zstyle ':omz:alpha:lib:git' async-prompt no
# zstyle ':omz:alpha:lib:git' async-prompt force

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="my-final"  # based on "gnzh"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
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

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
# }}}

# 自定义颜色显示, 覆盖 ohmyzsh 默认设置. 需要放到 ohmyzsh 后面.
# --- [ COLOR 设置 ] ------------------------------------------------------------------------------- {{{
# *** 注意: macos 使用 LSCOLORS, linux 使用 LS_COLORS

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

# --- man 命令颜色设置 -----------------------------------------------------------------------------
export LESS_TERMCAP_md=$(printf "\e[1;32m")    # md      bold      start bold
export LESS_TERMCAP_me=$(printf "\e[0m")       # me      sgr0      turn off bold, blink and underline
export LESS_TERMCAP_so=$(printf "\e[30;43m")   # so      smso      start standout (eg: search result)
export LESS_TERMCAP_se=$(printf "\e[0m")       # se      rmso      stop standout
export LESS_TERMCAP_us=$(printf "\e[4;34m")    # us      smul      start underline
export LESS_TERMCAP_ue=$(printf "\e[0m")       # ue      rmul      stop underline
#export LESS_TERMCAP_mb=$(printf "\e[1;31m")   # mb      blink     start blink

# }}}

# NOTE 必须要: `echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile`  # for apple silicon installation.
# --- [ homebrew ] --------------------------------------------------------------------------------- {{{
# https://brew.sh/
# 不要每次安装/更新软件时自动清理, 可以使用 `brew cleanup` 手动清理.
export HOMEBREW_NO_INSTALL_CLEANUP=true

# `brew bundle --help` Install and upgrade (by default) all dependencies from the Brewfile.
# `brew bundle check`, `brew bundle cleanup`, `brew bundle list` ...
export HOMEBREW_BUNDLE_FILE=$HOME/.config/Brewfile  # 默认在 ~/.Brewfile
#export HOMEBREW_BUNDLE_NO_LOCK=1  # disable Brewfile.lock.json
# }}}

# go / py / ruby / node / :Mason ...
# --- [ Tools PATH ] ------------------------------------------------------------------------------- {{{
# --- [ neovim Mason tools ] ---
# mason tool path = `vim.fn.stdpath("data") .. "/mason_tools"`
export PATH=$PATH:$HOME/.local/share/nvim/mason_tools/bin

# --- [ golang ] --------------------------------------------------------------- {{{
### `go env` 查看
#export GOROOT=/usr/local/go
export GOPATH="$HOME/gopath"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOBIN"

export GOFLAGS="-buildvcs=false"
export GO111MODULE=on  # on | off | auto
#export GOPROXY=off  # 默认值 "https://proxy.golang.org,direct"
#export GOSUMDB=off  # Disable the Go checksum database


### DEBUG use only, 删除所有其他 PATH
#export PATH=/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin
#export PATH=/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/go/bin:$GOBIN

# }}}

# --- [ python ] --------------------------------------------------------------- {{{
# 安装 `$ brew install uv`
# `uv pip install <pkg>`
# uv 默认全局虚拟环境是 ~/.venv/, 在没有 source 其他虚拟环境的时候默认使用这个环境.
export PATH="$HOME/.venv/bin:$PATH"

# }}}

# --- [ node@20 ] -------------------------------------------------------------- {{{
export PATH="/opt/homebrew/opt/node@20/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/node@20/lib"
export CPPFLAGS="-I/opt/homebrew/opt/node@20/include"

# }}}

# --- [ ruby ] ----------------------------------------------------------------- {{{
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"

# }}}

# }}}

# NOTE: 必须放在 $EDITOR 设置后. `man fzf`
# --- [ fzf ] -------------------------------------------------------------------------------------- {{{
# --- [ fzf fd bat 使用说明 ] ---------------------------------------------------------------------- {{{
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

# --- [ bat flags ] --------------------------------------------------------------------------------
# `man bat`
#    -n   相当于 --style=numbers 只显示 line number 没有其他装饰, eg: file name, header...
#    -H   高亮 line, -H=line_start:line_end; -H=line_start:+number_of_line
#    -r   只显示指定行内容, -r=line_start:line_end; -r=line_start:+number_of_line, line_start 显示在最上方.
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
#
#      ctrl-e:become(...)                 become(...) 相当于 abort+execute(...)
#      ctrl-e:abort+execute(nvim -- {})   nvim/vim 编辑文件. 这里将 ctrl-e 绑定了两个命令, 命令间用 + 连接.
#                                         先 abort 关闭 fzf 窗口, 然后执行 nvim 操作. 否则 fzf 窗口不会自动关闭.
#      ctrl-o:abort+execute(open {})      打开文件.
#
#      btab:change-preview-window(down,border-top|hidden|)'  # <Shift-Tab> 滚动切换 preview-window 展示方式,
#                                                            # NOTE: 注意最后有个 |
#
#    --preview'  展示预览, 默认使用 cat.
#      可以设置为:
#        - 如果是文件   [[ -f {} ]] && bat {} 则使用 bat 来预览.
#        - 如果是文件夹 [[ -d {} ]] && tree {} 则使用 tree 来预览.
#
#    fzf 对 stdin 字符串的处理.
#       {}    代表光标所在行的 string.
#       {1}   代表光标所在行按照 --delimiter 分隔后的 str[0], --delimiter 默认是空格.
#       {2}   代表光标所在行 str[1].
#
#       {-1}     光标所在行 split string 中的最后一个.
#       {1..3}   光标所在行 str[0:3]
#       {-4..-2} 光标所在行 split string 中倒数第4个 ~ 倒数第2个. eg: ls -l | fzf --preview="echo user={3} when={-4..-2}; cat {-1}"
#
#       {+}   NOTE: 表示多个 <tab> selected item.
#                   如果没有 selected items 则返回当前行;
#                   如果有 selected items 则返回 selected items.
#       {+1}  表示多个 <tab> selected item 中的 []str[0]
#
#       {+f}  NOTE: 创建一个临时文件, 然后将多选 items 写入其中. 可用其他程序读取该文件.
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

# NOTE: Set up fzf key bindings and fuzzy completion.
eval "$(fzf --zsh)"

# FZF_DEFAULT_COMMAND & FZF_DEFAULT_OPTS ---------------------------------------
# -E='**/.*/**' 显示所有隐藏文件夹, 但 exclude 隐藏文件夹中的文件.
fzf_def_cmd="fd --color=always --follow --hidden --no-ignore \
	-E='.DS_Store' -E='.git' -E='*.swp' -E='**/.*/**' -E='**/node_modules/**' -E='**/coverage/**' \
	-E='**/vendor/**' -E='**/dist/**' -E='**/out/**'"

# 'fzf' 文件搜索设置
export FZF_DEFAULT_COMMAND="$fzf_def_cmd"

# NOTE: The $'…' quoting syntax, which expands ANSI-C backslash-escaped characters in the text between the single quotes, is supported (see ANSI-C Quoting).
FZF_DEFAULT_OPTS=$'--header="<C-e>:Edit; <C-o>:Open; <Tab>:Select; <S-Tab>:Prev-win; <C-k>:Prev-wrap; <C-a>:Select-ALL; <C-d>:Deselect-All"'

# btab=<Shift-Tab>
# Vim: Warning: Output not to a terminal. 解决方法: `vim/nvim "filepath" > /dev/tty`
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS" --height=80% --ansi --multi --layout=reverse --border --scrollbar='▌▐' \
	--marker='✔' --pointer='▸' --info='inline-right' \
	--color='dark,hl:191:reverse,hl+:191:reverse,fg+:underline,bg+:238:bold,border:240' \
	--color='scrollbar:240,pointer:191,marker:191,gutter:-1,header:71:italic:underline' \
	--preview='([[ -d {} ]] && (tree -NC -L 1 {})) || ([[ -f {} ]] && (bat --color=always --style=numbers {}))' \
	--preview-window='right,60%,border-left' \
	--bind='btab:change-preview-window(top,70%,border-bottom|hidden|)' \
	--bind='ctrl-k:toggle-preview-wrap+toggle-wrap' \
	--bind='shift-up:half-page-up,shift-down:half-page-down' \
	--bind='pgup:preview-half-page-up,pgdn:preview-half-page-down' \
	--bind='ctrl-a:select-all,ctrl-d:deselect-all' \
	--bind='ctrl-e:become($EDITOR \"+lua FZF_selected([[{+f}]])\" > /dev/tty)' \
	--bind='ctrl-o:execute(open {})'"

# FZF_CTRL_T_COMMAND & FZF_CTRL_T_OPTS -----------------------------------------
# NOTE: 需要先设置 key bindings 和 fuzzy completion.
export FZF_CTRL_T_COMMAND="$fzf_def_cmd --type=directory"

# Ctrl+T 快捷键 options 设置. 这里会继承 default 设置, 只需要覆盖设置.
export FZF_CTRL_T_OPTS="--bind='start:unbind(ctrl-e)+unbind(ctrl-o)' \
	--header='# Dirs only, <Enter>:accept; <S-Tab>:Preview-win; <Tab>:Select; <C-a>:Toggle-All-Selected'"

# FZF_CTRL_R_OPTS, Ctrl+R 不能设置 Command. ------------------------------------
# NOTE: Ctrl+R 不能设置 Command.
# NOTE: CTRL+R 强制 --no-multi 禁止 <tab> multi select.
export FZF_CTRL_R_OPTS="--bind='start:unbind(ctrl-e)+unbind(ctrl-o)' \
	--height=24 --preview-window=hidden \
	--header='# Command history, <Enter>:accept; <Esc>:cancel'"

# fzf auto completion 的设置 --------------------------------------------------
# NOTE: fzf 的 auto completion 是智能触发的. 使用不同的前置命令会得到不同的结果.
#   - '$ vim **<tab>' 这里会触发文件(filepath)查找命令;
#   - '$ cd **<tab>' 会触发文件夹(dir)查找命令.
# 使用 '\\<tab>' 触发 fzf. 默认值是 '**<tab>'.
export FZF_COMPLETION_TRIGGER='\\'

# 这里会继承 default 设置, 需要 unbind.
export FZF_COMPLETION_OPTS="--bind='start:unbind(ctrl-e)+unbind(ctrl-o)'"

# fzf advance settings ---------------------------------------------------------
# 定义 fzf autocomplete 文件路径(filepath)的 command.
# eg: 'vim **<tab>'; '$ vim src/**<tab>'; '$ cat ~/**<tab>'
_fzf_compgen_path() {
	# find "$1" -type f
	# "$1" 代表输入的前置路径, eg: "cat src/**<tab>" 从 src/ 开始搜索.
	# "." 表示名字匹配
	eval "$fzf_def_cmd --type=file . $1"
}

# 定义 fzf autocomplete 文件夹路径(dir)的时候的 command. "$1" 代表输入的前置路径.
# eg: '$ cd **<tab>'; 'cd ~/**<tab>'
_fzf_compgen_dir() {
	# find "$1" -type d
	eval "$fzf_def_cmd --type=directory . $1"
}

# Advanced customization of fzf options via _fzf_comprun function
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

# NOTE: 必须安装 ripgrep
# Ripgrep 文件内容查找 ----------------------------------------------------------------------------- {{{
# --- [ rg bat vim/nvim 使用说明 ] ----------------------------------------------------------------- {{{
# 需要安装 ripgrep, fzf, bat, nvim - 'brew install rg fzf bat nvim' 命令行工具
#
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
#   --                  -- 后不能再设置其他 flag. eg: `rg -- "foo" -g "bar.md"` 这是错误的.
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
#   --sort=path     结果排序, 默认 'none'.
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
# }}}

# NOTE: 使用方法
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
	# NOTE: fzf 的设置会从 FZF_DEFAULT_OPTS 继承过来, 这里不需要重复设置.
	# --no-multi 表示不能使用 <tab> 多选, 这里可以覆盖 fzf default 设置.
	# --delimiter=':' 意思是使用 ':' 分隔 string 结果.
	# {}    代表当前行的 string.
	# {1}   filepath. 是按照 --delimiter 分隔后的 str[0], --delimiter 默认是空格.
	# {2}   line_num
	# {3}   column
	# --preview-window '+50/2'   将第 50 行放到 preview window 中间.
	# --preview-window 'right,70%,border-left,+50/2'   preview-window 在右侧占 70%, 左边框, 将第 50 行放到屏幕中间.

	# NOTE: command 中不要插入注释, 否则报错.
	rg --colors="path:fg:81" --colors="line:fg:241" --colors="column:fg:241" \
		--colors="match:fg:207" --colors="match:style:nobold" --colors="match:style:underline" \
		--color=always --sort=path --follow --crlf --vimgrep --trim --smart-case "$@" | \
	fzf --delimiter=':' \
		--preview "bat --color=always --style=numbers --highlight-line={2} {1}" \
		--preview-window '+{2}/2' \
		--bind "ctrl-o:execute(open {1})"
}

# }}}

# }}}

# the followings are core shell script functions, to make sure this `zshrc` working properly.
# do not move these functions to other places!!!
# NOTE: 本文件和 source 文件函数中的 for loop 变量必须先使用 local 定义,
# 否则在函数执行后变量会变成 global variable.
# --- [ core shell script functions ] -------------------------------------------------------------- {{{
# NOTE:
# `cp -r src dst/`   注意 src 后面没有 /   copy src 整个文件夹到 dst 文件夹内, 结果: dst/src/...
# `cp -r src/ dst/`  注意 src 后面有 /     copy src 内所有 file/dir 到 dst 内, 包括隐藏文件.
# `cp -r src/* dst/` 注意 src 后面有 /*    copy src 内 file/dir 到 dst 内, 不包括隐藏文件.
# backup - vimrc zshrc coc-setting lazygit snippets alacritty vscode ----------- {{{
function backupConfigFiles() {
	# 多个备份文件夹地址
	# ~/Library/Mobile\ Documents/com~apple~CloudDocs/myautobak  # icloud drive 文件夹
	# 不能用单/双引号 '~/xxx' "~/xxx", 否则无法解析 ~/ 路径.
	local backup_folder_list=(
		$HOME/.config/backup
	)

	# mark 是否有备份文件夹不存在
	local backupFoldersExist=true

	# for 循环
	local backup_folder
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

		# zprofile & zshrc
		cp $HOME/.zprofile $backup_folder/HOME/
		cp $HOME/.zshrc $backup_folder/HOME/

		# oh-my-zsh custom themes
		cp -r $HOME/.oh-my-zsh/custom/themes $backup_folder/HOME/.oh-my-zsh/custom/
		cp $HOME/.warprc $backup_folder/HOME/   # oh-my-zsh plugin `wd` config file

		# ~/.ssh/config
		cp $HOME/.ssh/config $backup_folder/HOME/.ssh/

		# git setting
		# NOTE: '~/.gitconfig' is a private file, SHOULD NOT be uploaded to internet.
		cp $HOME/.gitconfig_ext $backup_folder/HOME/
		cp $HOME/.gitconfig_tools $backup_folder/HOME/
		cp $HOME/.gitconfig_delta $backup_folder/HOME/
		cp $HOME/.gitmessage $backup_folder/HOME/
		cp $HOME/.gitignore_global $backup_folder/HOME/

		# vimrc
		cp $HOME/.vimrc $backup_folder/HOME/
		cp -r $HOME/.vim $backup_folder/HOME/

		# tmux
		cp $HOME/.tmux.conf $backup_folder/HOME/

		# lazygit ~/Library/Application Support/lazygit/config.yml
		cp $HOME/Library/Application\ Support/lazygit/config.yml $backup_folder/lazygit/

		# vscode settings.json keybindings.json & snippets
		cp $HOME/Library/Application\ Support/Code/User/*.json $backup_folder/vscode/
		cp -r $HOME/Library/Application\ Support/Code/User/snippets $backup_folder/vscode/
	done

	echo -e "\e[32mBackup Done! Happy Coding!\e[0m"
}

# }}}

# 设置 'vimExistFile -- [filepath]' 命令, 不打开不存在的文件 ------------------- {{{
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
	local arg  # 防止 for 循环中的变量变成 global variable.
	for arg in "$@"
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
	$EDITOR "$@"
}

# }}}

# NOTE: stop using 'rm'
#alias rm="rm -i"  # prompt every time when 'rm file/dir'
alias rm="echo '\e[33muse \"trash\" instead\e[0m'; #ignore_rest_cmd"
# NOTE: trash cmd is available in Macos
# alias trash="zsh $HOME/.config/.my_shell_functions/trash.sh"

### open/edit file
alias e="vimExistFile --"   # edit file, vimExistFile() 函数定义在下面.

# 检查 command tools 是否安装
alias checkZshTools="zsh $HOME/.config/.my_shell_functions/check_zsh_tools.sh"

# 检查 terminal 是否支持 256-color
# 256color [fg | bg | all]
# 256color 可以直接 sh / bash 执行, 语法兼容.
alias 256color="sh $HOME/.config/.my_shell_functions/256color.sh"

# 检查 vscode 开发环境.
# checkDevelopEnv [go | js | ts | react | py]
# 只能使用 zsh 执行, 语法不兼容 sh & bash.
alias checkDevEnv="zsh $HOME/.config/.my_shell_functions/check_dev_env.sh"

# NOTE: 现在可以使用 `brew bundle check`, `brew bundle cleanup` 来检查不属于 Brewfile 的包.
# 检查 brew 中所有不属于任何别的包依赖的包.
#alias checkBrewRootFormula="zsh $HOME/.config/.my_shell_functions/brew_root_formula.sh"
# 检查 brew dependency 属于哪个包.
alias checkBrewDependency="bash $HOME/.config/.my_shell_functions/brew_dep_check.sh"

# NOTE: DEBUG 用, my test functions
#source $HOME/.config/.my_shell_functions/zshrc_custom_functions

# }}}

# --- [ keybindings ] ------------------------------------------------------------------------------ {{{
# `bindkey -M main`   # 查看所有快捷键
# `bindkey "^k" kill-line`       # 设置快捷键, CTRL-k
# `bindkey "^[f" forward-word`   # ESC-f, 先按 ESC 再按 f.
# `bindkey "^[b" backward-word`  # ESC-b, 先按 ESC 再按 b.
#
# }}}

# --- [ others ] ----------------------------------------------------------------------------------- {{{
### bat 主题颜色, 'bat --list-themes' 查看 theme 样式.
# "base16" 使用 0-15 color 兼容性好.
# "ansi" 只使用 0-7 color, 兼容性最好.
export BAT_THEME="Dracula"

### firefox chrome ssl key 文件保存位置, 用于 wireshark 解密 https tls 数据.
# wireshark `设置 -> Protocols -> TLS -> (Pre)-Master-Secret log filename` 中
# 输入 SSLKEYLOGFILE 相同文件路径. 这样 wireshark 就能使用 ssl-key 解密 https 消息.
# NOTE: 必须完全退出 chrome/firefox 后, 再使用 terminal 打开 firefox/chrome 才会生成 sslkey.log 文件.
export SSLKEYLOGFILE=/tmp/sslkey.log  # /tmp 文件夹会被系统自动清理.
alias firefox='open -n /Applications/Firefox.app'
alias chrome='open -n /Applications/Google\ Chrome.app'

### du file size
alias lldu="du -shc ./.* ./*"

### alias 快速设置本地 time zone
alias setny='sudo systemsetup -settimezone America/New_York'
alias setsy='sudo systemsetup -settimezone Australia/Sydney'

### lazygit
# brew info lazygit; https://github.com/jesseduffield/lazygit
# brew info git-delta; https://github.com/dandavison/delta
alias lg=$(brew --prefix)/bin/lazygit

### delta, 需要安装 'brew info git-delta'
### 放在 oh-my-zsh 后面是为了覆盖已提供的 diff() 函数.
### NOTE: 这里不适用 alias 主要是因为 auto-completion.
function diff() {
	$(brew --prefix)/bin/delta --dark --line-numbers --side-by-side \
		--syntax-theme=none --line-numbers-minus-style=196 "$@"
}

### 使用方法 `Fd foo /path`, eg: `Fd minecraft /`
### 查找文件同时显示大小.
function Fd() {
	fd --hidden --no-ignore --color="never" -E="/System/" -E=".git/" -E=".Trash/" "$@" | xargs -I {} du -sh "{}"
}

# }}}



