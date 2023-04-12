; extends

; 将 VVI 加入到 @text.warning
((tag
  (name) @text.warning @nospell
  ("(" @punctuation.bracket (user) @constant ")" @punctuation.bracket)?
  ":" @punctuation.delimiter)
  (#any-of? @text.warning "VVI"))

("text" @text.warning @nospell
 (#any-of? @text.warning "VVI"))

((tag
  (name) @text.note @nospell
  ("(" @punctuation.bracket (user) @constant ")" @punctuation.bracket)?
  ":" @punctuation.delimiter)
  (#any-of? @text.note "README"))

("text" @text.note @nospell
 (#any-of? @text.note "README"))



