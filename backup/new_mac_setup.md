# 新 MAC 设置

## 环境安装

### 1. install brew
- install XCode CommandLine Tool, `xcode-select --install`
- install [HomeBrew](https://brew.sh), 
- ⭐️ write `eval "$(/opt/homebrew/bin/brew shellenv)"` to file `~/.zprofile`

### 2. restore config
- Safari goto github, download `config` repo, `Code > Download Zip`
- ⭐️ `$ cp backup/HOME/* ~/`

### 3. brew bundle
- make sure `~/.config/Brewfile` exist
- `brew update`
- `brew bundle check -v`
- `brew bundle install`
- `brew bundle cleanup`
- `brew cleanup`
- `brew dr`

### 4. 环境设置
#### git config
- ⭐️ 设置 `~/.gitconfig` 文件中的 name, email

#### ssh config
- ⭐️ 隔空传送 `~/.ssh/git_keys/` 文件夹到 `~/.ssh/` 内
- `ssh -vT git@github.com`
- `ssh -vT git@gitlab.com`

#### neovim
- Mason 安装必要工具

<br/>

## 安装 APPs
- [go](https://go.dev)
- chrome
- pixelmator pro
- Adguard for Safari
- obsidian `settings > Community Plugins` 需要手动下载
	- Advanced Table
	- [Charts](https://github.com/phibr0/obsidian-charts)
	- Dataview
	- Excalidraw
	- File Explorer Note Count
	- Mind Map


### APPs 设置
- Dropbox 设置 KeePassXC `~/Library/Application Support/KeePassXC/keepassxc.ini`
- Raycast: export/import settings
- Adguard: export/import settings
- RIME:
	- 修改 `installation.yaml` 中的备份信息.
	- 拷贝所有文件到 `~/Library/Rime` 用戶设定文件夹, 然后重新部署 (Deploy)

### python env
- `cd; uv venv` 在 HOME 目录创建 `~/.venv` 全局环境

<br/>

## 系统设置

```zsh
# 特指 ~/Library/Preferences/.GlobalPreferences.plist, 系统设置, 包括: 语言, 时间, 快捷键...
defaults read -g
# 系统快捷键
defaults read ~/Library/Preferences/com.apple.symbolichotkeys.plist

# 从旧电脑导出设置
defaults export ~/Library/Preferences/com.apple.symbolichotkeys.plist ~/Desktop/com.apple.symbolichotkeys.plist
defaults export ~/Library/Preferences/.GlobalPreferences.plist ~/Desktop/.GlobalPreferences.plist

# 在新电脑上恢复设置, VVI: 在新电脑上先备份好原始 plist.
defaults import ~/Library/Preferences/com.apple.symbolichotkeys.plist ~/Desktop/com.apple.symbolichotkeys.plist
defaults import ~/Library/Preferences/.GlobalPreferences.plist ~/Desktop/.GlobalPreferences.plist

# 会注销当前用户，请保存好工作.
killall WindowServer
```

> 或者手动设置快捷键
>
> - system setting - 键盘 - 键盘快捷键: 取消大多数快捷键设置, F1~FXX
>
> - system setting - 键盘 - 输入法 - 编辑 - 双引号样式, 单引号样式修改为 "abc" 'abc'



