; extends
;;; `:help treesitter-predicates`

; VVI: @comment.warning, (|xxx|) @constant, ":" @punctuation.delimiter.comment
; VVI(message): comment
((tag
  (name) @comment.warning @nospell
  ("(" @punctuation.bracket.comment (user) @constant ")" @punctuation.bracket.comment)?
  ":" @punctuation.delimiter.comment)
  (#any-of? @comment.warning "VVI" "DEPRECATED"))

; VVI 加入到 @comment.warning
("text" @comment.warning @nospell
 (#any-of? @comment.warning "VVI" "DEPRECATED"))



