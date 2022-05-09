--- delve 下载地址, 以下为默认值
--- vim.g.vimspector_base_dir='~/.local/share/nvim/site/pack/packer/start/vimspector'
--- 预定义变量: https://puremourning.github.io/vimspector/configuration.html#replacements-and-variables

local port = "54321"
vim.g.vimspector_adapters = {
  -- NOTE: adapter 名字用于 configuration
  go_delve = {
    command = { "dlv", "dap", "--listen", "localhost:"..port},
    tty = true,
    host = "localhost",
    port = port,
  },
}

vim.g.vimspector_configurations = {
  -- NOTE: 名字用于 vimspector#LaunchWithSettings({"configuration": "debug_go"})
  debug_go = {
    adapter = "go_delve",  -- NOTE: vim.g.vimspector_adapters 中定义的名字
    filetype = {"go"},
    configuration = {
      request = "launch",
      program = "${fileDirname}",
      mode = "debug",
    },
  },
  debug_go_test = {
    adapter = "go_delve",
    filetype = {"go"},
    configuration = {
      request = "launch",
      program = "${file}",
      mode = "test",
    },
  },
}

--- 窗口设置
--- if  sidebar_width + code_minwidth + terminal_maxwidth < screen, terminal 在右边, 否则在下面.
--- 这里的 terminal 是指 output terminal, 不是 dap terminal.
vim.g.vimspector_terminal_maxwidth = 65  -- 默认 80
vim.g.vimspector_terminal_minwidth = 8  -- 默认 10

vim.g.vimspector_sidebar_width = 46  -- 默认 50
vim.g.vimspector_code_minwidth = 70  -- 默认 82

vim.g.vimspector_bottombar_height = 10  -- 默认 10


