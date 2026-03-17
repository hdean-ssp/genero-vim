" Integration test for sign column stability across compilation scenarios

set runtimepath+=.

" Test: Sign column remains stable through multiple error/clear cycles
function! Test_sign_column_stability_cycles() abort
  let g:genero_tools_config = {}
  let g:genero_tools_config.compiler_sign_column_always_visible = v:true
  
  enew
  
  " Initialize
  call genero_tools#compiler#signs#init()
  let initial = &signcolumn
  
  " Cycle 1: Place errors
  let errors = [{'file': expand('%'), 'line': 1, 'message': 'Error 1'}]
  call genero_tools#compiler#signs#place(errors, [], [])
  let after_errors = &signcolumn
  
  " Cycle 2: Clear errors
  call genero_tools#compiler#signs#clear()
  let after_clear = &signcolumn
  
  " Cycle 3: Place different errors
  let errors2 = [
    \ {'file': expand('%'), 'line': 2, 'message': 'Error 2'},
    \ {'file': expand('%'), 'line': 3, 'message': 'Error 3'}
  \ ]
  call genero_tools#compiler#signs#place(errors2, [], [])
  let after_errors2 = &signcolumn
  
  " Cycle 4: Place warnings
  let warnings = [{'file': expand('%'), 'line': 4, 'message': 'Warning 1'}]
  call genero_tools#compiler#signs#place([], warnings, [])
  let after_warnings = &signcolumn
  
  " Cycle 5: Clear all
  call genero_tools#compiler#signs#clear()
  let final = &signcolumn
  
  bdelete!
  
  " All should be 'yes'
  if initial == 'yes' && after_errors == 'yes' && after_clear == 'yes' && 
     \ after_errors2 == 'yes' && after_warnings == 'yes' && final == 'yes'
    return 'PASS'
  else
    return 'FAIL: Inconsistent signcolumn values'
  endif
endfunction

" Test: Sign column with mixed errors and warnings
function! Test_sign_column_with_mixed_errors_warnings() abort
  let g:genero_tools_config = {}
  let g:genero_tools_config.compiler_sign_column_always_visible = v:true
  
  enew
  
  call genero_tools#compiler#signs#init()
  
  let errors = [
    \ {'file': expand('%'), 'line': 1, 'message': 'Error 1'},
    \ {'file': expand('%'), 'line': 3, 'message': 'Error 2'}
  \ ]
  
  let warnings = [
    \ {'file': expand('%'), 'line': 2, 'message': 'Warning 1'},
    \ {'file': expand('%'), 'line': 4, 'message': 'Warning 2'}
  \ ]
  
  let info = [
    \ {'file': expand('%'), 'line': 5, 'message': 'Info 1'}
  \ ]
  
  call genero_tools#compiler#signs#place(errors, warnings, info)
  
  let result = &signcolumn == 'yes' ? 'PASS' : 'FAIL: ' . &signcolumn
  
  bdelete!
  
  return result
endfunction

" Test: Update function maintains sign column
function! Test_update_maintains_sign_column() abort
  let g:genero_tools_config = {}
  let g:genero_tools_config.compiler_sign_column_always_visible = v:true
  
  enew
  
  call genero_tools#compiler#signs#init()
  
  " Create a result object
  let result = {
    \ 'success': v:true,
    \ 'errors': [{'file': expand('%'), 'line': 1, 'message': 'Error'}],
    \ 'warnings': [],
    \ 'info': []
  \ }
  
  call genero_tools#compiler#signs#update(result)
  
  let col1 = &signcolumn
  
  " Update with different result
  let result2 = {
    \ 'success': v:true,
    \ 'errors': [],
    \ 'warnings': [{'file': expand('%'), 'line': 2, 'message': 'Warning'}],
    \ 'info': []
  \ }
  
  call genero_tools#compiler#signs#update(result2)
  
  let col2 = &signcolumn
  
  bdelete!
  
  if col1 == 'yes' && col2 == 'yes'
    return 'PASS'
  else
    return 'FAIL: signcolumn changed'
  endif
endfunction

" Test: Failed compilation clears signs but keeps column
function! Test_failed_compilation_keeps_column() abort
  let g:genero_tools_config = {}
  let g:genero_tools_config.compiler_sign_column_always_visible = v:true
  
  enew
  
  call genero_tools#compiler#signs#init()
  
  " Place some signs
  let errors = [{'file': expand('%'), 'line': 1, 'message': 'Error'}]
  call genero_tools#compiler#signs#place(errors, [], [])
  
  let col_before = &signcolumn
  
  " Simulate failed compilation
  let result = {'success': v:false}
  call genero_tools#compiler#signs#update(result)
  
  let col_after = &signcolumn
  
  bdelete!
  
  if col_before == 'yes' && col_after == 'yes'
    return 'PASS'
  else
    return 'FAIL: signcolumn changed after failed compilation'
  endif
endfunction

" Run tests
let output = []
call add(output, 'Sign Column Integration Tests')
call add(output, '=============================')
call add(output, '')
call add(output, 'Test 1: Stability through error/clear cycles - ' . Test_sign_column_stability_cycles())
call add(output, 'Test 2: Mixed errors and warnings - ' . Test_sign_column_with_mixed_errors_warnings())
call add(output, 'Test 3: Update function maintains column - ' . Test_update_maintains_sign_column())
call add(output, 'Test 4: Failed compilation keeps column - ' . Test_failed_compilation_keeps_column())
call add(output, '')

call writefile(output, 'test/test_sign_column_integration_results.txt')
quit
