### 清除快捷键
- system setting - 键盘 - 键盘快捷键: 取消大多数快捷键设置, F1~FXX
- system setting - 键盘 - 输入法 - 编辑 - 双引号样式, 单引号样式修改为 "abc" 'abc'

### install brew
- install XCode CommandLine Tool, `xcode-select --install`
- install [HomeBrew](https://brew.sh), then write `eval "$(/opt/homebrew/bin/brew shellenv)"` to file `~/.zprofile`

### restore config
- Safari goto github, download `config` repo, `Code > Download Zip`
- ⭐️`cp backup/HOME/.zshrc ~/.zshrc`, 内容需要有 `export HOMEBREW_BUNDLE_FILE=~/.config/Brewfile`
- Restore other backup files

#### brew bundle
- `brew update`
- `brew bundle check -v`
- `brew bundle install`
- `brew bundle cleanup`
- `brew cleanup`
- `brew dr`

### git config
- `cp backup/HOME/.git* ~/` 拷贝所有 `.git*` 文件到 `~/` 内
- `cp backup/HOME/gitconfig_needs_setup ~/.gitconfig` 修改 `name` & `email` 设置, 或隔空传送 `~/.gitconfig`

### ssh config
- `cp -r backup/HOME/.ssh ~/`
- ⭐️隔空传送 `~/.ssh/git_keys/` 文件夹到 `~/.ssh/` 内
- `ssh -vT git@github.com`
- `ssh -vT git@gitlab.com`

### install oh-my-zsh, 会生成一个新的 ~/.zshrc 文件.
- [ohmyzsh](https://github.com/ohmyzsh/ohmyzsh)

#### install omz plugins `zsh-autosuggestions` & `zsh-syntax-highlighting`
- `cd ~/.oh-my-zsh/custom/plugins`
- `git clone https://github.com/zsh-users/zsh-autosuggestions`
- `git clone https://github.com/zsh-users/zsh-syntax-highlighting.git`

#### copy backup custom theme
- `cp ~/.config/backup/HOME/.oh-my-zsh/custom/themes/my-final.zsh-them ~/.oh-my-zsh/custom/themes/`
- make sure `ZSH_THEME="my-final"` in `~/.zshrc`

### install neovim
- Mason 安装必要工具

### 安装必要软件
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

### login vscode turn on sync
- install go tools
- go install golang.org/x/tools/gopls@latest
- go install github.com/cweill/gotests/gotests@v1.6.0
- go install github.com/fatih/gomodifytags@v1.16.0
- go install github.com/josharian/impl@v1.1.0
- go install github.com/go-delve/delve/cmd/dlv@latest
- go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

### Dropbox & iCloud
- 设置 keePassXC config
- Raycast: export/import settings
- Adguard: export/import settings
- RIME 拷贝所有文件到 `~/Library/Rime` 用戶设定文件夹然后重新部署

### lazygit config
- `backup/HOME/Library/Application Support/lazygit/config` 设置



