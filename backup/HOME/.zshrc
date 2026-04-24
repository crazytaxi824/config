# UTF-8, `locale` 查看 LC_* 设置.
# VVI: MacOS 中最好不要设置 LC_ALL. It breaks on some version of MacOS.
# 设置了 LC_ALL 后, 其他 LC_* 强制等于 LC_ALL, 单独设置其他 LC_* 无效.
unset LC_ALL  # 清除 LC_ALL 设置
export LANG=en_US.UTF-8 # 设置了 LANG, 但是没有设置 LC_ALL 的情况下, 其他 LC_* 默认等于 LANG, 但可以单独设置其他 LC_*.

# VVI: 很多工具的 config 文件保存地址, eg: Ghostty, Neovim, Lazygit, Yazi ...
export XDG_CONFIG_HOME="$HOME/.config"

# NOTE: 手动安装 https://github.com/neovim/neovim/releases/
# Run: `$ xattr -c ./nvim-macos-arm64.tar.gz` (to avoid "unknown developer" warning)
# Extract: `$ tar xzvf nvim-macos-arm64.tar.gz`
# export PATH=$HOME/nvim-macos-arm64/bin:$PATH
export EDITOR=nvim  # EDITOR editor should be able to work without use of "advanced" terminal functionality.
export VISUAL=$EDITOR  # VISUAL editor could be a full screen editor as vi or emacs.

# 加载顺序重要
source "$HOME/.config/zsh_config/env.zsh"
source "$HOME/.config/zsh_config/options.zsh"
source "$HOME/.config/zsh_config/plugins.zsh"
source "$HOME/.config/zsh_config/funcs.zsh"
source "$HOME/.config/zsh_config/aliases.zsh"  # 优先级更高, 可以覆盖 funcs
source "$HOME/.config/zsh_config/keybindings.zsh"



