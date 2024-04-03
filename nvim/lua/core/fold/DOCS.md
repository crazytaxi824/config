- 重新设置 `:set foldmethod=expr` 和 `:set foldexpr` 都会导致 foldexpr() 重新计算.

- `foldexpr(v:lnum)` 是按照 0, 1, >1, 2, 3 ... 等标记来 Fold 的.
