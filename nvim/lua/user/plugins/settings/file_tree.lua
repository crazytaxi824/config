local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  return
end

--- for "nvim-tree.lua", `:help nvim-tree-netrw`
--- keep using |netrw| without its file browser features.
--- 将以下设置放入 init.lua 会导致 BUG: `:echo v:errmsg`, E216: No such group or event: FileExplorer *
--vim.g.loaded_netrw = 1
--vim.g.loaded_netrwPlugin = 1

local nt_api = require("nvim-tree.api")

--- file/dir icons --------------------------------------------------------------------------------- {{{
local nt_indent_line = {
  corner = "└ ",
  edge = "│ ",
  item = "│ ",
  none = "  ",
}

local glyphs = {
  default = '',
  symlink = '',  -- 这里的 symlink 和 symlink_arrow 设置不一样, 这里是文件名前面的 icon.
  bookmark = '➜',
  folder = {
    arrow_closed = "▶︎",  -- folder_arrow
    arrow_open = "▽",    -- folder_arrow
    default = '▶︎',  -- folder
    open = '▽',     -- folder
    empty = '-',    -- folder
    empty_open = '-',  -- folder
    symlink = '▶︎',
    symlink_open = '▽',
  },
  git = {
    unstaged  = "M",  -- ✕✖︎✗✘⛌
    staged    = "M",  -- ✓✔︎
    unmerged  = "U",
    renamed   = "R",
    untracked = "?",  -- ★ untracked = new file.
    deleted   = "D",
    ignored   = "◌",
  },
}

local diagnostics_icons = {
  hint    = "⚐ ",  -- ⚐⚑
  info    = "𝖎 ",
  warning = "⚠️ ",
  error   = "⛌ ",  -- ❌✕✖︎✗✘⛌
}

-- -- }}}

