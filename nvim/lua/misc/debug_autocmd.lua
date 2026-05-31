-- Events 触发顺序: ------------------------------------------------------------------------------- {{{
--   VimEnter     -- After doing all the startup stuff, including loading vimrc files, executing the "-c cmd"
                   -- arguments, creating all windows and loading the buffers in them.
--   BufNew       -- Just after creating a new buffer. `:e` 第一次打开 buffer 时触发.
                   -- `:bwipeout` 彻底删除 buffer 后再加载 buffer 时也会触发.
--   BufAdd       -- Just after creating a new buffer which is added to the buffer list.
                   -- 在第一次打开 buffer & unlisted => listed 时触发. `:bdelete` 执行 unlist buffer.
--
-- 读取文件时按顺序触发:
--   BufReadPre   -- before reading the file into the buffer.
--   FileType     -- VVI: 如果文件的 filetype 无法被识别, 则不会触发. eg: 'log'
--   BufReadPost  -- after reading the file into the buffer. before processing modelines.
--
-- buffer
--   BufLeave     -- cursor 离开 buffer 所在 window.
--   BufEnter     -- cursor 进入 buffer 所在 window.
--   BufWinLeave  -- VVI: buffer 离开最后一个 window 时, 即: buffer 进入 hidden 状态时触发.
--                -- 多个 window 显示同一个 buffer 的情况下, 该 buffer 离开最后一个显示它的 window 时才会触发.
--   BufWinEnter  -- 每次有 window 显示某个 buffer 时触发.
--                -- buffer 在已经被某个 window 显示的情况下, 即: active (hidden=0) 状态下, 被其他 window 显示时也触发.

-- write / save file:
--   BufWritePre   -- before write to file
--   BufWritePost  -- after write to file

-- change file name:
--   BufFilePre   -- before change file name
--   BufFilePost  -- after change file name

-- NOTE: bdelete/bwipeout 的情况, 前两个是 bdelete 的情况.
--   BufUnload  -- bdelete 触发
--   BufDelete  -- bdelete 触发
--   BufWipeout -- bwipeout 触发
--
-- terminal:
--   TermOpen:  when job is starting
--   TermClose: when job done/end
--   TermEnter: after Terminal-Insert Mode
--   TermLeave: after Terminal-Normal Mode
-- }}}
-- VVI:
--   FileType 在 buffer 第一次加载到 window 中的时候触发; `:bdelete` 后再次加载 buffer 的情况下也会触发.
--   BufEnter 每次 buffer 切换的时候. FileType 触发的情况 & hidden -> display 的时候.

---@type integer|nil
local augroup_id

local vim_events = { "VimEnter", "VimLeave", "VimLeavePre", "VimResized", "VimResume", "VimSuspend" }

local buf_events = {
  "BufAdd", "BufDelete",
  "BufEnter", "BufFilePre", "BufFilePost",
  "BufHidden", "BufLeave",
  "BufNew", "BufNewFile",
  "BufReadPre", "BufReadPost",
  "BufUnload", "BufWipeout",
  "BufWinEnter", "BufWinLeave",
  "BufWritePre", "BufWritePost",

  -- file events
  "FileType",
  "FileReadCmd", "FileReadPost", "FileReadPre",
  "FileWriteCmd", "FileWritePost", "FileWritePre",
}

local cmd_events = { "CmdUndefined", "CmdlineChanged", "CmdlineEnter", "CmdlineLeave", "CmdwinEnter", "CmdwinLeave" }

local cursor_events = { "CursorHold", "CursorHoldI", "CursorMoved", "CursorMovedI", "CursorMovedC" }

local win_events = { "WinNew", "WinEnter", "WinLeave", "WinClosed", "WinScrolled", "WinResized" }

local lsp_events = { "LspAttach", "LspDetach", "LspNotify", "LspProgress", "LspRequest", "LspTokenUpdate" }

local tab_events = { "TabEnter", "TabLeave", "TabNew", "TabNewEntered", "TabClosed" }

local term_events = { "TermOpen", "TermClose", "TermEnter", "TermLeave", "TermRequest", "TermResponse" }


---@param events string[]
local function debug_autocmd(events)
  if vim.list_contains(events, "off") then
    if augroup_id then
      vim.api.nvim_del_augroup_by_id(augroup_id)
      augroup_id = nil
    end

    vim.notify("debug autocmd events: Disabled")
    return
  end

  ---@type string[]
  local valid_events = {}
  if vim.list_contains(events, "all") then
    vim.list_extend(valid_events, buf_events)
    vim.list_extend(valid_events, win_events)
    vim.list_extend(valid_events, term_events)
    vim.list_extend(valid_events, vim_events)
    vim.list_extend(valid_events, cursor_events)
    vim.list_extend(valid_events, lsp_events)
    vim.list_extend(valid_events, tab_events)
    vim.list_extend(valid_events, cmd_events)
  else
    if vim.list_contains(events, "buf") or vim.list_contains(events, "buffer") or vim.list_contains(events, "file") then
      vim.list_extend(valid_events, buf_events)
    end

    if vim.list_contains(events, "win") or vim.list_contains(events, "window") then
      vim.list_extend(valid_events, win_events)
    end

    if vim.list_contains(events, "term") or vim.list_contains(events, "terminal") then
      vim.list_extend(valid_events, term_events)
    end

    if vim.list_contains(events, "cmd") or vim.list_contains(events, "command") then
      vim.list_extend(valid_events, cmd_events)
    end

    if vim.list_contains(events, "vim") then
      vim.list_extend(valid_events, vim_events)
    end

    if vim.list_contains(events, "cursor") then
      vim.list_extend(valid_events, cursor_events)
    end

    if vim.list_contains(events, "lsp") then
      vim.list_extend(valid_events, lsp_events)
    end

    if vim.list_contains(events, "tab") then
      vim.list_extend(valid_events, tab_events)
    end
  end

  if vim.tbl_isempty(valid_events) then
    vim.notify("command args: buf, win, cursor, vim, lsp, tab, term, cmd || all, off", vim.log.levels.WARN)
    return
  end

  -- 开启 autocmd
  augroup_id = vim.api.nvim_create_augroup('my_autocmd_debug', { clear = true })
  vim.api.nvim_create_autocmd(valid_events, {
    group = augroup_id,
    pattern = {"*"},
    callback = function(args)
      local curr = {
        curr_win = vim.api.nvim_get_current_win(),
        curr_buf = vim.api.nvim_get_current_buf(),
      }
      print(vim.json.encode(curr), vim.json.encode(args))
      if args.event == "VimLeave" then
        vim.fn.getchar()  -- pause neovim before VimLeave
      end
    end,
    desc = "autocmd debug",
  })
  vim.notify("debug autocmd events: Enabled")
end

-- `:AutocmdDebug all`, `:AutocmdDebug off`
-- `:AutocmdDebug buf`, `:AutocmdDebug buf win lsp`, ...
local user_cmd_name = "DebugAutocmd"
vim.api.nvim_create_user_command(user_cmd_name, function(params)
  -- params.args: string
  -- params.fargs: list
  debug_autocmd(params.fargs)
end,
{
  nargs = "*",
  bang=true,
  bar=true,
  desc = 'toggle autocmd debug function, print all events.',
  complete = function()
    return { 'buf', 'win', 'cursor', 'vim', 'lsp', 'tab', 'term', 'cmd', 'all', 'off' }
  end,
})

-- 启动时开启
if __Debug.autocmd then
  vim.cmd[user_cmd_name]({ args = { 'vim', 'win', 'buf', 'lsp' }})
end



