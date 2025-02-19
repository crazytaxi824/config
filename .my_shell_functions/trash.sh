#!/bin/zsh

# Use system Trash to move file to .Trash bin, which can be put back.
function trash() {
	local main_exit_code=0
	local filepath_list=()

	for filepath in "$@"; do
		# VVI: 这里不能用 local ap=$(realpath $filepath), 因为 local 命令会导致 $? 永远等于 0.
		# 这个文件是使用 zsh trash.sh 来执行, 所以 absolute_fp 不会变成全局变量.
		absolute_fp=$(realpath $filepath)
		local exit_code=$?
		if [[ $exit_code -ne 0 ]]; then
			echo -n $absolute_fp
			main_exit_code=$exit_code
		else
			filepath_list+=("$absolute_fp")
		fi
	done

	# exit code != 0
	if [[ $main_exit_code -ne 0 ]]; then
		exit $main_exit_code
	fi

	# Use AppleScript to delete multi files.
	for delete_fp in "${filepath_list[@]}"; do
		local applescript="tell app \"Finder\" to delete POSIX file \"$delete_fp\""
		osascript -e $applescript
	done
}

# 自定义 trash 函数, 主要使用 mv 命令.
# function trash() {
# 	local trash_dir=~/.Trash/
# 	# NOTE: linux DO NOT have "~/.Trash/" dir
# 	if [[ ! -d $trash_dir ]]; then
# 		echo -e "\e[31m$trash_dir is NOT exist.\e[0m"
# 		return
# 	fi
#
# 	# get time_now unix timestamp (second)
# 	local now_unix=$(date +%s)
#
# 	local filepath # 防止 for 循环中的变量变成 global variable.
# 	for filepath in "$@"; do
# 		# filepath_tail only, without path. could be filename.ext OR dir name.
# 		local filepath_tail=$(basename $filepath)
#
# 		# check file/dir existence in '~/.Trash/', if file/dir exists then using unix timestamp.
# 		if [[ -f "$trash_dir$filepath_tail" ]]; then
# 			# 如果是移动文件, 且文件名在 ~/.Trash/ 中存在.
# 			local fname="${filepath_tail%.*}"            # fname only, without ext
# 			local ext="${filepath_tail##*.}"             # ext only
# 			mv $filepath $trash_dir$fname-$now_unix.$ext # mv filepath ~/.Trash/fname-timestamp.ext
# 		elif [[ -d "$trash_dir$filepath_tail" ]]; then
# 			# 如果是移动文件夹, 且文件夹名在 ~/.Trash/ 中存在.
# 			mv $filepath $trash_dir$filepath_tail-$now_unix # mv filepath ~/.Trash/dir-timestamp
# 		else
# 			# 如果文件/文件夹名在 ~/.Trash/ 中不存在, 则直接移动.
# 			mv $filepath $trash_dir # mv filepath ~/.Trash/
# 		fi
# 	done
# }

trash $@