--- nvim-tree keymaps ------------------------------------------------------------------------------ {{{
--- compare two marked files, using `:vert diffsplit <filename>` --------------- {{{
local function compare_two_marked_files()
  local marks_list = nt_api.marks.list()  -- 获取 mark 的 nodes
  if #marks_list ~= 2 then
    Notify("more than 2 marks available, can only campare exactly 2 files")
    return
  end

  vim.cmd('tabnew ' .. marks_list[1].absolute_path)  -- open new tab for compare
  vim.cmd('vert diffsplit ' .. marks_list[2].absolute_path) -- compare file
end
-- -- }}}

--- system open file ----------------------------------------------------------- {{{
local function system_open()
  local node = nt_api.tree.get_node_under_cursor()

  --- 根据文件属性使用对应的 application 打开. 依次使用 `open`, `open -a`, `open -R` 打开文件.
  --- NOTE: 有些 filepath 中有空格, 需要使用引号 ""
  local r1 = vim.fn.system('open "' .. node.absolute_path .. '"')
  if vim.v.shell_error == 0 then
    return
  end

  --- `open -a file` Specifies the application to use for opening the file.
  local r2 = vim.fn.system('open -a "/Applications/Visual Studio Code.app/" "' .. node.absolute_path .. '"')
  if vim.v.shell_error == 0 then
    return
  end

  --- `open -R file` Reveals the file(s) in the Finder instead of opening them.
  local r3 = vim.fn.system('open -R "' .. node.absolute_path .. '"')
  if vim.v.shell_error ~= 0 then
    Notify({vim.trim(r1), vim.trim(r2), vim.trim(r3)}, "ERROR")
  end
end
-- -- }}}

--- go back to pwd ------------------------------------------------------------- {{{
local pwd = vim.fn.getcwd()  -- cache pwd
local function back_to_pwd()
  nt_api.tree.change_root(pwd)
end
-- --}}}

--- nvim-tree buffer keymaps ---------------------------------------------------
--- only works within "NvimTree_X" buffer.
--- ":help nvim-tree-mappings-default"
local nt_buffer_keymaps = {
  { "<CR>",        nt_api.node.open.edit,   "Open" },
  { "e",           nt_api.node.open.edit,   "Open" },
  { "<C-v>",       nt_api.node.open.vertical,     "Open vsplit" },  -- vsplit edit
  { "<C-x>",       nt_api.node.open.horizontal,   "Open split" },
  { "<F8>",        nt_api.node.navigate.diagnostics.next,   "Next Diagnostic Item" },  -- next diagnostics item
  { "<F20>",       nt_api.node.navigate.diagnostics.prev,   "Prev Diagnostic Item" },  -- <S-F8> previous diagnostics item

  { "E",           nt_api.tree.collapse_all,   "Collapse All" },  -- vscode 自定义按键为 cmd+E
  { "W",           nt_api.tree.expand_all,     "Expand All" },
  { "r",           nt_api.tree.reload,         "Refresh" },
  { "H",           nt_api.tree.toggle_hidden_filter,      "Toggle Hidden Files" },  -- 隐藏文件
  { "<leader>gi",  nt_api.tree.toggle_gitignore_filter,   "Toggle Git Ignored" },   -- toggle show git ignored files
  { "<leader>gf",  nt_api.tree.toggle_git_clean_filter,   "Toggle Git Status Changed" },  -- toggle show git_status changed files ONLY
  { "<S-CR>",      nt_api.tree.change_root_to_node,   "cd" },  -- `cd` in the directory under the cursor
  { "q",           nt_api.tree.close,          "Close" },  -- close nvim-tree window
  { "?",           nt_api.tree.toggle_help,    "Help" },

  { "a",           nt_api.fs.create,   "Create File" },
  { "d",           nt_api.fs.remove,   "Remove File" },
  { "R",           nt_api.fs.rename_sub,   "Full Rename" },  -- 类似 `$ mv foo bar`
  { "y",           nt_api.fs.copy.absolute_path,   "Copy Absolute Path" },
  { "C",           nt_api.fs.copy.node,   "Copy File" },
  { "P",           nt_api.fs.paste,       "Paste File" },

  { "m",           nt_api.marks.toggle,   "Toggle Mark" },
  { "M",           nt_api.marks.clear,    "Clear All Marks" },

  --- 自定义功能
  {  "o",            back_to_pwd,                "back to Original pwd" },
  {  "<C-o>",        system_open,                "system open" },
  {  "<leader>c",    compare_two_marked_files,   "compare two marked files" },
}

--- global keymap --------------------------------------------------------------
local opts = {noremap=true, silent=true}
local tree_keymaps = {
  {'n', '<leader>;',    '<cmd>NvimTreeToggle<CR>',    opts, 'filetree: toggle'},
  {'n', '<leader><CR>', '<cmd>NvimTreeFindFile!<CR>', opts, 'filetree: jump to file'},
}

require('user.utils.keymaps').set(tree_keymaps)

-- -- }}}

