--- Events 触发顺序:
---   VimEnter     -- After doing all the startup stuff, including loading vimrc files, executing the "-c cmd"
                   -- arguments, creating all windows and loading the buffers in them.
---   BufNew       -- Just after creating a new buffer. `:e` 第一次打开 buffer 时触发.
                   -- `:bwipeout` 彻底删除 buffer 后再加载 buffer 时也会触发.
---   BufAdd       -- Just after creating a new buffer which is added to the buffer list.
                   -- 在第一次打开 buffer & unlisted => listed 时触发. `:bdelete` 执行 unlist buffer.
---
--- 读取文件时按顺序触发:
---   BufReadPre   -- before reading the file into the buffer.
---   FileType
---   BufReadPost  -- after reading the file into the buffer. before processing modelines.
---
---   BufLeave     -- cursor 离开 buffer 所在 window.
---   BufEnter     -- cursor 进入 buffer 所在 window.
---   BufWinLeave  -- VVI: buffer 离开最后一个 window 时, 即: buffer 进入 hidden 状态时触发. 可以使用 BufHidden 代替.
---                -- 多个 window 显示同一个 buffer 的情况下, 该 buffer 离开最后一个显示它的 window 时才会触发.
---   BufWinEnter  -- 每次有 window 显示某个 buffer 时触发.
---                -- buffer 在已经被某个 window 显示的情况下, 即: active (hidden=0) 状态下, 被其他 window 显示时也触发.

--- NOTE: bdelete/bwipeout 的情况, 前两个是 bdelete 的情况.
---   BufUnload  -- bdelete 触发
---   BufDelete  -- bdelete 触发
---   BufWipeout -- bwipeout 触发
---
--- terminal:
---   TermOpen:  when job is starting
---   TermClose: when job done/end
---   TermEnter: after Terminal-Insert Mode
---   TermLeave: after Terminal-Normal Mode

--- VVI:
---   FileType 在 buffer 第一次加载到 window 中的时候触发; `:bdelete` 后再次加载 buffer 的情况下也会触发.
---   BufEnter 每次 buffer 切换的时候. FileType 触发的情况 & hidden -> display 的时候.

local autocmd_id

local function debug_autocmd_toggle()
  local common_events = {
    "VimEnter", "VimLeave",
    "BufAdd", "BufNew", "BufNewFile",
    "BufEnter", "BufLeave",
    "BufReadPre", "BufReadPost", "BufWritePre", "BufWritePost", "BufFilePre", "BufFilePost",
    "BufHidden", "BufDelete", "BufUnload", "BufWipeout",
    "BufWinEnter", "BufWinLeave",
    "WinNew", "WinEnter", "WinLeave", "WinClosed",
    "FileType",

    "TermOpen", "TermEnter", "TermLeave", "TermClose", "TermResponse",
  }

  if autocmd_id then
    vim.api.nvim_del_autocmd(autocmd_id)
    autocmd_id = nil
  else
    autocmd_id = vim.api.nvim_create_autocmd(common_events, {
      pattern = {"*"},
      -- once = true,
      callback = function(params)
        print(vim.api.nvim_get_current_win(), params.buf, params.event, params.file)
      end,
      desc = "autocmd debug",
    })
  end
end

vim.api.nvim_create_user_command("AutocmdDebugToggle", function()
    debug_autocmd_toggle()
  end,
  {
    bang=true,
    bar=true,
    desc = 'toggle autocmd debug function, print all events.'
  }
)

