" Test that highlighting works alongside signs

set runtimepath+=.

" Test: Highlighting and signs work together
function! Test_highlighting_with_signs() abort
  call genero_tools#compiler#highlight#init()
  call genero_tools#compiler#signs#init()
  
  " Create test data
  let errors = [
    \ {'file': 'test.4gl', 'line': 1, 'col': 1, 'end_col': 5, 'message': 'Error 1'},
    \ {'file': 'test.4gl', 'line': 5, 'col': 1, 'end_col': 10, 'message': 'Error 2'}
  \ ]
  
  let warnings = [
    \ {'file': 'test.4gl', 'line': 3, 'col': 5, 'end_col': 15, 'message': 'Warning 1'}
  \ ]
  
  " Apply both signs and highlighting
  try
    call genero_tools#compiler#signs#place(errors, warnings, [])
    call genero_tools#compiler#highlight#apply(errors, warnings)
    return 'PASS'
  catch
    return 'FAIL: ' . v:exception
  endtry
endfunction

" Test: Clearing both signs and highlights
function! Test_clearing_signs_and_highlights() abort
  call genero_tools#compiler#highlight#init()
  call genero_tools#compiler#signs#init()
  
  " Create test data
  let errors = [{'file': 'test.4gl', 'line': 1, 'col': 1, 'end_col': 5, 'message': 'Error'}]
  
  " Apply both
  call genero_tools#compiler#signs#place(errors, [], [])
  call genero_tools#compiler#highlight#apply(errors, [])
  
  " Clear both
  try
    call genero_tools#compiler#signs#clear()
    call genero_tools#compiler#highlight#clear()
    return 'PASS'
  catch
    return 'FAIL: ' . v:exception
  endtry
endfunction

" Run tests
let output = []
call add(output, 'Highlighting with Signs Tests')
call add(output, '=============================')
call add(output, '')
call add(output, 'Test 1: Highlighting and signs work together - ' . Test_highlighting_with_signs())
call add(output, 'Test 2: Clearing signs and highlights - ' . Test_clearing_signs_and_highlights())

call writefile(output, 'test/test_highlighting_with_signs_results.txt')
quit