--- `:help nvim-tree-setup` ------------------------------------------------------------------------ {{{
nvim_tree.setup {
  auto_reload_on_write = true,  -- NOTE: `:w` 时刷新 nvim-tree.

  --- VVI: Don't change disable_netrw, hijack_netrw, hijack_directories settings. --- {{{
  --- `:help nvim-tree-netrw`, netrw: vim's builtin file explorer.
  --disable_netrw = false,  -- completely disable netrw. VVI: 不要设为 true, 否则 netrw 的所有功能都无法使用.

  --- NOTE: 是否显示 netrw file-explorer 内容. `:e dir` 时, 默认会显示 netrw file-explorer 内容.
  ---   true  - `:e dir` 时, 当前 window 中不显示 netrw file-explorer 内容;
  ---   false - `:e dir` 时, 当前 window 中显示 netrw file-explorer 内容.
  --- 配合 hijack_directories 使用.
  --hijack_netrw = true,

  --- NOTE: hijacks new directory buffers when they are opened.
  --- 如果 `hijack_netrw` & `disable_netrw` 都是 false, 则 `hijack_directories` 的设置无效.
  ---   true  - `:e dir` 时, 在 nvim_tree 窗口打开 dir;
  ---   false - `:e dir` 时, 当前 window 中显示空文件.
  --hijack_directories = {
  --  --- NOTE: 和 auto close the tab/vim when nvim-tree is the last window 一起使用时, 会导致 nvim 退出.
  --  enable = true,
  --  --- hijack_directories 时自动打开 nvim-tree open().
  --  auto_open = true,
  --},
  -- -- }}}

  hijack_cursor = false,  -- keeps the cursor on the first letter of the filename
  hijack_unnamed_buffer_when_opening = false,  -- Opens in place of the unnamed buffer if it's empty. 默认 false.

  --- 启动 nvim 时, 打开 tree.
  open_on_tab = false,  -- 在 tree 打开的状态下 open new tab, 则在新 tab 中自动打开 tree.
  ignore_buf_on_tab_change = {},  -- List of filetypes or buffer names that will prevent `open_on_tab` to open.

  sort = {
    sorter = "name",
    folders_first = true,
  },
  sync_root_with_cwd = false,  -- Changes the tree root directory on `DirChanged` and refreshes the tree.

  view = {
    --- float = {  -- 在 floating window 中打开 nvim-tree ---------------------- {{{
    ---   enable = true,
    ---   open_win_config = {
    ---     relative = "editor",
    ---     border = "rounded",
    ---     width = 30,
    ---     height = 30,
    ---     row = 1,
    ---     col = 1,
    ---   },
    --- },
    -- -- }}}
    side = "left", -- left / right
    width = 36,    -- OR "25%"
    preserve_window_proportions = false,
    number = false,          -- 显示 line number
    relativenumber = false,  -- 显示 relative number
    signcolumn = "yes",      -- VVI: 显示 signcolumn, "yes" | "auto" | "no"
  },

  --- NOTE: on_attach 主要是设置 keymaps 的.
  --- ":help nvim-tree.on_attach" & ":help nvim-tree-mappings"
  on_attach = function(bufnr)
    local function opt(desc)
      if not desc then
        return {  buffer = bufnr, noremap = true, silent = true, nowait = true }
      end
      return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    for _, keymap in ipairs(nt_buffer_keymaps) do
      vim.keymap.set('n', keymap[1], keymap[2], opt(keymap[3]))
    end
  end,

  renderer = {
    highlight_git = true,  -- 开启 git filename 颜色. 需要设置 git.enable = true
    highlight_opened_files = "name", -- highlight icon or filename or both.
                                     -- "none"(*) | "icon" | "name" | "all"
    indent_width = 2, -- 默认 2.
    indent_markers = {
      enable = true,
      icons = nt_indent_line,
    },
    icons = {
      webdev_colors = false,  -- 使用 `nvim-web-devicons`, otherwise `NvimTreeFileIcon`.
      git_placement = "before",  -- 'before' (filename) | 'after' | 'signcolumn' (vim.signcolumn='yes')
      symlink_arrow = " ➜ ",  -- old_name ➜ new_name, 这个不是显示在 filename/dir 之前的 icon.
      show = {
        folder = true, -- 显示 folder icon
        folder_arrow = false,  -- NOTE: 使用 folder icon 代替, folder_arrow icon 无法改变颜色,
                               -- 也无法设置 empty icon.
        file = false,  -- 显示 file icon, `nvim-web-devicons` will be used if available.
        git = true,    -- 显示 git icon. 需要设置 git.enable = true
      },
      glyphs = glyphs,
    },
    special_files = {
      "Makefile", "MAKEFILE", "README.md", "readme.md", "Readme.md",
      ".editorconfig", ".gitignore",
    },
    symlink_destination = true,  -- Whether to show the destination of the symlink.
  },
  update_focused_file = {
    --- 可以使用 `:NvimTreeFindFile!`
    enable = false,  -- `:e file` 时, 更新 tree, 展开文件夹直到找到该文件.
    update_root = false,  -- VVI: Update the root directory of the tree if
                          -- the file is not under current root directory.
    ignore_list = {},
  },
  -- system_open = {
  --   cmd = "",  -- Mac 中可以改为 "open", NOTE: 无法处理错误, 推荐使用 action_cb.
  --   args = {},
  -- },
  diagnostics = {  --- VVI: 显示 vim diagnostics (Hint|Info|Warn|Error) 需要设置 vim.signcolumn='yes'
    enable = true,
    show_on_dirs = true,  -- 在文件所属的 dir name 前也显示 sign.
    show_on_open_dirs = false,  -- 打开的文件夹上不显示 sign.
    icons = diagnostics_icons,
  },
  filters = {
    dotfiles = false,  -- true:不显示隐藏文件, false:显示隐藏文件.
    custom = { '^\\.DS_Store$', '^\\.git$', '.*\\.swp$' },    -- 不显示指定文件
    exclude = {},  -- List of dir or files to exclude from filtering: always show them.
    git_ignored = false,  -- 不显示 .gitignore files
  },
  git = {
    enable = true,  -- VVI: 开启 git filename 和 icon 颜色显示.
                    -- 需要开启 renderer.highlight_git 和 renderer.icons.show.git
    show_on_dirs = true,  -- 在文件所属的 dir name 前也显示 sign.
    show_on_open_dirs = false,  -- 在打开的文件夹上不显示 sign.
    disable_for_dirs = {},
    timeout = 400,  -- Kills the git process after some time if it takes too long.
  },
  actions = {
    use_system_clipboard = true,
    change_dir = {
      enable = true,   -- change root dir
      global = false,
    },
    expand_all = {
      max_folder_discovery = 60,  -- VVI: 最多递归打开 n 个 folder, 到达该数字后停止 expand.
      exclude = { "node_modules", ".mypy_cache", ".git" },  -- NOTE: 排除 expand dir
    },
    open_file = {
      quit_on_open = false,  -- VVI: 打开文件后自动关闭 Nvimtree
      resize_window = true,  -- VVI: 重新渲染 nvimtree 窗口大小.

      --- 有多个 win 的情况下, 在 nvim-tree 中打开文件时需要选择 window.
      window_picker = {
        enable = true,  -- false: 总在 vsplit 窗口中打开新文件.
        chars = "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ",  -- 多选窗口的标识.
        exclude = {   -- 以下类型的窗口不能用于 nvim-tree 打开文件.
          filetype = {
            "qf", "help", "diff", "notify", "packer", "NvimTree",
            "tagbar", "fugitive", "fugitiveblame",
          },
          buftype = { "nofile", "quickfix", "help", "terminal", "prompt" },
        },
      },
    },
  },
  trash = {
    cmd = "trash",  -- Mac 没有 trash cmd
    require_confirm = true,
  },

  --- 日志 ---
  log = {
    enable = false,
    truncate = false,
    types = {
      all = false,
      config = false,
      copy_paste = false,
      diagnostics = false,
      git = false,
      profile = false,
    },
  },
} -- END_DEFAULT_OPTS

