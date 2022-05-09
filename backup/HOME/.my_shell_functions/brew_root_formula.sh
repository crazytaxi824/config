#!/bin/zsh

# 目前常用 formula
# bat          - cat 替代工具
# clang-format - proto 格式化工具
# fd           - find 替代工具, 查找文件名
# ffmpeg
# fzf
# git
# git-delta    - git diff 工具
# git-flow     - git-flow 插件, 也可以使用 git-flow-avh, 二选一即可
# git-flow-avh
# graphviz  - 图表绘制工具, go 性能分析需要用到
# grpcurl   - grpc
# lazygit   - git cui 工具
# pandoc    - 文档格式转换工具, 支持 word, pdf, markdown ... 各种格式
# prettier  - 格式化工具
# protobuf
# rclone   - ftp / sftp / webstorage ... 工具
# ripgrep  - (rg) grep 替代工具, 内容查找工具
# siege    - http request 压力测试工具
# tmux
# tree
# universal-ctags  - 各种语言的 object 分析工具, 语法分析
# vim
# viu  - terminal 显示图片工具
# w3m  - terminal 显示网页工具
# youtube-dl

# 检查 brew 中所有不属于任何别的包依赖的包.
function checkBrewRootFormula() {
	local common_formula_list=(bat clang-format fd ffmpeg fzf git git-delta git-flow git-flow-avh graphviz grpcurl
		lazygit pandoc prettier protobuf rclone ripgrep siege stylua tmux tree universal-ctags vim viu w3m youtube-dl
		yarn neovim)

	# brew list --formula   # 已经安装的所有 formula, 不包括 cask.
	local formula_list=()
	formula_list+=( $(brew list --formula | cat) )  # 这里使用 cat 只是为了变成 list.

	# brew deps --installed   # 列出所有已安装的包和各自的依赖
	local all_deps=$(brew deps --installed)

	for formula in $formula_list
	do
		# [^^] 表示不要 mactch 开头是 xxx 的行.
		# \b   boundary 表示单词的边界, 可以是空格或者\t \n ...; eg: \bfoo\b 表示单词完全匹配.
		# [[ $(echo $all_deps | grep "[^^]\b$formula\b") == '' ]] && echo "$formula"

		# 不是任何别的包依赖, 同时不在 common formula list 中
		[[ $(echo $all_deps | grep "[^^]\b$formula\b") == '' ]] \
			&& ([[ $(echo $common_formula_list | grep "\b$formula\b") == '' ]] \
			&& echo -e "\e[1;33m$formula ???\e[0m" || echo -e "$formula")
	done
}

# 运行函数
checkBrewRootFormula
