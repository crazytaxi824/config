# 安装环境

## 清除快捷键
- system setting - 键盘 - 键盘快捷键: 取消大多数快捷键设置, F1~FXX
- system setting - 键盘 - 输入法 - 编辑 - 双引号样式, 单引号样式修改为 "abc" 'abc'

## install brew
- install XCode CommandLine Tool, `xcode-select --install`
- install [HomeBrew](https://brew.sh), 
- ⭐️ write `eval "$(/opt/homebrew/bin/brew shellenv)"` to file `~/.zprofile`

## restore config
- Safari goto github, download `config` repo, `Code > Download Zip`
- ⭐️ `$ cp backup/HOME/* ~/`

### brew bundle
- make sure `~/.config/Brewfile` exist
- `brew update`
- `brew bundle check -v`
- `brew bundle install`
- `brew bundle cleanup`
- `brew cleanup`
- `brew dr`

### git config
- ⭐️ 设置 `~/.gitconfig` 文件中的 name, email

### ssh config
- ⭐️ 隔空传送 `~/.ssh/git_keys/` 文件夹到 `~/.ssh/` 内
- `ssh -vT git@github.com`
- `ssh -vT git@gitlab.com`

### neovim
- Mason 安装必要工具

## 安装必要软件
- [go](https://go.dev)
- chrome
- pixelmator pro
- obsidian `settings > Community Plugins` 需要手动下载
	- Advanced Table
	- [Charts](https://github.com/phibr0/obsidian-charts)
	- Dataview
	- Excalidraw
	- File Explorer Note Count
	- Mind Map

## login vscode turn on sync
- install go tools
- go install golang.org/x/tools/gopls@latest
- go install github.com/cweill/gotests/gotests@v1.6.0
- go install github.com/fatih/gomodifytags@v1.16.0
- go install github.com/josharian/impl@v1.1.0
- go install github.com/go-delve/delve/cmd/dlv@latest
- go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

## Dropbox & iCloud
- 设置 keePassXC config
- Raycast: export/import settings
- Adguard: export/import settings
- RIME 拷贝所有文件到 `~/Library/Rime` 用戶设定文件夹然后重新部署

## 其他设置
### python env
- `cd; uv venv` 在 HOME 目录创建 `~/.venv` 全局环境



