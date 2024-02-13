; extends
;;; `:help treesitter-predicates`

; 将 VVI 加入到 warning
((tag
  (name) @comment.warning @nospell
  ("(" @punctuation.bracket (user) @constant ")" @punctuation.bracket)?
  ":" @punctuation.delimiter)
  (#any-of? @comment.warning "VVI"))

("text" @comment.warning @nospell
 (#any-of? @comment.warning "VVI"))

; 将 README 加入到 note
((tag
  (name) @comment.note @nospell
  ("(" @punctuation.bracket (user) @constant ")" @punctuation.bracket)?
  ":" @punctuation.delimiter)
  (#any-of? @comment.note "README"))

("text" @comment.note @nospell
 (#any-of? @comment.note "README"))



