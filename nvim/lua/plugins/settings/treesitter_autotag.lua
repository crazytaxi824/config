local status_ok, autotag = pcall(require, "nvim-ts-autotag")
if not status_ok then
  return
end

-- `:help nvim-ts-autotag-setup`
-- VVI: `nvim-ts-autotag` will not work unless you have treesitter parsers (like `html`) installed
autotag.setup({
  opts = {
    -- Defaults
    enable_close = true, -- Auto close tags
    enable_rename = true, -- Auto rename pairs of tags
    enable_close_on_slash = false -- Auto close on trailing </
  },
  -- override individual filetype configs, these take priority.
  per_filetype = {
    ["html"] = {
      enable_close_on_slash = true,
    }
  }
})



