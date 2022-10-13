vim.filetype.add({
  extension = {
    json = "jsonc",
    sh = "sh",  -- shell 文件. 如果没有这个定义, #!/bin/zsh 等文件的 filetype 会变成 zsh.
  },
  filename = {
    ["go.mod"] = "gomod",
    ["go.sum"] = "gosum",
    ["go.work"] = "gowork",
  },
})
