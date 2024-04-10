- `:help fold-expr` foldexpr 折叠规则.

- `foldexpr(v:lnum)` 是按照 0, 1, 1, 2, 3 ... 等标记来 Fold 的.

- 可以通过 `foldlevel(lnum)` 检查 foldexpr 的标记.

- 重新设置 `:set foldmethod=expr` 和 `:set foldexpr` 都会导致 foldexpr() 重新计算.

- 同时设置 `:set foldmethod=expr` 和 `:set foldexpr` foldexpr() 也只会计算一次, 不会重复计算.

- `foldexpr` 是一个 local to window 的 option, 但是 window 加载不同 buffer 的时候, foldexpr 是随着 buffer 不同而不同的.

