; extends
;;; `:help treesitter-predicates`

;;; go struct private field
;;; 如果 field_declaration 中的 field_identifier 名字是小写开头, 则定义为 @field.private,
;;; 需要在 colors.lua 中定义 @field.private 颜色.
;;; type Foo struct { bar string } 中的 bar.
(field_declaration name: ((field_identifier) @field.private
  (#lua-match? @field.private "^[a-z]")))

;;; 调用 private field 时的颜色, foo.bar 中的 bar.
; (selector_expression field: ((field_identifier) @field.private
;   (#lua-match? @field.private "^[a-z]")))

;;; TODO: fmt format verbs, https://github.com/tree-sitter/tree-sitter-go/pull/88

