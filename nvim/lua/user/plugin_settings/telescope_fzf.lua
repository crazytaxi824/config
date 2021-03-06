local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
  return
end

local actions = require "telescope.actions"  -- actions 用来自定义 key mapping

telescope.setup {
  defaults = {
    --- VVI: 这里必须使用占 2 格的 icon, 否则渲染会出 bug.
    prompt_prefix = "> ",
    selection_caret = " ➜",
    path_display = { "absolute" },  -- `:help telescope.defaults.path_display`

    --- rg defaults, `:help telescope.defaults.vimgrep_arguments`
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--vimgrep",        -- --no-heading,--with-filename,--line-number,--column
      "--only-matching",  -- only print matched text, 也可以使用 "--trim" 打印整行内容.
      "--smart-case",     -- 如果有大写则 case sensitive, 如果全小写则 ignore case.
    },

    --- `:help telescope.defaults.layout_config`
    --layout_strategy = "vertical",  -- horizontal(*) - preview 在右边 | vertical - preview 在上面
    layout_config = {
      height = 0.9,
      width = 0.92,
      prompt_position = "top",
    },
    sorting_strategy = "ascending",  -- ascending | descending(*) - 默认在 prompt_position = "bottom" 时候用.

    --- `:help telescope.defaults.mappings`         - 默认 key mapping 也能使用
    --- `:help telescope.defaults.default_mappings` - 只使用自定义 key mapping
    mappings = {
      i = {
        --["<C-c>"] = actions.close,
        ["<C-n>"] = actions.cycle_history_next,  -- next 已输入过的搜索内容
        ["<C-p>"] = actions.cycle_history_prev,  -- prev 已输入过的搜索内容

        ["<Down>"] = actions.move_selection_next,
        ["<Up>"] = actions.move_selection_previous,

        ["<CR>"] = actions.select_default,
        ["<C-x>"] = actions.select_horizontal,
        ["<C-v>"] = actions.select_vertical,
        --["<C-t>"] = actions.select_tab,

        ["<C-u>"] = false,  -- NOTE: 为了在 insert 模式下使用 <C-u> 清空 input.
        ["<C-d>"] = false,
        ["<PageUp>"] = actions.preview_scrolling_up,
        ["<PageDown>"] = actions.preview_scrolling_down,
        ["<S-Up>"] = actions.results_scrolling_up,
        ["<S-Down>"] = actions.results_scrolling_down,

        ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
        ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
        --["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
        --["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,

        --["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
        --["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
        --["<C-l>"] = actions.complete_tag,

        ["<C-_>"] = actions.which_key, -- key help, <C-/> not working
      },

      n = {
        ["<esc>"] = actions.close,
        ["<CR>"] = actions.select_default,
        ["<C-x>"] = actions.select_horizontal,
        ["<C-v>"] = actions.select_vertical,
        -- ["<C-t>"] = actions.select_tab,

        ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
        ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
        --["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
        --["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
        --["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
        --["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

        ["<Down>"] = actions.move_selection_next,
        ["<Up>"] = actions.move_selection_previous,
        ["gg"] = actions.move_to_top,
        ["G"] = actions.move_to_bottom,
        --["M"] = actions.move_to_middle,

        ["<C-u>"] = false,  -- NOTE: 为了配合上面 i 的设置.
        ["<C-d>"] = false,
        ["<PageUp>"] = actions.preview_scrolling_up,
        ["<PageDown>"] = actions.preview_scrolling_down,
        ["<S-Up>"] = actions.results_scrolling_up,
        ["<S-Down>"] = actions.results_scrolling_down,

        ["?"] = actions.which_key, -- key help
      },
    },
  },
  --- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#remove--from-fd-results
  pickers = {
    --- `:help telescope.builtin`, 这里可以修改默认 picker 的属性
    find_files = {
      --- fd 使用说明 --- {{{
      -- NOTE: 这里没有使用 --type=f/d/l/..., 这里是参照 ~/.zshrc 中的 FZF_DEFAULT_COMMAND
      -- -E=.git                  不显示名为 .git 的文件(夹)
      -- -E=**/.*/**              显示隐藏文件夹, 但不列出其中的文件.
      -- -E=**/node_modules/**    显示 node_modules 文件夹, 但不列出其中的文件.
      -- -- }}}
      find_command = {"fd", "--follow",
        -- NOTE: 这里不搜索隐藏文件, 也不显示被 .gitignore 忽略的文件
        -- "--hidden", "--no-ignore", "-E=.DS_Store", "-E=.git", "-E=**/.*/**",
        "-E=**/node_modules/**", "-E=*.swp", "-E=**/vendor/**",
        "-E=**/dist/**", "-E=**/out/**", "-E=**/coverage/**"
      },
    },
  },
  extensions = {
    -- Your extension configuration goes here:
    -- extension_name = {
    --   extension_config_key = value,
    -- }
    -- please take a look at the readme of the extension you want to configure
  },
}


--- keymaps ----------------------------------------------------------------------------------------
local builtin = require("telescope.builtin")
local opt = { noremap = true, silent = true }
local telescope_keymaps = {
  --- Picker functions, https://github.com/nvim-telescope/telescope.nvim#pickers
  --- 使用 `:Telescope` 列出所有 Picker
  {'n', '<leader>ff', builtin.find_files, opt, 'Telescope - fd'},
  {'n', '<leader>fb', builtin.buffers,    opt, 'Telescope - Buffer List'},
  {'n', '<leader>fh', builtin.help_tags,  opt, 'Telescope - Vim Help Doc'},
  {'n', '<leader>fk', builtin.keymaps,    opt, 'Telescope - Keymap normal Mode'},
  {'n', '<leader>fc', builtin.command_history, opt, 'Telescope - Command History'},
  {'n', '<leader>fs', builtin.search_history,  opt, 'Telescope - Search History'},
  {'n', '<leader>fl', builtin.highlights,  opt, 'Telescope - Search Highlight'},
  {'n', 'z=', builtin.spell_suggest, opt, 'Telescope - Spell Suggests'},  -- 也可以使用 which-key 显示.
  --{'n', '<leader>fg', builtin.live_grep,  opt, 'Telescope - rg'},  -- NOTE: 使用自定义 :Rg 命令更灵活.
}

Keymap_set_and_register(telescope_keymaps, {
  key_desc = {f = {name = "Telescope Find"}},
  opts = {mode='n', prefix='<leader>'}
})

--- 自定义 Rg command ------------------------------------------------------------------------------
--- NOTE: 修改自 telescope.builtin.grep_string() 定义在:
---       https://github.com/nvim-telescope/telescope.nvim -> lua/telescope/builtin/files.lua
---       files.grep_string = function(opts), opts 参数为 `:help grep_string()`, cwd, search ...
--- make_entry 的内置函数定义在:
---       https://github.com/nvim-telescope/telescope.nvim -> lua/telescope/make_entry.lua
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local pickers = require "telescope.pickers"
local conf = require("telescope.config").values

local function rg_search(additional_args)
  local result = vim.fn.system(vim.fn.join(conf.vimgrep_arguments, " ") .. " " .. additional_args)
  if vim.v.shell_error ~= 0 then  --- 判断 system() 结果是否错误
    if result == "" then
      vim.notify("no result found", vim.log.levels.WARN)
    else
      Notify(result, "ERROR")
    end
    return
  end

  pickers.new({}, {
    prompt_title = ":Rg",
    finder = finders.new_table({
      results = vim.fn.split(result, '\n'),
      entry_maker = make_entry.gen_from_vimgrep(),  -- VVI: gen_from_vimgrep() 设置作用: <CR> jump to <file:line:column>
    }),
    previewer = conf.grep_previewer({}),
    sorter = conf.generic_sorter(),  -- VVI: 设置 sorter 后可以通过 fzf 输入框对 results 进行过滤.
  }):find()
end

--- Rg command 使用方法 --- {{{
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
  function(opts)
    rg_search(opts.args)
  end,
{nargs="+"})



