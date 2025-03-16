; extends
;;; `:help treesitter-predicates`

;;; 将 "literal_type" 中的 null | undefined 显示为 @type
;;; 其他地方的 null | undefined 还是显示为 @constant.builtin | @variable.builtin
(type_alias_declaration value: (union_type (literal_type [(null) (undefined)] @type)))

;;; 定义 class Foo {...} 后, const foo = new Foo() 作为一个 type 而不是 constructor.
;(variable_declarator value: (new_expression constructor: ((identifier) @type )))

;;; 'this' keyword
((this) @keyword)

;;; 'super'
((super) @keyword)
