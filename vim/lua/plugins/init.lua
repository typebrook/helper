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
    lazy = false,
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
    lazy = false,
    -- event = 'BufWritePre', -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- See `:help ibl`
    enabled = true,
    main = "ibl",
    opts = {
      indent = { char = "┊" },
      whitespace = { highlight = { "Whitespace", "NonText" } },
    },
  },

  {
    'lewis6991/gitsigns.nvim',
    opts = function()
      return {
        -- See `:help gitsigns.txt`
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
        on_attach = function(bufnr)
          local gs = require('gitsigns')
          vim.keymap.set('n', '<leader>gp', gs.prev_hunk, { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
          vim.keymap.set('n', '<leader>gn', gs.next_hunk, { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
          vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr, desc = '[P]review [H]unk' })
          vim.keymap.set('n', '<leader>hd', gs.diffthis, { buffer = bufnr, desc = '[h]unk [d]iff' })
          vim.keymap.set('n', '<leader>hD', function() gs.diffthis('~') end,
            { buffer = bufnr, desc = '[h]unk [d]iff for ~' })
          -- vim.keymap.set("n", "<leader>gb", gs.blame_line{full=true}, { desc = "Git Blame" })
          vim.keymap.set("n", "<leader>gb", gs.toggle_current_line_blame, { desc = "Blame Line" })
          vim.keymap.set('v', 'hr', gs.reset_hunk, { buffer = bufnr, desc = '[h]unk [r]eset' })
        end
      }
    end,
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
      -- Optional, for templates (see below).
      templates = {
        folder = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
        -- A map for custom variables, the key should be the variable and the value a function
        substitutions = {},
      },
    },
  },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
    init = function()
      vim.g.mkdp_preview_options = {
        mkit = {
        }
      }
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = function()
      return require "configs.telescope"
    end,
  },

  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release'
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

  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },
  --
  {
    "williamboman/mason.nvim",
    opts = {
      automatically_installation = true,
      ensure_installed = {
        "vim-language-server",
        "lua-language-server",
        "css-lsp",
        "html-lsp",
        "prettier",
        "stylua",
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

  {
    'tpope/vim-surround',
    lazy = false,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = function()
      local opts = require "nvchad.configs.nvimtree"
      opts.on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.set('n', 'l', api.node.open.edit, { buffer = bufnr, nowait = true })
        vim.keymap.set('n', 'h', api.tree.change_root_to_parent, { buffer = bufnr, nowait = true })
      end
      return opts
    end,
  },
  -- {
  --   'junegunn/goyo.vim',
  --   lazy = false,
  -- },


  -- {
  --   'akinsho/bufferline.nvim',
  --   lazy = false,
  --   version = "*",
  --   dependencies = 'nvim-tree/nvim-web-devicons'
  -- }
}
