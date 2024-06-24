return {

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- Use sudo in command mode
  {
    'lambdalisue/suda.vim',
    cmd = { "SudaWrite" },
  },

  -- For focus mode
  {
    "Pocco81/true-zen.nvim",
    cmd = { "TZAtaraxis", "TZMinimalist" },
  },

  -- hop.nvim: For quick jump
  {
    'smoka7/hop.nvim',
    lazy = false,
    version = "*",
    opts = {
      keys = 'etovxqpdygfblzhckisuran'
    },
    config = function()
      require("hop").setup()
    end
  },

  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- See `:help ibl`
    enabled = false,
    main = "ibl",
    opts = {
      indent = { char = "┊" },
      whitespace = { highlight = { "Whitespace", "NonText" } },
    },
  },

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

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = function()
      return require "configs.telescope"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    opts = function()
      return require "configs.treesitter"
    end,
  },

  {
    'stevearc/aerial.nvim',
    opts = {
      on_attach = function(bufnr)
        -- Jump forwards/backwards with '{' and '}'
        vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
        vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
        vim.keymap.set("n", "<leader><leader>a", "<cmd>Telescope aerial<CR>")
        vim.keymap.set("n", "<leader><leader>A", "<cmd>AerialToggle!left<CR>")
      end,
    },
    -- Optional dependencies
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
  },

  -- {
  --   'numToStr/Comment.nvim',
  --   lazy = true,
  --   opts = {
  --     opleader = {
  --       ---Line-comment keymap
  --       line = '<C-/>',
  --       ---Block-comment keymap
  --       block = 'gb',
  --     },
  --   }
  -- },

  -- These are some examples, uncomment them if you want to see them work!
  -- {
  --   "neovim/nvim-lspconfig",
  --   config = function()
  --     require("nvchad.configs.lspconfig").defaults()
  --     require "configs.lspconfig"
  --   end,
  -- },
  --
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server", "stylua",
        "html-lsp", "css-lsp", "prettier"
      },
    },
  },

  {
    'numToStr/Comment.nvim',
    lazy = false,
    opts = {
      toggler = {
        line = '<C-/>',
        block = 'gb',
      },
      opleader = {
        line = '<C-/>',
        block = 'gb',
      },
    },
  },


  -- {
  --   'akinsho/bufferline.nvim',
  --   lazy = false,
  --   version = "*",
  --   dependencies = 'nvim-tree/nvim-web-devicons'
  -- }
}
