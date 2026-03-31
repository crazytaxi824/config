; extends
;;; `:help treesitter-predicates`

; `VVI`: @comment.warning, `()` @punctuation.bracket.comment , (`xxx`) @constant, `:` @punctuation.delimiter.comment
; VVI(message): comment
((tag
  (name) @comment.warning @nospell
  ("(" @punctuation.bracket (user) @constant ")" @punctuation.bracket)?
  ":" @punctuation.delimiter)
  (#any-of? @comment.warning "VVI" "DEPRECATED"))

; VVI 加入到 @comment.warning
("text" @comment.warning @nospell
 (#any-of? @comment.warning "VVI" "DEPRECATED"))



