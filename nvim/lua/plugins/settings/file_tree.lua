local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  return
end

--- VVI: for "nvim-tree.lua", `:help nvim-tree-netrw`
--- keep using |netrw| without its file browser features.
--- 将以下设置放入 init.lua 会导致 BUG: `:echo v:errmsg`, E216: No such group or event: FileExplorer *
--vim.g.loaded_netrw = 1
--vim.g.loaded_netrwPlugin = 1

local nt_api = require("nvim-tree.api")

--- file/dir icons --------------------------------------------------------------------------------- {{{
local nt_indent_line = {
  edge   = Nerd_icons.indent.edge .. " ",
  item   = Nerd_icons.indent.item .. " ",
  corner = Nerd_icons.indent.corner .. " ",
  none = "  ",
}

local glyphs = {
  git = {
    unstaged  = "M",
    staged    = "M",
    unmerged  = "U",
    renamed   = "R",
    untracked = "?",  -- ★ untracked = new file.
    deleted   = "D",
    ignored   = "◌",  --  ◌
  },
}

local diagnostics_icons = {
  hint    = Nerd_icons.diag.hint,
  info    = Nerd_icons.diag.info,
  warning = Nerd_icons.diag.warn,
  error   = Nerd_icons.diag.error,
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
  { "R",           nt_api.fs.rename_full,   "Full Rename" },  -- 类似 `$ mv foo bar`
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

require('utils.keymaps').set(tree_keymaps)

-- -- }}}

--- `:help nvim-tree-setup` ------------------------------------------------------------------------ {{{
nvim_tree.setup {
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

  auto_reload_on_write = true,  -- NOTE: `:w` 时刷新 nvim-tree.
  sync_root_with_cwd = false,  -- Changes the tree root directory on `DirChanged` and refreshes the tree.

  --- VVI: Don't change disable_netrw, hijack_netrw, hijack_directories settings. --- {{{
  --- DOCS: `:help nvim-tree-netrw`, netrw: vim's builtin file explorer.
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

  sort = {
    sorter = "name",
    folders_first = true, -- Sort folders before files.
    files_first = false,  -- Sort files before folders. If set to `true` it overrides |folders_first|.
  },

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

  renderer = {
    highlight_git = "all",  -- 开启 git filename 颜色. 需要设置 nvim-tree.git.enable = true
    highlight_bookmarks = "all",
    highlight_diagnostics = "none",
    --highlight_opened_files = "all",  -- VVI: 严重影响 :qa 退出 vim 时的性能.
                                       -- highlight icon or filename or both.
                                       -- "none"(*) | "icon" | "name" | "all"
    indent_width = 2, -- 默认 2.
    indent_markers = {
      enable = true,  -- 显示 indent line
      --icons = nt_indent_line,  -- 和自定义 indent 一样, 如果以后出现变化可以调整.
    },
    icons = {
      git_placement = "before",  -- 'before' (filename) | 'after' | 'signcolumn' (vim.signcolumn='yes')
      symlink_arrow = ' ' .. Nerd_icons.arrows.right .. ' ',  -- old_name ⟶ new_name, 这个不是显示在 filename/dir 之前的 icon.
      show = {
        file = true,  -- 显示 file icon, `nvim-web-devicons` will be used if available.
        folder = true, -- 显示 folder icon
        folder_arrow = false,  -- NOTE: 使用 folder icon 代替, folder_arrow icon 无法改变颜色, 也无法设置 empty icon.
        git = true,    -- 显示 git icon. 需要设置 git.enable = true
      },
      glyphs = glyphs,
    },
    special_files = {
      "Makefile", "MAKEFILE", "README.md", "readme.md", "Readme.md", "DOCS.md",
      ".editorconfig", ".gitignore",
      "eslint.config.mjs", "eslint.config.js", "eslint.config.cjs", "package.json", "package-lock.json",
      "pyproject.toml", "pyrightconfig.json", "ruff.toml",
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
  git = {
    enable = true,  -- VVI: 开启 git filename 和 icon 颜色显示.
                    -- 需要开启 renderer.highlight_git 和 renderer.icons.show.git
    show_on_dirs = true,  -- 在文件所属的 dir name 前也显示 sign.
    show_on_open_dirs = false,  -- 在打开的文件夹上不显示 sign.
    disable_for_dirs = {},
    timeout = 400,  -- Kills the git process after some time if it takes too long.
  },
  diagnostics = {  --- VVI: 显示 vim diagnostics (Hint|Info|Warn|Error) 需要设置 vim.signcolumn='yes'
    enable = true,
    show_on_dirs = true,  -- 在文件所属的 dir name 前也显示 sign.
    show_on_open_dirs = false,  -- 打开的文件夹上不显示 sign.
    icons = diagnostics_icons,
  },
  filters = {
    git_ignored = false,  -- 不显示 .gitignore files
    dotfiles = false,  -- true:不显示隐藏文件, false:显示隐藏文件.
    custom = { '^\\.DS_Store$', '^\\.git$', '.*\\.swp$' },  -- NOTE: 不显示指定文件
    exclude = {},  -- List of dir or files to exclude from filtering: always show them.
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
  },
  ui = {
    confirm = {
      remove = true,
      trash = true,
      default_yes = false,
    },
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
vim.api.nvim_set_hl(0, 'NvimTreeRootFolder', {ctermfg=Colors.cyan.c, fg=Colors.cyan.g})  -- non-foucs nvim-tree window color
-- vim.cmd('hi! default link NvimTreeWinSeparator VertSplit')  =- 分割线

vim.api.nvim_set_hl(0, 'NvimTreeFolderName', {ctermfg=Colors.cyan.c, fg=Colors.cyan.g, bold=true})
vim.cmd('hi! default link NvimTreeFolderIcon NvimTreeFolderName')
vim.cmd('hi! default link NvimTreeEmptyFolderName NvimTreeFolderName')
vim.cmd('hi! default link NvimTreeOpenedFolderName NvimTreeFolderName')  -- 已打开文件夹的颜色
vim.api.nvim_set_hl(0, 'NvimTreeOpenedHL', {underline=true})   -- 已经打开文件的颜色.
vim.api.nvim_set_hl(0, 'NvimTreeIndentMarker', {ctermfg=242, fg='#6c6c6c'}) -- └ │ 颜色

vim.api.nvim_set_hl(0, 'NvimTreeSymlink', {ctermfg=Colors.magenta.c, fg=Colors.magenta.g}) -- 链接文件, magenta
vim.api.nvim_set_hl(0, 'NvimTreeExecFile', {ctermfg=Colors.red.c, fg=Colors.red.g}) -- 可执行文件, red
vim.api.nvim_set_hl(0, 'NvimTreeSpecialFile', {ctermfg=Color.dark_orange, fg=Color_gui.dark_orange})  -- 自定义 Sepcial 文件, orange

--- window_picker color
vim.api.nvim_set_hl(0, 'NvimTreeWindowPicker', {
  ctermfg=Colors.black.c, fg=Colors.black.g,
  ctermbg=Colors.magenta.c, bg=Colors.magenta.g,
  bold=true,
})

--- bookmark color
vim.api.nvim_set_hl(0, 'NvimTreeBookmarkIcon', {ctermfg=Colors.magenta.c, fg=Colors.magenta.g})  -- icon color
vim.api.nvim_set_hl(0, 'NvimTreeBookmarkHL', {  -- filename color
  ctermfg=Colors.black.c, fg=Colors.black.g,
  ctermbg=Colors.magenta.c, bg=Colors.magenta.g,
})

--- nvim-tree Git color, 需要开启 highlight_git=true, render={git={enable=true}}
--- 这里设置了 git icon color
vim.api.nvim_set_hl(0, 'NvimTreeGitDirtyIcon',   {ctermfg=Colors.red.c, fg=Colors.red.g})
vim.api.nvim_set_hl(0, 'NvimTreeGitStagedIcon',  {ctermfg=Colors.green.c, fg=Colors.green.g})
vim.api.nvim_set_hl(0, 'NvimTreeGitMergeIcon',   {ctermfg=Color.purple, fg=Color_gui.purple})
vim.api.nvim_set_hl(0, 'NvimTreeGitRenamedIcon', {ctermfg=Color.purple, fg=Color_gui.purple})
vim.api.nvim_set_hl(0, 'NvimTreeGitNewIcon',     {ctermfg=Colors.red.c, fg=Colors.red.g})
vim.api.nvim_set_hl(0, 'NvimTreeGitDeletedIcon', {ctermfg=Colors.red.c, fg=Colors.red.g})
vim.api.nvim_set_hl(0, 'NvimTreeGitIgnoredIcon', {ctermfg=244, fg='#808080'})

--- git filename color, 默认是 link 上面 git icon color.
-- vim.cmd('hi! default link NvimTreeGitFileDirtyHL   NvimTreeGitStagedIcon')  -- hi! default link 在 hi clear 时回到该设置.
-- vim.cmd('hi! default link NvimTreeGitFileNewHL     NvimTreeGitStagedIcon')
--- vim.cmd('hi! default link NvimTreeGitFileStagedHL NvimTreeGitStagedIcon')
--- vim.cmd('hi! default link NvimTreeGitFileMergeHL   NvimTreeGitMergeIcon')
--- vim.cmd('hi! default link NvimTreeGitFileRenamedHL NvimTreeGitRenamedIcon')
--- vim.cmd('hi! default link NvimTreeGitFileDeletedHL NvimTreeGitDeletedIcon')
--- vim.cmd('hi! default link NvimTreeGitFileIgnoredHL NvimTreeGitIgnoredIcon')

--- diagnostic icons highlight.
--- NvimTreeLspDiagnosticsError
--- NvimTreeLspDiagnosticsWarning
--- NvimTreeLspDiagnosticsInformation
--- NvimTreeLspDiagnosticsHint

-- -- }}}

--- autocmd ---------------------------------------------------------------------------------------- {{{
--- automatically close the tab/vim when nvim-tree is the last window in the tab.
--vim.cmd [[autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif]]
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



