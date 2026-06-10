" tests/helpers/assertions.vim — custom assertion helpers for vader tests

function! AssertEqual(expected, actual, msg) abort
  if a:expected != a:actual
    throw 'AssertionError: ' . a:msg
      \ . ' — expected ' . string(a:expected)
      \ . ' got ' . string(a:actual)
  endif
endfunction

function! AssertContains(list, item, msg) abort
  if index(a:list, a:item) == -1
    throw 'AssertionError: ' . a:msg
      \ . ' — list does not contain ' . string(a:item)
  endif
endfunction

function! AssertHasKey(dict, key, msg) abort
  if !has_key(a:dict, a:key)
    throw 'AssertionError: ' . a:msg . ' — dict missing key ' . a:key
  endif
endfunction

function! AssertMatch(pattern, str, msg) abort
  if a:str !~# a:pattern
    throw 'AssertionError: ' . a:msg
      \ . ' — "' . a:str . '" does not match /' . a:pattern . '/'
  endif
endfunction

function! AssertTrue(expr, msg) abort
  if !a:expr
    throw 'AssertionError: ' . a:msg . ' — expected true, got false'
  endif
endfunction

function! AssertFalse(expr, msg) abort
  if a:expr
    throw 'AssertionError: ' . a:msg . ' — expected false, got true'
  endif
endfunction
