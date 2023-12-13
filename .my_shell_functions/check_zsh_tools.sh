#!/bin/zsh

# 检查 command tools 是否安装
function checkZshTools() {
	echo -e "\e[32mcheck homebrew installation:\e[0m"
	if [[ -x "$(which brew)" ]]; then
		echo -e "\e[32m - brew ✔\e[0m"
	else
		echo -e "\e[31m - brew ✗, https://brew.sh/\e[0m"
		echo -e "\e[33mplease install 'homebrew' first before continue.\e[0m"

		# return error code
		return 2
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

	# NOTE: 如果 brew install neovim, 会安装依赖: gettext, libtermkey, libuv, luajit, luv, msgpack, tree-sitter, unibilium
	echo -e "\e[32mcheck nvim environment:\e[0m"
	[ -x $brew_path/nvim ] && echo -e "\e[32m - nvim ✔\e[0m" || echo -e "\e[31m - nvim ✗, 'brew info nvim'\e[0m"
	[ -x $brew_path/node ] && echo -e "\e[32m - node ✔\e[0m" || echo -e "\e[31m - node ✗, 'brew info node'\e[0m"
	[ -x $brew_path/pandoc ] && echo -e "\e[32m - pandoc ✔\e[0m" || echo -e "\e[31m - pandoc ✗, 'brew info pandoc'\e[0m"
	[ -x $brew_path/prettier ] && echo -e "\e[32m - prettier ✔\e[0m" || echo -e "\e[31m - prettier ✗, 'brew info prettier'\e[0m"
}

checkZshTools
