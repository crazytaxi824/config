local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  return
end

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
  bookmark = '★',
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
    unstaged  = "M",  -- ✗✘
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
  error   = "✘ ",  -- ❌✕✖︎✗✘
}

-- -- }}}

--- nvim-tree buffer keymaps ----------------------------------------------------------------------- {{{
--- git: Discard file changes --- {{{
local function git_discard_file_changes(node)
  --print(node.name, node.absolute_path, vim.inspect(node.git_status), node.type)

  --- READMD: node.name: filename, not prefix path --- {{{
  --- node.absolute_path
  --- node.type = 'file' | 'directory'
  ---
  --- DOC: git file dirty.
  --- https://git-scm.com/docs/git-status#_short_format
  --- https://github.com/kyazdani42/nvim-tree.lua/blob/master/lua/nvim-tree/renderer/components/git.lua
  ---
  --- git command:
  ---   - git reset: staged -> unstaged
  ---   - git checkout: delete unstaged changes
  ---
  --- node.git_status:
  --- modify: ' M': unstaged
  ---               discard all: git checkout -- 'file'
  --          'M ': staged
  ---               discard all: git reset -- 'file' && git checkout -- 'file'
  --          'MM': some parts staged, some parts unstaged
  ---               discard unstaged: git checkout -- 'file',
  ---               discard all: git reset -- 'file' && git checkout -- 'file'
  --- new/add:
  ---         '??', ' A': unstracked new file
  ---               discard all: rm 'file'
  ---         'A ': staged new file
  ---               discard all: git rest -- 'file' && rm 'file'
  ---         'AA': unknown
  ---         'AU': unknown
  ---         'AM': staged new file + unstaged part
  ---               discard unstaged: git checkout -- 'file'
  ---               discard all: git rest -- 'file' && rm 'file'
  --- NOTE: Rename: 是在 staged new file & staged deleted file 后才会被认为是 Rename file.
  ---       Delete file && Rename file 必须在下次进入 nvim 时才能看到.
  -- -- }}}

  if node.type ~= 'file' then
    Notify("Cannot Discard on ".. node.type, "INFO")
    return
  end

  local cmd

  if node.git_status == "MM" then
    --- prompt
    local prompt = "git: Discard file changes " .. node.name .. " ? a[ll]/u[nstaged]/n: "
    vim.ui.input({ prompt = prompt }, function(choice)
      vim.cmd("normal! :")  -- clear command line prompt message.
      if choice == 'a' or choice == 'all' then
        cmd = 'git reset -- "' .. node.absolute_path .. 
          '" && git checkout -- "' .. node.absolute_path .. '"'
      elseif choice == 'u' or choice == 'unstaged' then
        cmd = 'git checkout -- "' .. node.absolute_path .. '"'
      end
    end)
  elseif node.git_status == "M " then
    local prompt = "git: Discard file changes " .. node.name .. " ? a[ll]/n: "
    vim.ui.input({ prompt = prompt }, function(choice)
      vim.cmd("normal! :")  -- clear command line prompt message.
      if choice == 'a' or choice == 'all' then
        cmd = 'git reset -- "' .. node.absolute_path ..
          '" && git checkout -- "' .. node.absolute_path .. '"'
      end
    end)
  elseif node.git_status == " M" then
    local prompt = "git: Discard file changes " .. node.name .. " ? a[ll]/n: "
    vim.ui.input({ prompt = prompt }, function(choice)
      vim.cmd("normal! :")  -- clear command line prompt message.
      if choice == 'a' or choice == 'all' then
        cmd = 'git checkout -- "' .. node.absolute_path .. '"'
      end
    end)
  elseif node.git_status == "AM" then
    local prompt = "git: Discard file changes " .. node.name .. " ? a[ll]/u[nstaged]/n: "
    vim.ui.input({ prompt = prompt }, function(choice)
      vim.cmd("normal! :")  -- clear command line prompt message.
      if choice == 'a' or choice == 'all' then
        cmd = 'git reset -- "' .. node.absolute_path ..
          '" && rm "' .. node.absolute_path .. '"'
      elseif choice == 'u' or choice == 'unstaged' then
        cmd = 'git checkout -- "' .. node.absolute_path .. '"'
      end
    end)
  elseif node.git_status == "??" or node.git_status == " A" then
    local prompt = "git: Discard file changes " .. node.name .. " ? a[ll]/n: "
    vim.ui.input({ prompt = prompt }, function(choice)
      vim.cmd("normal! :")  -- clear command line prompt message.
      if choice == 'a' or choice == 'all' then
        cmd = 'rm "' .. node.absolute_path .. '"'
      end
    end)
  elseif node.git_status == "A " then
    local prompt = "git: Discard file changes " .. node.name .. " ? a[ll]/n: "
    vim.ui.input({ prompt = prompt }, function(choice)
      vim.cmd("normal! :")  -- clear command line prompt message.
      if choice == 'a' or choice == 'all' then
        cmd = 'git reset -- "' .. node.absolute_path ..
          '" && rm "' .. node.absolute_path .. '"'
      end
    end)
  else
    Notify({
      "git: Cannot Discard Changes on current file",
      "please use other tools to do complex git operations",
    }, "INFO")
    return
  end

  if cmd then
    local result = vim.fn.system(cmd)
    if vim.v.shell_error ~= 0 then
      vim.notify(result, vim.log.levels.ERROR)
    end
    vim.cmd('checktime')
  end
end
-- -- }}}

--- compare two marked files, using `:vert diffsplit <filename>` --- {{{
local function compare_two_marked_files(node)
  local marks_list = nt_api.marks.list()  -- 获取 mark 的 nodes
  if #marks_list ~= 2 then
    Notify("more than 2 marks available, can only campare exactly 2 files")
    return
  end

  vim.cmd('tabnew ' .. marks_list[1].absolute_path)  -- open new tab for compare
  vim.cmd('vert diffsplit ' .. marks_list[2].absolute_path) -- compare file
end
-- -- }}}

--- system open file --- {{{
local function system_open(node)
  --- 根据文件属性使用对应的 application 打开.
  --- NOTE: 有些 filepath 中有空格, 需要使用引号 ""
  vim.fn.system('open "' .. node.absolute_path .. '"')
  if vim.v.shell_error == 0 then
    return
  end

  --- `open -a file` Specifies the application to use for opening the file.
  vim.fn.system('open -a "/Applications/Visual Studio Code.app/" "' .. node.absolute_path .. '"')
  if vim.v.shell_error == 0 then
    return
  end

  --- `open -R file` Reveals the file(s) in the Finder instead of opening them.
  local r = vim.fn.system('open -R "' .. node.absolute_path .. '"')
  if vim.v.shell_error ~= 0 then
    Notify(r, "ERROR")
  end
end
-- -- }}}

local nt_buffer_keymaps = {
  { key = {"<CR>", "e"},   action = "edit" },
  { key = "<C-v>",         action = "vsplit" },  -- vsplit edit
  { key = "<C-x>",         action = "split" },
  { key = "a",             action = "create" },
  { key = {"d", "D"},      action = "remove" },
  { key = "R",             action = "rename" },  -- 类似 `$ mv foo bar`
  { key = "r",             action = "refresh" },
  { key = "y",             action = "copy_absolute_path" },
  { key = "E",             action = "collapse_all" },  -- vscode 自定义按键为 cmd+E
  { key = "W",             action = "expand_all" },
  { key = "I",             action = "toggle_git_ignored" },
  { key = "H",             action = "toggle_dotfiles" },  -- 隐藏文件
  { key = "m",             action = "toggle_mark" }, -- paste file
  { key = "q",             action = "close" },  -- close nvim-tree window
  { key = "?",             action = "toggle_help" },
  { key = "<F8>",          action = "next_diag_item" },  -- next diagnostics item
  { key = "<F20>",         action = "prev_diag_item" },  -- <S-F8> previous diagnostics item
  { key = "<S-CR>",        action = "cd" },  -- `cd` in the directory under the cursor
  { key = "<C-CR>",        action = "cd" },  -- `cd` in the directory under the cursor
  { key = "C",             action = "copy" },  -- copy file
  { key = "P",             action = "paste" }, -- paste file

  --- 自定义功能. NOTE: action 内容成为 help 中展示的文字.
  --- action_cb 意思是 callback 函数.
  { key = "<C-o>",         action = "system open", action_cb = system_open},
  { key = "<leader>c",     action = "compare two marked files", action_cb = compare_two_marked_files},
  { key = "<leader>D",     action = "git: Discard file changes", action_cb = git_discard_file_changes},
}

--- global keymap ---
vim.keymap.set('n', '<leader>,', '<cmd>NvimTreeFindFileToggle<CR>', {
  noremap=true, silent=true, desc='toggle Nvim-Tree'
})

-- -- }}}

