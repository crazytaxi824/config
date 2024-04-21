; extends
;;; `:help treesitter-predicates`

;;; 给 go struct 添加 private field 属性和颜色, eg: type Foo struct { bar string } 中的 bar (第一个字母是 lower case).
;;; 可以通过 `:InspectTree` 查看 node 属性, 得到 field_identifier | field_declaration ...
;;; 如果 "field_declaration" 中的 "name: field_identifier" 名字不是 Capital letter 开头, 则定义为 @property.private,
;;; NOTE: eg: type T struct { A, a, _a, 你好 string }, 其中 a, _a, 你好 都是私有属性, 无法在 package 外使用.
;;; 需要在 colors.lua 中定义 @property.private 颜色.
(field_declaration name: ((field_identifier) @property.private
  (#lua-match? @property.private "^[^A-Z]")))

(keyed_element (literal_element (identifier) @property.private
  (#lua-match? @property.private "^[^A-Z]")))

;;; 调用 private field 时的颜色, foo.bar 中的 bar.
(selector_expression field: ((field_identifier) @property.private
  (#lua-match? @property.private "^[^A-Z]")))

;;; TODO: fmt format verbs, eg: %s %d ... https://github.com/tree-sitter/tree-sitter-go/pull/88

