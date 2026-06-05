-- fmt "\n" 换行符颜色, 提升 priority 为 201
local my_query = [[
; extends
((escape_sequence) @string.escape
  (#set! "priority" 201))
]]


-- cache 已经处理过的 filetype, 只执行一次
---@type table<string, boolean>
local lang_set = {}

-- 给所有 filetype 都实现的 query highlight
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    -- 以处理
    if lang_set[args.match] then
      return
    end

    local lang = vim.treesitter.language.get_lang(args.match)
    if lang then
      -- query 中是否包含 (escape_sequence) node
      local ok, query = pcall(vim.treesitter.query.parse, lang, "(escape_sequence)")
      if ok and query then
        -- 追加到该语言的 highlights
        vim.treesitter.query.set(lang, "highlights", my_query)
      end
    end

    -- 以处理
    lang_set[args.match] = true
  end,
})
