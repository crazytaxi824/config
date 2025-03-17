; extends
;;; `:help treesitter-predicates`

; 将 VVI 加入到 warning
((tag
  (name) @comment.warning @nospell
  ("(" @punctuation.bracket (user) @constant ")" @punctuation.bracket)?
  ":" @punctuation.delimiter)
  (#any-of? @comment.warning "VVI" "DEPRECATED"))

("text" @comment.warning @nospell
 (#any-of? @comment.warning "VVI" "DEPRECATED"))



