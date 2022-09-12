local hover_short = require("user.lsp.custom_lsp_request.hover_short")
local doc_hl = require("user.lsp.custom_lsp_request.doc_highlight")

local M = {
  hover_short = hover_short.hover_short,
  doc = {
    highlight = doc_hl.doc_highlight,
    clear = doc_hl.doc_clear,
  },
}

return M
