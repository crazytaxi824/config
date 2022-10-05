vim.filetype.add({
  extension = {
    json = "jsonc",
  },
  filename = {
    ["go.mod"] = "gomod",
    ["go.sum"] = "gosum",
    ["go.work"] = "gowork",
  },
})
