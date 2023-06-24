--- regexp pattern for filepath and URL in terminal.

local M = {}

--- VVI: vim `:h pattern-overview` 中使用双引号和单引号是不一样的. 单引号 '\(\)\+' 在双引号中需要写成 "\\(\\)\\+"
--- regex: (ipfs:|ipns:|magnet:|mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:)
---   '\f' - isfname, 表示可用于 filename 的字符/数字/符号...
---   '\<' - beginning of a word
---   '\+' - 1~n
---   '\?' - 0~1
---   '\{0,2}' - 0~2

--- 'file:///abc/def.txt', 'file://~/abc/def.txt', 'file://./abc/def.txt'
M.file_schema_pattern = '\\<file://' -- file://
  .. '[~.]\\?/'  -- '~/' | './' | '/'
  .. '\\f\\+'  -- filename 可以用字符. '\+' 表示至少有一个字符.
  .. '\\(:[0-9]\\+\\)\\{0,2}'  -- ':num:num' | ':num' | '' (空)

--- '/a/b/c', '~/a/b/c', './a/b/c'
M.filepath_pattern = '\\(^\\|\\s\\|\\[\\|<\\|{\\|(\\)\\@<='  -- '^' | whitespace | '(' | '[' | '{' | '<' 开头
  .. '[~.]\\?/'  -- '~/' | './' | '/'
  .. '\\f\\+'  -- filename 可以用字符. '\+' 表示至少有一个字符.
  .. '\\(:[0-9]\\+\\)\\{0,2}'  -- ':num:num' | ':num' | '' (空)

--- 'http://' | 'https://'
M.url_schema_pattern = '\\<http[s]\\?://'  -- 'http://' | 'https://' 开头
  .. '\\f\\+'  -- filename 可以用字符. eg: 'www.abc.com'
  .. '\\(:[0-9]\\+\\)\\?' -- port, eg: ':80'
  .. '[/]\\?'
  .. '\\(?\\f\\+\\(&\\f\\+\\)*\\)\\?'  -- '/?foo=fuz&bar=buz'

return M
