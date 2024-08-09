-- vim: sw=2 et foldmethod=marker foldmarker={{{,}}} foldlevel=0

-- Ref: https://github.com/echasnovski/mini.nvim
--      https://lazy.folke.io/spec

-- Install mini.nvim {{{
-- Put this at the top of 'init.lua'
local path_package = vim.fn.stdpath("data") .. "/site"
local mini_path = path_package .. "/pack/deps/start/mini.nvim"
vim.o.packpath = path_package

if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    "git",
    "clone",
    "--filter=blob:none",
    -- Uncomment next line to use 'stable' branch
    -- '--branch', 'stable',
    "https://github.com/echasnovski/mini.nvim",
    mini_path,
  }
  vim.fn.system(clone_cmd)
  vim.cmd("packadd mini.nvim | helptags ALL")
end

-- }}}
-- mini.deps {{{
require("mini.deps").setup({
  path = { package = path_package },
})
Add, Now, Later = MiniDeps.add, MiniDeps.now, MiniDeps.later
-- }}}
-- -- mini.basics {{{
-- require("mini.basics").setup()
-- -- }}}
-- mini.misc {{{
require("mini.misc").setup({
  make_global = { "put", "put_text", "zoom" },
})
vim.keymap.set( 'n', '<leader>Z', function()
  zoom()
  vim.cmd("silent! call ToggleWinPadding()")
end, { buffer = bufnr, desc = 'zoom' })
--}}}
-- mini.extra {{{
require("mini.extra").setup()
-- }}}
-- mini.colors {{{
require("mini.colors").setup()
vim.keymap.set("n", "<leader><leader>co", function()
  require("mini.colors").interactive()
end)
-- }}}
-- mini.base16 {{{
require("mini.base16").setup({
  palette = {
    -- Default Background
    base00 = "#2d2a2e",
    -- Lighter Background (Used for status bars, line number and folding marks)
    base01 = "#37343a",
    -- Selection Background
    base02 = "#423f46",
    -- Comments, Invisible, Line Highlighting
    base03 = "#848089",
    -- Dark Foreground (Used for status bars)
    base04 = "#66d9ef",
    -- Default Foreground, Caret, Delimiters, Operators
    base05 = "#e3e1e4",
    -- Light Foreground (Not often used)
    base06 = "#a1efe4",
    -- Light Background (Not often used)
    base07 = "#f8f8f2",
    -- Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
    base08 = "#f85e84",
    -- Integers, Boolean, Constants, XML Attributes, Markup Link Url
    base09 = "#ef9062",
    -- Classes, Markup Bold, Search Text Background
    base0A = "#a6e22e",
    -- Strings, Inherited Class, Markup Code, Diff Inserted
    base0B = "#e5c463",
    -- Support, Regular Expressions, Escape Characters, Markup Quotes
    base0C = "#66d9ef",
    -- Functions, Methods, Attribute IDs, Headings
    base0D = "#9ecd6f",
    -- Keywords, Storage, Selector, Markup Italic, Diff Changed
    base0E = "#a1efe4",
    -- Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>
    base0F = "#f9f8f5",
  },
  use_cterm = false,
})
--
-- Override settings for search
vim.cmd("hi Search guibg=#e5c07b")
--
-- Resume terminal color
for i = 1, 15, 1 do
  vim.cmd("let terminal_color_" .. i .. " = ''")
end
--
-- Override settings for bufferline
vim.cmd("hi BufferLineTabSelected guibg=#f85e84")
vim.cmd("hi BufferLineTab guibg=Gray")
--
--}}}
-- mini.icons {{{
require("mini.icons").setup({})
--}}}
-- mini.comment {{{
require("mini.comment").setup({
  -- Module mappings. Use `''` (empty string) to disable one.
  mappings = {
    -- Toggle comment (like `gcip` - comment inner paragraph) for both
    -- Normal and Visual modes
    comment = "gc",
    --
    -- Toggle comment on current line
    comment_line = "<C-/>",
    --
    -- Toggle comment on visual selection
    comment_visual = "<C-/>",
    --
    -- Define 'comment' textobject (like `dgc` - delete whole comment block)
    -- Works also in Visual mode if mapping differs from `comment_visual`
    textobject = "gc",
  },
}) -- }}}
-- mini.cursorword {{{
require("mini.cursorword").setup()
-- }}}
-- mini.diff {{{
require("mini.diff").setup({
  -- Options for how hunks are visualized
  view = {
    -- Visualization style. Possible values are 'sign' and 'number'.
    -- Default: 'number' if line numbers are enabled, 'sign' otherwise.
    style = "sign",
    --
    -- Signs used for hunks with 'sign' view
    signs = { add = "+", change = "▒", delete = "-" },
    --
    -- Priority of used visualization extmarks
    priority = 199,
  },
})
--
vim.keymap.set("n", "\\gh", function()
  MiniDiff.toggle_overlay()
end, { buffer = bufnr, desc = "Toggle diff" })
--
-- }}}
-- mini.map {{{
require("mini.map").setup()
vim.keymap.set("n", "\\M", function() require("mini.map").toggle() end, { desc = "Minimap", buffer = bufnr })
-- }}}
-- mini.visits {{{

require("mini.visits").setup()
-- vim.keymap.set("n", "<leader><leader>li", function()
-- 	MiniVisits.list_paths()
-- end, { buffer = bufnr, desc = "" })
--
-- }}}
-- mini.ai {{{
require("mini.ai").setup {}
-- }}}
-- mini.surround {{{
require("mini.surround").setup {
  mappings = {
    add = 's'
  }
}
-- }}}
-- mini.indentscope {{{
require("mini.indentscope").setup()
-- }}}
-- mini.splitjoin {{{
require("mini.splitjoin").setup()
-- }}}
-- mini.move {{{
require("mini.move").setup()
-- }}}
-- mini.hipatterns {{{
--
local hipatterns = require("mini.hipatterns")
hipatterns.setup({
  highlighters = {
    -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
    hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
    note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
    --
    -- Highlight hex color strings (`#rrggbb`) using that color
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})
vim.keymap.set("n", "<leader><leader>hi", function()
  MiniHipatterns.toggle()
end, { buffer = bufnr, desc = "Toggle hex color highlight" })
--
-- }}}
-- mini.pairs {{{
require("mini.pairs").setup()
-- }}}
-- -- mini.statusline {{{
-- --
-- require("mini.statusline").setup({
--   content = {
--     active = status_config,
--   },
-- })
-- local function diagnostics_table(args)
--   local info = vim.b.coc_diagnostic_info
--   if MiniStatusline.is_truncated(args.trunc_width) or info == nil then
--     return {}
--   end
--   local table = {}
--   table.e = (info["error"] or 0) > 0 and "E" .. info["error"] or ""
--   table.w = (info["warning"] or 0) > 0 and "W" .. info["warning"] or ""
--   table.h = (info["hint"] or 0) > 0 and "H" .. info["hint"] or ""
--   table.i = (info["information"] or 0) > 0 and "I" .. info["information"] or ""
--   table.s = vim.g.coc_status
--   return table
-- end
--
-- function status_config()
--   local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
--   local git = MiniStatusline.section_git({ trunc_width = 75 })
--   local diagnostics = diagnostics_table({ trunc_width = 75 })
--   local filename = MiniStatusline.section_filename({ trunc_width = 140 })
--   local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
--   local location = MiniStatusline.section_location({ trunc_width = 75 })
--
--   return MiniStatusline.combine_groups({
--     { hl = mode_hl,                 strings = { mode } },
--     { hl = "MiniStatuslineDevinfo", strings = { git, diagnostics["s"] } },
--     { hl = "MiniStatuslineError",   strings = { diagnostics["e"] } },
--     { hl = "MiniStatuslineWarning", strings = { diagnostics["w"] } },
--     { hl = "MiniStatuslineInfo",    strings = { diagnostics["i"] } },
--     { hl = "MiniStatuslineHint",    strings = { diagnostics["h"] } },
--     "%<", -- Mark general truncate point
--     { hl = "MiniStatuslineFilename", strings = { filename } },
--     "%=", -- End left alignment
--     { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
--     { hl = mode_hl,                  strings = { location } },
--   })
-- end
--
-- -- }}}
-- -- mini.completion {{{
-- require('mini.completion').setup()
-- -- }}}
-- -- mini.tabline {{{
--
-- require('mini.tabline').setup {
--   format = function(buf_id, label)
--     local suffix = vim.bo[buf_id].modified and '+ ' or ''
--     return MiniTabline.default_format(buf_id, label) .. suffix
--   end,
--   tabpage_section = 'right'
-- }
--
-- for i = 1, 9, 1 do
--   vim.keymap.set("n", string.format("<A-%s>", i), function()
--     vim.api.nvim_set_current_buf(vim.fn.getbufinfo({ buflisted=true })[i].bufnr)
--   end, {silent = true})
-- end
--
-- -- }}}
-- -- mini.clue {{{
-- local miniclue = require('mini.clue')
-- miniclue.setup({
--   triggers = {
--     -- Leader triggers
--     { mode = 'n', keys = '<Leader>' },
--     { mode = 'x', keys = '<Leader>' },
--
--     -- Built-in completion
--     { mode = 'i', keys = '<C-x>' },
--
--     -- `g` key
--     { mode = 'n', keys = 'g' },
--     { mode = 'x', keys = 'g' },
--
--     -- Marks
--     { mode = 'n', keys = "'" },
--     { mode = 'n', keys = '`' },
--     { mode = 'x', keys = "'" },
--     { mode = 'x', keys = '`' },
--
--     -- Registers
--     { mode = 'n', keys = '"' },
--     { mode = 'x', keys = '"' },
--     { mode = 'i', keys = '<C-r>' },
--     { mode = 'c', keys = '<C-r>' },
--
--     -- Window commands
--     { mode = 'n', keys = '<C-w>' },
--
--     -- `z` key
--     { mode = 'n', keys = 'z' },
--     { mode = 'x', keys = 'z' },
--   },
--
--   clues = {
--     -- Enhance this by adding descriptions for <Leader> mapping groups
--     miniclue.gen_clues.builtin_completion(),
--     miniclue.gen_clues.g(),
--     miniclue.gen_clues.marks(),
--     miniclue.gen_clues.registers(),
--     miniclue.gen_clues.windows(),
--     miniclue.gen_clues.z(),
--   },
-- -- }}}
-- -- mini.bufremote {{{
-- require('mini.bufremove')
--}}}
-- -- mini.animate --{{{
-- require("mini.animate").setup()
-- -- }}}
-- -- suda {{{
-- add { source = "lambdalisue/suda.vim" }
-- }}}
-- marks.nvim {{{
Add {
  source = "chentoast/marks.nvim"
}
require('marks').setup {
  bookmark_0 = {
    sign = "⚑",
    virt_text = "hello world",
    -- explicitly prompt for a virtual line annotation when setting a bookmark from this group.
    -- defaults to false.
    annotate = false,
  },
}
vim.cmd("hi MarkSignHL gui=bold guifg=#f85e84 guibg=#37343a")
-- }}}
-- highlight-match-under-cursor {{{
Add {
  source = "adamheins/vim-highlight-match-under-cursor"
}
-- }}}
-- vim-livedown {{{
Add {
  source  ='shime/vim-livedown'
}
vim.keymap.set( 'n', '<F10>', ":LivedownToggle<CR>", { buffer = bufnr, desc = '' })
-- }}}
-- Preview Image {{{
Add {
  source = 'qaiviq/vim-imager'
}
vim.cmd("let g:imager#filetypes = ['.md']")
vim.keymap.set( 'n', '\\i', ":ToggleImages<CR>", { buffer = bufnr, desc = '' })
-- }}}


-- Install Lazy {{{
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.cmd("set rtp+="..lazypath)
-- }}}
require("lazy").setup({
  -- "tpope/vim-sleuth",
-- bufferline {{{
  {
    "akinsho/bufferline.nvim",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "tiagovla/scope.nvim",
    },
    config = function()
      require('bufferline').setup{
        options = {
          numbers = 'ordinal',
          tab_size = 14,
          separator_style = { "", "" },
          themable = true,
          buffer_close_icon = "",
          close_icon = "",
          groups = {
            items = {
              require("bufferline.groups").builtin.pinned:with({ icon = "󰐃" }),
            },
          },
          enforce_regular_tabs = false,
          diagnostics = "coc",
          diagnostics_update_in_insert = true,
          diagnostics_indicator = function(count, level)
            local icon = level:match("error") and " " or " "
            return " " .. icon .. count
          end,
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              highlight = "Directory",
              text_align = "left"
            },
            {
              filetype = "coc-explorer",
              text = function()
                return vim.fn.getcwd()
              end,
              highlight = "Directory",
              text_align = "left"
            },
            {
              filetype = 'vista',
              text = function()
                return vim.fn.getcwd()
              end,
              highlight = "Tags",
              text_align = "right"
            }
          },
          custom_filter = function (buf_number)
            for _, p in ipairs(vim.t.bufs) do
              if p == buf_number then
                return true
              end
            end
            return false
          end
        }
      }
      -- keymaps {{{
      for i = 1, 9, 1 do
        vim.keymap.set("n", string.format("<A-%s>", i), function()
          require("bufferline").go_to(i, true)
        end, { silent = true })
      end
      local opts = { noremap = true, silent = true }
      vim.keymap.set("n", "<TAB>", "<Cmd>BufferLineCyclePrev<CR>", opts)
      vim.keymap.set("n", "<S-TAB>", "<Cmd>BufferLineCycleNext<CR>", opts)
      vim.keymap.set("n", "<M-h>", "<Cmd>BufferLineMovePrev<CR>", opts)
      vim.keymap.set("n", "<M-l>", "<Cmd>BufferLineMoveNext<CR>", opts)
      vim.keymap.set("n", "<M-p>", "<Cmd>BufferLineTogglePin<CR>", opts)
      -- }}}
    end
  },
  -- }}}
  -- lualine {{{
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    init = function()
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        -- set an empty statusline till lualine loads
        vim.o.statusline = " "
      else
        -- hide the statusline on the starter page
        vim.o.laststatus = 0
      end
    end,
    opts = function()
      -- PERF: we don't need this lualine require madness 🤷
      local lualine_require = require("lualine_require")
      lualine_require.require = require

      vim.o.laststatus = vim.g.lualine_laststatus

      local opts = {
        options = {
          theme = "auto",
          globalstatus = vim.o.laststatus == 3,
          disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },

          lualine_x = {
            -- stylua: ignore
            {
              function() return require("noice").api.status.command.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
            },
            -- stylua: ignore
            {
              function() return require("noice").api.status.mode.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
            },
            -- stylua: ignore
            {
              function() return "  " .. require("dap").status() end,
              cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
            },
            -- stylua: ignore
            {
              require("lazy.status").updates,
              cond = require("lazy.status").has_updates,
            },
            {
              "diff",
              source = function()
                local gitsigns = vim.b.gitsigns_status_dict
                if gitsigns then
                  return {
                    added = gitsigns.added,
                    modified = gitsigns.changed,
                    removed = gitsigns.removed,
                  }
                end
              end,
            },
          },
          lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            function()
              return " " .. os.date("%R")
            end,
          },
        },
        extensions = { "neo-tree", "lazy" },
      }

      return opts
    end,
    config = function()
      require('lualine').setup(opts)
      if vim.o.lines < 20 then
        vim.o.laststatus=0
      end
    end
  },
  -- }}}
  -- Telescope {{{
  {
    "nvim-telescope/telescope.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    config = function()
      -- extensions {{{
      require("telescope").load_extension("fzf")
      -- require("telescope").load_extension("aerial")
      -- }}}
      -- config {{{
      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              -- ["<c-j>"] = "move_selection_next",
              -- ["<c-k>"] = "move_selection_previous",
              ["<C-o>"] = require("telescope.actions.layout").toggle_preview,
              ["<C-u>"] = false,
              ["<C-q>"] = function(p_bufnr)
                require("telescope.actions").send_selected_to_qflist(p_bufnr)
                vim.cmd.cfdo("edit")
              end,
            },
          },
          layout_config = {
            horizontal = {
              prompt_position = "bottom",
            },
            vertical = { height = 0.8 },
            -- other layout configuration here
            preview_cutoff = 0,
          },
          file_ignore_patterns = {
            "node_modules",
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
              },
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,                 -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,  -- override the file sorter
            case_mode = "smart_case",     -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
          },
          aerial = {
            -- Display symbols as <root>.<parent>.<symbol>
            show_nesting = {
              ["_"] = false, -- This key will be the default
              json = true, -- You can set the option for specific filetypes
              yaml = true,
            },
          },
        },
      })
      -- }}}
      -- Keymaps {{{
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
      --
      vim.keymap.set("n", "<leader>ss", function()
        local current_filetype = vim.bo.filetype
        local cwd = os.getenv("HOME") .. "/snippets"
        require("telescope.builtin").find_files({
          prompt_title = "Press <C-T> to edit a snippet",
          default_text = current_filetype == "" and "" or current_filetype .. "_",
          cwd = cwd,
          attach_mappings = function(prompt_bufnr, map)
            local get_prompt_or_entry = function()
              local file_list = require("telescope.actions.state").get_selected_entry()
              if file_list then
                return file_list[1]
              else
                local current_picker =
                    require("telescope.actions.state").get_current_picker(prompt_bufnr)
                return current_picker:_get_prompt()
              end
            end
            --
            local edit_snippet = function()
              local file = get_prompt_or_entry()
              require("telescope.actions").close(prompt_bufnr)
              local prefix_filetype = string.match(file, "([^_]+)")
              vim.cmd(":vs")
              vim.cmd(":e " .. cwd .. "/" .. file)
              vim.bo.filetype = prefix_filetype
              vim.bo.bufhidden = "wipe"
              vim.cmd("set filetype?")
            end
            --
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
            --
            map("i", "<CR>", insert_selected_snippet)
            map("i", "<C-T>", edit_snippet)
            map("n", "<CR>", insert_selected_snippet)
            --
            return true
          end,
        })
      end, { desc = "[S]earch [S]nippets" })
      --
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
            --
            map("i", "<CR>", cd_prompt)
            map("n", "<CR>", cd_prompt)
            --
            return true
          end,
        })
      end, { desc = "Search Directory" })
      -- }}}
    end,
  },
  -- }}}
  -- nvim-tree {{{
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      -- config {{{
      require("nvim-tree").setup({
        filters = {
          dotfiles = false,
        },
        disable_netrw = true,
        hijack_netrw = true,
        hijack_cursor = true,
        hijack_unnamed_buffer_when_opening = false,
        sync_root_with_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = false,
        },
        view = {
          adaptive_size = false,
          side = "left",
          width = 26,
          preserve_window_proportions = true,
        },
        git = {
          enable = true,
          ignore = true,
        },
        filesystem_watchers = {
          enable = true,
        },
        actions = {
          open_file = {
            resize_window = true,
          },
        },
        renderer = {
          root_folder_label = false,
          highlight_git = true,
          highlight_opened_files = "none",
          --
          indent_markers = {
            enable = true,
          },
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
            glyphs = {
              default = "󰈚",
              symlink = "",
              folder = {
                default = "",
                empty = "",
                empty_open = "",
                open = "",
                symlink = "",
                symlink_open = "",
                arrow_open = "",
                arrow_closed = "",
              },
              git = {
                unstaged = "✗",
                staged = "✓",
                unmerged = "",
                renamed = "➜",
                untracked = "★",
                deleted = "",
                ignored = "◌",
              },
            },
          },
        },
      })
      -- }}}
      -- keymaps {{{
      vim.keymap.set("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })
      vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "nvimtree focus window" })
      -- }}}
    end,
  },
  -- }}}
  -- which-key {{{
  {
    "folke/which-key.nvim",
    lazy = false,
    config = function()
      require("which-key").setup({
        defaults = {
          win = {
            -- don't allow the popup to overlap with the cursor
            no_overlap = false,
            -- width = 1,
            height = { min = 10, max = 25 },
            -- col = 0,
            -- row = math.huge,
            -- border = "none",
            padding = { 1, 2 }, -- extra window padding [top/bottom, right/left]
            title = true,
            title_pos = "center",
            zindex = 1000,
            -- Additional vim.wo and vim.bo options
            bo = {},
            wo = {
              -- winblend = 10, -- value between 0-100 0 for fully opaque and 100 for fully transparent
            },
          },
        },
      })
    end,
  },
  -- }}}
  -- Tig {{{
  {
    "iberianpig/tig-explorer.vim",
    dependencies = { "rbgrouleff/bclose.vim" },
    config = function()
      vim.cmd("nunmap <leader>bd")
    end,
  },
  --}}}
  -- toggleterm {{{
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({
        persist_size = false,
        direction = "float",
      })

      vim.keymap.set({ "n", "t" }, "<A-i>", function()
        vim.cmd("ToggleTerm direction=float")
      end, { desc = "terminal toggle floating term" })
      vim.keymap.set({ "n", "t" }, "<A-e>", function()
        zoom()
      end, { desc = "terminal toggle floating term" })
      vim.keymap.set({ "n", "t" }, "<A-v>", function()
        vim.cmd("ToggleTerm direction=horizontal")
      end, { desc = "terminal toggle floating term" })
      vim.keymap.set("v", ",s", function()
        require("toggleterm").send_lines_to_terminal("single_line", trim_spaces, { args = vim.v.count })
        vim.cmd("ToggleTerm direction=float")
      end)
    end,
  },
  --}}}
