--[[

From kickstarter

    TODO: The very first thing you should do is to run the command `:Tutor` in Neovim.

    If you don't know anything about Lua, I recommend taking some time to read through
    a guide. One possible example which will only take 10-15 minutes:
      - https://learnxinyminutes.com/docs/lua/

    After understanding a bit more about Lua, you can use `:help lua-guide` as a
    reference for how Neovim integrates Lua.
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html

    MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
    which is very useful when you're not exactly sure of what you're looking for.
--]]

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.runtimepath:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration
  -- Git related plugins
  'tpope/vim-fugitive',
  -- 'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- Use sudo in command mode
  'lambdalisue/suda.vim',

  -- For surrounding
  'tpope/vim-surround',


  -- From vim plugin
  'junegunn/goyo.vim',
  'itchyny/lightline.vim',
  'preservim/nerdtree',

  -- Adds git related signs to the gutter, as well as utilities for managing changes
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>gp', require('gitsigns').prev_hunk,
          { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
        vim.keymap.set('n', '<leader>gn', require('gitsigns').next_hunk, { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
        vim.keymap.set('n', '<leader>ph', require('gitsigns').preview_hunk, { buffer = bufnr, desc = '[P]review [H]unk' })
        vim.keymap.set('n', '<leader>hd', require('gitsigns').diffthis, { buffer = bufnr, desc = '[h]unk [d]iff' })
        vim.keymap.set('n', '<leader>hD', function() require('gitsigns').diffthis('~') end,
          { buffer = bufnr, desc = '[h]unk [d]iff for ~' })
        vim.keymap.set('v', 'hr', ":Gitsigns reset_hunk<CR>", { buffer = bufnr, desc = '[h]unk [r]eset' })
      end,
    },
  },

  -- colorscheme
  {
    -- onedark.nvim: Theme inspired by Atom
    'navarasu/onedark.nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'onedark'
      -- vim.cmd('source ~/.vim/vim-init/init/init-basic.vim')
    end,
  },

  -- hop.nvim for quick jump
  {
    'smoka7/hop.nvim',
    version = "*",
    opts = {
      keys = 'etovxqpdygfblzhckisuran'
    }
  },

  -- Useful plugin to show you pending keybinds.
  {
    'folke/which-key.nvim',
    opts = {
      plugins = {
        spelling = {
          enabled = true,   -- enabling this will show WhichKey when pressing z= to select spelling suggestions
          suggestions = 20, -- how many suggestions should be shown in the list?
        },
      }
    }
  },

  -- For obsidian
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
    --   "BufReadPre path/to/my-vault/**.md",
    --   "BufNewFile path/to/my-vault/**.md",
    -- },
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",

      -- see below for full list of optional dependencies 👇
    },
    opts = {
      workspaces = {
        {
          name = "log",
          path = "~/log",
        },
      },
      completion = {
        -- Set to false to disable completion.
        nvim_cmp = true,
        -- Trigger completion at 2 chars.
        min_chars = 2,
      },
      mapping = {
        -- Toggle check-boxes.
        ["<leader>oc"] = {
          action = function()
            return require("obsidian").util.toggle_checkbox()
          end,
          opts = { buffer = true },
        },
        -- Smart action depending on context, either follow link or toggle checkbox.
        ["<cr>"] = {
          action = function()
            return require("obsidian").util.smart_action()
          end,
          opts = { buffer = true, expr = true },
        }
      },
      -- see below for full list of options 👇
      note_id_func = function(title)
        return title
        -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
        -- In this case a note with the title 'My new note' will be given an ID that looks
        -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
        -- local suffix = ""
        -- title = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        -- if title ~= nil and title ~= "" then
        --   -- If title is given, transform it into valid file name.
        --   suffix = "-" .. title
        -- else
        --   -- If title is nil, just add 4 random uppercase letters to the suffix.
        --   for _ = 1, 4 do
        --     suffix = suffix .. string.char(math.random(65, 90))
        --   end
        --   suffix = "-" .. title
        -- end
        -- return tostring(os.time()) .. suffix
      end,
    },
  },

  -- install without yarn or npm
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },

  -- For beancount
  'nathangrigg/vim-beancount',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim',       tag = 'legacy', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  {
    'stevearc/aerial.nvim',
    enable = false,
    opts = {},
    -- Optional dependencies
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
  },


  --{
  --  -- Set lualine as statusline
  --  'nvim-lualine/lualine.nvim',
  --  -- See `:help lualine.txt`
  --  opts = {
  --    options = {
  --      icons_enabled = false,
  --      theme = 'onedark',
  --      component_separators = '|',
  --      section_separators = { left = '', right = '' },
  --    },
  --  },
  --},

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = "ibl",
    opts = {
      indent = { char = "┊" },
      whitespace = { highlight = { "Whitespace", "NonText" } },
    },
  },

  -- "gc" to comment visual regions/lines
  --{ 'numToStr/Comment.nvim', opts = {} },
  -- Another config
  {
    'numToStr/Comment.nvim',
    opts = {
      opleader = {
        ---Line-comment keymap
        line = '<C-/>',
        ---Block-comment keymap
        block = 'gb',
      },
    }
  },


  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },
}, {})

