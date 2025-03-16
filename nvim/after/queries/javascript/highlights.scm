; extends
;;; `:help treesitter-predicates`

;;; 定义 class Foo {...} 后, const foo = new Foo() 作为一个 type 而不是 constructor.
;(variable_declarator value: (new_expression constructor: ((identifier) @type )))

;;; 'this' keyword
((this) @keyword)

;;; 'super'
((super) @keyword)
