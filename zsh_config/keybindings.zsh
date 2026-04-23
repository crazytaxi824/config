# --- [ keybindings ] ------------------------------------------------------------------------------
# `$ cat -v`  查看组合键发送的 CSI (Sequence)
# `$ bindkey -M main`  查看所有快捷键
# `$ zle -la`  列出所有 bindkey actions
#
# bindkey "^k" kill-line       # 设置快捷键, CTRL-k
# bindkey "\x1b[1;2C" vi-forward-word    # shift-right
# bindkey "\x1b[1;2D" vi-backward-word   # shift-left
bindkey "^[[1;5C" vi-forward-word       # option-right
bindkey "^[[1;5D" vi-backward-word      # option-left
bindkey "^[^?" vi-backward-kill-word    # option-delete

# 1. 加载前缀搜索模块
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search

# 2. 将它们定义为可用的小部件 (Widgets)
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# 绑定搜索模块, `^[[A` - UP, `^[[B` - Down, `^[[C` - Right, `^[[D` - Left
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search



