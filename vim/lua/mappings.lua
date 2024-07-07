-- require "nvchad.mappings"

-- add yours here

vim.keymap.set("i", "jk", "<ESC>")
vim.keymap.set("n", "<leader>co", "<cmd>cd ~/.config/nvim<CR><cmd>pwd<CR>")
vim.cmd("command! W execute 'SudaWrite %'")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

vim.keymap.set("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })

-- map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "file copy whole" })

-- map("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "toggle line number" })
-- map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "toggle relative number" })
vim.keymap.set("n", "<leader>ch", "<cmd>NvCheatsheet<CR>", { desc = "toggle nvcheatsheet" })

-- global lsp mappings
vim.keymap.set("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "lsp diagnostic loclist" })

-- nvimtree
vim.keymap.set("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })

-- telescope
vim.keymap.set("n", "<leader>f", "<cmd>Telescope oldfiles<CR>", { desc = "telescope find oldfiles" })
vim.keymap.set("n", "<leader>b", "<cmd>Telescope buffers<CR>", { desc = "telescope find buffers" })
vim.keymap.set(
"n",
"<leader>/",
"<cmd>Telescope current_buffer_fuzzy_find<CR>",
{ desc = "telescope find in current buffer" }
)
vim.keymap.set("n", "<leader>sf", "<cmd>Telescope find_files<cr>", { desc = "telescope find files" })
vim.keymap.set(
"n",
"<leader>sF",
"<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
{ desc = "telescope find all files" }
)
vim.keymap.set("n", "<leader>sg", "<cmd>Telescope live_grep<CR>", { desc = "telescope live grep" })

vim.keymap.set("n", "<leader>gf", "<cmd>Telescope git_files<CR>", { desc = "telescope git files" })
vim.keymap.set("n", "<leader>sH", "<cmd>Telescope help_tags<CR>", { desc = "telescope help page" })
vim.keymap.set("n", "<leader>sm", "<cmd>Telescope marks<CR>", { desc = "telescope marks" })
vim.keymap.set("n", "<leader>sj", "<cmd>Telescope jumplist<CR>", { desc = "telescope marks" })
vim.keymap.set("n", "<leader>tt", "<cmd>Telescope<CR>", { desc = "telescope help page" })
vim.keymap.set("n", "<leader>sk", "<cmd>Telescope keymaps<CR>", { desc = "telescope keymaps" })
vim.keymap.set("n", "<leader>pt", "<cmd>Telescope terms<CR>", { desc = "telescope pick hidden term" })

vim.keymap.set("n", "<leader>ss", function()
  local current_filetype = vim.bo.filetype
  local cwd = os.getenv("HOME") .. "/snippets"
  require("telescope.builtin").find_files({
    prompt_title = "Press <C-T> to edit a snippet",
    default_text = current_filetype .. "_",
    cwd = cwd,
    attach_mappings = function(prompt_bufnr, map)
      local get_prompt_or_entry = function()
        local file_list = require("telescope.actions.state").get_selected_entry()
        if file_list then
          return file_list[1]
        else
          local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
          return current_picker:_get_prompt()
        end
      end

      local edit_snippet = function()
        local file = get_prompt_or_entry()
        require("telescope.actions").close(prompt_bufnr)
        local prefix_filetype = string.match(file, "([^_]+)")
        vim.cmd(":e " .. cwd .. "/" .. file)
        vim.bo.filetype = prefix_filetype
        vim.cmd("set filetype?")
      end

      local insert_selected_snippet = function()
        local file = get_prompt_or_entry()
        local path = cwd .. "/" .. file
        if vim.fn.filereadable(path) ~= 0 then
          local snippet_content = vim.fn.readfile(path)
          require("telescope.actions").close(prompt_bufnr)
          vim.fn.setreg('"', snippet_content)
          print("Snippet saved to register")
        else
          edit_snippet()
        end
      end

      map("i", "<CR>", insert_selected_snippet)
      map("i", "<C-T>", edit_snippet)
      map("n", "<CR>", insert_selected_snippet)

      return true
    end,
  })
end, { desc = "[S]earch [S]nippets" })

vim.keymap.set("n", "<leader>sd", function()
  require("telescope.builtin").oldfiles({
    prompt_title = "CD to",
    attach_mappings = function(prompt_bufnr, map)
      local cd_prompt = function()
        local file = require("telescope.actions.state").get_selected_entry()[1]
        local path = string.match(file, "(.*[/\\])")
        require("telescope.actions").close(prompt_bufnr)
        vim.api.nvim_feedkeys(":cd " .. path, "n", true)
      end

      map("i", "<CR>", cd_prompt)
      map("n", "<CR>", cd_prompt)

      return true
    end,
  })
end, { desc = "Search Directory" })

-- map("n", "<leader>ma", "<cmd>Telescope marks<CR>", { desc = "telescope find marks" })
-- map("n", "<leader>cm", "<cmd>Telescope git_commits<CR>", { desc = "telescope git commits" })
-- map("n", "<leader>gt", "<cmd>Telescope git_status<CR>", { desc = "telescope git status" })

-- terminal
-- map("t", "<C-x>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })

-- new terminals
vim.keymap.set("n", "<leader><leader>h", function()
  require("nvchad.term").new({ pos = "sp" })
end, { desc = "terminal new horizontal term" })
vim.keymap.set("n", "<leader>v", function()
  require("nvchad.term").new({ pos = "vsp" })
end, { desc = "terminal new vertical window" })
-- toggleable
vim.keymap.set({ "n", "t" }, "<A-v>", function()
  require("nvchad.term").toggle({ pos = "vsp", id = "vtoggleTerm" })
end, { desc = "terminal toggleable vertical term" })
vim.keymap.set("t", "<C-x>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })
vim.keymap.set({ "t" }, "<A-e>", "<C-\\><C-N><C-W>|<C-W>_i", { desc = "terminal toggleable vertical term" })
vim.keymap.set({ "n", "t" }, "<A-t>", function()
  require("nvchad.term").toggle({ pos = "sp", id = "htoggleTerm" })
end, { desc = "terminal new horizontal term" })
vim.keymap.set({ "n", "t" }, "<A-i>", function()
  require("nvchad.term").toggle({ pos = "float", id = "floatTerm" })
end, { desc = "terminal toggle floating term" })
vim.keymap.set("n", "<leader>th", "<cmd>Telescope themes<CR>", { desc = "telescope nvchad themes" })

-- whichkey
vim.keymap.set("n", "<leader>wK", "<cmd>WhichKey <CR>", { desc = "whichkey all keymaps" })

vim.keymap.set("n", "<leader>wk", function()
  vim.cmd("WhichKey " .. vim.fn.input("WhichKey: "))
end, { desc = "whichkey query lookup" })

-- blankline
vim.keymap.set("n", "<leader>cc", function()
  local config = { scope = {} }
  config.scope.exclude = { language = {}, node_type = {} }
  config.scope.include = { node_type = {} }
  local node = require("ibl.scope").get(vim.api.nvim_get_current_buf(), config)

  if node then
    local start_row, _, end_row, _ = node:range()
    if start_row ~= end_row then
      vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), { start_row + 1, 0 })
      vim.api.nvim_feedkeys("_", "n", true)
    end
  end
end, { desc = "blankline jump to current context" })

-- vim.cmd("let g:mkdp_browser = 'surf'")
vim.cmd("let g:mkdp_browser = 'firefox'")
vim.g.mkdp_preview_options = {
  mkit = { breaks = true },
  toc = {
    containerClass = "toc",
    format = "function format(x, htmlencode) { return `<span>${htmlencode(x)}</span>`; }",
      callback = "console.log('foo')",
    },
  }

  -- [ Configure Hop ]
  vim.keymap.set("n", "<space>", ":HopWord<CR>")
  vim.keymap.set("n", "<C-.>", ":HopChar1<CR>")

  -- [ Configure vim-surround ]
  vim.cmd("vmap s S")

  -- [ Aerial ]"" "<cmd>AerialNext<CR>", {})
  vim.keymap.set("n", "gL", "<cmd>Telescope aerial<CR>")
  vim.keymap.set("n", "gl", function()
    require("aerial").toggle({ direction = "left" })
  end)

  --[ TrunZen ]
  vim.keymap.set("n", "<leader>z", ":TZAtaraxis<CR>")

  vim.keymap.set("v", "<leader><leader>tz", function()
    vim.cmd('norm o^zt"ty')
    local translated_text = vim.fn.system("trans -t zh-TW -b", vim.fn.getreg("t"))
    local lines = vim.split(translated_text, "\n")
    table.remove(lines)

    local new_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(new_buf, 0, -1, true, lines)

    vim.api.nvim_open_win(new_buf, true, {
      relative = "cursor",
      width = 80,
      height = #lines,
      row = #lines,
      col = 0,
    })

    vim.cmd("setl nocul nonu nornu")
    vim.cmd("hi ActiveWindow guibg=#2a5a6a guifg=White | setl winhighlight=Normal:ActiveWindow")
    vim.cmd(':silent %s/\\%x1b\\[[0-9;]*m//g')
  end, { desc = "Description" })
