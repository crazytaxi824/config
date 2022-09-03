--- key-settings for both vim.keymap.set() and which_key.register() --------------------------------
--- keymap_list: { mode, key, remap, opt, description }  - description for 'which-key'
--- keys_desc_only: which_key.register({keymap},{opts}) 中的两个入参. 用于只注册到 which-key 中显示, 而不用真的 keymap.
function Keymap_set_and_register(keymap_list, keys_desc_only)
  --- NOTE: 这里是正真设置 keymap 的地方, 下面的 which-key 如果不存在, 也不会影响 keymap 设置.
  for _, keymap in ipairs(keymap_list) do
    vim.keymap.set(keymap[1], keymap[2], keymap[3], keymap[4])
  end

  --- NOTE: which-key 主要是起到显示 description 的作用.
  local wk_status_ok, which_key = pcall(require, "which-key")
  if not wk_status_ok then
    return
  end

  --- NOTE: 参考 which_key.register({keymap},{opts}) 设置
  --- https://github.com/folke/which-key.nvim#%EF%B8%8F-mappings
  for _, keymap in ipairs(keymap_list) do
    if keymap[5] then
      which_key.register({[keymap[2]] = keymap[5]},{mode = keymap[1]})
    end
  end

  --- set group name manually ---
  --- 如果 opts 为 nil, 则使用默认值 --- {{{
  -- {
  --   mode = "n", -- NORMAL mode
  --   -- prefix: use "<leader>f" for example for mapping everything related to finding files
  --   -- the prefix is prepended to every mapping part of `mappings`
  --   prefix = "",
  --   buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  --   silent = true, -- use `silent` when creating keymaps
  --   noremap = true, -- use `noremap` when creating keymaps
  --   nowait = false, -- use `nowait` when creating keymaps
  -- }
  -- -- }}}
  if keys_desc_only and keys_desc_only.key_desc then
    which_key.register(keys_desc_only.key_desc, keys_desc_only.opts)
  end
end