-- Markdown: obsidian {{{
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = false,
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
    config = function()
      vim.keymap.set("n", "<leader>oo", ":Obsidian", { })
      vim.keymap.set("n", "<leader>ot", ":ObsidianTags<CR>", { })
      vim.keymap.set("n", "<leader>os", ":ObsidianSearch<CR>", { })
      vim.keymap.set("n", "<leader>oq", ":ObsidianQuickSwitch<CR>", { })
      vim.keymap.set("v", "<leader>on", ":ObsidianLinkNew<CR>", { })
      vim.keymap.set("n", "<leader>ol", ":ObsidianLinks<CR>", { })
      require("obsidian").setup({
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
          },
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
      })
    end,
  },
-- }}}
-- Markdown: preview {{{
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      {
        "<leader>cp",
        ft = "markdown",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Markdown Preview",
      },
    },
    config = function()
      vim.cmd([[do FileType]])
      vim.g.mkdp_browser = 'firefox'
    end,
  },
-- }}}
  -- markview.nvim {{{
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    ft = "markdown",

    dependencies = {
      -- You may not need this if you don't lazy load
      -- Or if the parsers are in your $RUNTIMEPATH
      "nvim-treesitter/nvim-treesitter",

      "nvim-tree/nvim-web-devicons"
    },
    config = function()
      vim.keymap.set( 'n', '\\m', ":Markview<CR>", { buffer = bufnr, desc = '' })
    end
  },
  -- }}}

  -- lspconfig {{{
  -- Use :help lspconfig-all to check servers
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local lspconfig = require "lspconfig"
      --
      -- typescript
      lspconfig.lua_ls.setup {}
      lspconfig.tsserver.setup {}
      lspconfig.vimls.setup {}
      lspconfig.html.setup {}
      --
      vim.keymap.set("n", "<leader>F", function()
        vim.lsp.buf.format()
      end, { desc = "format files" })
    end,
  },
  -- }}}
  -- Mason {{{
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require('mason').setup {
        automatically_installation = true,
        ensure_installed = {
          "vim-language-server",
          "lua-language-server",
          "css-lsp",
          "html-lsp",
          "prettier",
          "stylua",
        },
      }
    end
  },
  -- }}}
  -- treesitter {{{
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "markdown", "markdown_inline", "lua", "luadoc", "printf", "vim", "vimdoc" },

        highlight = {
          enable = true,
          use_languagetree = true,
          additional_vim_regex_highlighting = true,
        },

        indent = { enable = true },
      })
    vim.cmd([[
      syn match MarkdownHtmlDetails '^<details>' conceal cchar=▶
      syn match MarkdownHtmlSummary '<summary>' conceal cchar= 
      syn match MarkdownHtmlSummaryEnd '</summary>' conceal
      syn match MarkdownHtmlDetailsEnd '^</details>' conceal cchar=E
    ]])
    end,
  },
  -- }}}
  -- nvim-cmp {{{
  {
    "hrsh7th/nvim-cmp",
    event = {
      "InsertEnter",
      "CmdlineEnter"
    },
    dependencies = { -- {{{
      {
        -- snippet plugin
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp",
        dependencies = {
          "rafamadriz/friendly-snippets",
          "saadparwaiz1/cmp_luasnip",
          "onsails/lspkind-nvim",
        },
        opts = {
          history = true,
          updateevents = "TextChanged,TextChangedI"
        },
        config = function(_, opts)
          require("luasnip").config.set_config(opts)
          require("luasnip.loaders.from_vscode").lazy_load()
          require("luasnip.loaders.from_lua").load()
          require("luasnip.loaders.from_lua").lazy_load { paths = vim.g.lua_snippets_path or "" }
          --
          vim.api.nvim_create_autocmd("InsertLeave", {
            callback = function()
              if
                  require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
                  and not require("luasnip").session.jump_active
              then
                require("luasnip").unlink_current()
              end
            end,
          })
        end,
      },
      --
      -- cmp sources plugins
      {
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
      },
    }, -- }}}
    config = function()
      local cmp = require "cmp"
      local default_mapping = {
        ["<S-TAB>"] = cmp.mapping.select_prev_item(),
        ["<TAB>"] = cmp.mapping.select_next_item(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm(),
        ['<C-c>'] = cmp.mapping.abort(),
      }

      require("cmp").setup({
        completion = {
          completeopt = "menu,menuone,noselect",
        },
        window = {
          documentation = cmp.config.window.bordered(),
          completion = cmp.config.window.bordered({
            winhighlight = 'Normal:CmpPmenu,CursorLine:PmenuSel,Search:None'
          }),
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        formatting = {
          format = require('lspkind').cmp_format({
            with_text = true, -- do not show text alongside icons
            maxwidth = 50,  -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            before = function(entry, vim_item)
              -- Source 显示提示来源
              vim_item.menu = '<' .. entry.source.name .. '>'
              return vim_item
            end
          })
        },
        mapping = default_mapping,
        sources = cmp.config.sources {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "nvim_lua" },
          { name = "path" },
        },
        experimental = {
          -- ghost_text = true,
        }
      })
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline {
          ['<C-n>'] = cmp.config.disable,
          ['<C-p>'] = cmp.config.disable,
          ['<C-c>'] = cmp.mapping.abort(),
        },
        sources = cmp.config.sources(
          { { name = 'path' } },
          { { name = 'cmdline' } }
        )
      })
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline {
          ['<C-n>'] = cmp.config.disable,
          ['<C-p>'] = cmp.config.disable,
          ['<C-c>'] = cmp.mapping.abort(),
        },
        sources = { { name = 'buffer' } }
      })

      vim.opt.complete = ""
    end,
  },

  -- }}}
  -- lspsaga {{{
  {
    'nvimdev/lspsaga.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter', -- optional
      'nvim-tree/nvim-web-devicons',     -- optional
    },
  config = function()
    require('lspsaga').setup({
        autochdir = true,
      })
    vim.api.nvim_create_autocmd("LspAttach", {
      group = custom_autocommands,
      pattern = "*",
        callback = function(args)
          local map = vim.api.nvim_buf_set_keymap
          map(0, "n", "gd", "<cmd>Lspsaga goto_definition<cr>", {silent = true, noremap = true})
          map(0, "n", "gr", "<cmd>Lspsaga rename<cr>", {silent = true, noremap = true})
          map(0, "n", "gx", "<cmd>Lspsaga code_action<cr>", {silent = true, noremap = true})
          map(0, "x", "gx", ":<c-u>Lspsaga range_code_action<cr>", {silent = true, noremap = true})
          map(0, "n", "K",  "<cmd>Lspsaga hover_doc<cr>", {silent = true, noremap = true})
          map(0, "n", "go", "<cmd>Lspsaga show_line_diagnostics<cr>", {silent = true, noremap = true})
          map(0, "n", "gj", "<cmd>Lspsaga diagnostic_jump_next<cr>", {silent = true, noremap = true})
          map(0, "n", "gk", "<cmd>Lspsaga diagnostic_jump_prev<cr>", {silent = true, noremap = true})
      end,
    })
  end
  },
  -- }}}
  -- -- conform {{{
  -- {
  --   "stevearc/conform.nvim",
  --   config = function(_, opts)
  --     require("conform").setup({
  --       formatters_by_ft = {
  --         lua = { "stylua" },
  --         sh = { "shfmt" },
  --         bash = { "shfmt" },
  --         zsh = { "shfmt" },
  --         markdown = { "prettier" },
  --         css = { "prettier" },
  --         html = { "prettier" },
  --       },
  --     })
  --     vim.keymap.set("n", "<leader>F", function()
  --       require("conform").format({ lsp_fallback = true })
  --     end, { desc = "format files" })
  --   end,
  -- },
  -- -- }}}
})

-- KEYMAPS {{{

-- Use floating window for translation
vim.keymap.set("v", "Tz", function()
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
  vim.cmd(":silent! %s/\\%x1b\\[[0-9;]*m//g")
end, { desc = "Description" })
-- }}}
