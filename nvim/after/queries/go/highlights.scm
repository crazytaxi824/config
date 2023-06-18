; extends
;;; `:help treesitter-predicates`

;;; 给 go struct 添加 private field 属性和颜色, eg: type Foo struct { bar string } 中的 bar (第一个字母是 lower case).
;;; 可以通过 `:TSPlaygroundToggle` 查看 node 属性, 得到 field_identifier | field_declaration ...
;;; 如果 "field_declaration" 中的 "name: field_identifier" 名字是小写开头, 则定义为 @field.private,
;;; NOTE: 需要在 colors.lua 中定义 @field.private 颜色.
(field_declaration name: ((field_identifier) @field.private
  (#lua-match? @field.private "^[a-z]")))

;;; 调用 private field 时的颜色, foo.bar 中的 bar.
; (selector_expression field: ((field_identifier) @field.private
;   (#lua-match? @field.private "^[a-z]")))

;;; TODO: fmt format verbs, eg: %s %d ... https://github.com/tree-sitter/tree-sitter-go/pull/88

