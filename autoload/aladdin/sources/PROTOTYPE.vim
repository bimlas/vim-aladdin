function! aladdin#sources#PROTOTYPE#define()
  let obj = {}
  let obj.whitelist = []
  let obj.blacklist = []
  let obj.hlgroup = 'ErrorMsg'
  let obj.priority = 1000
  let obj._pattern = ''
  let obj._pattern_to_eval = ''
  let obj._autoHighlight = 1
  let obj._index = -1

  function! obj.Highlight() "{{{
    if self._autoHighlight
      call self._ManualHighlight(1)
    endif
  endfunction "}}}

  function! obj._ManualHighlight(enabled) "{{{
    if a:enabled && self._EnabledForFiletype(&filetype)
      call self._MatchAdd()
    else
      call self._MatchClear()
    endif
  endfunction "}}}

  function! obj._Clone() "{{{
    return deepcopy(self)
  endfunction "}}}

  function! obj._AddSource(source) "{{{
    let a:source._index = len(g:aladdin.loaded_sources)
    call extend(g:aladdin.loaded_sources, [a:source])
  endfunction "}}}

  function! obj._EnabledForFiletype(filetype) "{{{
    return (len(self.whitelist) == 0 || index(self.whitelist, a:filetype) >= 0)
    \ && (len(self.blacklist) == 0 || index(self.blacklist, a:filetype) < 0)
  endfunction "}}}

  function! obj._MatchAdd() "{{{
    if self._PatternChanged()
      call self._MatchClear()
    endif
    if self._GetMatchID() < 0
      call self._SetMatchID(matchadd(self.hlgroup, self._pattern, self.priority))
    endif
  endfunction "}}}

  function! obj._MatchClear() "{{{
    if self._GetMatchID() >= 0
      call matchdelete(self._GetMatchID())
      call self._SetMatchID(-1)
    endif
  endfunction "}}}

  function! obj._InitMatchID() "{{{
    if !exists('w:aladdin_match_ids')
      let w:aladdin_match_ids = {}
    endif
  endfunction "}}}

  function! obj._GetMatchID() "{{{
    call self._InitMatchID()
    return get(get(w:, 'aladdin_match_ids', []), self._index, -1)
  endfunction "}}}

  function! obj._SetMatchID(id) "{{{
    call self._InitMatchID()
    let w:aladdin_match_ids[self._index] = a:id
  endfunction "}}}

  function! obj._PatternChanged() "{{{
    if !len(self._pattern_to_eval)
      return 0
    endif
    let self._pattern = eval(self._pattern_to_eval)
    " TODO: find a faster way to detect if the match is exists in the current
    " window.
    let current_match = filter(getmatches(), 'v:val.id == '.self._GetMatchID())
    return len(current_match) && (self._pattern != current_match[0].pattern)
  endfunction "}}}

  function! obj._Customize(settings) "{{{
    for [key, value] in items(a:settings)
      let self[key] = value
    endfor
  endfunction "}}}

  return obj
endfunction
