--- Events 触发顺序:
---   BufNew       -- Just after creating a new buffer. `:e` 第一次打开 buffer 时触发.
                   -- `:bwipeout` 彻底删除 buffer 后再加载 buffer 时也会触发.
---   BufAdd       -- Just after creating a new buffer which is added to the buffer list.
                   -- 在第一次打开 buffer & unlisted => listed 时触发. `:bdelete` 执行 unlist buffer.
---   BufReadPre   -- before reading the file into the buffer.
---   BufReadPost  -- after reading the file into the buffer. before processing modelines.
---   FileType
---   BufEnter     -- After entering a buffer.
---   BufWinEnter  -- After a buffer is displayed in a window.
---   VimEnter     -- After doing all the startup stuff, including loading vimrc files, executing the "-c cmd"
                   -- arguments, creating all windows and loading the buffers in them.

--- NOTE: 加载别的 buffer, 当前 buffer 进入 hidden 状态的情况.
---   BufLeave     -- Before leaving to another buffer.
---   BufWinLeave  -- Before a buffer is removed from a window.

--- NOTE: bdelete/bwipeout 的情况, 前两个是 bdelete 的情况.
---   BufUnload
---   BufDelete
---   BufWipeout

--- VVI:
---   FileType 在 buffer 第一次加载到 window 中的时候触发; `:bdelete` 后再次加载 buffer 的情况下也会触发.
---   BufEnter 每次 buffer 切换的时候. FileType 触发的情况 & hidden -> display 的时候.

if __Debug_Neovim.autocmd_events then
  local common_events = {
    "VimEnter", "VimLeave",
    "BufAdd", "BufNew", "BufNewFile",
    "BufEnter", "BufLeave",
    "BufReadPre", "BufReadPost", "BufWritePre", "BufWritePost", "BufFilePre", "BufFilePost",
    "BufHidden", "BufDelete", "BufUnload", "BufWipeout",
    "BufWinEnter", "BufWinLeave",
    "WinNew", "WinEnter", "WinLeave", "WinClosed",
    "FileType",
  }

  vim.api.nvim_create_autocmd(common_events, {
    pattern = {"*"},
    -- once = true,
    callback = function(params)
      print(params.buf, params.event)
    end
  })
end



