-- require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("i", "jk", "<ESC>")
vim.cmd("command! W execute 'SudaWrite %'")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })

-- map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "file copy whole" })

-- map("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "toggle line number" })
-- map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "toggle relative number" })
map("n", "<leader>ch", "<cmd>NvCheatsheet<CR>", { desc = "toggle nvcheatsheet" })

map("n", "<leader>F", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "format files" })

-- global lsp mappings
map("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "lsp diagnostic loclist" })

-- tabufline
map("n", "<tab>", function()
  require("nvchad.tabufline").next()
end, { desc = "buffer goto next" })

map("n", "<S-tab>", function()
  require("nvchad.tabufline").prev()
end, { desc = "buffer goto prev" })

map("n", "<leader>x", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "buffer close" })

-- Comment
map("n", "<leader>/", "gcc", { desc = "comment toggle", remap = true })
map("v", "<leader>/", "gc", { desc = "comment toggle", remap = true })

-- nvimtree
map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })
map("n", "<leader>nf", "<cmd>NvimTreeFocus<CR>", { desc = "nvimtree focus window" })

-- telescope
map("n", "<leader>f", "<cmd>Telescope oldfiles<CR>", { desc = "telescope find oldfiles" })
map("n", "<leader>b", "<cmd>Telescope buffers<CR>", { desc = "telescope find buffers" })
map("n", "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "telescope find in current buffer" })
map("n", "<leader>sf", "<cmd>Telescope find_files<cr>", { desc = "telescope find files" })
map("n", "<leader>sF", "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
  { desc = "telescope find all files" })
map("n", "<leader>sg", "<cmd>Telescope live_grep<CR>", { desc = "telescope live grep" })

map("n", "<leader>gf", "<cmd>Telescope git_files<CR>", { desc = "telescope git files" })
map("n", "<leader>sH", "<cmd>Telescope help_tags<CR>", { desc = "telescope help page" })
map("n", "<leader>tt", ":Telescope ", { desc = "telescope help page" })
map('n', '<leader>sk', "<cmd>Telescope keymaps<CR>", { desc = 'telescope keymaps' })
map("n", "<leader>pt", "<cmd>Telescope terms<CR>", { desc = "telescope pick hidden term" })

vim.keymap.set('n', '<leader>ss', function()
  local current_filetype = vim.bo.filetype
  local cwd = os.getenv("HOME") .. '/snippets/' .. current_filetype
  require('telescope.builtin').find_files {
    prompt_title = 'Select a snippet for ' .. current_filetype,
    cwd = cwd,
    attach_mappings = function(prompt_bufnr, map)
      local insert_selected_snippet = function()
        local file = require('telescope.actions.state').get_selected_entry()[1]
        local snippet_content = vim.fn.readfile(cwd .. "/" .. file)
        require('telescope.actions').close(prompt_bufnr)
        vim.api.nvim_put(snippet_content, '', false, true)
      end

      map('i', '<CR>', insert_selected_snippet)
      map('n', '<CR>', insert_selected_snippet)

      return true
    end,
  }
end, { desc = '[S]earch [S]nippets' })

vim.keymap.set('n', '<leader>sn', function()
  vim.ui.input({ prompt = 'Snippet Name: ' }, function(snippet_path)
    local current_filetype
    local snippet
    if string.find(snippet_path, "/") then
      current_filetype = string.match(snippet_path, "^(.-)/")
      snippet = string.match(snippet_path, "/(.-)$")
    else
      current_filetype = vim.bo.filetype
      snippet = snippet_path
    end
    local dir = os.getenv("HOME") .. '/snippets/' .. current_filetype
    local path = dir .. '/' .. snippet
    vim.cmd("!mkdir -p" .. dir)
    vim.cmd("e " .. path)
    vim.cmd("set filetype=" .. current_filetype)
    vim.cmd("set filetype?")
  end)
end, { desc = "Create a new snippet" })


-- map("n", "<leader>ma", "<cmd>Telescope marks<CR>", { desc = "telescope find marks" })
-- map("n", "<leader>cm", "<cmd>Telescope git_commits<CR>", { desc = "telescope git commits" })
-- map("n", "<leader>gt", "<cmd>Telescope git_status<CR>", { desc = "telescope git status" })
-- map("n", "<leader>th", "<cmd>Telescope themes<CR>", { desc = "telescope nvchad themes" })

-- terminal
-- map("t", "<C-x>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })

-- new terminals
map("n", "<leader><leader>h", function() require("nvchad.term").new { pos = "sp" } end,
  { desc = "terminal new horizontal term" })
map("n", "<leader>v", function() require("nvchad.term").new { pos = "vsp" } end,
  { desc = "terminal new vertical window" })
-- toggleable
map({ "n", "t" }, "<A-v>", function() require("nvchad.term").toggle { pos = "vsp", id = "vtoggleTerm" } end,
  { desc = "terminal toggleable vertical term" })
map({ "n", "t" }, "<A-t>", function() require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" } end,
  { desc = "terminal new horizontal term" })
map({ "n", "t" }, "<A-i>", function() require("nvchad.term").toggle { pos = "float", id = "floatTerm" } end,
  { desc = "terminal toggle floating term" })

-- whichkey
map("n", "<leader>wK", "<cmd>WhichKey <CR>", { desc = "whichkey all keymaps" })

map("n", "<leader>wk", function()
  vim.cmd("WhichKey " .. vim.fn.input "WhichKey: ")
end, { desc = "whichkey query lookup" })

-- blankline
map("n", "<leader>cc", function()
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
map('n', "<leader>oo", ':Obsidian')
map('n', "<leader>ot", ':ObsidianTags<CR>')
map('n', "<leader>os", ':ObsidianSearch<CR>')
map('n', "<leader>oq", ':ObsidianQuickSwitch<CR>')
map('v', "<leader>on", ':ObsidianLinkNew<CR>')

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
