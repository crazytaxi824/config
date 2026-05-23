; extends
;; `:help treesitter-predicates`

;; 提高 python @function.method.call 的 priority
;; 解决 sys.stdout.write() sys.stdout.flush() ... 函数被 'ty', 'pyrefly' 解析为 @lsp.type.variable 的问题
;; 'basedpyright' 不存在这个问题, 正确解析为: @lsp.type.method
(call
  function: (attribute
    attribute: (identifier) @function.method.call)
    (#set! "priority" 160))
