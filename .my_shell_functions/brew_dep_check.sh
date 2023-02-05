#!/bin/zsh

# 检查有哪些包 deps on 指定的 Formulae
function checkBrewDep() {
	if (( ${#*[@]} > 1 )); then
		echo "only one dependency is allowed"
		return 2
	fi

	brew deps --installed | grep "[^^]\b$1\b" | awk "{print \$1,\"-\",\"$1\"}"
}

# 运行函数
checkBrewDep $@
