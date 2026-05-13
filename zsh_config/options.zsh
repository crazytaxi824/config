# --- [ auto completion menu ] ---------------------------------------------------------------------

# 开启菜单选择：当补全候选多于 1 个时，按 Tab 进入选择模式
zmodload zsh/complist  # 加载补全列表选择模块
zstyle ':completion:*' menu select  # 开启补全菜单选择
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"  # 补全列表显示颜色（与 ls 一致）

# --- [ command history ] --------------------------------------------------------------------------
HISTFILE=~/.zsh_history  # 历史记录文件的存放位置, 默认为 `~/.zsh_history`
HISTSIZE=6000  # 内存中保存的历史命令条数. 输入命令时, Zsh 会在内存里记录
SAVEHIST=6000  # 硬盘中保存的历史命令条数. 关闭终端时, Zsh 会把内存中的记录"持久化"到硬盘上

setopt SHARE_HISTORY   # 允许在多个正在运行的终端窗口之间共享历史记录
setopt INC_APPEND_HISTORY  # 立即将命令写入历史文件，而不是等终端关闭 (防止崩溃导致记录丢失)
setopt HIST_REDUCE_BLANKS  # 在保存历史时去掉多余的空格
setopt HIST_IGNORE_SPACE   # 在命令开头加个空格, 这条命令就不会被记录
# setopt EXTENDED_HISTORY  # 记录命令执行的时间戳，配合 'history -E' 查看

# setopt HIST_IGNORE_DUPS    # 如果连续输入相同的命令，只记录一个
setopt HIST_IGNORE_ALL_DUPS  # 任何命令只被记录一次


# --- [ others ] -----------------------------------------------------------------------------------
# 开启交互式注释, 可以在 command 中插入注释. eg: `ls # foo`
setopt interactivecomments



