#!/bin/zsh
# NOTE: 必须安装 firacode nerd font
# 占位符
#   %d, %/  - pwd 绝对位置
#   %~      - pwd 相对 HOME 的位置
#   %n      - username
#   %M      - full machine hostname
#
# 颜色设置
#   %K{xx} / %k   - background 颜色开始/结束
#   %F{xx} / %f   - foreground 颜色开始/结束
#   %B / %b       - bold 字体开始/结束
#
# Glyphs
# 字体默认带 \uE0A0 ~ \uE0B3 只有 Fira Code. 如果使用其他字体无法显示.
# https://fonts.google.com/?preview.text=%EE%82%B0&preview.text_type=custom&query=fira
#   echo "\uE0A0"  # 
#   echo "\uE0A1"  # 
#   echo "\uE0A2"  # 
#   echo "\uE0B0"  # 
#   echo "\uE0B1"  # 
#   echo "\uE0B2"  # 
#   echo "\uE0B3"  # 
#
# oh-my-zsh 中 git 插件函数, https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/git.zsh
# $(git_prompt_info), $(parse_git_dirty), $(git_current_branch) 都是 oh-my-zsh 中 git 插件的函数.
# $(my_git_info) 是自己写的函数

setopt prompt_subst

() {

# 样式
local PR_USER PR_PROMPT PR_HOST

# Check the UID. 根据 user 或者 root user 显示不同颜色和 prompt ($ # ... 可以为任意 char)
if [[ $UID -ne 0 ]]; then # normal user
  PR_USER='%K{237}%F{215} %n%f%k' # 灰底橙字
  PR_PROMPT='%b%f%k$' # 命令最前端的符号一般为 $ / #, $ 前的 %f%k 用于清除之前的颜色.
else # root user
  PR_USER='%K{237}%F{1}%n%f%k' # 灰底红字
  PR_PROMPT='%b%f%k%F{1}#%f'   # 红字
fi

# Check if we are on SSH or not. 根据 local 或者 remote 显示不同颜色.
if [[ -n "$SSH_CLIENT"  ||  -n "$SSH2_CLIENT" ]]; then
  PR_HOST='%K{237}%F{1}@%M %f%k' # SSH - 灰底红字
else
  PR_HOST='%K{237}%F{215}@%M %f%k' # no SSH - 灰底橙字
fi

local user_and_host="${PR_USER}${PR_HOST}"

#local current_dir="%B%K{25} %~ %k%F{25}%f%b"  # NOTE: 使用 powerline fonts █
local current_dir="%B%K{25} %~ %k%b"  # blue

# 以下环境变量是为了显示 git 状态.
ZSH_THEME_GIT_PROMPT_DIRTY=" ⛌ "
ZSH_THEME_GIT_PROMPT_CLEAN=" ✓ "
ZSH_THEME_GIT_PROMPT_SUFFIX="%b%f%k" # 清空所有颜色

# 命令返回的 exit code - 0 | 1 | 2
local return_code="%(?..%F{red}%? ↵%f)"

# NOTE: 这里必须使用函数字符串, 因为需要每次执行. my_git_info() 是自定义函数.
local git_branch='$(my_git_info)'

# NOTE: 本文件的主要变量 "PROMPT" "RPROMPT", 所有设置都是为了给这两个环境变量赋值.
# 左边 PROMPT 显示 user, host, dir, git
PROMPT="${user_and_host}${git_branch}${current_dir}
$PR_PROMPT "

# 右边 PROMPT 显示 exit code
RPROMPT="${return_code}"

}

# NOTE: 这个函数是为了每次回车时, PROMPT 能够刷新 git 状态. 主要是给 ZSH_THEME_GIT_PROMPT_PREFIX 动态赋值.
# $(git_prompt_info), $(parse_git_dirty), $(git_current_branch) 都是 oh-my-zsh 中 git 插件的函数.
# oh-my-zsh 中 git 插件函数, https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/git.zsh
function my_git_info() {
  local current_branch=$(git_current_branch)
  local dirty=$(parse_git_dirty)
  # 当前 branch 如果是 master 或者 main, 显示高亮黄色警告.
  if [[ ( $current_branch == master || $current_branch == main ) && $dirty == $ZSH_THEME_GIT_PROMPT_DIRTY ]]; then
    ZSH_THEME_GIT_PROMPT_PREFIX="%K{196}%F{15} %B " # 红底白字, 粗体
  elif [[ ( $current_branch == master || $current_branch == main ) && $dirty != $ZSH_THEME_GIT_PROMPT_DIRTY ]]; then
    ZSH_THEME_GIT_PROMPT_PREFIX="%K{214}%F{234} %B%b " # 橙底黑字
  # 判断 git 当前是 dirty 还是 clean.
  elif [[ $dirty == $ZSH_THEME_GIT_PROMPT_DIRTY ]]; then
    ZSH_THEME_GIT_PROMPT_PREFIX="%K{221}%F{234} %B%b " # 黄底黑字
  else
    ZSH_THEME_GIT_PROMPT_PREFIX="%K{35}%F{234} %B%b " # 绿底黑字
  fi

  # 最后调用 git_prompt_info() 打印整个 git info 的字符串.
  # echo $(git_prompt_info), 打印结果为 %K{xx}%F{xx} %B feature/dev ✔ %b%f%k
  echo $(git_prompt_info)  # %K{xx}%F{xx} %B feature/dev ✔ %b%f%k
}