-- -- }}}

--- `:help nvim-tree-highlight` -------------------------------------------------------------------- {{{
vim.api.nvim_set_hl(0, 'NvimTreeNormalNC', {link="NormalNC"})  -- non-foucs nvim-tree window color
vim.api.nvim_set_hl(0, 'NvimTreeRootFolder', {ctermfg=Color.cyan})  -- non-foucs nvim-tree window color

vim.api.nvim_set_hl(0, 'NvimTreeFolderName', {ctermfg=Color.cyan, bold=true})
vim.cmd('hi! default link NvimTreeFolderIcon NvimTreeFolderName')
vim.cmd('hi! default link NvimTreeEmptyFolderName NvimTreeFolderName')
vim.cmd('hi! default link NvimTreeOpenedFolderName NvimTreeFolderName')  -- 已打开文件夹的颜色
vim.api.nvim_set_hl(0, 'NvimTreeOpenedFile', {ctermbg=240})   -- 已经打开文件的颜色, 只设置 bg.
vim.api.nvim_set_hl(0, 'NvimTreeIndentMarker', {ctermfg=242}) -- └ │ 颜色

vim.api.nvim_set_hl(0, 'NvimTreeSymlink', {ctermfg=Color.magenta}) -- 链接文件, magenta
vim.api.nvim_set_hl(0, 'NvimTreeExecFile', {ctermfg=Color.red}) -- 可执行文件, red
vim.api.nvim_set_hl(0, 'NvimTreeSpecialFile', {ctermfg=179})  -- 自定义 Sepcial 文件, orange

--- window_picker color
vim.api.nvim_set_hl(0, 'NvimTreeWindowPicker',
  {ctermfg=Color.black, ctermbg=Color.magenta, bold=true})

--- nvim-tree Git color, 需要开启 highlight_git=true, render={git={enable=true}}
--- 这里设置了 git icon color
vim.api.nvim_set_hl(0, 'NvimTreeGitDirty',   {ctermfg=Color.red})
vim.api.nvim_set_hl(0, 'NvimTreeGitStaged',  {ctermfg=Color.green})
vim.api.nvim_set_hl(0, 'NvimTreeGitMerge',   {ctermfg=Color.purple})
vim.api.nvim_set_hl(0, 'NvimTreeGitRenamed', {ctermfg=Color.purple})
vim.api.nvim_set_hl(0, 'NvimTreeGitNew',     {ctermfg=Color.red})
vim.api.nvim_set_hl(0, 'NvimTreeGitDeleted', {ctermfg=Color.red})
vim.api.nvim_set_hl(0, 'NvimTreeGitIgnored', {ctermfg=244})

--- git filename color, 默认是 link 上面 git icon color.
vim.cmd('hi! default link NvimTreeFileDirty  NvimTreeGitStaged')  -- hi! default link 在 hi clear 时回到该设置.
vim.cmd('hi! default link NvimTreeFileNew    NvimTreeGitStaged')
--- vim.cmd('hi! default link NvimTreeFileStaged NvimTreeGitStaged')
--- vim.cmd('hi! default link NvimTreeFileMerge   NvimTreeGitMerge')
--- vim.cmd('hi! default link NvimTreeFileRenamed NvimTreeGitRenamed')
--- vim.cmd('hi! default link NvimTreeFileDeleted NvimTreeGitDeleted')
--- vim.cmd('hi! default link NvimTreeFileIgnored NvimTreeGitIgnored')

--- diagnostic icons highlight.
--- NvimTreeLspDiagnosticsError         -- 默认 DiagnosticError
--- NvimTreeLspDiagnosticsWarning       -- 默认 DiagnosticWarn
--- NvimTreeLspDiagnosticsInformation   -- 默认 DiagnosticInfo
--- NvimTreeLspDiagnosticsHint          -- 默认 DiagnosticHint

-- -- }}}

