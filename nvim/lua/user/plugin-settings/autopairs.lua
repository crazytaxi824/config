--- Use a protected call so we don't error out on first use
local status_ok, npairs = pcall(require, "nvim-autopairs")
if not status_ok then
  return
end

npairs.setup {
  check_ts = true,  -- check tree-sitter
  ts_config = {     -- tree-sitter 排除规则
    -- NOTES: tree-sitter node 可以通过 `:TSPlaygroundToggle` 查看.
    lua = { "string", "source" },  -- it will not add a pair on that treesitter node,
    javascript = { "string", "template_string" },
    java = false,  -- don't check treesitter on java, 使用 autopairs 默认设置.
  },

  --- 特殊情况设置
  disable_filetype = { "TelescopePrompt", "spectre_panel" },  -- 指定文件中不使用 autopairs
  enable_check_bracket_line = false,  -- NOTE: 不好用. 同一行中如果有 ), 则在左边输入 ( 时, 不自动补充.
  enable_bracket_in_quote = true,     -- false - 在 "" 中不自动 {} () []
  enable_afterquote = true,           -- NOTE: 如果在 |"xxx" 输入 (, 会自动在 "xxx"| 后补充 ).
  --ignored_next_char = "[%w%.]",     -- 如果光标后一位是字符 & 数字 & . 则不运行 autopairs
                                      -- VVI: 不要使用 [%S], 因为在 (|) 输入 ", 会被 [%S] 阻止.

  --- key mapping
  map_cr = true,  -- <CR>
  map_bs = true,  -- <BS>
  map_c_h = true, -- VVI: <C-h> & Mac <BS> 一次删除一对.

  --fast_wrap = {},  -- pair 选中的文字. NOTE: 不开启, 使用自定义 keymap.
}

--local Rule = require('nvim-autopairs.rule')
--npairs.add_rule(Rule('<','>',"lua"))  -- NOTE: 添加 rules
npairs.remove_rule('`')   -- 删除 `` 匹配

--- NOTE: 自动补全 cmp 配合使用.
--- If you want insert `(` after select function or method item
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
  return
end
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done { map_char = { tex = "" } })


