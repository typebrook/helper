return {
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
      horizontal = {
        prompt_position = "bottom",
      },
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
  extensions_list = {},
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
