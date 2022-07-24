--- Use a protected call so we don't error out on first use
local autopairs_status_ok, autopairs = pcall(require, "nvim-autopairs")
if not autopairs_status_ok then
  return
end

autopairs.setup {
  check_ts = false,  -- check treesitter, NOTE: 没有太大作用.
  -- ts_config = {     -- treesitter 排除规则
  --   -- NOTE: treesitter node 可以通过 `:TSPlaygroundToggle` 查看.
  --   lua = { "string" },  -- it will not add a pair on that treesitter node,
  --   javascript = { "string", "template_string" },
  --   java = false,  -- don't check treesitter on java, 使用 autopairs 默认设置.
  -- },

  --- 特殊情况设置
  disable_filetype = { "TelescopePrompt", "spectre_panel" },  -- 指定文件中不使用 autopairs
  enable_check_bracket_line = false,  -- NOTE: 不好用. 同一行中如果有 ), 则在左边输入 ( 时, 不自动补充.
  enable_bracket_in_quote = true,     -- false - 在 "" 中不自动 {} () []
  enable_afterquote = true,           -- NOTE: 如果在 |"xxx" 输入 (, 会自动在 "xxx"| 后补充 ).
  --ignored_next_char = "[%w%.]",     -- 如果光标后一位是字符 & 数字 & . 则不运行 autopairs
                                      -- VVI: 不要使用 [%S], 因为在 (|) 输入 ", 会被 [%S] 阻止.

  --- key mapping
  map_cr = true,  -- adding a newline when you press <cr> inside brackets
  map_bs = true,  -- <BS>
  map_c_h = true, -- VVI: <C-h> & Mac <BS> 一次删除一对括号.

  --fast_wrap = {},  -- pair 选中的文字. NOTE: 不开启, 使用自定义 keymap.
}

--- NOTE: 设置 rules 规则
--- examples --- {{{
--autopairs.get_rule('('):with_pair(...)  -- 获取 rule, 用于修改默认值.
--autopairs.add_rule(Rule('<','>'))  -- 添加 rules 给所有 filetype.
--autopairs.add_rule(Rule('<','>',"javascript"))   -- 添加 rules 给指定 filetype.
--autopairs.add_rule(Rule('<','>',"-javascript"))  -- 添加 rules 给所有 filetype, 除了指定 filetype.
-- -- }}}
local Rule = require('nvim-autopairs.rule')
local cond = require('nvim-autopairs.conds')
--- 从规则中排除指定 filetype
autopairs.get_rule('`'):with_pair(cond.not_filetypes({"markdown"}))  -- exclude filetype 'markdown' for rule ``
--- 给指定 filetype 添加规则
autopairs.add_rule(Rule('$','$',{"tex", "latex", "markdown"}))
autopairs.add_rule(Rule('$$','$$',{"tex", "markdown"}))

--- VVI: 自动补全 cmp 配合使用 ---------------------------------------------------------------------
--- If you want insert `(` after select function or method item
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
  return
end
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done { map_char = { tex = "" } })



