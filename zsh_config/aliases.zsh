### ls
alias ls='ls -G'
alias la='ls -aG'
alias ll='ls -lFG'

### du dir/files size, (N) 如果没找到，就自动消失，不传给 du.
alias lldu='du -shc ./*(N) ./.*(N)'

### lazygit
# brew info lazygit; https://github.com/jesseduffield/lazygit
alias lg='lazygit'

### yazi
alias ya='yazi'

### delta
# brew info git-delta; https://github.com/dandavison/delta
alias diff='delta --dark --line-numbers --side-by-side --syntax-theme=none --line-numbers-minus-style=196 -- '

### check brew dep
alias check_brew_dep='brew uses --recursive --installed -- '

### alias 快速设置本地 time zone
# alias setny='sudo systemsetup -settimezone America/New_York'
# alias setsy='sudo systemsetup -settimezone Australia/Sydney'

# --- [ others ] -----------------------------------------------------------------------------------
### firefox chrome ssl key 文件保存位置, 用于 wireshark 解密 https tls 数据.
# wireshark `设置 -> Protocols -> TLS -> (Pre)-Master-Secret log filename` 中
# 输入 SSLKEYLOGFILE 相同文件路径. 这样 wireshark 就能使用 ssl-key 解密 https 消息.
# NOTE: 必须完全退出 chrome/firefox 后, 再使用 terminal 打开 firefox/chrome 才会生成 sslkey.log 文件.
export SSLKEYLOGFILE=/tmp/sslkey.log  # /tmp 文件夹会被系统自动清理.
alias firefox='open -n /Applications/Firefox.app'
alias chrome='open -n /Applications/Google\ Chrome.app'



