-- vim: sw=2 foldmethod=marker foldmarker={{{,}}}

-- Ref: https://github.com/echasnovski/mini.nvim?tab=readme-ov-file
-- TODO

-- Install mini.nvim {{{

-- Put this at the top of 'init.lua'
local path_package = vim.fn.stdpath('data') .. '/site'
vim.o.packpath = path_package
local mini_path = path_package .. '/pack/deps/start/mini.nvim'

if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    'git', 'clone', '--filter=blob:none',
    -- Uncomment next line to use 'stable' branch
    -- '--branch', 'stable',
    'https://github.com/echasnovski/mini.nvim', mini_path
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
end

-- }}}
-- mini.deps {{{
require('mini.deps').setup({
  path = { package = path_package }
})
add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
-- }}}
-- Disabled: mini.bufremote {{{
add('echasnovski/mini.bufremove')
vim.g.bufremove_disable = true
--}}}
-- Disabled: mini.animate --{{{
add('echasnovski/mini.animate')
vim.g.animate_disable = true
-- }}}
-- mini.basics {{{
require('mini.basics').setup()
-- }}}
-- mini.base16 {{{
require('mini.base16').setup({
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
  use_cterm = true,
}) --}}}
-- mini.misc {{{
require('mini.misc').setup({
  make_global = { 'put', 'put_text', 'zoom'}
}) --}}}
-- mini.icons {{{
require('mini.icons').setup({
}) --}}}
-- mini.statusline {{{
require('mini.statusline').setup({
  content = {
    active = status_config
  },
})
function diagnostics_table(args)
  local info = vim.b.coc_diagnostic_info
  if MiniStatusline.is_truncated(args.trunc_width) or info == nil then
    return {}
  end
  local table = {}
  table.e = (info['error'] or 0) > 0 and 'E'..info['error'] or ''
  table.w = (info['warning'] or 0) > 0 and 'W'..info['warning'] or ''
  table.h = (info['hint'] or 0) > 0 and 'H'..info['hint'] or ''
  table.i = (info['information'] or 0) > 0 and 'I'..info['information'] or ''
  table.s = vim.g.coc_status
  return table
end
function status_config()
  local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
  local git           = MiniStatusline.section_git({ trunc_width = 75 })
  local diagnostics   = diagnostics_table({ trunc_width = 75 })
  local filename      = MiniStatusline.section_filename({ trunc_width = 140 })
  local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
  local location      = MiniStatusline.section_location({ trunc_width = 75 })

  return MiniStatusline.combine_groups({
    { hl = mode_hl,                  strings = { mode } },
    { hl = 'MiniStatuslineDevinfo',  strings = { git, diagnostics['s'] } },
    { hl = 'MiniStatuslineError',  strings = { diagnostics['e'] } },
    { hl = 'MiniStatuslineWarning',  strings = { diagnostics['w'] } },
    { hl = 'MiniStatuslineInfo',  strings = { diagnostics['i'] } },
    { hl = 'MiniStatuslineHint',  strings = { diagnostics['h'] } },
    '%<', -- Mark general truncate point
    { hl = 'MiniStatuslineFilename', strings = { filename } },
    '%=', -- End left alignment
    { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
    { hl = mode_hl,                  strings = { location } },
  })
end
-- }}}
-- mini.clue {{{
local miniclue = require('mini.clue')
miniclue.setup({
  triggers = {
    -- Leader triggers
    { mode = 'n', keys = '<Leader>' },
    { mode = 'x', keys = '<Leader>' },

    -- Built-in completion
    { mode = 'i', keys = '<C-x>' },

    -- `g` key
    { mode = 'n', keys = 'g' },
    { mode = 'x', keys = 'g' },

    -- Marks
    { mode = 'n', keys = "'" },
    { mode = 'n', keys = '`' },
    { mode = 'x', keys = "'" },
    { mode = 'x', keys = '`' },

    -- Registers
    { mode = 'n', keys = '"' },
    { mode = 'x', keys = '"' },
    { mode = 'i', keys = '<C-r>' },
    { mode = 'c', keys = '<C-r>' },

    -- Window commands
    { mode = 'n', keys = '<C-w>' },

    -- `z` key
    { mode = 'n', keys = 'z' },
    { mode = 'x', keys = 'z' },
  },

  clues = {
    -- Enhance this by adding descriptions for <Leader> mapping groups
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },
})-- }}}
-- mini.colors {{{
require('mini.colors').setup()
-- }}}
-- mini.comment {{{
require('mini.comment').setup({
  -- Module mappings. Use `''` (empty string) to disable one.
  mappings = {
    -- Toggle comment (like `gcip` - comment inner paragraph) for both
    -- Normal and Visual modes
    comment = 'gc',

    -- Toggle comment on current line
    comment_line = '<C-/>',

    -- Toggle comment on visual selection
    comment_visual = '<C-/>',

    -- Define 'comment' textobject (like `dgc` - delete whole comment block)
    -- Works also in Visual mode if mapping differs from `comment_visual`
    textobject = 'gc',
  },
})-- }}}
-- mini.cursorword {{{
require('mini.cursorword').setup()
-- }}}
-- mini.diff {{{
require('mini.diff').setup({
  -- Options for how hunks are visualized
  view = {
    -- Visualization style. Possible values are 'sign' and 'number'.
    -- Default: 'number' if line numbers are enabled, 'sign' otherwise.
    style = 'sign',

    -- Signs used for hunks with 'sign' view
    signs = { add = '+', change = '▒', delete = '-' },

    -- Priority of used visualization extmarks
    priority = 199,
  },
})
-- }}}
-- mini.extra {{{
require('mini.extra').setup()
-- }}}
-- mini.map {{{
require('mini.map').setup()
-- }}}
-- mini.tabline {{{

require('mini.tabline').setup()

for i = 1, 9, 1 do
  vim.keymap.set("n", string.format("<A-%s>", i), function()
    vim.api.nvim_set_current_buf(vim.t.bufs[i])
  end)
end

-- }}}
-- mini.visits {{{
require('mini.visits').setup()
-- }}}
-- mini.completion {{{
require('mini.completion').setup()
-- }}}
-- Telescope {{{
add({
  source = "nvim-telescope/telescope.nvim",
  depends = {
    'nvim-lua/plenary.nvim',
  },
  hooks = { post_checkout = function() end },
})
-- add({
--   source = 'nvim-telescope/telescope-fzf-native.nvim',
--   hooks = { post_checkout = function()
--     vim.fn.system('make')
--   end },
-- })
-- config {{{
require('telescope').setup({
  defaults = {-- {{{
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
},-- }}}
pickers = {-- {{{
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
},-- }}}
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
})
-- }}}
-- require("telescope").load_extension("fzf")
-- require("telescope").load_extension("aerial")

-- Keymaps {{{
vim.keymap.set("n", "<leader>f", "<cmd>Telescope oldfiles<CR>", { desc = "telescope find oldfiles" })
vim.keymap.set("n", "<leader>b", "<cmd>Telescope buffers<CR>", { desc = "telescope find buffers" })
vim.keymap.set("n", "//", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "telescope find in current buffer" })
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
          local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
          return current_picker:_get_prompt()
        end
      end

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

      map("i", "<CR>", insert_selected_snippet)
      map("i", "<C-T>", edit_snippet)
      map("n", "<CR>", insert_selected_snippet)

      return true
    end,
  })
end, { desc = "[S]earch [S]nippets" })

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

      map("i", "<CR>", cd_prompt)
      map("n", "<CR>", cd_prompt)

      return true
    end,
  })
end, { desc = "Search Directory" })-- }}}

-- }}}
-- toggleterm {{{

add({
  source = "akinsho/toggleterm.nvim",
  hooks = { post_checkout = function() end },
})
require("toggleterm").setup{
    persist_size = false,
    direction = 'float',
}

vim.keymap.set({ "n", "t" }, "<A-i>", function() vim.cmd("ToggleTerm direction=float") end, { desc = "terminal toggle floating term" })
vim.keymap.set({ "n", "t" }, "<A-v>", function() vim.cmd("ToggleTerm direction=horizontal") end, { desc = "terminal toggle floating term" })

--}}}
