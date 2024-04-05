--- 使用 lsp 的 'textDocument/foldingRange' 获取 fold 信息, 然后通过 expr 来 fold.
--- https://github.com/kevinhwang91/nvim-ufo
--- https://github.com/kevinhwang91/nvim-ufo/blob/main/lua/ufo/provider/lsp/nvim.lua

local M = {}

M.foldexpr_str = 'v:lua.require("fold.fold_lsp").foldexpr(v:lnum)'
M.foldtext_str = 'v:lua.require("fold.foldtext").foldtext_lsp()'

--- table, 记录 foldexpr 格式. { bufnr = { lnum: expr }}
--- VVI: foldexpr='v:lua.xxx' 设置时, vim 中的 table key 必须是连续的 int, 或者是 string.
local foldlevel_cache = {}

M.clear_cache =function(bufnr)
  foldlevel_cache[bufnr] = nil
end

M.debug = function()
  vim.print(foldlevel_cache)
end

--- `set foldexpr=xxx` 用
--- NOTE: 每次 `set foldmethod=expr` 都会重新执行 foldexpr()
M.foldexpr = function(lnum)
  local bufnr = vim.api.nvim_get_current_buf()
  if foldlevel_cache[bufnr] then
    return foldlevel_cache[bufnr][lnum] or 0
  end
  return 0
end

--- 初始化两个 list 用于计算和缓存 foldmethod=expr 结果.
local function init_expr_cache(bufnr)
  foldlevel_cache[bufnr] = {}

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  for i = 1, line_count, 1 do
    foldlevel_cache[bufnr][i] = 0
  end
end

--- 将 foldingRange 返回的数据按照 foldexpr 的格式记录到 list cache 中.
local function parse_fold_data(bufnr, fold_range, foldnestmax)
  -- fold:
  --   kind = "comment",   -- (optional), "comment", "imports" ...
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
    local endLine = fold.endLine + 1

    --- 最多标记到 foldnestmax level.
    if foldlevel_cache[bufnr][startLine] + 1 > foldnestmax then
      goto continue
    end

    --- 根据 fold range 计算 foldexpr 的值.
    for i = startLine, endLine, 1 do
      foldlevel_cache[bufnr][i] = foldlevel_cache[bufnr][i] + 1  --- VVI: increase foldlevel
    end

    ::continue::
  end
end

--- 发送 'textDocument/foldingRange' 请求到 lsp, 分析 response, 然后按照 foldexpr 的格式记录.
--- https://github.com/kevinhwang91/nvim-ufo/blob/main/lua/ufo/provider/lsp/nvim.lua
--- 必须保证 lsp 的 client.server_capabilities.foldingRangeProvider == true
M.lsp_fold_request = function(bufnr, win_id)
  local params = {textDocument = require('vim.lsp.util').make_text_document_params(bufnr)}
  vim.lsp.buf_request_all(bufnr, 'textDocument/foldingRange', params, function(resps)
    --- VVI: 获取到 resps 之后再 init cache.
    --- 否则可能出现 init cache 之后, buf_request_all() 失败导致 str_cache[bufnr] = {'0', ...} 被全部初始化为 "0".
    init_expr_cache(bufnr)

    --- resps = { client_id: data }.
    for lsp_client_id, data in pairs(resps) do
      if data.result then
        --- VVI: 这里必须检查 win_id 是否存在,  因为 buf_request_all() 是一个异步函数.
        local win_is_valid = vim.api.nvim_win_is_valid(win_id)

        local foldnestmax
        if win_is_valid then
          foldnestmax = vim.wo[win_id].foldnestmax
        else
          foldnestmax = vim.wo.foldnestmax
        end

        --- parse lsp response fold range
        parse_fold_data(bufnr, data.result, foldnestmax)

        --- NOTE: 在计算完 lsp_fold 之后再设置 foldmethod=expr 否则无法 Fold.
        --- VVI: buf_request_all() 是一个异步函数, 这里在异步函数的回调函数里所以可以保证执行顺序.
        if win_is_valid and vim.api.nvim_win_get_buf(win_id) == bufnr then
          vim.api.nvim_set_option_value('foldmethod', 'expr', { scope = 'local', win = win_id })
        end

        --- 只计算一次 foldexpr
        return
      end
    end
  end)
end

M.set_fold = function(client, bufnr, win_id)
  --- lsp 不支持 foldingRange
  if not client.server_capabilities or not client.server_capabilities.foldingRangeProvider then
    return
  end

  --- VVI: buf_request_all() 是一个异步函数, 所以 set foldexpr foldnestmax foldmethod 写在
  --- buf_request_all() 的前面或者后面效果都一样, 都会在 buf_request_all() 的前面运行.
  local opts = { scope = 'local', win = win_id }
  vim.api.nvim_set_option_value('foldexpr', M.foldexpr_str, opts)
  vim.api.nvim_set_option_value('foldtext', M.foldtext_str, opts)
  --- VVI: 在 lsp_fold 计算完成之后再设置 foldmethod=expr 否则无法 Fold.
  --- 这里是在 buf_request_all() 的回调函数里设置 foldmethod 以保证执行顺序.

  --- vim.lsp.buf_request_all()
  M.lsp_fold_request(bufnr, win_id)

  return true  -- 设置成功
end

return M

