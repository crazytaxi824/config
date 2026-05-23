-- `:help vim.filetype.add()`, Add new filetype mappings.
-- extension, filename, pattern
vim.filetype.add({
  extension = {
    json = "jsonc",  -- 将 json 文件看作 jsonc
  },
  filename = {
    ["go.mod"] = "gomod",
    ["go.sum"] = "gosum",
    ["go.work"] = "gowork",
  },
})
