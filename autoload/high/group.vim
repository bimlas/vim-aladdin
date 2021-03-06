" Group related functions
"
" Author:  Bimba Laszlo <https://github.com/bimlas>
" Source:  https://github.com/bimlas/vim-high
" License: MIT license

let s:match_id_index = 0

function! high#group#Register(group_name, ...) abort "{{{
  if a:0
    let new = extend(high#utils#Clone(), a:1)
  else
    let new = high#group#LoadSettings(a:group_name)
  endif
  " TODO: if settings not changed, then it's an invalid group name.
  " else
  "   throw '[high] No such group: '.a:group_name
  " endif
  let new.__group_name = a:group_name
  let g:high.registered_groups[a:group_name] = new
  " If the group controlls the highlight by self (manual highlight), then
  " initialization would never reach.
  if !new.__auto_highlight
    call high#group#Init(a:group_name)
  endif
  return new
endfunction "}}}

function! high#group#LoadSettings(group_name) abort "{{{
  let autoloaded = 1
  let user_defined = 1
  let settings = high#utils#Clone()
  try
    call extend(settings, high#light#{a:group_name}#Define())
  catch /.*/
    let autoloaded = 0
  endtry
  try
    call extend(settings, g:high_lighters[a:group_name])
  catch /.*/
    let user_defined = 0
  endtry
  if !(autoloaded || user_defined)
    throw '[high] No such group: '.a:group_name
  endif
  return settings
endfunction "}}}

function! high#group#Init(group_name) "{{{
  let settings = high#group#GetSettings(a:group_name)
  let g:high.group_members[a:group_name] = []
  if !empty(settings.__init_function)
    call call(settings.__init_function, [settings])
  else
    call high#group#AddMember(settings)
  endif
endfunction "}}}

function! high#group#AddMember(lighter) "{{{
  let a:lighter.__match_id_index = s:match_id_index
  let s:match_id_index += 1
  call extend(g:high.group_members[a:lighter.__group_name], [a:lighter])
endfunction "}}}

function! high#group#IsRegistered(group_name) "{{{
  return has_key(g:high.registered_groups, a:group_name)
endfunction "}}}

function! high#group#IsInitialized(group_name) "{{{
  return has_key(g:high.group_members, a:group_name)
endfunction "}}}

function! high#group#IsEnabled(group_settings) "{{{
  return a:group_settings.enabled && high#group#IsEnabledForFiletype(a:group_settings, &filetype)
endfunction "}}}

function! high#group#IsEnabledForFiletype(group_settings, filetype) "{{{
  return (empty(a:group_settings.whitelist) || index(a:group_settings.whitelist, a:filetype) >= 0)
  \ && (empty(a:group_settings.blacklist) || index(a:group_settings.blacklist, a:filetype) < 0)
endfunction "}}}

function! high#group#GetSettings(group_name) "{{{
  return get(g:high.registered_groups, a:group_name, {})
endfunction "}}}

function! high#group#GetMembers(group_name) "{{{
  return get(g:high.group_members, a:group_name, [])
endfunction "}}}

function! high#group#HaveToUpdate(group_settings) "{{{
  return empty(a:group_settings.__update_function)
  \ ? 0
  \ : a:group_settings.__update_function(a:group_settings)
endfunction "}}}
