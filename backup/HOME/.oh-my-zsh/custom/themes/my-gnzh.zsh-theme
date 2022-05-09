# Based on bira theme

setopt prompt_subst

() {

local PR_USER PR_USER_OP PR_PROMPT PR_HOST

# Check the UID
if [[ $UID -ne 0 ]]; then # normal user
  PR_USER='%F{green}%n%f' # green
  PR_USER_OP='%F{green}%#%f' # green
  PR_PROMPT='%f$%f'
else # root
  PR_USER='%F{red}%n%f'
  PR_USER_OP='%F{red}%#%f'
  PR_PROMPT='%F{red}#%f'
fi

# Check if we are on SSH or not
if [[ -n "$SSH_CLIENT"  ||  -n "$SSH2_CLIENT" ]]; then
  PR_HOST='%F{red}%M%f' # SSH
else
  PR_HOST='%F{green}%M%f' # no SSH
fi

# 命令返回的 exit code - 0 | 1 | 2
local return_code="%(?..%F{red}%? ↵%f)"

local user_host="${PR_USER}%F{cyan}@${PR_HOST}"
local current_dir="%B%F{cyan}%~%f%b"
local git_branch='$(git_prompt_info)'

# PROMPT="╭─${user_host} ${current_dir} ${git_branch}
# ╰─$PR_PROMPT "

PROMPT="${user_host} ${current_dir} ${git_branch}
$PR_PROMPT "

# 右边显示 exit code
RPROMPT="${return_code}"

# ZSH_THEME_GIT_PROMPT_PREFIX="%F{yellow}‹\uE0A0 "
# ZSH_THEME_GIT_PROMPT_SUFFIX="%F{yellow}›%f "
ZSH_THEME_GIT_PROMPT_PREFIX="%F{222}‹\uE0A0 "
ZSH_THEME_GIT_PROMPT_SUFFIX="%F{222}›%f "
ZSH_THEME_GIT_PROMPT_DIRTY=" %F{176}✗%f" # purple
ZSH_THEME_GIT_PROMPT_CLEAN=" %F{65}✔%f" # green

}
