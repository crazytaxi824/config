-- fmt "\n" 换行符颜色, 提升 priority
local my_query = [[
; extends
((escape_sequence) @string.escape
  (#set! "priority" 201))
]]

-- 给所有 filetype 都实现的 query highlight
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if lang then
      -- 追加到该语言的 highlights
      vim.treesitter.query.set(lang, "highlights", my_query)
    end
  end,
})
