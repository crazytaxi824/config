#!/bin/zsh

# packages brew, npm, pip
# brew update && brew outdated
function brewOutdated() {
	local update="brew update"
	(echo -e "\e[32mrunning: $update\e[0m") && (eval $update)

	local outdated="brew outdated"
	echo -e "\e[32mrunning: $outdated\e[0m"
	local brew_output=$(eval $outdated)
	if [[ $brew_output != "" ]]; then
		echo "$brew_output"
		echo -e "\e[33mbrew upgrade [<package>]\e[0m\n"
	fi
}

# npm outdated -g
function npmOutdated() {
	local outdated="npm outdated --location=global"
	echo -e "\e[32mrunning: $outdated\e[0m"
	local npm_output=$(eval $outdated)
	if [[ $npm_output != "" ]]; then
		echo "$npm_output"
		echo -e "\e[33mnpm upgrade --location=global [<package>]\e[0m  # 'upgrade' is alias of 'update'\n"
	fi
}

# python3 -m pip list --outdated
function pipOutdated() {
	local outdated="python3 -m pip list --outdated"
	echo -e "\e[32mrunning: $outdated\e[0m"
	local pip_output=$(eval $outdated)
	if [[ $pip_output != "" ]]; then
		echo "$pip_output"
		echo -e "\e[33mpython3 -m pip install --upgrade <package>\e[0m  # 必须指定 package_name\n"
	fi
}

# cleanup brew, npm, pip
function cleanupPackages() {
	local brew_clean="brew cleanup"
	local npm_clean="npm cache verify -g"
	local pip_clean="python3 -m pip cache purge"

	echo -e "\e[32mrunning: $brew_clean\e[0m" && (eval $brew_clean) &&
		echo -e "\e[32mrunning: $npm_clean\e[0m" && (eval $npm_clean) &&
		echo -e "\e[32mrunning: $pip_clean\e[0m" && (eval $pip_clean)
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