-- [[ Setting options ]]
-- See `:help vim.o`

-- Let cursor be line in insert mode
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"

-- Enable break indent
vim.o.breakindent = true

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
-- vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Use suda.vim to run sudo, or terminal prompt fails
-- See more details at https://github.com/neovim/neovim/issue
vim.cmd("command! W execute 'SudaWrite %'")

-- [[ Configure vim.surround ]]
vim.cmd('vmap s S')

-- [[ Configure lualine ]]
-- Change the background of lualine_b section for normal mode
-- local custom_wombat = require 'lualine.themes.wombat'
-- custom_wombat.normal.b.bg = '#a8a8a8'
-- custom_wombat.normal.b.fg = '#444444'
-- require('lualine').setup {
--   options = { theme = custom_wombat },
-- }

-- [[ Configure lightline ]]
vim.cmd("let g:lightline = { 'colorscheme': 'wombat' }")

-- [[ Configure Goyo ]]
vim.cmd("nnoremap <silent> <leader>z :Goyo<CR>")

-- [[ Configure NERDTree ]]
vim.g.NERDTreeWinPos = 'left'
vim.g.NERDTreeShowHidden = 0
vim.api.nvim_set_var('NERDTreeWinSize', 35)
vim.cmd("map <C-n> :NERDTreeToggle<cr>")
vim.cmd("map <leader>nb :NERDTreeFromBookmark<Space>")
vim.cmd("map <leader>nf :NERDTreeFind<cr>")
vim.o.autochdir = 0
-- vim.cmd("autocmd BufWinEnter * if &buftype != 'quickfix' && getcmdwintype() == '' | silent NERDTreeMirror | endif")

-- [ Configure Hop ]
vim.keymap.set('n', "<space>", ':HopWord<CR>')
vim.keymap.set('n', '<C-.>', ':HopChar1<CR>')

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
-- local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
-- vim.api.nvim_create_autocmd('TextYankPost', {
--   callback = function()
--     vim.highlight.on_yank()
--   end,
--   group = highlight_group,
--   pattern = '*',
-- })

-- [[ Configure Comment.nvim ]]
vim.cmd('nmap <C-/> V<C-/>')

-- [[ Configure Obsidian.nvim ]]
vim.keymap.set('n', "<leader>oo", ':Obsidian')
vim.keymap.set('n', "<leader>ot", ':ObsidianTags<CR>')
vim.keymap.set('n', "<leader>os", ':ObsidianSearch<CR>')
vim.keymap.set('n', "<leader>oq", ':ObsidianQuickSwitch<CR>')
vim.keymap.set('v', "<leader>on", ':ObsidianLinkNew<CR>')

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
