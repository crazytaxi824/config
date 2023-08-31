#!/bin/sh

# printf(fg bg text), 模板可以多次替换.
# printf "\e[38;5;%dm\e[48;5;%dm   %d   "   255 0 0 232 1 1 232 2 2 232 3 3 232 4 4 232 5 5 232 6 6 232 7 7
# \e38;5;%dm - fg color
# \e48;5;%dm - bg color
# 最后一个 %d 是需要显示的 text.

# 0 ~ 15 foreground (text) color
function fgSystem() {
	printf "normal "
	printf "\e[38;5;%dm%s" 0 " black " 1 "  red  " 2 " green " 3 "yellow " 4 " blue  " 5 "magenta" 6 "  cyan " 7 " white "
	printf "\e[0m\n"
	printf "\e[1m\e[38;5;15mbright "
	printf "\e[1m\e[38;5;%dm%s" 8 " black " 9 "  red  " 10 " green " 11 "yellow " 12 " blue  " 13 "magenta" 14 "  cyan " 15 " white "
	printf "\e[0m\n\n"
}

# 232 ~ 255 color
function fgGrayscale() {
	for (( color=232; color < 244; color++ ))
	do
		printf "\e[38;5;%dm %d " $color $color
	done
	printf "\e[0m\n"

	for (( color=244; color < 256; color++ ))
	do
		printf "\e[38;5;%dm %d " $color $color
	done
	printf "\e[0m\n\n"
}

# cube text color
function fgCube() {
	for (( line=0; line < 6; line++ ))
	do
		for (( cube=0; cube < 3; cube++ ))  # 每行 3 个 cube.
		do
			for (( cell=0; cell < 6; cell++ ))
			do
				((cell_color=line*6+16+cube*36+cell))

				if (( $cell_color < 100 )); then
					printf "\e[38;5;%dm %d " $cell_color $cell_color  # double digit
				else
					printf "\e[38;5;%dm%d " $cell_color $cell_color  # triple digit
				fi
			done
			printf "\e[0m "  # space between cubes
		done
		printf "\n"
	done
	printf "\n"

	for (( line=0; line < 6; line++ ))
	do
		for (( cube=0; cube < 3; cube++ ))  # 每行 3 个 cube.
		do
			for (( cell=0; cell < 6; cell++ ))
			do
				((cell_color=line*6+124+cube*36+cell))

				printf "\e[38;5;%dm%d " $cell_color $cell_color  # triple digit only
			done
			printf "\e[0m "  # space between cubes
		done
		printf "\n"
	done
	printf "\n"
}

function bgSystem() {
	printf "       "
	printf "%s" " black " "  red  " " green " "yellow " " blue  " "magenta" "  cyan " " white "
	printf "\e[0m\n"

	printf "       "
	printf "\e[38;5;%dm\e[48;5;%dm   %d   "   255 0 0 232 1 1 232 2 2 232 3 3 232 4 4 232 5 5 232 6 6 232 7 7
	printf "\e[0m\n"

	printf "normal "
	printf "\e[48;5;%dm       " 0 1 2 3 4 5 6 7
	printf "\e[0m\n"
	printf "       "
	printf "\e[48;5;%dm       " 0 1 2 3 4 5 6 7
	printf "\e[0m\n"

	printf "       "
	printf "\e[38;5;%dm\e[48;5;%dm   %d   " 255 8 8 232 9 9
	printf "\e[38;5;%dm\e[48;5;%dm  %d   "  232 10 10 232 11 11 232 12 12 232 13 13 232 14 14 232 15 15
	printf "\e[0m\n"

	printf "\e[1m\e[38;5;15mbright \e[0m"  # bold white
	printf "\e[48;5;%dm       " 8 9 10 11 12 13 14 15
	printf "\e[0m\n"
	printf "\e[1m\e[38;5;15m(bold) \e[0m"  # bold white
	printf "\e[48;5;%dm       " 8 9 10 11 12 13 14 15
	printf "\e[0m\n\n"
}

function bgGrayscale() {
	for (( line=0; line < 2; line++ ))
	do
		for (( color=232; color < 244; color++ ))  # from 0 to 255 step 1
		do
			if (( line == 0 )); then
				printf "\e[38;5;255m\e[48;5;%dm %d " $color $color
			else
				printf "\e[48;5;%dm     " $color
			fi
		done
		printf "\e[0m\n"
	done

	for (( line=0; line < 2; line++ ))
	do
		for (( color=244; color < 256; color++ ))  # from 0 to 255 step 1
		do
			if (( line == 0 )); then
				printf "\e[38;5;233m\e[48;5;%dm %d " $color $color
			else
				printf "\e[48;5;%dm     " $color
			fi
		done
		printf "\e[0m\n"
	done
	printf "\e[0m\n"
}

function bgCube() {
	for (( line=0; line < 12; line++ ))  # 12 行, 双数行 color code, 单数行空格.
	do
		for (( cube=0; cube < 3; cube++ ))  # 每行 3 个 cube.
		do
			for (( cell=0; cell < 6; cell++ ))
			do
				# 以下两种写法都可以
				# cell_color=$((line/2*6+16+cube*36+cell))
				((cell_color=line/2*6+16+cube*36+cell))

				if (( $line/2 < 3 )); then
					printf "\e[38;5;255m"  # foreground white
				else
					printf "\e[38;5;232m"  # foreground black
				fi

				if (( $line%2 == 0 )); then
					# upper cell - color code
					if (( $cell_color < 100 )); then
						printf "\e[48;5;%dm %d " $cell_color $cell_color  # double digit
					else
						printf "\e[48;5;%dm%d " $cell_color $cell_color  # triple digit
					fi
				else
					# lower cell - blanks
					printf "\e[48;5;%dm    " $cell_color
				fi
			done
			printf "\e[0m "  # space between cubes
		done
		printf "\n"
	done
	printf "\n"

	for (( line=0; line < 12; line++ ))  # 12 行, 双数行 color code, 单数行空格.
	do
		for (( cube=0; cube < 3; cube++ ))  # 每行 3 个 cube.
		do
			for (( cell=0; cell < 6; cell++ ))
			do
				((cell_color=line/2*6+124+cube*36+cell))

				if (( $line/2 < 3 )); then
					printf "\e[38;5;255m"  # foreground white
				else
					printf "\e[38;5;232m"  # foreground black
				fi

				if (( $line%2 == 0 )); then
					# upper cell - color code
					printf "\e[48;5;%dm%d " $cell_color $cell_color  # triple digit only
				else
					# lower cell - blanks
					printf "\e[48;5;%dm    " $cell_color
				fi
			done
			printf "\e[0m "  # space between cubes
		done
		printf "\n"
	done
	printf "\n"
}

# main function
case $1 in
	"fg")
		echo "System colors: 0~15 normal & bright colors"
		fgSystem
		echo "Grayscale ramp: 232~255"
		fgGrayscale
		echo "Color cube, 6x6x6: 16~231"
		fgCube
		;;
	"bg")
		echo "System colors: 0~15 normal & bright colors"
		bgSystem
		echo "Grayscale ramp: 232~255"
		bgGrayscale
		echo "Color cube, 6x6x6: 16~231"
		bgCube
		;;
	"all")
		echo "System colors: 0~15 normal & bright colors"
		bgSystem
		fgSystem
		echo "Grayscale ramp: 232~255"
		bgGrayscale
		fgGrayscale
		echo "Color cube, 6x6x6: 16~231"
		bgCube
		fgCube
		;;
	*)
		echo "256color [fg | bg | all]"
		;;
esac
