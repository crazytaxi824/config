--- "L3MON4D3/LuaSnip"
local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
  return
end

--- "L3MON4D3/LuaSnip" 设置 ------------------------------------------------------------------------
--- https://github.com/L3MON4D3/LuaSnip/blob/master/Examples/snippets.lua
--- https://github.com/L3MON4D3/LuaSnip#config
luasnip.config.set_config({
  history = false,
})

--- VVI: 读取配置文件地址 --- {{{
--- 默认加载 `:set runtimepath?` 中的 package.json 文件. NOTE: package.json, go.json ... 不能有注释 否则无法解析.
--- 可以参照 https://github.com/rafamadriz/friendly-snippets 自己定义 snippets
-- -- }}}
--- NOTE: `:help luasnip-loaders`
require("luasnip.loaders.from_vscode").lazy_load({
  --- 指定读取 "~/.config/nvim/snip/package.json"
  --- 这里是加载自定义 snippets, 地址是 runtimepath/snip/package.json
  --- 这里的 runtimepath 是 ~/.config/nvim/
  paths = {"./snip"},  -- 这里的路径是相对于 runtimepath
})
require("luasnip.loaders.from_vscode").lazy_load({
  --- paths 缺省时自动加载 runtimepath/package.json 这里是加载 friendly-snippets
  --- 这里的 runtimepath 是 ~/.local/share/nvim/site/pack/*/start/*/,
  --- 即: ~/.local/share/nvim/site/pack/packer/start/friendly-snippets/
  --paths = {},
  exclude = {"go"},  -- 排除 go, 使用自定义的 snippets
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



