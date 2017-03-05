" Group related functions
"
" Author:  Bimba Laszlo <https://github.com/bimlas>
" Source:  https://github.com/bimlas/vim-high
" License: MIT license

function! high#group#Register(group_name) "{{{
  let new = high#core#Clone()
  if high#group#IsAutoloaded(a:group_name)
    call extend(new, high#light#{a:group_name}#Defaults())
    if exists('g:high_lighters')
      call extend(new, get(g:high_lighters, a:group_name, {}))
    endif
    call extend(new, high#light#{a:group_name}#Rules(new))
  elseif high#group#IsUserDefined(a:group_name)
    call extend(new, g:high_lighters[a:group_name])
  else
    throw '[high] No such group: '.a:group_name
  endif
  let new.__group_name = a:group_name
  let g:high.registered_groups[a:group_name] = new
  " If the group controlls the highlight by self (manual highlight), then
  " initialization would never reach.
  if !new.__auto_highlight
    call high#group#Init(a:group_name)
  endif
  return new
endfunction "}}}

function! high#group#Init(group_name) "{{{
  let settings = high#group#GetSettings(a:group_name)
  let g:high.lighter_groups[a:group_name] = []
  if high#group#IsAutoloaded(a:group_name)
    call high#light#{a:group_name}#Init(settings)
  endif
endfunction "}}}

function! high#group#IsAutoloaded(group_name) "{{{
  return !empty(globpath(&runtimepath, 'autoload/high/light/'.a:group_name.'.vim'))
endfunction "}}}

function! high#group#IsUserDefined(group_name) "{{{
  return exists('g:high_lighters') && has_key(g:high_lighters, a:group_name)
endfunction "}}}

function! high#group#IsRegistered(group_name) "{{{
  return has_key(g:high.registered_groups, a:group_name)
endfunction "}}}

function! high#group#IsInitialized(group_name) "{{{
  return has_key(g:high.lighter_groups, a:group_name)
endfunction "}}}

function! high#group#GetSettings(group_name) "{{{
  return get(g:high.registered_groups, a:group_name, {})
endfunction "}}}

function! high#group#GetMembers(group_name) "{{{
  return get(g:high.lighter_groups, a:group_name, [])
endfunction "}}}

function! high#group#DropMembers(group_name) "{{{
  windo call high#core#ManualHighlight(high#group#GetSettings(a:group_name), 0)
  let g:high.lighter_groups[a:group_name] = []
endfunction "}}}
