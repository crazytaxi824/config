--- 使用 lsp 的 'textDocument/foldingRange' 获取 fold 信息, 然后通过 expr 来 fold.
--- https://github.com/kevinhwang91/nvim-ufo
--- https://github.com/kevinhwang91/nvim-ufo/blob/main/lua/ufo/provider/lsp/nvim.lua

local M = {}

--- table, 记录 foldexpr 格式. { lnum: expr }
--- VVI: foldexpr='v:lua.xxx' 设置时, vim 中的 table key 必须是连续的 int, 或者是 string.
local str_cache = {}

--- `set foldexpr` 用
M.foldexpr = function(lnum)
  return str_cache[lnum]
end

--- 通过 nvim_buf_call 获取 local to window 的 opt
local function get_win_local_option(bufnr, opt)
  local v
  vim.api.nvim_buf_call(bufnr, function()
    v = vim.wo[opt]
  end)
  return v
end

--- 初始化两个 list 用于 cache expr 结果.
local function init_expr_cache(bufnr)
  local d_cache = {}
  str_cache = {}

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  for i = 1, line_count, 1 do
    d_cache[i] = 0
    str_cache[i] = "0"
  end

  return d_cache
end

--- 将 foldingRange 返回的数据按照 foldexpr 的格式记录到 list cache 中.
local function parse_fold_data(fold_range, d_cache, foldnestmax, foldoneline)
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
    if d_cache[fold.startLine + 1] + 1 > foldnestmax then
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
      d_cache[i] = d_cache[i] + 1
      if i == startLine then
        str_cache[i] = ">" .. d_cache[i]
      else
        str_cache[i] = tostring(d_cache[i])
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
local function set_fold(bufnr)
  local d_cache = init_expr_cache(bufnr)
  local foldnestmax = get_win_local_option(bufnr, 'foldnestmax')

  local params = {textDocument = require('vim.lsp.util').make_text_document_params(bufnr)}
  vim.lsp.buf_request_all(bufnr, 'textDocument/foldingRange', params, function(resps)
    --- resps = { client_id: data }.
    for client_id, data in pairs(resps) do
      if data.result then
        --- parse lsp response fold range
        --- gopls 返回的 endLine 是倒数第一行, 在 parse 的时候人为的改为倒数第二行.
        parse_fold_data(data.result, d_cache, foldnestmax, foldoneline(client_id))

        --- 只计算一次
        break
      end
    end

    --- DEBUG:
    -- vim.print(str_cache)

    --- VVI: 确保 fold 设置都是 local to window, 所以使用 nvim_buf_call 保证 setlocal 设置.
    --- VVI: 想要更新 buffer 中的 foldexpr 位置, 需要重新 `setlocal foldexpr`, foldexpr 值不用变.
    vim.api.nvim_buf_call(bufnr, function()
      vim.opt_local.foldexpr = 'v:lua.require("user.fold.fold_lsp").foldexpr(v:lnum)'
      vim.opt_local.foldtext = 'v:lua.require("user.fold.foldtext").foldtext_lsp()'
      vim.opt_local.foldmethod = 'expr'
    end)
  end)
end

--- 设置 lsp foldexpr
M.set_foldexpr = function(client, bufnr)
  --- lsp 不支持 foldingRange
  if not client.server_capabilities or not client.server_capabilities.foldingRangeProvider then
    return
  end

  --- foldmethod 已经被设置过.
  if get_win_local_option(bufnr, 'foldmethod') ~= "manual" then
    return
  end

  set_fold(bufnr)

  --- 文件 save 后重新计算 foldexpr.
  local g_id = vim.api.nvim_create_augroup('my_lsp_fold_' .. bufnr, {clear=true})
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = g_id,
    buffer = bufnr,
    callback = function(params)
      --- set_fold() 时会重新设置 `set foldexpr` 会触发 foldexpr 重新计算.
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

  return true
end

return M

