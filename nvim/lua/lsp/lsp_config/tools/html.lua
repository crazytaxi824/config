--- 具体设置可以看 :Mason 中 "html-lsp" 的设置.
return {
  settings = {
    html = {
      validate = {
        scripts = true,  -- 默认为 true.
        styles = false,  -- 检查 html DOM 中的 style 时 <div style="">, lsp 报错.
      },
    },
  },
}
