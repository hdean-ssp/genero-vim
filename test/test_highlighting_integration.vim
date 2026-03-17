" Integration test for Task 22: E2.1 - Error Highlighting
" Tests highlighting with actual compiler workflow

set runtimepath+=.

" Test 1: Highlighting with compiler result
function! Test_highlighting_with_compiler_result() abort
  call genero_tools#compiler#highlight#init()
  call genero_tools#compiler#highlight#clear()
  
  " Simulate compiler result
  let result = {
    \ 'success': v:true,
    \ 'errors': [
      \ {'file': 'test.4gl', 'line': 10, 'col': 5, 'end_col': 15, 'message': 'Syntax error'},
      \ {'file': 'test.4gl', 'line': 20, 'col': 1, 'end_col': 10, 'message': 'Undefined variable'}
    \ ],
    \ 'warnings': [
      \ {'file': 'test.4gl', 'line': 15, 'col': 8, 'end_col': 18, 'message': 'Unused variable'},
      \ {'file': 'test.4gl', 'line': 25, 'col': 3, 'end_col': 12, 'message': 'Deprecated function'}
    \ ],
    \ 'info': []
  \ }
  
  " Apply highlighting
  let apply_result = genero_tools#compiler#highlight#apply(result.errors, result.warnings)
  
  if apply_result.success
    return 'PASS'
  else
    return 'FAIL: ' . apply_result.error
  endif
endfunction

" Test 2: Clearing highlights after compilation
function! Test_clearing_after_compilation() abort
  call genero_tools#compiler#highlight#init()
  
  " Apply some highlights
  let errors = [
    \ {'line': 1, 'col': 1, 'end_col': 5, 'message': 'Error'},
    \ {'line': 5, 'col': 1, 'end_col': 10, 'message': 'Error'}
  \ ]
  call genero_tools#compiler#highlight#apply(errors, [])
  
  " Clear them
  let clear_result = genero_tools#compiler#highlight#clear()
  
  if clear_result.success
    return 'PASS'
  else
    return 'FAIL: ' . clear_result.error
  endif
endfunction

" Test 3: Multiple compilations (clear and reapply)
function! Test_multiple_compilations() abort
  call genero_tools#compiler#highlight#init()
  
  " First compilation
  let errors1 = [{'line': 1, 'col': 1, 'end_col': 5, 'message': 'Error 1'}]
  call genero_tools#compiler#highlight#apply(errors1, [])
  
  " Second compilation (should clear first and apply new)
  let errors2 = [
    \ {'line': 2, 'col': 1, 'end_col': 5, 'message': 'Error 2'},
    \ {'line': 3, 'col': 1, 'end_col': 5, 'message': 'Error 3'}
  \ ]
  call genero_tools#compiler#highlight#apply(errors2, [])
  
  if !has('nvim')
    let matches = getmatches()
    let error_matches = filter(copy(matches), "v:val.group == 'GeneroError'")
    
    " Should have 2 matches from second compilation (first was cleared)
    if len(error_matches) == 2
      return 'PASS'
    else
      return 'FAIL: expected 2 matches, got ' . len(error_matches)
    endif
  else
    return 'PASS'
  endif
endfunction

" Test 4: Unused variable highlighting
function! Test_unused_variable_highlighting() abort
  call genero_tools#compiler#highlight#init()
  call genero_tools#compiler#highlight#clear()
  
  " Create warnings for unused variables
  let warnings = [
    \ {'line': 1, 'col': 1, 'message': "The symbol 'l_unused_var' is unused.", 'code': '(-6615)'},
    \ {'line': 2, 'col': 1, 'message': "The symbol 'l_another_var' is unused.", 'code': '(-6615)'}
  \ ]
  
  " Apply unused variable highlighting
  call genero_tools#compiler#highlight#unused_vars(warnings)
  
  if !has('nvim')
    let matches = getmatches()
    let unused_matches = filter(copy(matches), "v:val.group == 'GeneroUnusedVariable'")
    
    if len(unused_matches) >= 2
      return 'PASS'
    else
      return 'FAIL: expected 2+, got ' . len(unused_matches)
    endif
  else
    return 'PASS'
  endif
endfunction

" Test 5: Highlight groups have correct colors
function! Test_highlight_colors() abort
  call genero_tools#compiler#highlight#init()
  
  " Check error highlight
  let error_hl = execute('highlight GeneroError')
  let warning_hl = execute('highlight GeneroWarning')
  let info_hl = execute('highlight GeneroInfo')
  
  " Verify that highlights have background colors defined
  if error_hl =~? 'guibg' && warning_hl =~? 'guibg' && info_hl =~? 'guibg'
    return 'PASS'
  else
    return 'FAIL: missing colors'
  endif
endfunction

" Run tests and write to file
let output = []
call add(output, 'Error Highlighting Integration Tests')
call add(output, '====================================')
call add(output, '')
call add(output, 'Test 1: Highlighting with compiler result - ' . Test_highlighting_with_compiler_result())
call add(output, 'Test 2: Clearing after compilation - ' . Test_clearing_after_compilation())
call add(output, 'Test 3: Multiple compilations - ' . Test_multiple_compilations())
call add(output, 'Test 4: Unused variable highlighting - ' . Test_unused_variable_highlighting())
call add(output, 'Test 5: Highlight colors - ' . Test_highlight_colors())

call writefile(output, 'test/test_highlighting_integration_results.txt')
quit
