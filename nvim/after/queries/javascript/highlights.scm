; extends
;;; `:help treesitter-predicates`

;;; 定义 class Foo {...} 后, const foo = new Foo() 作为一个 type 而不是 constructor.
(variable_declarator value: (new_expression constructor: ((identifier) @type )))

;;; 'this' keyword
(member_expression object: ((this) @keyword))

;;; TODO: const foo = "bar" 定义为 @constant 而不是 @variable

