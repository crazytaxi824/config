--- `:help vim.filetype.add()`, Add new filetype mappings.
--- extension, filename, pattern
vim.filetype.add({
  extension = {
    -- json = "json5",  -- 将 json 文件看作 json5
  },
  filename = {
    ["go.mod"] = "gomod",
    ["go.sum"] = "gosum",
    ["go.work"] = "gowork",
  },
})
