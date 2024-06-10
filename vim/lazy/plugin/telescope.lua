-- See `:help telescope` and `:help telescope.setup()`

require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        -- ["<c-j>"] = "move_selection_next",
        -- ["<c-k>"] = "move_selection_previous",
        ["<C-w>"] = require("telescope.actions.layout").toggle_preview,
        ["<C-u>"] = false,
      },
    },
    layout_config = {
      vertical = { height = 0.8 },
      -- other layout configuration here
      preview_cutoff = 0,
    },
  },
  pickers = {
    buffers = {
      show_all_buffers = true,
      sort_lastused = true,
      theme = "dropdown",
      previewer = false,
      mappings = {
        i = {
          ["<c-d>"] = "delete_buffer",
        },
        n = {
          ["<c-d>"] = "delete_buffer",
        }
      }
    },

  },
  extensions = {
    aerial = {
      -- Display symbols as <root>.<parent>.<symbol>
      show_nesting = {
        ["_"] = false, -- This key will be the default
        json = true,   -- You can set the option for specific filetypes
        yaml = true,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'repo')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>T', ':Telescope<CR>', { desc = '[T]elescope' })
vim.keymap.set('n', '<leader>f', require('telescope.builtin').oldfiles, { desc = '[F] Find recently opened files' })
vim.keymap.set('n', '<leader>b', require('telescope.builtin').buffers, { desc = '[B] Find existing buffers' })
vim.keymap.set('n', '<leader>st', require('telescope.builtin').builtin, { desc = '[S]earch [T]elescope for builtin' })
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sk', require('telescope.builtin').keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })

-- For grep in current buffer
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    --winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

-- For neovim config files
vim.keymap.set('n', '<leader>sn', function()
  require('telescope.builtin').find_files {
    cwd = vim.fn.stdpath 'config',
    follow = true
  }
end, { desc = '[S]earch [N]eovim files' })

-- Get snippets from ~/helper/snippets
vim.keymap.set('n', '<leader>ss', function()
  local current_filetype = vim.bo.filetype
  local cwd = '/home/pham/helper/snippets/' .. current_filetype
  require('telescope.builtin').find_files {
    prompt_title = 'Select a snippet for ' .. current_filetype,
    cwd = cwd,
    attach_mappings = function(prompt_bufnr, map)
      local insert_selected_snippet = function()
        local file = require('telescope.actions.state').get_selected_entry()[1]
        local snippet_content = vim.fn.readfile(cwd .. "/" .. file)
        require('telescope.actions').close(prompt_bufnr)
        vim.api.nvim_command('normal! h')
        vim.api.nvim_put(snippet_content, '', false, true)
      end

      map('i', '<CR>', insert_selected_snippet)
      map('n', '<CR>', insert_selected_snippet)

      return true
    end,
  }
end, { desc = '[S]earch [S]nippets' })
