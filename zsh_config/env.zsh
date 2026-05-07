# --- [ LSCOLORS 设置 ] ----------------------------------------------------------------------------
# NOTE: macos 使用 LSCOLORS, linux 使用 LS_COLORS

# --- LSCOLORS 设置
# https://www.cyberciti.biz/faq/apple-mac-osx-terminal-color-ls-output-option/
# a / A : black   / bold
# b / B : red     / bold
# c / C : green   / bold
# d / D : yellow  / bold
# e / E : blue    / bold
# f / F : magenta / bold
# g / G : cyan    / bold
# h / H : white   / bold
# x : 终端默认颜色
export LSCOLORS=Gxfxcxdxbxegedabagacad  # 默认值是 'Gxfxcxdxbxegedabagacad'

# --- LS_COLORS 设置
# 注意: 这里设置 LS_COLORS 主要是给 `fzf`, `fd`, `tree`, `ohmyzsh` 显示颜色用. Macos 系统不会用到这个设置.
# 使用 16 color 设置 LS_COLORS, 但是因为有些颜色 vim 无法识别可能导致有很大偏差.
# fg: (30 black, 31 red, 32 green, 33 yellow, 34 blue, 35 magenta, 36 cyan, 37 white)
# bg: (40 black, 41 red, 42 green, 43 yellow, 44 blue, 45 magenta, 46 cyan, 47 white)
export LS_COLORS='rs=0:di=01;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43:'

# 使用 256 color 设置 LS_COLORS, 和上面的 16 color 使用最相近的颜色.
# LS_COLORS='rs=0:di=01;38;5;81:ln=38;5;207:so=38;5;42:pi=38;5;191:ex=38;5;167:bd=38;5;75;48;5;81:cd=38;5;75;48;5;191:su=30;48;5;167:sg=30;48;5;81:tw=30;48;5;42:ow=30;48;5;191'
# LS_COLORS="$LS_COLORS:*.go=38;5;72:*.ts=38;5;72:*.tsx=38;5;72:*.py=38;5;72:*.js=38;5;72:*.jsx=38;5;72"   # 根据文件类型设置.
#export LS_COLORS="$LS_COLORS:*.bak=38;5;242:*.gitignore=38;5;242:*.editorconfig=38;5;242"   # 根据文件类型设置.

# --- man 命令颜色设置
export LESS_TERMCAP_md=$(printf "\e[1;32m")    # md      bold      start bold
export LESS_TERMCAP_me=$(printf "\e[0m")       # me      sgr0      turn off bold, blink and underline
export LESS_TERMCAP_so=$(printf "\e[30;43m")   # so      smso      start standout (eg: search result)
export LESS_TERMCAP_se=$(printf "\e[0m")       # se      rmso      stop standout
export LESS_TERMCAP_us=$(printf "\e[4;34m")    # us      smul      start underline
export LESS_TERMCAP_ue=$(printf "\e[0m")       # ue      rmul      stop underline
#export LESS_TERMCAP_mb=$(printf "\e[1;31m")   # mb      blink     start blink  遇到需要“闪烁”显示的内容时, 将其改为“加粗红色”显示

# --- [ homebrew ] ---------------------------------------------------------------------------------
# https://brew.sh/
# VVI: 必须 `echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile`  # for apple silicon installation.
# 不要每次安装/更新软件时自动清理, 可以使用 `brew cleanup` 手动清理.
export HOMEBREW_NO_INSTALL_CLEANUP=true

# `brew bundle --help` Install and upgrade (by default) all dependencies from the Brewfile.
# `brew bundle check`, `brew bundle cleanup`, `brew bundle list` ...
export HOMEBREW_BUNDLE_FILE="$XDG_CONFIG_HOME/homebrew/brewfile"    # 默认在 ~/.Brewfile
#export HOMEBREW_BUNDLE_NO_LOCK=1  # disable brewfile.lock.json

# --- [ Tools PATH ] -------------------------------------------------------------------------------
# --- [ neovim tools ] ---
# mason tool path = `vim.fn.stdpath("data") .. "/mason_tools"`
export PATH="$PATH:$HOME/.local/share/nvim/mason_tools/bin"

# --- [ golang ] ---
### `go env` 查看
#export GOROOT="/usr/local/go"
export GOPATH="$HOME/gopath"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOBIN"

export GOFLAGS="-buildvcs=false"
export GO111MODULE=on  # on | off | auto
#export GOPROXY=off  # 默认值 "https://proxy.golang.org,direct"
#export GOSUMDB=off  # Disable the Go checksum database

### DEBUG use only, 删除所有其他 PATH
#export PATH="/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin"
#export PATH="/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/go/bin:$GOBIN"

# --- [ python ] ---
# 安装 `$ brew install uv`
# uv 默认全局虚拟环境是 ~/.venv/, 如果没有则使用 `cd; uv venv`. 在没有 source 其他虚拟环境的时候默认使用这个环境.
export PATH="$HOME/.venv/bin:$PATH"

# --- [ node@24 ] ---
export PATH="/opt/homebrew/opt/node@24/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/node@24/lib"
export CPPFLAGS="-I/opt/homebrew/opt/node@24/include"

# --- [ Godot ] ---
export PATH="/Applications/Godot.app/Contents/MacOS:$PATH"



