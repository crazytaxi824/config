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
      "--only-matching",  -- only print matched text, 也可以使用 --trim 打印整行内容.
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
local opt = { noremap = true, silent = true }
local telescope_keymaps = {
  --- Picker functions, https://github.com/nvim-telescope/telescope.nvim#pickers
  --- 使用 `:Telescope` 列出所有 Picker
  {'n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<cr>", opt, 'Telescope - fd'},
  {'n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>", opt, 'Telescope - rg'},
  {'n', '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>", opt, 'Telescope - Buffer List'},
  {'n', '<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>", opt, 'Telescope - Vim Help Doc'},
  {'n', '<leader>fc', "<cmd>lua require('telescope.builtin').command_history()<cr>", opt, 'Telescope - Command History'},
  {'n', '<leader>fs', "<cmd>lua require('telescope.builtin').search_history()<cr>", opt, 'Telescope - Search History'},
  {'n', '<leader>fk', "<cmd>lua require('telescope.builtin').keymaps()<cr>", opt, 'Telescope - Keymap normal Mode'},
  {'n', 'z=', "<cmd>lua require('telescope.builtin').spell_suggest()<cr>", opt, 'Telescope - Spell Suggests'},  -- NOTE: 也可以使用 which-key 显示
}

Keymap_list_set(telescope_keymaps,
  {
    key_desc = {f = {name = "Telescope Find"}},
    opts = {mode='n', prefix='<leader>'}
  }
)



