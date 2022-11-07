; inherits: typescript
;;; NOTE: "; inherits typescript" 继承 nvim-treesitter 中 nvim-treesitter/queries/typescript/*

;;; literal_type 下如果是 null | undefined 则显示为 @type
;;; 其他地方的 null | undefined 还是显示为 @constant.builtin | @variable.builtin
(literal_type
  [(null) (undefined)] @type)

