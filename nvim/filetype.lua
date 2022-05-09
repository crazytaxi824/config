vim.filetype.add({
  extension = {
    json = "jsonc"
  },
  filename = {
    ["go.mod"] = "gomod",
    [".gitignore"] = "gitignore"
  },
})
