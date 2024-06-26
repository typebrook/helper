require "nvchad.options"

-- add yours here!

local o = vim.o

o.clipboard = ''

-- To enable cursorline!
o.cursorlineopt ='both'

-- Let cursor be line in insert mode
o.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"

-- Enable break indent
o.breakindent = true

-- To have a better completion experience
o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
o.termguicolors = true

o.whichwrap = "b,s"
