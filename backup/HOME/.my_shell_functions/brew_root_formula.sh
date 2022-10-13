#!/bin/zsh

# 检查 brew 中所有不属于任何别的包依赖的包.
function checkBrewRootFormula() {
	# local common_formula_list=(bat clang-format fd ffmpeg fzf git git-delta git-flow git-flow-avh graphviz grpcurl
	# 	lazygit pandoc prettier protobuf rclone ripgrep siege stylua tmux tree universal-ctags vim viu w3m youtube-dl
	# 	yarn neovim shfmt wget)
	local common_formula_list=(
		fzf
		bat     # cat 替代工具, 语法高亮.
		fd      # find 替代工具, 查找文件名
		ripgrep # (rg) grep 替代工具, 内容查找工具

		git
		lazygit   # git cui 工具
		gitui     # git cui 工具
		git-delta # git diff 工具
		git-flow  # git-flow 插件, 也可以使用 git-flow-avh, 二选一即可
		git-flow-avh

		# editor pluglins
		vim
		neovim

		# language && tools
		node
		go
		rust
		cargo
		lua
		luajit          # lua 环境
		stylua          # lua format tool
		luarocks        # lua package manager
		universal-ctags # 各种语言的 object 分析工具. vim/neovim tagbar 插件使用
		prettier        # 格式化工具
		clang-format    # c,c++,object-c 格式化工具
		shfmt           # shell format tool

		# dev tools
		graphviz # 图表绘制工具, go 性能分析需要用到
		protobuf # protoc 命令行工具
		yarn     # 代替 npm 包管理工具

		# testing tools
		curl    # url 请求工具
		wget    # terminal 下载工具
		grpcurl # grpc 请求工具
		rclone  # ftp / sftp / webstorage ... 工具
		siege   # http request 压力测试工具

		# terminal tools
		tmux # terminal session / split screen 工具
		tree # terminal 显示 dir 结构
		viu  # terminal 显示图片工具
		w3m  # terminal 显示网页工具

		# other tools
		pandoc # 文档格式转换工具, 支持 word, pdf, markdown ... 各种格式
		ffmpeg
		yt-dlp # fork youtube-dl
	)

	# brew list --formula   # 已经安装的所有 formula, 不包括 cask.
	local formula_list=()
	formula_list+=($(brew list --formula | cat)) # 这里使用 cat 只是为了变成 list.

	# brew deps --installed   # 列出所有已安装的包和各自的依赖
	local all_deps=$(brew deps --installed)

	for formula in $formula_list; do
		# [^^] 表示不要 mactch 开头是 xxx 的行.
		# \b   boundary 表示单词的边界, 可以是空格或者\t \n ...; eg: \bfoo\b 表示单词完全匹配.
		# [[ $(echo $all_deps | grep "[^^]\b$formula\b") == '' ]] && echo "$formula"

		# 不是任何别的包依赖, 同时不在 common formula list 中
		[[ $(echo $all_deps | grep "[^^]\b$formula\b") == '' ]] &&
			([[ $(echo $common_formula_list | grep "\b$formula\b") == '' ]] &&
				echo -e "\e[1;33m$formula ???\e[0m" || echo -e "$formula")
	done
}

# 运行函数
checkBrewRootFormula
