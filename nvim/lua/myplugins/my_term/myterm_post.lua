--- 继承 MyTerm
--- @class MyTermPost: MyTerm
--- @field bufnr integer
--- @field job_id integer
local MyTermPost = setmetatable({}, { __index = require("myplugins.my_term.myterm") })  -- 继承 MyTerm
MyTermPost.__index = MyTermPost


--- @param myterm MyTerm
--- @param bufnr integer
--- @param job_id integer
--- @return MyTermPost
function MyTermPost.from(myterm, bufnr, job_id)
  --- @cast myterm MyTermPost
  myterm.bufnr = bufnr
  myterm.job_id = job_id

  --- @type MyTermPost
  local self = setmetatable(myterm, MyTermPost)
  return self
end

return MyTermPost
