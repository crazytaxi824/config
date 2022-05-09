#!/bin/zsh

# packages brew, npm, pip3
# brew update && brew outdated
function brewOutdated() {
	(echo -e "\e[32mrunning: brew update\e[0m") && (brew update)
	echo -e "\e[32mrunning: brew outdated\e[0m"
	local brew_output=$(brew outdated)
	if [[ $brew_output != "" ]]; then
		echo "$brew_output"
		echo -e "\e[33mbrew upgrade [<package>]\e[0m\n"
	fi
}

# npm outdated -g
function npmOutdated() {
	echo -e "\e[32mrunning: npm outdated -g"
	local npm_output=$(npm outdated -g)
	if [[ $npm_output != "" ]]; then
		echo "$npm_output"
		echo -e "\e[33mnpm upgrade -g [<package>]\e[0m  # 'upgrade' is alias of 'update'\n"
	fi
}

# pip3 list --outdated
function pipOutdated() {
	echo -e "\e[32mrunning: pip3 list --outdated\e[0m"
	local pip_output=$(pip3 list --outdated)
	if [[ $pip_output != "" ]]; then
		echo "$pip_output"
		echo -e "\e[33mpip3 install --upgrade <package>\e[0m  # 必须指定 package_name\n"
	fi
}

# cleanup brew, npm, pip3
function cleanupPackages() {
	echo -e "\e[32mrunning: brew cleanup\e[0m" && (brew cleanup) && echo -e "\e[32mrunning: npm cache verify -g\e[0m" && (npm cache verify -g) && echo -e "\e[32mrunning: pip3 cache purge\e[0m" && (pip3 cache purge)
}



# 执行函数 - 必须放在函数定义后面
# main function
case $1 in
	"outdated")
		brewOutdated
		npmOutdated
		pipOutdated
		;;

	"clean")
		cleanupPackages
		;;

	*)
		echo -e "\e[33mpackages [outdated | clean]\e[0m"
		;;
esac
