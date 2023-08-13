--- 使用 lsp 的 'textDocument/foldingRange' 获取 fold 信息, 然后通过 expr 来 fold.
--- https://github.com/kevinhwang91/nvim-ufo
--- https://github.com/kevinhwang91/nvim-ufo/blob/main/lua/ufo/provider/lsp/nvim.lua

local M = {}

--- table, 记录 foldexpr 格式. { bufnr = { lnum: expr }}
--- VVI: foldexpr='v:lua.xxx' 设置时, vim 中的 table key 必须是连续的 int, 或者是 string.
local str_cache = {}

M.clear_cache = function(bufnr)
  str_cache[bufnr] = nil
end

M.debug = function()
  vim.print(str_cache)
end

--- `set foldexpr=xxx` 用
M.foldexpr = function(lnum)
  local bufnr = vim.api.nvim_get_current_buf()
  if str_cache[bufnr] then
    return str_cache[bufnr][lnum] or "0"
  end
  return "0"
end

--- 初始化两个 list 用于 cache expr 结果.
local function init_expr_cache(bufnr)
  local tmp_cache = {}  -- tmp_cache 只在计算的时候临时使用.
  str_cache[bufnr] = {}

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  for i = 1, line_count, 1 do
    tmp_cache[i] = 0
    str_cache[bufnr][i] = "0"
  end

  return tmp_cache
end

--- 将 foldingRange 返回的数据按照 foldexpr 的格式记录到 list cache 中.
local function parse_fold_data(bufnr, fold_range, tmp_cache, foldnestmax, foldoneline)
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

    --- 最多标记到 foldnestmax level.
    if tmp_cache[fold.startLine + 1] + 1 > foldnestmax then
      goto continue
    end

    local startLine = fold.startLine + 1
    local endLine = fold.endLine + 1

    --- lsp 返回的 fold 是否在同一行内. eg:
    ---  - gopls 返回的 endLine 是函数的最后一行, 返回的 comment 也是最后一行.
    ---  - tsserver 返回的 endLine 是函数的倒数第二行, 但是返回的 comment 是最后一行.
    --- 这里人为的将 fold 格式设为倒数第二行.
    if foldoneline then
      endLine = fold.endLine
    end

    --- "comment" 的情况下, fold 最后一行, 其他情况下 fold 至 range 的倒数第二行.
    if fold.kind == "comment" then
      endLine = fold.endLine + 1
    end

    --- 根据 fold range 计算 foldexpr 的值.
    for i = startLine, endLine, 1 do
      tmp_cache[i] = tmp_cache[i] + 1
      if i == startLine then
        str_cache[bufnr][i] = ">" .. tmp_cache[i]
      else
        str_cache[bufnr][i] = tostring(tmp_cache[i])
      end
    end

    ::continue::
  end
end

--- lsp 返回的 fold 是否在同一行内. eg:
---  - gopls 返回的 endLine 是函数的最后一行, 返回的 comment 也是最后一行.
---  - tsserver 返回的 endLine 是函数的倒数第二行, 但是返回的 comment 是最后一行.
--- 这里人为的将 fold 格式设为倒数第二行.
local function foldoneline(client_id)
  local lsp_foldoneline = {"gopls"}
  local client = vim.lsp.get_client_by_id(client_id)
  return vim.tbl_contains(lsp_foldoneline, client.name)
end

--- 发送 'textDocument/foldingRange' 请求到 lsp, 分析 response, 然后按照 foldexpr 的格式记录.
--- https://github.com/kevinhwang91/nvim-ufo/blob/main/lua/ufo/provider/lsp/nvim.lua
M.set_fold = function(bufnr, win_id)
  local params = {textDocument = require('vim.lsp.util').make_text_document_params(bufnr)}
  vim.lsp.buf_request_all(bufnr, 'textDocument/foldingRange', params, function(resps)
    --- VVI: 获取到 resps 之后再 init cache.
    --- 否则可能出现 init cache 之后, buf_request_all() 失败导致 str_cache[bufnr] = {'0', ...} 被全部初始化为 "0".
    local tmp_cache = init_expr_cache(bufnr)

    --- resps = { client_id: data }.
    for client_id, data in pairs(resps) do
      if data.result then
        --- parse lsp response fold range
        --- gopls 返回的 endLine 是倒数第一行, 在 parse 的时候人为的改为倒数第二行.
        parse_fold_data(bufnr, data.result, tmp_cache, vim.wo[win_id].foldnestmax, foldoneline(client_id))

        --- 只计算一次
        break
      end
    end

    --- VVI: 确保 fold 设置都是 local to window, 所以使用 nvim_win_call 保证 setlocal 设置.
    --- VVI: 想要更新 buffer 中的 foldexpr 位置, 需要重新 `setlocal foldexpr`, foldexpr 值不用变.
    vim.api.nvim_win_call(win_id, function()
      vim.opt_local.foldexpr = 'v:lua.require("user.fold.fold_lsp").foldexpr(v:lnum)'
      vim.opt_local.foldtext = 'v:lua.require("user.fold.foldtext").foldtext_lsp()'
      vim.opt_local.foldmethod = 'expr'
    end)
  end)
end

return M

