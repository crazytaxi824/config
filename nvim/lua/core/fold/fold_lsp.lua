--- 使用 lsp 的 'textDocument/foldingRange' 获取 fold 信息, 然后通过 expr 来 fold.
--- https://github.com/kevinhwang91/nvim-ufo
--- https://github.com/kevinhwang91/nvim-ufo/blob/main/lua/ufo/provider/lsp/nvim.lua
local expr_ts = require("core.fold.fold_treesitter")
local ms = vim.lsp.protocol.Methods

local M = {}

M.foldexpr_str = 'v:lua.require("core.fold.fold_lsp").foldexpr(v:lnum)'
M.foldtext_str = 'v:lua.require("core.fold.foldtext").foldtext_lsp()'

--- table, 记录 foldexpr 格式. { bufnr = { lnum: expr }}
--- VVI: foldexpr='v:lua.xxx' 设置时, vim 中的 table key 必须是连续的 int, 或者是 string.
local foldlevel_cache = {}

M.clear_cache =function(bufnr)
  foldlevel_cache[bufnr] = nil
end

M.debug = function()
  vim.print(foldlevel_cache)
end

--- cache map[bufnr] = { timer = defer_fn(), cancel = vim.lsp.buf_request_all() }
local buf_timer = {}

--- DOCS: `:help vim.defer_fn` & `:help uv.new_timer()`
local function clearInterval(bufnr)
  if not buf_timer[bufnr] then
    return
  end

  --- cancel vim.lsp.buf_request_all() if it's already started.
  local cancel = buf_timer[bufnr].cancel
  if cancel then cancel() end

  --- stop & abort timer
  local timer = buf_timer[bufnr].timer
  if timer then
    timer:stop()
    if not timer:is_closing() then
      timer:close()
    end
  end
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

--- 初始化 list cache 用于计算和缓存 foldmethod=expr 结果.
local function init_expr_cache(bufnr)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  if line_count < 1 then
    --- VVI: nvim_buf_line_count() 一个 bdelete bufnr 返回 0.
    return
  end

  foldlevel_cache[bufnr] = {}
  for i = 1, line_count, 1 do
    foldlevel_cache[bufnr][i] = 0
  end

  --- fold init success
  return true
end

--- 将 foldingRange 返回的数据按照 foldexpr 的格式记录到 list cache 中.
--- vim.lsp.buf_request_all() response data: ----------------------------------- {{{
--- {
---   lsp_id = {
---     result = {
---       {
---         kind = "comment",   -- (optional), "comment", "imports" ...
---         startLine = 13      -- 0-index, 等于 vim 的 line_num - 1
---         startCharacter = 29,
---         endLine = 17,       -- 0-index, 等于 vim 的 line_num - 1
---         endCharacter = 31,  -- (optional)
---       },
---       { ... },
---     },
---     error = {
---       code = -32601,
---       message = "Unhandled method textDocument/foldingRange",
---     },
---   }
--- }
-- -- }}}
local function parse_fold_data(bufnr, fold_range, foldnestmax)
  --- VVI: mark startLine & endLine 解决两个同级别的折叠块在一起的时候会被折叠到一起的问题.
  --- eg: comments & code_blocks
  local startLine_marks, endLine_marks = {}, {}

  for _, fold in ipairs(fold_range) do
    --- fold range 是同一行时跳过.
    if fold.startLine == fold.endLine then
      goto continue
    end

    --- lsp using 0-index for line_num, neovim using 1-index for line_num.
    local startLine = fold.startLine + 1
    local endLine = fold.endLine + 1

    --- 最多标记到 foldnestmax level.
    if foldlevel_cache[bufnr][startLine] + 1 > foldnestmax then
      goto continue
    end

    --- 根据 fold range 计算 foldexpr 的值.
    for i = startLine, endLine, 1 do
      if i == startLine then
        table.insert(startLine_marks, startLine)
      end
      if i == endLine then
        table.insert(endLine_marks, endLine)
      end

      foldlevel_cache[bufnr][i] = foldlevel_cache[bufnr][i] +1  --- increase foldlevel
    end

    ::continue::
  end

  --- mark foldpexr
  for _, sl in ipairs(startLine_marks) do
    foldlevel_cache[bufnr][sl] = ">" .. foldlevel_cache[bufnr][sl]
  end

  for _, el in ipairs(endLine_marks) do
    foldlevel_cache[bufnr][el] = "<" .. foldlevel_cache[bufnr][el]
  end
end

--- 发送 'textDocument/foldingRange' 请求到 lsp, 分析 response, 然后按照 foldexpr 的格式记录.
--- https://github.com/kevinhwang91/nvim-ufo/blob/main/lua/ufo/provider/lsp/nvim.lua
--- 必须保证 lsp 的 client.server_capabilities.foldingRangeProvider == true
M.lsp_fold_request = function(bufnr, win_id, opts)
  clearInterval(bufnr)

  buf_timer[bufnr] = {}
  buf_timer[bufnr].timer = vim.defer_fn(function()
    local params = {textDocument = vim.lsp.util.make_text_document_params(bufnr)}
    buf_timer[bufnr].cancel = vim.lsp.buf_request_all(bufnr, ms.textDocument_foldingRange, params, function(resp)
      --- VVI: 获取到 resps 之后再 init cache, 否则可能出现 init cache 之后
      --- buf_request_all() 失败导致 str_cache[bufnr] = {'0', ...} 被全部初始化为 "0".
      if not init_expr_cache(bufnr) then
        --- 如果返回 false 说明 bufnr 已经被关闭, 不需要计算 fold 了.
        return
      end

      --- lsp fold 是否设置成功.
      local set_fold_success = false

      --- resps = { client_id: data }.
      for lsp_client_id, data in pairs(resp) do
        if data.result and #data.result > 0 then
          --- VVI: 因为 buf_request_all() 是一个异步函数, 这里必须检查 win_id 是否存在.
          local win_is_valid = vim.api.nvim_win_is_valid(win_id)

          local foldnestmax
          if win_is_valid then
            foldnestmax = vim.wo[win_id].foldnestmax
          else
            foldnestmax = vim.wo.foldnestmax
          end

          --- parse lsp response fold range
          parse_fold_data(bufnr, data.result, foldnestmax)

          --- VVI: 可能在异步函数中执行, 必须检查 window 中的 buffer 是否已经被改变.
          if not win_is_valid or vim.api.nvim_win_get_buf(win_id) ~= bufnr then
            return
          end

          vim.api.nvim_set_option_value('foldexpr', M.foldexpr_str, { scope = 'local', win = win_id })
          vim.api.nvim_set_option_value('foldtext', M.foldtext_str, { scope = 'local', win = win_id })
          vim.api.nvim_set_option_value('foldmethod', 'expr', { scope = 'local', win = win_id })

          --- fallback to treesitter fold or not.
          set_fold_success = true

          --- NOTE: 只计算一次 foldlevel
          break
        end
      end

      --- VVI: clear timer cache
      buf_timer[bufnr] = nil

      --- NOTE: try fallback to fold_treesitter if fold_lsp fail.
      if opts and opts.treesitter_fallback and not set_fold_success then
        expr_ts.set_fold(bufnr, win_id)
      end
    end)
  end, 300)
end

return M