--- autocmd ---------------------------------------------------------------------------------------- {{{
--- automatically close the tab/vim when nvim-tree is the last window in the tab.
--vim.cmd [[autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif]]
-- -- }}}

--- HACK: keymaps toggle git icons and filename highlights ----------------------------------------- {{{
--- 通过改变内部 "nvim-tree.renderer.components.git" 的 git_icons 来显示/隐藏图标.
local cache_git_icons  -- cache git icons table

--- 清除 git icons && file highlights ------------------------------------------ {{{
local function git_file_icons_and_highlight_remove()
  local git_component_ok, git_comp = pcall(require, "nvim-tree.renderer.components.git")
  if not git_component_ok then
    Notify('"nvim-tree.renderer.components.git" load error.', "WARN")
    return
  end

  --- 如果已经存入 git_icons 则不再赋值, git_icons 值不会变.
  if not cache_git_icons then
    cache_git_icons = git_comp.git_icons  -- cache git_icons
  end
  git_comp.git_icons = {}  -- clear icons

  --- VVI: 清除 file git status 颜色, 将颜色设置为 {group} xxx clear, 忽略 default 设置.
  vim.api.nvim_set_hl(0, 'NvimTreeFileDirty',   {link = 'NONE'})
  vim.api.nvim_set_hl(0, 'NvimTreeFileStaged',  {link = 'NONE'})
  vim.api.nvim_set_hl(0, 'NvimTreeFileMerge',   {link = 'NONE'})
  vim.api.nvim_set_hl(0, 'NvimTreeFileRenamed', {link = 'NONE'})
  vim.api.nvim_set_hl(0, 'NvimTreeFileNew',     {link = 'NONE'})
  vim.api.nvim_set_hl(0, 'NvimTreeFileDeleted', {link = 'NONE'})
  vim.api.nvim_set_hl(0, 'NvimTreeFileIgnored', {link = 'NONE'})

  --- 启用 special_file & exe_file & symlink_file color ------------------------ {{{
  -- vim.cmd('hi NvimTreeSymlink ctermfg=207')      -- 链接文件, magenta
  -- vim.cmd('hi NvimTreeExecFile ctermfg=167')     -- 可执行文件, red
  -- vim.cmd('hi NvimTreeSpecialFile ctermfg=179')  -- 自定义 Sepcial 文件, orange
  -- -- }}}

  nt_api.tree.reload()  -- refresh tree
end
-- -- }}}

--- 重置 git icons && file highlights ------------------------------------------ {{{
local function git_file_icons_and_highlight_enable()
  local git_component_ok, git_comp = pcall(require, "nvim-tree.renderer.components.git")
  if not git_component_ok then
    Notify('"nvim-tree.renderer.components.git" load error.', "WARN")
    return
  end

  --- 避免第一次使用时 cache_git_icons = nil
  git_comp.git_icons = cache_git_icons or git_comp.git_icons -- restore icons

  --- 启用 file git status 颜色, 使用 hi clear 让 group 恢复 default 设置.
  vim.cmd('hi clear NvimTreeFileDirty')
  vim.cmd('hi clear NvimTreeFileStaged')
  vim.cmd('hi clear NvimTreeFileMerge')
  vim.cmd('hi clear NvimTreeFileRenamed')
  vim.cmd('hi clear NvimTreeFileNew')
  vim.cmd('hi clear NvimTreeFileDeleted')
  vim.cmd('hi clear NvimTreeFileIgnored')

  --- 清除 special_file & exe_file & symlink_file color ------------------------ {{{
  --- vim.cmd('hi! link NvimTreeSymlink Normal')
  --- vim.cmd('hi! link NvimTreeExecFile Normal')
  --- vim.cmd('hi! link NvimTreeSpecialFile Normal')
  -- -- }}}

  nt_api.tree.reload()  -- refresh tree
end
-- -- }}}

--- 显示 nvim-tree icons and highlights & gitsigns signs
local function git_show_highlights()
  git_file_icons_and_highlight_enable()

  local git_signs_ok, git_signs = pcall(require, 'gitsigns')
  if git_signs_ok then
    git_signs.toggle_signs(true)   -- true: show highlights
  end
end

--- 隐藏 nvim-tree icons and highlights & gitsigns signs
local function git_hide_highlights()
  git_file_icons_and_highlight_remove()

  local git_signs_ok, git_signs = pcall(require, 'gitsigns')
  if git_signs_ok then
    git_signs.toggle_signs(false)  -- false: hide highlights
  end
end

--- 设置 keymaps ---------------------------------------------------------------
local opt = { noremap = true, silent = true}
local gitsigns_keymaps = {
  {'n', '<leader>gs', function() git_show_highlights() end, opt, "git: Show highlights"},
  {'n', '<leader>gh', function() git_hide_highlights() end, opt, "git: Hide highlights"},
}

require('user.utils.keymaps').set(gitsigns_keymaps, {
  key_desc = {
    g = {name = "Git"},
  },
  opts = {mode='n', prefix='<leader>'}
})

-- -- }}}

--- Event Hooks, `:help nvim-tree-events` ---------------------------------------------------------- {{{
--- FolderCreated 在创建 folder 和 file 时都会触发.
--- FileCreated 只在创建 file 时会触发.
--- local Event = nt_api.events.Event
--- nt_api.events.subscribe(Event.FolderCreated, function(data)
---   vim.print('folder add:', data)
--- end)
---
--- nt_api.events.subscribe(Event.FolderRemoved, function(data)
---   vim.print('folder remove:', data)
--- end)
---
--- nt_api.events.subscribe(Event.FileCreated, function(data)
---   vim.print('file add:', data)
--- end)
---
--- nt_api.events.subscribe(Event.FileRemoved, function(data)
---   vim.print('file remove:', data)
--- end)
-- -- }}}



