--- key-settings for both vim.keymap.set() and which_key.register() --------------------------------

local M = {}

--- cache key register for which-key
local keymap_cache = {}
local loaded_whichkey = 0

--- which_key register or cache keymap
local function wk_reg(key_reg)
  --- NOTE: which_key 已加载则直接 register; 如果 which_key 还没加载则缓存起来后面再 register.
  if loaded_whichkey == 1 then
    --- NOTE: which-key 主要是起到显示 description 的作用.
    --- 如果 keys_desc_only.opts == nil, 则 which_key 会使用默认值 ------------- {{{
    --- {
    ---   mode = "n", -- NORMAL mode
    ---   -- prefix: use "<leader>f" for example for mapping everything related to finding files
    ---   -- the prefix is prepended to every mapping part of `mappings`
    ---   prefix = "",
    ---   buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
    ---   silent = true, -- use `silent` when creating keymaps
    ---   noremap = true, -- use `noremap` when creating keymaps
    ---   nowait = false, -- use `nowait` when creating keymaps
    --- }
    -- -- }}}
    require("which-key").register(key_reg.key_desc, key_reg.opts)
  else
    --- cache key register for which-key lazy load.
    table.insert(keymap_cache, key_reg)
  end
end

--- NOTE: for which-key use only.
vim.api.nvim_create_autocmd("User", {
  pattern = {"LoadedWhichKey"},
  once = true,  -- VVI: 只用执行一次.
  callback = function(params)
    --- which_key loaded 后 register 所有 cache 的 keymaps.
    for _, key_reg in ipairs(keymap_cache) do
      require("which-key").register(key_reg.key_desc, key_reg.opts)
    end

    loaded_whichkey = 1  -- 记录 which_key is already loaded.
    keymap_cache = {}  -- 清空缓存.
  end,
  desc = "which-key: register cached keymaps"
})

--- keymap_list: { mode, key, rhs, opts, description }
--- key_reg: which_key.register({keymap},{opts}) 中的两个入参. 用于只注册到 which-key 中显示,
--- 而不用真的 set keymap.
M.keymap_set_and_register = function(keymap_list, key_reg)
  --- NOTE: 通过 nvim api 设置 keymap. 即使 which-key 不存在也不会影响 keymap 设置.
  for _, keymap in ipairs(keymap_list) do
    local opts = keymap[4] or {}
    local key_desc = {desc = keymap[5]} or {}

    --- opts add 'desc', which_key 会默认读取 desc 设置.
    opts = vim.tbl_deep_extend('error', opts, key_desc)

    vim.keymap.set(keymap[1], keymap[2], keymap[3], opts)
  end

  --- for which_key lazy load.
  if key_reg and key_reg.key_desc then
    wk_reg(key_reg)
  end
end

return M
