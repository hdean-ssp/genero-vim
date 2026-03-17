" Test sign column stability - ensures sign column remains visible

set runtimepath+=.

" Test 1: Sign column is set to persistent when enabled
function! Test_sign_column_persistent_when_enabled() abort
  " Initialize config with persistent sign column enabled
  let g:genero_tools_config = {}
  let g:genero_tools_config.compiler_sign_column_always_visible = v:true
  
  " Create a test buffer
  new test_buffer.4gl
  
  " Initialize signs and set persistent column
  call genero_tools#compiler#signs#init()
  
  " Check that signcolumn is set to 'yes'
  if &signcolumn == 'yes'
    call delete('test_buffer.4gl')
    return 'PASS'
  else
    call delete('test_buffer.4gl')
    return 'FAIL: signcolumn is ' . &signcolumn . ', expected yes'
  endif
endfunction

" Test 2: Sign column remains visible with no errors
function! Test_sign_column_visible_with_no_errors() abort
  let g:genero_tools_config = {}
  let g:genero_tools_config.compiler_sign_column_always_visible = v:true
  
  new test_buffer2.4gl
  
  " Initialize and place empty signs
  call genero_tools#compiler#signs#init()
  call genero_tools#compiler#signs#place([], [], [])
  
  " Check that signcolumn is still 'yes'
  if &signcolumn == 'yes'
    call delete('test_buffer2.4gl')
    return 'PASS'
  else
    call delete('test_buffer2.4gl')
    return 'FAIL: signcolumn is ' . &signcolumn . ', expected yes'
  endif
endfunction

" Test 3: Sign column remains visible when errors appear
function! Test_sign_column_visible_with_errors() abort
  let g:genero_tools_config = {}
  let g:genero_tools_config.compiler_sign_column_always_visible = v:true
  
  new test_buffer3.4gl
  
  " Initialize signs
  call genero_tools#compiler#signs#init()
  
  " Create test errors
  let errors = [
    \ {'file': 'test_buffer3.4gl', 'line': 1, 'message': 'Error 1'},
    \ {'file': 'test_buffer3.4gl', 'line': 5, 'message': 'Error 2'}
  \ ]
  
  " Place signs
  call genero_tools#compiler#signs#place(errors, [], [])
  
  " Check that signcolumn is still 'yes'
  if &signcolumn == 'yes'
    call delete('test_buffer3.4gl')
    return 'PASS'
  else
    call delete('test_buffer3.4gl')
    return 'FAIL: signcolumn is ' . &signcolumn . ', expected yes'
  endif
endfunction

" Test 4: Sign column remains visible when errors are cleared
function! Test_sign_column_visible_after_clearing_errors() abort
  let g:genero_tools_config = {}
  let g:genero_tools_config.compiler_sign_column_always_visible = v:true
  
  new test_buffer4.4gl
  
  " Initialize signs
  call genero_tools#compiler#signs#init()
  
  " Place errors
  let errors = [{'file': 'test_buffer4.4gl', 'line': 1, 'message': 'Error'}]
  call genero_tools#compiler#signs#place(errors, [], [])
  
  " Clear errors
  call genero_tools#compiler#signs#clear()
  
  " Check that signcolumn is still 'yes'
  if &signcolumn == 'yes'
    call delete('test_buffer4.4gl')
    return 'PASS'
  else
    call delete('test_buffer4.4gl')
    return 'FAIL: signcolumn is ' . &signcolumn . ', expected yes'
  endif
endfunction

" Test 5: Sign column respects disabled config
function! Test_sign_column_respects_disabled_config() abort
  let g:genero_tools_config = {}
  let g:genero_tools_config.compiler_sign_column_always_visible = v:false
  
  new test_buffer5.4gl
  
  " Initialize signs
  call genero_tools#compiler#signs#init()
  
  " When disabled, signcolumn should not be set to 'yes'
  " (it will be whatever the default is, not 'yes')
  if &signcolumn != 'yes'
    call delete('test_buffer5.4gl')
    return 'PASS'
  else
    call delete('test_buffer5.4gl')
    return 'FAIL: signcolumn should not be yes when disabled'
  endif
endfunction

" Test 6: Multiple compilations maintain sign column visibility
function! Test_sign_column_stable_across_compilations() abort
  let g:genero_tools_config = {}
  let g:genero_tools_config.compiler_sign_column_always_visible = v:true
  
  new test_buffer6.4gl
  
  " Initialize signs
  call genero_tools#compiler#signs#init()
  
  " First compilation with errors
  let errors1 = [{'file': 'test_buffer6.4gl', 'line': 1, 'message': 'Error 1'}]
  call genero_tools#compiler#signs#place(errors1, [], [])
  let col1 = &signcolumn
  
  " Second compilation with different errors
  let errors2 = [
    \ {'file': 'test_buffer6.4gl', 'line': 2, 'message': 'Error 2'},
    \ {'file': 'test_buffer6.4gl', 'line': 3, 'message': 'Error 3'}
  \ ]
  call genero_tools#compiler#signs#place(errors2, [], [])
  let col2 = &signcolumn
  
  " Third compilation with no errors
  call genero_tools#compiler#signs#place([], [], [])
  let col3 = &signcolumn
  
  " All should be 'yes'
  if col1 == 'yes' && col2 == 'yes' && col3 == 'yes'
    call delete('test_buffer6.4gl')
    return 'PASS'
  else
    call delete('test_buffer6.4gl')
    return 'FAIL: signcolumn changed during compilations: ' . col1 . ', ' . col2 . ', ' . col3
  endif
endfunction

" Test 7: Configuration option is properly initialized
function! Test_config_option_initialized() abort
  call genero_tools#config#init()
  
  let config_value = genero_tools#config#get('compiler_sign_column_always_visible')
  
  if config_value == v:true
    return 'PASS'
  else
    return 'FAIL: compiler_sign_column_always_visible is ' . config_value . ', expected true'
  endif
endfunction

" Test 8: Persistent column function works correctly
function! Test_set_persistent_column_function() abort
  let g:genero_tools_config = {}
  let g:genero_tools_config.compiler_sign_column_always_visible = v:true
  
  new test_buffer8.4gl
  
  " Call the function directly
  call genero_tools#compiler#signs#set_persistent_column()
  
  if &signcolumn == 'yes'
    call delete('test_buffer8.4gl')
    return 'PASS'
  else
    call delete('test_buffer8.4gl')
    return 'FAIL: signcolumn is ' . &signcolumn . ', expected yes'
  endif
endfunction

" Run all tests
let output = []
call add(output, 'Sign Column Stability Tests')
call add(output, '============================')
call add(output, '')

call add(output, 'Test 1: Sign column persistent when enabled - ' . Test_sign_column_persistent_when_enabled())
call add(output, 'Test 2: Sign column visible with no errors - ' . Test_sign_column_visible_with_no_errors())
call add(output, 'Test 3: Sign column visible with errors - ' . Test_sign_column_visible_with_errors())
call add(output, 'Test 4: Sign column visible after clearing errors - ' . Test_sign_column_visible_after_clearing_errors())
call add(output, 'Test 5: Sign column respects disabled config - ' . Test_sign_column_respects_disabled_config())
call add(output, 'Test 6: Sign column stable across compilations - ' . Test_sign_column_stable_across_compilations())
call add(output, 'Test 7: Configuration option initialized - ' . Test_config_option_initialized())
call add(output, 'Test 8: Set persistent column function - ' . Test_set_persistent_column_function())

call add(output, '')
call add(output, 'All tests completed')

call writefile(output, 'test/test_sign_column_stability_results.txt')
quit
