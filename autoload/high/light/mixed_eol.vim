" Highlight mixed EOL (mixed end-of-line), highlight ^M
"
" Author:  Bimba Laszlo <https://github.com/bimlas>
" Source:  https://github.com/bimlas/vim-high
" License: MIT license

function! high#light#mixed_eol#define(settings)
  let lighter = high#core#Clone()
  call high#core#AddLighter('mixed_eol', lighter)

  call high#core#Customize(lighter, a:settings)

  let lighter.pattern = '\r'
endfunction
