#!/bin/zsh

function checkBrewDep() {
	if (( ${#*[@]} > 1 )); then
		echo "only one dependency is allowed"
		return 2
	fi

	brew deps --installed | grep "[^^]\b$1\b" | awk "{print \$1,\"-\",\"$1\"}"
}

# 运行函数
checkBrewDep $@
