-- 设置 lsp config
local lsp_update_config = require("lsp.lsp_config.update_config")
local utils = require("lsp.project_local_settings.utils")
local lsp_keymaps = require("lsp.lsp_keymaps")
local ms = vim.lsp.protocol.Methods

-- 获取 lsp 列表
local lsp_servers_map = require('lsp.svr_list').list

-- 读取 & cache local_settings files
lsp_update_config.reload_local_settings()

-- setup 所有 lsp config
for lsp_tool, _ in pairs(lsp_servers_map) do
  lsp_update_config.lspconfig_setup(lsp_tool)
end

-- 启动所有 lsp
vim.lsp.enable(vim.tbl_keys(lsp_servers_map))

-- `set filetype=xxx` 时 detach previous LSP.
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"*"},
  callback = function(args)
    local lsp_clients = vim.lsp.get_clients({ bufnr = args.buf })
    for _, c in ipairs(lsp_clients) do
      -- `set filetype` 后, detach 所有不匹配该 buffer 新 filetype 的 lsp client.
      -- NOTE: 排除 null-ls
      if c.name ~= 'null-ls'
        and not vim.tbl_contains(c.config['filetypes'] or {}, vim.bo[args.buf].filetype)
      then
        vim.lsp.buf_detach_client(args.buf, c.id)
      end
    end
  end,
  desc = "LSP: detach previous LSP when `set filetype=xxx`",
})

-- restart lsp when ".nvim/lsp.json" changes
local lsp_gid = vim.api.nvim_create_augroup("my_lsp_settings", {clear=true})
-- reload local lsp settings
vim.api.nvim_create_autocmd({'BufWritePost'}, {
  group = lsp_gid,
  pattern = { "**/" .. utils.lsp_file },
  callback = function(args)
    if vim.fs.abspath(args.file) == utils.find_local_settings_file(utils.lsp_file) then
      local old = lsp_update_config.exist_local_settings()
      if not lsp_update_config.reload_local_settings() then
        return
      end
      local new = lsp_update_config.exist_local_settings()

      local tools = utils.find_diff_tool(old, new)
      lsp_update_config.restart_lsps(tools)
    end
  end,
  desc = "reload local settings when '.nvim/lsp.json' changed",
})


vim.api.nvim_create_autocmd({'LspAttach'}, {
  group = lsp_gid,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    -- keymap setup
    lsp_keymaps.diagnostic_keymaps(args.buf)
    lsp_keymaps.textDocument_keymaps(args.buf)

    -- documentHighlight setup
    if client:supports_method(ms.textDocument_documentHighlight, args.buf) then
      require("lsp.custom_requests.doc_highlight").setup(client, args.buf)
    end
  end,
  desc = "LSP: set lsp keymaps",
})


-- schema for json, toml, yaml
vim.api.nvim_create_user_command("Schema", function(params)
  local ft = params.args:lower()
  if ft == 'json' then
    vim.notify('{ "$schema": "https://www.schemastore.org/xxx" }')
  elseif ft == 'toml' then
    vim.notify('# #:schema = "https://www.schemastore.org/xxx"')
  elseif ft == 'yaml' then
    vim.notify('# yaml-language-server: $schema=https://www.schemastore.org/xxx')
  else
    vim.notify("filetype: '" .. ft .. "' schema is not avaliable", vim.log.levels.WARN)
  end
end, {
  nargs = 1,
  bang = true,
  bar = true,
  desc = "Schema: modeline examples",
  complete = function()
    return { "json", "toml", "yaml" }
  end,
})



