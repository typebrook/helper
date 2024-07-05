return {
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
      "node_modules"
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
      },
    },

  },
  extensions_list = {},
  extensions = {
    fzf = {
      fuzzy = true,                   -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true,    -- override the file sorter
      case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    },
    aerial = {
      -- Display symbols as <root>.<parent>.<symbol>
      show_nesting = {
        ["_"] = false, -- This key will be the default
        json = true,   -- You can set the option for specific filetypes
        yaml = true,
      },
    },
  },
  on_attach = function()
    require("telescope").load_extension("fzf")
    require("telescope").load_extension("aerial")
  end
}
