--- 使用 lsp 的 'textDocument/foldingRange' 获取 fold 信息.
local str_cache = require("user.fold.lsp_expr_cache")

local M = {}

-- 通过 nvim_buf_call 获取 local to window 的 opt
local function get_win_local_option(bufnr, opt)
  local v
  vim.api.nvim_buf_call(bufnr, function()
    v = vim.wo[opt]
  end)
  return v
end

local function init_expr_cache(bufnr)
  local d_cache = {}
  str_cache.init()

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  for i = 1, line_count, 1 do
    d_cache[i] = 0
    --- NOTE: foldexpr='v:lua.xxx' 设置时, vim 中的 table key 必须是连续的 int, 或者是 string.
    --- 所以这里必须初始化成连续的 int.
    str_cache.set(i, "0")
  end

  return d_cache
end

local function parse_fold_data(fold_range, d_cache, foldnestmax)
  -- fold:
  --   kind = "comment",   -- (optional)
  --   startLine = 13      -- 0-index, 等于 vim 的 line_num - 1
  --   startCharacter = 29,
  --   endLine = 17,       -- 0-index, 等于 vim 的 line_num - 1
  --   endCharacter = 31,  -- (optional)
  for _, fold in ipairs(fold_range) do
    --- fold range 是同一行时跳过.
    if fold.startLine == fold.endLine then
      goto continue
    end

    local startLine = fold.startLine + 1
    local endLine = fold.endLine

    if d_cache[startLine] + 1 > foldnestmax then
      goto continue
    end

    --- "comment" 的情况下, fold 最后一行, 其他情况下 fold 至 range 的倒数第二行.
    if fold.kind == "comment" then
      endLine = fold.endLine + 1
    end

    --- 根据 fold range 计算 foldexpr 的值.
    for i = startLine, endLine, 1 do
      d_cache[i] = d_cache[i] + 1
      if i == startLine then
        str_cache.set(i, ">" .. d_cache[i])
      else
        str_cache.set(i, tostring(d_cache[i]))
      end
    end

    ::continue::
  end
end

local function set_fold(bufnr)
  local d_cache = init_expr_cache(bufnr)
  local foldnestmax = get_win_local_option(bufnr, 'foldnestmax')

  local params = {textDocument = require('vim.lsp.util').make_text_document_params(bufnr)}
  vim.lsp.buf_request_all(bufnr, 'textDocument/foldingRange', params, function(resps)
    --- resps = { client_id: data }.
    for client_id, data in pairs(resps) do
      if not data.result then
        goto continue
      end

      --- parse lsp response fold range
      parse_fold_data(data.result, d_cache, foldnestmax)

      ::continue::
    end

    --- VVI: 确保 fold 设置都是 local to window, 所以使用 nvim_buf_call 保证 setlocal 设置.
    vim.api.nvim_buf_call(bufnr, function()
      vim.opt_local.foldexpr = 'v:lua.require("user.fold.lsp_expr_cache").get(v:lnum)'
      vim.opt_local.foldtext = 'v:lua.require("user.fold.lsp_foldtext").foldtext()'
      vim.opt_local.foldmethod = 'expr'
    end)
  end)
end

M.set_foldexpr = function(bufnr)
  if get_win_local_option(bufnr, 'foldmethod') ~= "manual" then
    return
  end

  set_fold(bufnr)

  local g_id = vim.api.nvim_create_augroup('my_lsp_fold_' .. bufnr, {clear=true})
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = g_id,
    buffer = bufnr,
    callback = function(params)
      set_fold(params.buf)
    end,
    desc = "lsp set foldexpr"
  })

  --- LspDetach: `:set filetype=xxx`, `:LspStop`
  vim.api.nvim_create_autocmd({"LspDetach", "BufWipeout"}, {
    group = g_id,
    buffer = bufnr,
    callback = function(params)
      vim.api.nvim_del_augroup_by_id(g_id)
    end,
    desc = "lsp delete foldexpr augroup"
  })
end

return M

