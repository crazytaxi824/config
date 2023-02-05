#!/bin/zsh

# 开发环境检查
# go | py | js | ts | react

function checkVSCodeExtensions() {
	# check vscode 和 extensions 是否安装, which code
	echo -e "vscode check:\e[33m \$ which code\e[0m"
	if [[ -x "$(which code)" ]]; then
		echo -e "\e[32m - vscode is installed ✔\e[0m"
	else
		echo -e "\e[31m - vscode is not installed ✗\e[0m"
		return # stop vscode extension check
	fi

	# check vscode extensions
	echo -e "vscode extensions check:\e[33m \$ code --list-extensions | grep <extension_id>\e[0m"
	local vs_extensions=$(code --list-extensions)

	# Args needs to be a list
	for ext_id in $@; do
		if [[ $(echo $vs_extensions | grep $ext_id) == $ext_id ]]; then
			echo -e "\e[32m - $ext_id ✔\e[0m"
		else
			echo -e "\e[31m - $ext_id ✗ - run: \$ code --install-extension $ext_id\e[0m"
		fi
	done
}

function checkGoEnv() {
	# check golang 是否安装, which go
	echo -e "go check:\e[33m \$ which go\e[0m"
	if [[ -x "$(which go)" ]]; then
		echo -e "\e[32m - golang is installed: $(go version | awk '{print $3, $4}')  ✔\e[0m"
	else
		echo -e "\e[31m - golang is not installed ✗\e[0m"
	fi

	# check SHELL 环境设置
	echo -e "\$GOPATH check:\e[33m \$ echo \$GOPATH\e[0m"
	if [[ $GOPATH == "" ]]; then
		echo -e "\e[31m - \$GOPATH ✗\e[0m"
	else
		echo -e "\e[32m - \$GOPATH=$GOPATH ✔\e[0m"
	fi

	# check go tools - $GOPATH/bin/xxx
	echo -e "go tools check:\e[33m [[ -x \$GOPATH/bin/<tools> ]]\e[0m"
	local go_tools_list=("gotests" "gomodifytags" "impl" "dlv" "golangci-lint" "gopls" "goimports")
	for go_tools in $go_tools_list; do
		if [[ -x $GOPATH/bin/$go_tools ]]; then
			echo -e "\e[32m - \$GOPATH/bin/$go_tools ✔\e[0m"
		else
			echo -e "\e[31m - \$GOPATH/bin/$go_tools ✗ - run: \$ go install $go_tools\e[0m"
		fi
	done

	# check vscode 和 extensions 是否安装, which code
	local extensions_needed_list=("golang.go" "humao.rest-client" "zxh404.vscode-proto3" "cweijan.vscode-database-client2")
	checkVSCodeExtensions $extensions_needed_list
}

function checkJSTSEnv() {
	# which node
	echo -e "node check:\e[33m \$ which node && which npm\e[0m"
	if [[ -x "$(which node)" && -x "$(which npm)" ]]; then
		echo -e "\e[32m - node is installed: $(node --version) ✔\e[0m"
	else
		echo -e "\e[31m - node is not installed ✗\e[0m"
	fi

	echo -e "npm global tools check\e[33m (Optional): \$ npm list -g | grep <tools>\e[0m"
	local js_tools_list=$(npm list -g)
	local js_tools_needed_list=("eslint" "jest" "typescript")
	for js_tool in $js_tools_needed_list; do
		if [[ $(echo $js_tools_list | grep $js_tool) == "" ]]; then
			echo -e "\e[31m - $js_tool ✗ - run: \$ npm install -g $js_tool\e[0m"
		else
			echo -e "\e[32m - $js_tool ✔\e[0m"
		fi
	done

	# check vscode 和 extensions 是否安装, which code
	local extensions_needed_list=("VisualStudioExptTeam.vscodeintellicode" "esbenp.prettier-vscode" "christian-kohler.path-intellisense" "dbaeumer.vscode-eslint")
	checkVSCodeExtensions $extensions_needed_list
}

function checkPythonEnv() {
	# which python3
	echo -e "python3 check:\e[33m \$ which python3 && which pip3\e[0m"
	if [[ -x "$(which python3)" && -x "$(which pip3)" ]]; then
		echo -e "\e[32m - python3 is installed: $(python3 --version) ✔\e[0m"
	else
		echo -e "\e[31m - python3 is not installed ✗\e[0m"
	fi

	# 检查 mypy, autopep8, flake8, 可根据 vscode settings 中的设置检查.
	echo -e "python3 tools check:\e[33m \$ pip3 list | grep <tools>\e[0m"
	local py_tools_list=$(pip3 list) # 获取 pip3 已经安装的包
	local py_tools_needed_list=("mypy" "flake8" "autopep8")
	for py_tool in $py_tools_needed_list; do
		# if [[ $(echo $py_tools_list | grep $py_tool) == "" ]]; then
		if [[ $(echo $py_tools_list | grep $py_tool) == "" ]]; then
			echo -e "\e[31m - $py_tool ✗ - run: \$ pip3 install $py_tool\e[0m"
		else
			echo -e "\e[32m - $py_tool ✔\e[0m"
		fi
	done

	# check vscode 和 extensions 是否安装, which code
	local extensions_needed_list=("VisualStudioExptTeam.vscodeintellicode" "ms-python.python" "ms-python.vscode-pylance")
	checkVSCodeExtensions $extensions_needed_list
}

# main function
case $1 in
"go")
	checkGoEnv
	;;

"js" | "ts" | "javascript" | "typescript")
	checkJSTSEnv
	;;

"python" | "py")
	checkPythonEnv
	;;

*)
	echo "devcheck [go | py (python) | js (javascript) | ts (typescript)]"
	;;
esac
