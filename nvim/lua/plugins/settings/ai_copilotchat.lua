--- https://github.com/jellydn/lazy-nvim-ide/blob/main/lua/plugins/extras/copilot-chat-v2.lua

local chat_ok, chat = pcall(require, "CopilotChat")
if not chat_ok then
  return
end

local chat_select_ok, select = pcall(require, "CopilotChat.select")
if not chat_select_ok then
  return
end

local prompts = {
  --- VVI: 所有自定义的 prompts 都会自动创建一个 command, eg: "Foo" -> "CopilotChatFoo"
  -- Foo = "Foo",

  --- Code related prompts
  Explain = "Please explain how the following code works.",
  Review = "Please review the following code and provide suggestions for improvement.",
  Tests = "Please explain how the selected code works, then generate unit tests for it.",
  Refactor = "Please refactor the following code to improve its clarity and readability.",
  FixCode = "Please fix the following code to make it work as intended.",
  FixError = "Please explain the error in the following code and provide a solution.",
  BetterNamings = "Please provide better names for the following variables and functions.",
  Documentation = "Please provide documentation for the following code.",
  -- SwaggerApiDocs = "Please provide documentation for the following API using Swagger.",
  -- SwaggerJsDocs = "Please write JSDoc for the following API using Swagger.",

  --- Text related prompts
  Summarize = "Please summarize the following text.",
  Correct = "Please correct any grammar and spelling errors in the following text.",
  Improve = "Please improve the grammar and wording of the following text.",
  Simplify = "Please rewrite the following text to make it more concise.",
}

chat.setup {
  -- show_folds = false, -- foldcolumn = '1' & foldmethod = 'expr'
  question_header = "## User ",
  answer_header = "## Copilot ",
  error_header = "## [ERROR!] ",
  prompts = prompts,
  -- model = "claude-3.7-sonnet",
  mappings = {
    -- Use tab for completion
    complete = {
      detail = "Use @<Tab> or /<Tab> for options.",
      insert = "<Tab>",
    },
    -- Close the chat
    close = {
      normal = "q",
      insert = "<C-c>",
    },
    -- Reset the chat buffer
    reset = {
      normal = "<C-x>",
      insert = "<C-x>",
    },
    -- Submit the prompt to Copilot
    submit_prompt = {
      normal = "<CR>",
      insert = "<D-CR>",
    },
    -- Accept the diff
    accept_diff = {
      normal = "<C-y>",
      insert = "<C-y>",
    },
    -- Show help
    show_help = {
      normal = "?",
    },
  },
}

--- commands ---------------------------------------------------------------------------------------
--- Open new window, chat for visual selected
vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
  chat.ask(args.args, { selection = select.visual })
end, { nargs = "*", range = true })

-- Inline chat with Copilot
vim.api.nvim_create_user_command("CopilotChatInline", function(args)
  chat.ask(args.args, {
    selection = select.visual,
    window = {
      layout = "float",
      relative = "cursor",
      width = 1,
      height = 0.4,
      row = 1,
    },
  })
end, { nargs = "*", range = true })

-- Restore CopilotChatBuffer
vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
  chat.ask(args.args, { selection = select.buffer })
end, { nargs = "*", range = true })

--- keymaps ----------------------------------------------------------------------------------------




