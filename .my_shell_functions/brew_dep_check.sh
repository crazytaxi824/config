#!/bin/bash

# 检查有哪些包 deps on 指定的 Formulae
function checkBrewDep() {
	if (($# < 1)); then
		echo "one dependency is needed"
		return 2
	fi

	if (($# > 1)); then
		echo "only one dependency is allowed"
		return 2
	fi

	# grep 不支持 \s
	brew deps --installed --1 | grep --color=always " $1[ @]"
}

# 运行函数
checkBrewDep $@
