-- vim: foldmethod=marker foldmarker={{{,}}}

-- Install mini.nvim -{{{
-- Put this at the top of 'init.lua'
local path_package = vim.fn.stdpath('data') .. '/site'
vim.o.packpath=path_package
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
require('mini.base16').setup({ --{{{
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
require('mini.misc').setup({ --{{{
  make_global = { 'put', 'put_text', 'zoom'}
}) --}}}
require('mini.statusline').setup({--{{{
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
require('mini.animate').setup()--{{{
-- }}}
require('mini.basics').setup()--{{{
-- }}}
-- require('mini.bufremove').setup() --{{{
--}}}
require('mini.clue') --{{{
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
require('mini.colors').setup()-- {{{
-- }}}
require('mini.comment').setup({-- {{{
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
require('mini.cursorword').setup()-- {{{
-- }}}
require('mini.cursorword').setup()-- {{{
-- }}}
require('mini.diff').setup()-- {{{
-- }}}
