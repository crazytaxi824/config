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

	# [^^] 表示要查询的 word 不能在行的最开始.
	brew deps --installed | grep --color=always "[^^]$1"
}

# 运行函数
checkBrewDep $@
