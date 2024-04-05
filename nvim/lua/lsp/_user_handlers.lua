--- Overwrite handler 设置
--- DOCS: 使用 with() 方法. `:help lsp-handler-configuration`
--- DOCS: `:help lsp-api` lsp-method 显示 textDocument/... 列表

--- 'textDocument/publishDiagnostics' settings ------------------------------------------------------
--- `:help vim.lsp.diagnostic.on_publish_diagnostics()`
--- NOTE: 会影响 vim.diagnostic.config() 设置.
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.handlers["textDocument/publishDiagnostics"], {
    --- VVI: 必须为 true, 否则 diagnostic 无法正确显示颜色.
    underline = true,  -- Enable underline, use default values.

    --- 使用 virtual_text 显示 diagnostic message.
    virtual_text = false,
    --virtual_text = { spacing = 4 },  -- Enable virtual text, override spacing to 4

    --- 是否显示 diagnostic signs.
    signs = true,
    -- Use a function to dynamically turn signs off
    -- and on, using buffer local variables
    --signs = function(namespace, bufnr) end,

    --- 输入时实时更新 diagnostic, 比较耗资源.
    update_in_insert = false,
  }
)

--- 'textDocument/hover' handler 的 border 样式 ----------------------------------------------------
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers["textDocument/hover"],
  {
    focusable = false,  -- false: 重复执行 vim.lsp.buf.hover() 时不会进入 floating window.
    border = {"▄","▄","▄","█","▀","▀","▀","█"},

    --- events, to trigger close floating window
    --- https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/util.lua
    close_events = {"WinScrolled"},  -- 默认 {"CursorMoved", "CursorMovedI", "InsertCharPre"}
  }
)

--- HACK: 重写 neovim 内部函数 vim.lsp.util.make_floating_popup_options().
---       Always Put popup window on Top of the cursor.
--- 影响所有使用 vim.lsp.util.open_floating_preview() 的 popup window.
--- https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/util.lua
--- modify native function - `vim.lsp.util.make_floating_popup_options` ----------------------------
vim.lsp.util.make_floating_popup_options = function(width, height, opts)
    vim.validate {
    opts = { opts, 't', true };
  }
  opts = opts or {}
  vim.validate {
    ["opts.offset_x"] = { opts.offset_x, 'n', true };
    ["opts.offset_y"] = { opts.offset_y, 'n', true };
  }

  local anchor = ''
  local row, col

  local lines_above = vim.fn.winline() - 1
  local lines_below = vim.fn.winheight(0) - lines_above

  --- 原设置
  -- if lines_above < lines_below then
  --   anchor = anchor..'N'
  --   height = math.min(lines_below, height)
  --   row = 1
  -- else
  --   anchor = anchor..'S'
  --   height = math.min(lines_above, height)
  --   row = 0
  -- end

  --- 自定义设置部分 ---
  if vim.fn.winline() < height+2 then  -- +2 border width
    anchor = anchor..'N'
    height = math.min(lines_below, height)
    row = 1
  else
    anchor = anchor..'S'
    height = math.min(lines_above, height)
    row = 0
  end
  --- 自定义设置结束 ---

  if vim.fn.wincol() + width + (opts.offset_x or 0) <= vim.api.nvim_get_option('columns') then
    anchor = anchor..'W'
    col = 0
  else
    anchor = anchor..'E'
    col = 1
  end

  local default_border = {
    {"", "NormalFloat"},
    {"", "NormalFloat"},
    {"", "NormalFloat"},
    {" ", "NormalFloat"},
    {"", "NormalFloat"},
    {"", "NormalFloat"},
    {"", "NormalFloat"},
    {" ", "NormalFloat"},
  }

  return {
    anchor = anchor,
    col = col + (opts.offset_x or 0),
    height = height,
    focusable = opts.focusable,
    relative = 'cursor',
    row = row + (opts.offset_y or 0),
    style = 'minimal',
    width = width,
    border = opts.border or default_border,
    zindex = opts.zindex or 50,
  }
end



