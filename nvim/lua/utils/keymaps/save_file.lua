--- save file prompt

local M = {}

M.save = function()
  local fname = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  if fname == '' then
    --- file not exist, prompt filename
    local prompt = "save to filename: "
    vim.ui.input({ prompt = prompt }, function(filename)
      if not filename or filename == '' then
        return
      end

      vim.cmd.write(filename) -- write file
    end)
  else
    vim.cmd.update()
  end
end

return M
