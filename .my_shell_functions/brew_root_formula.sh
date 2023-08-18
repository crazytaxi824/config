#!/bin/zsh

# 检查 brew 中所有不属于任何别的包依赖的包.
function checkBrewRootFormula() {
	# brew list --formula   # 已经安装的所有 formula, 不包括 cask.
	local formula_list=()
	formula_list+=($(brew list --formula | cat)) # 这里使用 cat 只是为了变成 list.

	# brew deps --installed   # 列出所有已安装的包和各自的依赖
	local all_deps=$(brew deps --installed)

	for formula in $formula_list; do
		# [^^] 表示不要 mactch 开头是 xxx 的行.
		# \b   boundary 表示单词的边界, 可以是空格或者\t \n ...; eg: \bfoo\b 表示单词完全匹配.
		[[ $(echo $all_deps | grep "[^^]\b$formula\b") == '' ]] && echo "$formula" # 直接列出所有 root formula.
	done
}

# 运行函数
checkBrewRootFormula
