-- This file  needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.ui = {
  theme = "onedark",

  -- hl_override = {
  -- 	Comment = { italic = true },
  -- 	["@comment"] = { italic = true },
  -- },
  tabufline = {
    enabled = true,
    order = { "treeOffset", "buffers", "tabs" },
  },

  term = {
    hl = "Normal:term,WinSeparator:WinSeparator",
    sizes = { sp = 0.4, vsp = 0.4 },
    float = {
      relative = "editor",
      row = 0.15,
      col = 0.13,
      width = 0.7,
      height = 0.7,
      border = "single",
    },
  },
}

-- For tabufline
if M.ui.tabufline.enabled then
  vim.keymap.set("n", "<C-c>", function()
    local bufnrs = vim.tbl_filter(function(b) return 1 == vim.fn.buflisted(b) end, vim.api.nvim_list_bufs())
    if #bufnrs == 1 or #vim.fn.getwininfo() > 1 then
      vim.cmd("silent quit")
    else
      require("nvchad.tabufline").close_buffer()
    end
  end, { desc = "buffer close" })
  for i = 1, 9, 1 do
    vim.keymap.set("n", string.format("<A-%s>", i), function()
      vim.api.nvim_set_current_buf(vim.t.bufs[i])
    end)
  end
  vim.keymap.set("n", "<A-h>", function() require("nvchad.tabufline").move_buf(-1) end)
  vim.keymap.set("n", "<A-l>", function() require("nvchad.tabufline").move_buf(1) end)
  vim.keymap.set("n", "<A-H>", function() vim.cmd("tabprevious") end)
  vim.keymap.set("n", "<A-L>", function() vim.cmd("tabnext") end)
  vim.keymap.set("n", "<tab>", function() require("nvchad.tabufline").next() end, { desc = "buffer goto next" })
  vim.keymap.set("n", "<S-tab>", function() require("nvchad.tabufline").prev() end, { desc = "buffer goto prev" })
end


return M
