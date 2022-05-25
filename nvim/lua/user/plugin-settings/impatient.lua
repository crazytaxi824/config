-- Perfomance plugin.
-- 会生成 ~/.cache/nvim/luacache_chunks & luacache_modpaths 两个缓存文件.
local status_ok, impatient = pcall(require, "impatient")
if not status_ok then
  return
end

impatient.enable_profile()
