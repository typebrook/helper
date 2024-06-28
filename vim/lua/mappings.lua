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

vim.keymap.set("n", "<leader>F", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "format files" })

-- global lsp mappings
vim.keymap.set("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "lsp diagnostic loclist" })

-- nvimtree
vim.keymap.set("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })

-- telescope
vim.keymap.set("n", "<leader>f", "<cmd>Telescope oldfiles<CR>", { desc = "telescope find oldfiles" })
vim.keymap.set("n", "<leader>b", "<cmd>Telescope buffers<CR>", { desc = "telescope find buffers" })
vim.keymap.set("n", "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<CR>",
  { desc = "telescope find in current buffer" })
vim.keymap.set("n", "<leader>sf", "<cmd>Telescope find_files<cr>", { desc = "telescope find files" })
vim.keymap.set("n", "<leader>sF", "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
  { desc = "telescope find all files" })
vim.keymap.set("n", "<leader>sg", "<cmd>Telescope live_grep<CR>", { desc = "telescope live grep" })

vim.keymap.set("n", "<leader>gf", "<cmd>Telescope git_files<CR>", { desc = "telescope git files" })
vim.keymap.set("n", "<leader>sH", "<cmd>Telescope help_tags<CR>", { desc = "telescope help page" })
vim.keymap.set("n", "<leader>tt", ":Telescope ", { desc = "telescope help page" })
vim.keymap.set('n', '<leader>sk', "<cmd>Telescope keymaps<CR>", { desc = 'telescope keymaps' })
vim.keymap.set("n", "<leader>pt", "<cmd>Telescope terms<CR>", { desc = "telescope pick hidden term" })

vim.keymap.set('n', '<leader>ss', function()
  local current_filetype = vim.bo.filetype
  local cwd = os.getenv("HOME") .. '/snippets'
  require('telescope.builtin').find_files {
    prompt_title = 'Select a snippet for ' .. current_filetype,
    default_text = current_filetype .. "_",
    cwd = cwd,
    attach_mappings = function(prompt_bufnr, map)
      local insert_selected_snippet = function()
        local file = require('telescope.actions.state').get_selected_entry()[1]
        local snippet_content = vim.fn.readfile(cwd .. "/" .. file)
        require('telescope.actions').close(prompt_bufnr)
        vim.api.nvim_put(snippet_content, '', false, true)
      end
      local edit_selected_snippet = function()
        local file = require('telescope.actions.state').get_selected_entry()[1]
        require('telescope.actions').close(prompt_bufnr)
        vim.cmd(":e " .. cwd .. "/" .. file)
      end

      map('i', '<CR>', insert_selected_snippet)
      map('i', '<C-T>', edit_selected_snippet)
      map('n', '<CR>', insert_selected_snippet)

      return true
    end,
  }
end, { desc = '[S]earch [S]nippets' })

vim.keymap.set('n', '<leader>sd', function()
  require('telescope.builtin').oldfiles {
    prompt_title = 'CD to',
    attach_mappings = function(prompt_bufnr, map)
      local cd_to_dir = function()
        local file = require('telescope.actions.state').get_selected_entry()[1]
        local path = string.match(file, "(.*[/\\])")
        require('telescope.actions').close(prompt_bufnr)
        vim.cmd("cd " .. path)
        vim.cmd("pwd")
      end

      map('i', '<CR>', cd_to_dir)
      map('n', '<CR>', cd_to_dir)

      return true
    end,
  }
end, { desc = 'Search Directory' })

vim.keymap.set('n', '<leader>sn', function()
  local current_filetype = vim.bo.filetype
  vim.ui.input({ prompt = 'Snippet Name: ', default = current_filetype .. "_"  }, function(snippet)
    vim.cmd("cd ~/snippets")
    vim.cmd("e " .. snippet)
    vim.cmd("set filetype=" .. current_filetype)
    vim.cmd("set filetype?")
  end)
end, { desc = "Create a new snippet" })


-- map("n", "<leader>ma", "<cmd>Telescope marks<CR>", { desc = "telescope find marks" })
-- map("n", "<leader>cm", "<cmd>Telescope git_commits<CR>", { desc = "telescope git commits" })
-- map("n", "<leader>gt", "<cmd>Telescope git_status<CR>", { desc = "telescope git status" })

-- terminal
-- map("t", "<C-x>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })

-- new terminals
vim.keymap.set("n", "<leader><leader>h", function() require("nvchad.term").new { pos = "sp" } end, { desc = "terminal new horizontal term" })
vim.keymap.set("n", "<leader>v", function() require("nvchad.term").new { pos = "vsp" } end, { desc = "terminal new vertical window" })
-- toggleable
vim.keymap.set({ "n", "t" }, "<A-v>", function() require("nvchad.term").toggle { pos = "vsp", id = "vtoggleTerm" } end, { desc = "terminal toggleable vertical term" })
vim.keymap.set("t", "<C-x>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })
vim.keymap.set({ "t" }, "<A-e>", "<C-\\><C-N><C-W>|<C-W>_i", { desc = "terminal toggleable vertical term" })
vim.keymap.set({ "n", "t" }, "<A-t>", function() require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" } end, { desc = "terminal new horizontal term" })
vim.keymap.set({ "n", "t" }, "<A-i>", function() require("nvchad.term").toggle { pos = "float", id = "floatTerm" } end, { desc = "terminal toggle floating term" })
vim.keymap.set("n", "<leader>th", "<cmd>Telescope themes<CR>", { desc = "telescope nvchad themes" })

-- whichkey
vim.keymap.set("n", "<leader>wK", "<cmd>WhichKey <CR>", { desc = "whichkey all keymaps" })

vim.keymap.set("n", "<leader>wk", function()
  vim.cmd("WhichKey " .. vim.fn.input "WhichKey: ")
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

-- [[ Configure Obsidian.nvim ]]
vim.keymap.set('n', "<leader>oo", ':Obsidian')
vim.keymap.set('n', "<leader>ot", ':ObsidianTags<CR>')
vim.keymap.set('n', "<leader>os", ':ObsidianSearch<CR>')
vim.keymap.set('n', "<leader>oq", ':ObsidianQuickSwitch<CR>')
vim.keymap.set('v', "<leader>on", ':ObsidianLinkNew<CR>')
vim.keymap.set('n', "<leader>ol", ':ObsidianLinks<CR>')

-- vim.cmd("let g:mkdp_browser = 'surf'")
vim.cmd("let g:mkdp_browser = 'firefox'")
vim.g.mkdp_preview_options = {
  mkit = { breaks = true },
  toc = {
    containerClass = "toc",
    format = 'function format(x, htmlencode) { return `<span>${htmlencode(x)}</span>`; }',
    callback = "console.log('foo')",
  }
}

-- [ Configure Hop ]
vim.keymap.set('n', "<space>", ':HopWord<CR>')
vim.keymap.set('n', '<C-.>', ':HopChar1<CR>')

-- [ Configure vim-surround ]
vim.cmd('vmap s S')

-- [ Aerial ]
vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", {})
vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", {})
vim.keymap.set("n", "gN", "<cmd>Telescope aerial<CR>")
vim.keymap.set("n", "gn", function() require("aerial").toggle({ direction = "left" }) end)
