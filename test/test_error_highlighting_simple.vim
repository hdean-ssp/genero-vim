" Simple test for Task 22: E2.1 - Add Line/Text Error Highlighting

set runtimepath+=.

" Test 1: Highlight groups are defined
function! Test_highlight_groups_defined() abort
  call genero_tools#compiler#highlight#init()
  
  " Check that highlight groups exist
  let error_hl = execute('highlight GeneroError')
  let warning_hl = execute('highlight GeneroWarning')
  let info_hl = execute('highlight GeneroInfo')
  
  if error_hl =~? 'GeneroError' && warning_hl =~? 'GeneroWarning' && info_hl =~? 'GeneroInfo'
    return 1
  else
    return 0
  endif
endfunction

" Test 2: Line highlighting for errors
function! Test_line_highlighting_errors() abort
  call genero_tools#compiler#highlight#init()
  call genero_tools#compiler#highlight#clear()
  
  " Create test errors
  let errors = [
    \ {'line': 1, 'col': 1, 'end_col': 5, 'message': 'Test error 1'},
    \ {'line': 5, 'col': 1, 'end_col': 10, 'message': 'Test error 2'},
    \ {'line': 10, 'col': 1, 'end_col': 15, 'message': 'Test error 3'}
  \ ]
  
  " Apply highlighting
  call genero_tools#compiler#highlight#apply(errors, [])
  
  " Check that matches were added (Vim only)
  if !has('nvim')
    let matches = getmatches()
    let error_matches = filter(copy(matches), "v:val.group == 'GeneroError'")
    
    if len(error_matches) == 3
      return 1
    else
      return 0
    endif
  else
    return 1
  endif
endfunction

" Test 3: Text highlighting for warnings
function! Test_text_highlighting_warnings() abort
  call genero_tools#compiler#highlight#init()
  call genero_tools#compiler#highlight#clear()
  
  " Create test warnings with column ranges
  let warnings = [
    \ {'line': 2, 'col': 5, 'end_col': 15, 'message': 'Test warning 1'},
    \ {'line': 7, 'col': 10, 'end_col': 20, 'message': 'Test warning 2'}
  \ ]
  
  " Apply highlighting
  call genero_tools#compiler#highlight#apply([], warnings)
  
  " Check that matches were added (Vim only)
  if !has('nvim')
    let matches = getmatches()
    let warning_matches = filter(copy(matches), "v:val.group == 'GeneroWarning'")
    
    if len(warning_matches) == 2
      return 1
    else
      return 0
    endif
  else
    return 1
  endif
endfunction

" Test 4: Clearing highlights
function! Test_clear_highlights() abort
  call genero_tools#compiler#highlight#init()
  
  " Create and apply highlights
  let errors = [
    \ {'line': 1, 'col': 1, 'end_col': 5, 'message': 'Error 1'},
    \ {'line': 5, 'col': 1, 'end_col': 10, 'message': 'Error 2'}
  \ ]
  
  call genero_tools#compiler#highlight#apply(errors, [])
  
  " Clear highlights
  let clear_result = genero_tools#compiler#highlight#clear()
  
  if !has('nvim')
    " Check that matches were cleared (Vim only)
    let matches = getmatches()
    let remaining_matches = filter(copy(matches), 
      \ "v:val.group == 'GeneroError' || v:val.group == 'GeneroWarning' || v:val.group == 'GeneroInfo'")
    
    if len(remaining_matches) == 0 && clear_result.success
      return 1
    else
      return 0
    endif
  else
    if clear_result.success
      return 1
    else
      return 0
    endif
  endif
endfunction

" Test 5: Apply function returns success
function! Test_apply_returns_success() abort
  call genero_tools#compiler#highlight#init()
  
  let errors = [{'line': 1, 'col': 1, 'end_col': 5, 'message': 'Error'}]
  let result = genero_tools#compiler#highlight#apply(errors, [])
  
  if result.success && result.error == ''
    return 1
  else
    return 0
  endif
endfunction

" Run tests
let test_results = []
call add(test_results, Test_highlight_groups_defined())
call add(test_results, Test_line_highlighting_errors())
call add(test_results, Test_text_highlighting_warnings())
call add(test_results, Test_clear_highlights())
call add(test_results, Test_apply_returns_success())

let passed = len(filter(copy(test_results), 'v:val == 1'))
let total = len(test_results)

if passed == total
  echom 'PASS: All ' . total . ' tests passed'
  quit
else
  echom 'FAIL: ' . passed . '/' . total . ' tests passed'
  quit
endif
