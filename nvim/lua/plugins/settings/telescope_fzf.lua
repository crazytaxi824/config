local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
  return
end

--- custom actions --------------------------------------------------------------------------------- {{{
--- 多选的情况下 send_selected_to_qflist; 没有任何选择的情况下 edit 光标所在行的 file.
local actions = require("telescope.actions")  -- 自定义 key mapping 用
local actions_layout = require("telescope.actions.layout")  -- 自定义 key mapping 用
local actions_state = require("telescope.actions.state")
local transform_mod = require('telescope.actions.mt').transform_mod

local my_action = transform_mod({
  edit_or_qf = function(prompt_bufnr)
    --- 参考 https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/actions/init.lua
    --- 中 send_selected_to_qf 函数设置.
    local picker = actions_state.get_current_picker(prompt_bufnr)
    local selected_items = picker:get_multi_selection()
    -- vim.print(selected_items, #selected_items)

    if #selected_items == 0 then
      actions.select_default(prompt_bufnr)
    else
      actions.send_selected_to_qflist(prompt_bufnr)
      vim.cmd('copen')
    end
  end,
})

-- -- }}}

--- `:help telescope.setup()`
telescope.setup {
  defaults = {
    --- VVI: 这里必须使用占 2 格的 icon, 否则渲染会出 bug.
    prompt_prefix = "> ",
    selection_caret = Nerd_icons.arrows.right .. ' ',
    multi_icon = Nerd_icons.tick,
    path_display = { "absolute" },  -- table|func, `:help telescope.defaults.path_display`
    --wrap_results = true,  -- result window `set wrap`
    --results_title = false,  -- result window 不显示 title.

    --- `:help telescope.defaults.layout_config`
    layout_config = {
      horizontal = {
        height = 0.9,  -- 占整个 vim 窗口的百分比
        width = 0.92,  -- 占整个 vim 窗口的百分比
        preview_cutoff = 1,  -- When lines are less than this value, the preview will be disabled.
        prompt_position = "top",  -- 搜索框位置, 默认是在 bottom.
        preview_width = 0.6,  -- 占 telescope 窗口的百分比
      },
      vertical = {
        height = 0.9,
        width = 0.92,
        preview_cutoff = 1,
        prompt_position = "top",
        preview_height = 0.5,
      }
    },
    layout_strategy = "horizontal",  -- horizontal(*) - preview 在右边 | vertical - preview 在上面
    cycle_layout_list = {"vertical", "horizontal"},  -- NOTE: 影响 actions_layout.cycle_layout_next() 显示顺序.
    sorting_strategy = "ascending",  -- ascending | descending(*) - descending 在 prompt_position = "bottom" 时候用.

    --- rg defaults, `:help telescope.defaults.vimgrep_arguments`
    vimgrep_arguments = {
      "rg",
      "--color=never",    -- VVI: 必须为 never
      "--sort=path",      -- ascending sort
      "--follow",         -- descend into symlinked directories.
      "--vimgrep",        -- --no-heading,--with-filename,--line-number,--column
      "--only-matching",  -- only print matched text, 也可以使用 "--trim" 打印整行内容.
      "--smart-case",     -- 如果有大写则 case sensitive, 如果全小写则 ignore case.
    },

    --- `:help telescope.defaults.mappings`         - 默认 key mapping 也能使用
    --- `:help telescope.defaults.default_mappings` - 只使用自定义 key mapping
    --- `:help telescope.actions`  -- 查看可用 actions
    --- https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/mappings.lua
    --- https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/actions/init.lua
    mappings = {  -------------------------------------------------------------- {{{
      i = {
        ["<CR>"] = my_action.edit_or_qf,
        ["<C-e>"] = my_action.edit_or_qf,
        ["<C-x>"] = actions.select_horizontal,  -- open file in split horizontal
        ["<C-v>"] = actions.select_vertical,    -- open file in split vertical
        --["<C-t>"] = actions.select_tab,  -- open file in new tab

        --["<C-c>"] = actions.close,
        ["<C-n>"] = actions.cycle_history_next,  -- next 已输入过的搜索内容
        ["<C-p>"] = actions.cycle_history_prev,  -- prev 已输入过的搜索内容

        ["<Down>"] = actions.move_selection_next,
        ["<Up>"] = actions.move_selection_previous,

        ["<C-u>"] = false,  -- NOTE: 为了在 insert 模式下使用 <C-u> 清空 input, 不能使用 nil.
        ["<C-d>"] = false,
        ["<PageUp>"] = actions.preview_scrolling_up,
        ["<PageDown>"] = actions.preview_scrolling_down,
        ["<S-Up>"] = actions.results_scrolling_up,
        ["<S-Down>"] = actions.results_scrolling_down,

        --- move_selection_next 和 move_selection_worse 的区别:
        --- next 移动到下一个结果; worse 移动到搜索排序的下一个结果.
        --- worse 会根据 sorting_strategy = "ascending" / "descending" 改变方向, 而 next 不会.
        ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
        ["<S-Tab>"] = actions_layout.cycle_layout_next,  -- layout window
        --["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
        --["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
        --["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,

        --- NOTE: put all <tab> selected files to quickfix list.
        ["<C-l>"] = actions.send_selected_to_qflist + actions.open_qflist,
        --["<C-l>"] = actions.complete_tag,
        --["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
        --["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

        ["<C-_>"] = actions.which_key, -- key help, <C-/> not working
      },

      n = {
        --["<ESC>"] = actions.close,

        ["<CR>"] = my_action.edit_or_qf,
        ["<C-e>"] = my_action.edit_or_qf,
        ["<C-x>"] = actions.select_horizontal,  -- open file in split horizontal
        ["<C-v>"] = actions.select_vertical,    -- open file in split vertical
        --["<C-t>"] = actions.select_tab,  -- open file in new tab

        ["<Down>"] = actions.move_selection_next,
        ["<Up>"] = actions.move_selection_previous,
        ["gg"] = actions.move_to_top,
        ["G"] = actions.move_to_bottom,
        --["M"] = actions.move_to_middle,

        ["<C-u>"] = false,  -- NOTE: 为了配合上面 i 的设置.
        ["<C-d>"] = false,
        ["<PageUp>"] = actions.preview_scrolling_up,
        ["<PageDown>"] = actions.preview_scrolling_down,
        --- actions.preview_scrolling_left(), actions.preview_scrolling_right()
        ["<S-Up>"] = actions.results_scrolling_up,
        ["<S-Down>"] = actions.results_scrolling_down,
        --- actions.results_scrolling_left(), actions.results_scrolling_right()

        ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
        ["<S-Tab>"] = actions_layout.cycle_layout_next,  -- layout window

        --- NOTE: put all <tab> selected files to quickfix list.
        ["<C-l>"] = actions.send_selected_to_qflist + actions.open_qflist,
        --["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
        --["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

        ["?"] = actions.which_key, -- key help
      },
    },
    -- -- }}}
  },
  --- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#remove--from-fd-results
  pickers = {
    --- `:help telescope.builtin`, 这里可以修改默认 picker 的属性
    find_files = {
      --- fd 使用说明 ---------------------------------------------------------- {{{
      -- NOTE: 这里没有使用 --type=f/d/l/..., 这里是参照 ~/.zshrc 中的 FZF_DEFAULT_COMMAND
      -- -E=.git                  不显示名为 .git 的文件(夹)
      -- -E=**/.*/**              显示隐藏文件夹, 但不列出其中的文件.
      -- -E=**/node_modules/**    显示 node_modules 文件夹, 但不列出其中的文件.
      -- -- }}}
      --theme = "dropdown",
      find_command = {
        "fd",
        "--follow",  -- descend into symlinked directories.
        "--type=file", "--type=symlink",  -- 不显示 directory | executable.
        -- NOTE: 这里不搜索隐藏文件, 也不显示被 .gitignore 忽略的文件
        -- "--hidden", "--no-ignore", "-E=.DS_Store", "-E=.git", "-E=**/.*/**",
        "-E=**/node_modules/**", "-E=*.swp", "-E=**/vendor/**",
        "-E=**/dist/**", "-E=**/out/**", "-E=**/coverage/**"
      },
    },
  },
  extensions = {
    --- https://github.com/nvim-telescope/telescope-fzf-native.nvim#telescope-setup-and-configuration
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    },
  },
}

--- VVI: load extension after setup()
telescope.load_extension('fzf')

--- keymap: toggle `set wrap` for filetype = TelescopePrompt only.
--- 打开 telescope 时, 设置快捷键用于显示超出 preview window 的内容 --------------------------------
--- `:set wrap` for preview window --------------------------------------------- {{{
vim.api.nvim_create_autocmd("User", {
  pattern = "TelescopePreviewerLoaded",
  callback = function(params)
    --- NOTE: preview window 不会改变, 但是 preview bufnr 会改变,
    --- 在 cursor 指向不同 result item 的时候, preview bufnr 会改变.
    local preview_winid = vim.api.nvim_get_current_win()

    --- find prompt_bufnr
    local prompt_bufnr
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[bufnr].filetype == 'TelescopePrompt' then
        prompt_bufnr = bufnr
      end
    end

    --- NOTE: 快捷键设置在 prompt bufnr 中, 因为其他 telescope window 通常不会 enter.
    vim.keymap.set({'n', 'i'}, '<C-k>', function()
      --- toggle `set wrap`
      vim.api.nvim_set_option_value('wrap', not vim.wo[preview_winid].wrap, {scope='local', win=preview_winid})
    end,
    {
      buffer=prompt_bufnr,
      silent = true,
      desc = 'telescope: toggle preview wrap',
    })
  end,
  desc = "set keymap of `:set wrap` for telescope preview window",
})
-- -- }}}

--- highlights -------------------------------------------------------------------------------------
vim.api.nvim_set_hl(0, "TelescopeMatching", {reverse = true})

--- VVI: 自定义 picker -----------------------------------------------------------------------------
--- Rg command ----------------------------------------------------------------- {{{
--- 基于 telescope.builtin.grep_string() 修改
--- https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/builtin/__files.lua
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local conf = require("telescope.config").values

local function my_rg_picker(additional_args)
  --- args 是一个 cmd list, eg: {'rg', '-w', '-s', 'filepath'}
  local args = vim.iter({conf.vimgrep_arguments, additional_args}):flatten():totable()

  --- VVI: gen_from_vimgrep() 是 preview file 的必要设置.
  --- opts 其他参数可以查看 `:help grep_string()`
  local opts = { entry_maker = make_entry.gen_from_vimgrep() }
  pickers.new(opts, {
    prompt_title = ":Rg",
    finder = finders.new_oneshot_job(args, opts),
    previewer = conf.grep_previewer(opts),
    sorter = conf.generic_sorter(opts),  -- VVI: 设置 sorter 后可以通过 fzf 输入框对 results 进行过滤.
  }):find()
end

--- Rg command 使用方法 -------------------------------------------------------- {{{
--- 例子: 如果要使用正则表达式, 则需要使用 '' OR "" OR \(escape), 否则报错 zsh: no matches found.
---   Rg foo\ bar == Rg 'foo bar' == Rg "foo bar" == Rg foo\ bar ./         # 在当前文件夹搜索
---   Rg 'foo.*bar' == Rg "foo.*bar" == Rg foo.\*bar == Rg 'foo.*bar' ./    # 同上
---
--- 搜索指定文件(夹)
---   Rg 'foo bar'  ./src/main.go    # 在 main.go 文件中搜索 'foo bar'
---   Rg 'foo bar'  ./src            # 在 src 文件夹下搜索 'foo bar'
---   Rg 'foo.*bar' ./src ./tmp      # 在 ./src 和 ./tmp 两个文件夹下搜索 'foo.*bar'
---
--- 搜索条件: -w -i -s ...
---   Rg -w 'foo'   # 匹配整个单词, 而不是部分匹配. 类似 '\bWord\b'
---   Rg -i 'foo'   # ignore case
---   Rg -s 'foo'   # case sensitive
---   Rg -S 'foo'   # --smart-case, 如果全小写则 ignore case, 如果有大写字母则 case sensitive.
---
---   Rg -wi 'foo' ./
---   Rg -ws 'foo' ./src
---   Rg -wS 'foo' ./src /tmp
-- -- }}}
vim.api.nvim_create_user_command("Rg",
  function(params)
    my_rg_picker(params.fargs)
  end,
{nargs="+"})
-- -- }}}

--- find pickers --------------------------------------------------------------- {{{
--- 找出所有的 pickers: builtin & extension
--- https://github.com/keyvchan/telescope-find-pickers.nvim/blob/main/lua/telescope/_extensions/find_pickers/main.lua
local builtin_pickers = require("telescope.builtin")
local extensions_pickers = require("telescope._extensions")
local themes = require("telescope.themes")

local function my_find_pickers()
  local opts = themes.get_dropdown()

  local opts_pickers = {
    bufnr = vim.api.nvim_get_current_buf(),
    winnr = vim.api.nvim_get_current_win(),
  }

  local result_table = {}
  for key, _ in pairs(builtin_pickers) do
    table.insert(result_table, key)
  end
  for key, _ in pairs(extensions_pickers.manager) do
    table.insert(result_table, key)
  end

  pickers.new(opts, {
    prompt_title = "Find Pickers",
    finder = finders.new_table({
      results = result_table,
    }),
    attach_mappings = function(prompt_bufnr, map)
      --- 修改 select_default 的默认方法
      actions.select_default:replace(function()
        --- 获取选中的 item
        local selection = actions_state.get_selected_entry()
        local value = selection.value

        --- 关闭现有 telescope
        actions.close(prompt_bufnr)

        --- 执行新的 picker
        if builtin_pickers[value] ~= nil then
          builtin_pickers[value](opts_pickers)
        elseif extensions_pickers.manager[value] ~= nil then
          extensions_pickers.manager[value][value](opts_pickers)
        end
      end)
      return true
    end,
    sorter = conf.generic_sorter(opts),  -- VVI: 设置 sorter 后可以通过 fzf 输入框对 results 进行过滤.
  }):find()
end
-- -- }}}

--- keymaps ----------------------------------------------------------------------------------------
local builtin = require("telescope.builtin")
local opt = { silent = true }
local telescope_keymaps = {
  --- Picker functions, https://github.com/nvim-telescope/telescope.nvim#pickers
  --- 使用 `:Telescope` 列出所有 Picker
  {'n', '<leader>ff', function() my_find_pickers() end, opt, 'telescope: find pickers'},
  {'n', '<leader>fd', function() builtin.find_files() end, opt, 'telescope: fd'},
  {'n', '<leader>fh', function() builtin.help_tags() end,  opt, 'telescope: Vim Help Doc'},
  {'n', '<leader>fk', function() builtin.keymaps() end,    opt, 'telescope: Keymap normal Mode'},
  {'n', '<leader>fc', function() builtin.commands() end,   opt, 'telescope: All Commands'},
  {'n', '<leader>f:', function() builtin.command_history() end, opt, 'telescope: History Command'},
  {'n', '<leader>f/', function() builtin.search_history() end,  opt, 'telescope: History Search'},
  {'n', '<leader>f?', function() builtin.search_history() end,  opt, 'telescope: History Search'},
  {'n', '<leader>fl', function() builtin.highlights() end,  opt, 'telescope: Search Highlight'},
  {'n', 'z=', function() builtin.spell_suggest() end, opt, 'telescope: Spell Suggests'},  -- 也可以使用 which-key 显示.
  --{'n', '<leader>fg', function() builtin.live_grep() end,  opt, 'telescope: rg'},  -- NOTE: 使用自定义 :Rg 命令更灵活.
}

require('utils.keymaps').set(telescope_keymaps, {
  key_desc = {f = {name = "Telescope Find"}},
  opts = {mode='n', prefix='<leader>'}
})



