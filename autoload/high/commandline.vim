" Command line interface for vim-high, a Vim custom highlighter plugin
"
" Author:  Bimba Laszlo <https://github.com/bimlas>
" Source:  https://github.com/bimlas/vim-high
" License: MIT license

function! high#commandline#listLighters(argLead, cmdLine, cursorPos) "{{{
  return filter(keys(g:high.named_lighters), 'v:val =~ "^'.a:argLead.'"')
endfunction "}}}

function! high#commandline#toggle(lighter, ...) "{{{
  for l in g:high.named_lighters[a:lighter]
    let l.enabled = a:0 ? a:1 : !l.enabled
    windo call high#main#Highlight(l)
  endfor
endfunction "}}}
