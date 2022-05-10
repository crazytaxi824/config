--- "L3MON4D3/LuaSnip"
local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
  return
end

--- "L3MON4D3/LuaSnip" 设置 ------------------------------------------------------------------------
--  https://github.com/L3MON4D3/LuaSnip -> Examples/snippets.lua
--  https://github.com/L3MON4D3/LuaSnip/blob/eb5b77e7927e4b28800b4f40c5507d6396b7eeaf/Examples/snippets.lua
luasnip.config.set_config({
  history = false,
})

--- 读取配置文件地址 --- {{{
-- 默认加载 `:set runtimepath?` 中的 package.json 文件. NOTE: package.json, go.json ... 不能有注释 否则无法解析.
-- 可以参照 https://github.com/rafamadriz/friendly-snippets 自己定义 snippets
--
-- require("luasnip/loaders/from_vscode").load({
--   paths = { "~/...", "./...", "/..." }, -- 这里的paths 里面只是 folder 地址, folder 中必须包含 package.json 文件.
--   exclude = {"python"},  -- 排除这些语言
--   include = {"go"},      -- VVI: 只加载某些 snippets
-- })
--
-- require("luasnip/loaders/from_vscode").lazy_load({
--   paths = { "~/...", "./...", "/..." }, -- NOTE: lazy_load 只有 paths 配置, 没有 exclude & include
-- })
--
-- }}}
--- vscode 指定读取 "~/.config/nvim/snip/package.json"
require("luasnip.loaders.from_vscode").load({
  -- paths = {},     -- NOTE: paths 缺省时自动加载 runtimepath. 这里是加载 friendly-snippets
  exclude = {"go"},  -- 排除 go, 使用下面自定义的 snippets
})
require("luasnip.loaders.from_vscode").lazy_load({
  -- NOTE: lazy_load 只有 paths 配置, 没有 exclude & include
  paths = {"./snip"},  -- runtimepath/snip, 这里是加载自定义 snippets
})

--- HACK: 从 insert/select mode 退出时取消 jumpable ------------------------------------------------
--- https://github.com/L3MON4D3/LuaSnip/issues/258
local function leave_snippet()
    -- NOTE: 如果从 's' -> 'n', 或者 'i' -> 'any' mode. 打断 jumpable.
    --if ((vim.v.event.old_mode == 's' and vim.v.event.new_mode == 'n') or vim.v.event.old_mode == 'i')
    if vim.v.event.new_mode == 'n'
        and luasnip.session.current_nodes[vim.api.nvim_get_current_buf()]
        and not luasnip.session.jump_active
    then
        require('luasnip').unlink_current()
    end
end

vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = {"*"},
  callback = leave_snippet,
})



