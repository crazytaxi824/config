; extends
;;; `:help treesitter-predicates`

;;; 将 "literal_type" 中的 null | undefined 显示为 @type
;;; 其他地方的 null | undefined 还是显示为 @constant.builtin | @variable.builtin
(literal_type [(null) (undefined)] @type)

