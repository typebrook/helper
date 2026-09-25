" Reload labwc on every :w, instead of only when the editor is closed.
"
" Sourced by the W-o binding in rc.xml (vim -S), so it shapes that editing
" session only and leaves vim's behaviour everywhere else alone.
"
" `labwc --reconfigure` cannot report a bad config: it only signals the running
" compositor, which parses in its own process and quietly keeps the last good
" config. So the XML is checked here first and a failure is reported in the
" editor, rather than leaving a save that looks applied but is not. Note that
" XML comments may not contain a double dash -- that is the easiest way to
" write an rc.xml that no longer parses.

if executable('xmllint')
  let s:check = 'xmllint --noout '
else
  let s:check = 'python3 -c ''import sys,xml.dom.minidom as m; m.parse(sys.argv[1])'' '
endif

function! s:Reconfigure() abort
  let l:path = expand('<afile>:p')
  let l:name = fnamemodify(l:path, ':t')

  if l:path =~# '\.xml$'
    let l:out = system(s:check . shellescape(l:path))
    if v:shell_error
      echohl ErrorMsg
      for l:line in split(l:out, '\n')[0:3]
        echomsg l:line
      endfor
      echomsg l:name . ' is not well-formed: labwc NOT reloaded'
      echohl None
      return
    endif
  endif

  call system('labwc --reconfigure')
  redraw
  echomsg 'labwc reconfigured (' . l:name . ')'
endfunction

" autostart and environment are read at login only, so reloading on those would
" report a change that has not actually taken effect.
augroup labwc_reconfigure
  autocmd!
  autocmd BufWritePost */.config/labwc/rc.xml call s:Reconfigure()
  autocmd BufWritePost */.config/labwc/menu.xml call s:Reconfigure()
  autocmd BufWritePost */.config/labwc/themerc-override call s:Reconfigure()
augroup END
