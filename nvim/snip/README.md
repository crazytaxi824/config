# READEME

- snippets 的 json 文件必须不能有 comments. 否则无法解析.

- package.json 是入口文件, "L3MON4D3/LuaSnip" 先读取到这个 package 文件, 然后根据该文件中的 filetype 读取相应的 snippest
  内容. 具体参考 `~/.config/nvim/lua/user/cmp.lua` 设置.

- 默认加载 `:set runtimepath?` 中的 package.json 文件. 指定文件路径如果是相对路径必须在 runtimepath 下.

- 参考 https://github.com/rafamadriz/friendly-snippets
