--- "L3MON4D3/LuaSnip"
local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
  return
end

--- "L3MON4D3/LuaSnip" 设置 ------------------------------------------------------------------------
--- https://github.com/L3MON4D3/LuaSnip/blob/master/Examples/snippets.lua
--- `:help luasnip-config-options`
-- luasnip.setup({
--   history = false,
--   update_events = 'TextChanged,TextChangedI',
-- })

--- VVI: 读取配置文件地址 --- {{{
--- 默认加载 `:set runtimepath?` 中的 package.json 文件.
--- NOTE: package.json, go.json ... 不能有注释 否则无法解析.
--- 可以参照 https://github.com/rafamadriz/friendly-snippets 自己定义 snippets
-- -- }}}
--- NOTE: `:help luasnip-loaders`
require("luasnip.loaders.from_vscode").lazy_load({
  --- 这里读取的是 "~/.config/nvim/snip/package.json" 文件.
  paths = {"./snip"},  -- './xxx' 相对路径 is where `:echo $MYVIMRC` resides.
})
require("luasnip.loaders.from_vscode").lazy_load({
  --- NOTE: paths 缺省时自动加载 "{runtimepath}/package.json". 用 `:set runtimepath?` 查看.
  --- 这里是加载 friendly-snippets
  paths = {vim.fn.stdpath('data') .. '/lazy/friendly-snippets'},
  exclude = {"go"},  -- 排除 go, 使用自定义的 snippets
})

--- luasnip log level
if __Debug_Neovim.luasnip then
  luasnip.log.set_loglevel('debug')  -- "error"|"warn"(*)|"info"|"debug"
end

--- HACK: 从 insert/select mode 退出时取消 jumpable ------------------------------------------------
--- https://github.com/L3MON4D3/LuaSnip/issues/656
local function leave_snippet(bufnr)
  if luasnip.session  -- luasnip session 存在.
    and luasnip.session.current_nodes[bufnr]  -- luasnip session 在当前 buffer 中存在.
    and not luasnip.session.jump_active
  then
    --- VVI: 使用 vim.schedule 是为了让 ${1:err} and $1 同步内容.
    vim.schedule(function ()
      luasnip.unlink_current() -- removes the current snippet from the jumplist.
    end)
  end
end

local unlink_group = vim.api.nvim_create_augroup( 'UnlinkSnipGroup', {clear = true})

vim.api.nvim_create_autocmd("ModeChanged", {
  group = unlink_group,
  --pattern = {'s:n', 'i:*'},  -- NOTE: 如果从 'Select' -> 'Normal', 或者 'Insert' -> 'any' mode.
  pattern = {'*:n'},  -- any -> Normal mode
  callback = function(params) leave_snippet(params.buf) end,
  desc = "HACK: unlink current snippet's session, exit current snippet jumplist",
})