--- `:help nvim-tree-setup` ------------------------------------------------------------------------ {{{
nvim_tree.setup {
  auto_reload_on_write = true,  -- VVI: `:w` 时刷新 nvim-tree.

  disable_netrw = false,   -- completely disable netrw. NOTE: netrw: vim's builtin file explorer.
  hijack_netrw = true,     -- hijack netrw windows (overriden if |disable_netrw| is `true`)
  hijack_cursor = false,   -- keeps the cursor on the first letter of the filename
  hijack_directories = {   -- hijacks new directory buffers when they are opened (`:e dir`)
    enable = true,  -- NOTE: 和下面的 auto close the tab/vim when nvim-tree is the last window 一起使用时,
                    -- 会导致 nvim 退出.
    auto_open = true,
  },
  hijack_unnamed_buffer_when_opening = false,  -- Opens in place of the unnamed buffer if it's empty.

  --- 启动 nvim 时, 打开 tree.
  open_on_setup = false,  -- 不好用. 启动 nvim 打开文件时, 自动打开 tree. eg: `nvim dir`
  open_on_setup_file = false,  -- 启动 nvim 打开文件, 且文件存在的情况下, 自动打开 tree. eg: `nvim file`
  open_on_tab = false,  -- 在 tree 打开的状态下 open new tab, 则在新 tab 中自动打开 tree.
  ignore_buffer_on_setup = false,  -- Will ignore the buffer, when deciding to open the tree on setup.
  ignore_ft_on_setup = {},  -- List of filetypes that will prevent `open_on_setup` to open.
  ignore_buf_on_tab_change = {},  -- List of filetypes or buffer names that will prevent `open_on_tab` to open.

  sort_by = "name",
  sync_root_with_cwd = false,  -- Changes the tree root directory on `DirChanged` and refreshes the tree.

  view = {
    -- float = {  -- 在 floating window 中打开 nvim-tree.  --- {{{
    --   enable = true,
    --   open_win_config = {
    --     relative = "editor",
    --     border = "rounded",
    --     width = 30,
    --     height = 30,
    --     row = 1,
    --     col = 1,
    --   },
    -- },
    -- -- }}}
    side = "left",
    width = 36,
    --height = 10,  -- side = "top" 时有效
    preserve_window_proportions = false,
    number = false,          -- 显示 line number
    relativenumber = false,  -- 显示 relative number
    signcolumn = "yes",      -- VVI: 显示 signcolumn, "yes" | "auto" | "no"
    --- ":help nvim-tree-default-mappings"
    mappings = {
      custom_only = true,  -- NOTE: 只使用 custom key mapping
      list = nt_buffer_keymaps,   -- user mappings go here
    },
  },

  renderer = {
    highlight_git = true,  -- 开启 git filename 颜色. 需要设置 git.enable = true
    highlight_opened_files = "all",  -- highlight icon or filename or both.
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
    enable = false,  -- `:e file` 时, 更新 tree, 展开文件夹直到找到该文件.
    update_root = false,  -- VVI: Update the root directory of the tree if
                          -- the file is not under current root directory.
    ignore_list = {},
  },
  system_open = {
    cmd = "",  -- Mac 中可以改为 "open", NOTE: 无法处理错误, 推荐使用 action_cb.
    args = {},
  },
  diagnostics = {  --- VVI: 显示 vim diagnostics (Hint|Info|Warn|Error) 需要设置 vim.signcolumn='yes'
    enable = true,
    show_on_dirs = true,  -- 在文件所属的 dir name 前也显示 sign.
    icons = diagnostics_icons,
  },
  filters = {
    dotfiles = false,  -- true:不显示隐藏文件, false:显示隐藏文件.
    custom = { '^\\.DS_Store$', '^\\.git$', '.*\\.swp$' },    -- 不显示指定文件
    exclude = {},
  },
  git = {
    enable = true,  -- VVI: 开启 git filename 和 icon 颜色显示.
                    -- 需要开启 renderer.highlight_git 和 renderer.icons.show.git
    ignore = false,  -- 不显示 .gitignore files
    show_on_dirs = true,  -- 在文件所属的 dir name 前也显示 sign.
    timeout = 400,
  },
  actions = {
    use_system_clipboard = true,
    change_dir = {
      enable = true,   -- change root dir
      global = false,
    },
    expand_all = {
      max_folder_discovery = 300,
      exclude = {"node_modules"},  -- NOTE: 排除 expand dir
    },
    open_file = {
      quit_on_open = false,  -- VVI: 打开文件后自动关闭 Nvimtree
      resize_window = true,  -- VVI: 重新渲染 nvimtree 窗口大小.
      window_picker = {
        enable = true,       -- false: 总在 vsplit 窗口中打开新文件.
        exclude = {          -- 以下类型的窗口不能用于 nvim-tree 打开文件.
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

  -- 日志 --
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
vim.cmd('hi NvimTreeFolderName ctermfg=81 cterm=bold')
vim.cmd('hi! default link NvimTreeFolderIcon NvimTreeFolderName')
vim.cmd('hi! default link NvimTreeEmptyFolderName NvimTreeFolderName')
vim.cmd('hi! default link NvimTreeOpenedFolderName NvimTreeFolderName')  -- 已打开文件夹的颜色
vim.cmd('hi NvimTreeOpenedFile ctermbg=238')   -- 已经打开文件的颜色, 只设置 bg.
vim.cmd('hi NvimTreeIndentMarker ctermfg=242') -- └ │ 颜色

vim.cmd('hi NvimTreeSymlink ctermfg=207')      -- 链接文件, magenta
vim.cmd('hi NvimTreeExecFile ctermfg=167')     -- 可执行文件, red
vim.cmd('hi NvimTreeSpecialFile ctermfg=179')  -- 自定义 Sepcial 文件, orange

--- nvim-tree Git color, 需要开启 highlight_git=true, render={git={enable=true}}
--- 这里设置了 git icon color
vim.cmd('hi NvimTreeGitDirty   ctermfg=167')
vim.cmd('hi NvimTreeGitStaged  ctermfg=42')
vim.cmd('hi NvimTreeGitMerge   ctermfg=170')
vim.cmd('hi NvimTreeGitRenamed ctermfg=170')
vim.cmd('hi NvimTreeGitNew     ctermfg=167')
vim.cmd('hi NvimTreeGitDeleted ctermfg=167')
vim.cmd('hi NvimTreeGitIgnored ctermfg=242')

--- git filename color, 默认是 link 上面 git icon color.
vim.cmd('hi! default link NvimTreeFileDirty  NvimTreeGitStaged')  -- hi! default link 在 hi clear 时回到该设置.
vim.cmd('hi! default link NvimTreeFileNew    NvimTreeGitStaged')
-- vim.cmd('hi! default link NvimTreeFileStaged NvimTreeGitStaged')
-- vim.cmd('hi! default link NvimTreeFileMerge   NvimTreeGitMerge')
-- vim.cmd('hi! default link NvimTreeFileRenamed NvimTreeGitRenamed')
-- vim.cmd('hi! default link NvimTreeFileDeleted NvimTreeGitDeleted')
-- vim.cmd('hi! default link NvimTreeFileIgnored NvimTreeGitIgnored')

--- diagnostic icons highlight.
-- NvimTreeLspDiagnosticsError         -- 默认 DiagnosticError
-- NvimTreeLspDiagnosticsWarning       -- 默认 DiagnosticWarn
-- NvimTreeLspDiagnosticsInformation   -- 默认 DiagnosticInfo
-- NvimTreeLspDiagnosticsHint          -- 默认 DiagnosticHint

-- -- }}}

--- autocmd ---------------------------------------------------------------------------------------- {{{
--- automatically close the tab/vim when nvim-tree is the last window in the tab
vim.cmd [[autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif]]

--- refresh nvim-tree when enter/delete a buffer.
--- BufEnter  用在打开 unloaded buffer 时.
--- BufDelete 用在 close 非当前 buffer 时.
vim.api.nvim_create_autocmd({"BufEnter", "BufDelete"}, {
  pattern = {"*"},
  callback = function(params)
    --- VVI: 必须使用 vim.schedule(), 否则 bdelete 的时候不会刷新显示.
    --- 因为 bnext | bdelete #, 先 Enter 其他 buffer, 这时之前的 buffer 还没有被 delete, 所以 reload()
    --- 的时候 buffer highlight 还在.
    vim.schedule(function ()
      nt_api.tree.reload()
    end)
  end
})
-- -- }}}

--- HACK: keymaps toggle git icons and filename highlights ----------------------------------------- {{{
--- 通过改变内部 "nvim-tree.renderer.components.git" 的 git_icons 来显示/隐藏图标.
local cache_git_icons  -- cache git icons table

--- 清除 git icons && file highlights ------------------------------------------ {{{
local function git_file_icons_and_highlight_clear()
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
  vim.cmd('hi! link NvimTreeFileDirty   NONE')
  vim.cmd('hi! link NvimTreeFileStaged  NONE')
  vim.cmd('hi! link NvimTreeFileMerge   NONE')
  vim.cmd('hi! link NvimTreeFileRenamed NONE')
  vim.cmd('hi! link NvimTreeFileNew     NONE')
  vim.cmd('hi! link NvimTreeFileDeleted NONE')
  vim.cmd('hi! link NvimTreeFileIgnored NONE')

  --- 启用 special_file & exe_file & symlink_file color --- {{{
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

  --- 清除 special_file & exe_file & symlink_file color --- {{{
  -- vim.cmd('hi! link NvimTreeSymlink Normal')
  -- vim.cmd('hi! link NvimTreeExecFile Normal')
  -- vim.cmd('hi! link NvimTreeSpecialFile Normal')
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
  git_file_icons_and_highlight_clear()

  local git_signs_ok, git_signs = pcall(require, 'gitsigns')
  if git_signs_ok then
    git_signs.toggle_signs(false)  -- false: hide highlights
  end
end

--- 设置 keymaps ---------------------------------------------------------------
local opt = { noremap = true, silent = true}
local gitsigns_keymaps = {
  {'n', '<leader>gs', git_show_highlights, opt, "git: Show highlights"},
  {'n', '<leader>gh', git_hide_highlights, opt, "git: Hide highlights"},
}

Keymap_set_and_register(gitsigns_keymaps, {
  key_desc = {
    g = {name = "Git"},
  },
  opts = {mode='n', prefix='<leader>'}
})

-- -- }}}



