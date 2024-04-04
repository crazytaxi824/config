- `:help fold-expr` foldexpr 折叠规则.

- `foldexpr(v:lnum)` 是按照 0, 1, 1, 2, 3 ... 等标记来 Fold 的.

- 可以通过 `foldlevel(lnum)` 检查 foldexpr 的标记.

- 重新设置 `:set foldmethod=expr` 和 `:set foldexpr` 都会导致 foldexpr() 重新计算.



