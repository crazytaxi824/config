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
  --update_events = 'TextChanged,TextChangedI', -- 默认: 'InsertLeave'
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
--- https://github.com/L3MON4D3/LuaSnip/issues/656
local function leave_snippet(params)
  if luasnip.session  -- luasnip session 存在.
    and luasnip.session.current_nodes[params.buf]  -- luasnip session 在当前 buffer 中存在.
    and not luasnip.session.jump_active
  then
    --- VVI: 使用 vim.schedule 是为了让 ${1:err} and $1 同步内容.
    vim.schedule(function ()
      luasnip.unlink_current()
    end)
  end
end

vim.api.nvim_create_autocmd("ModeChanged", {
  --pattern = {'s:n', 'i:*'},  -- NOTE: 如果从 'Select' -> 'Normal', 或者 'Insert' -> 'any' mode.
  pattern = {'*:n'},  -- any -> Normal mode
  callback = leave_snippet,
})



