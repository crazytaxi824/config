--- `:help marks`
---  'a - 'z   lowercase marks, valid within one file.
---  'A - 'Z   uppercase marks, also called file marks, valid between files
---  '0 - '9   numbered marks, set from .shada file

--- delmakrs! 删除 buffer 中所有 marks, 除了 A-Z0-9
vim.cmd('command -bar DelAllMarks delmarks! | delmarks A-Z0-9')



