# --- [ auto completion menu ] ---------------------------------------------------------------------
# 加载补全列表选择模块
zmodload zsh/complist

# 开启菜单选择：当补全候选多于 1 个时，按 Tab 进入选择模式
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"  # 补全列表显示颜色（与 ls 一致）

# --- [ command history ] --------------------------------------------------------------------------
# 内存中保存的历史命令条数
# 当你在当前终端输入命令时，Zsh 会在内存里记下这么多条
HISTSIZE=10000

# 硬盘（历史文件）中保存的历史命令条数
# 当你关闭终端时，Zsh 会把内存中的记录“持久化”到硬盘上
SAVEHIST=10000

# 历史记录文件的存放位置（可选，默认为 ~/.zsh_history）
HISTFILE=~/.zsh_history

# 立即将命令写入历史文件，而不是等终端关闭（防止崩溃导致记录丢失）
setopt INC_APPEND_HISTORY

# 允许在多个正在运行的终端窗口之间共享历史记录
setopt SHARE_HISTORY

# 在保存历史时去掉多余的空格
setopt HIST_REDUCE_BLANKS

# 如果连续输入相同的命令，只记录一个
# setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS

# 记录命令执行的时间戳，配合 'history -E' 查看
# setopt EXTENDED_HISTORY



