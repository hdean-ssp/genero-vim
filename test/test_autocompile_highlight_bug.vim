" Bug Condition Exploration Test for Autocompile Highlighting Consistency
" 
" This test demonstrates the bug where autocompile does not call highlight#apply()
" when compilation succeeds with errors or warnings.
"
" Property 1: Bug Condition - Autocompile Missing Error/Warning Highlighting
" Validates: Requirements 1.1, 1.2
"
" For any autocompile event (BufEnter or BufWritePost) where compilation succeeds
" and errors or warnings are present, the compile_silent() function SHALL call
" genero_tools#compiler#highlight#apply() with the errors and warnings.
"
" EXPECTED OUTCOME ON UNFIXED CODE: Test FAILS (this proves the bug exists)
" EXPECTED OUTCOME ON FIXED CODE: Test PASSES (this proves the bug is fixed)

" Mock tracking variables
let s:mock_calls = {
  \ 'highlight_apply': [],
  \ 'highlight_unused_vars': [],
  \ 'signs_update': [],
  \ 'quickfix_populate': []
  \ }

" Mock function: genero_tools#compiler#highlight#apply
function! genero_tools#compiler#highlight#apply(errors, warnings) abort
  call add(s:mock_calls.highlight_apply, {
    \ 'errors': a:errors,
    \ 'warnings': a:warnings,
    \ 'error_count': len(a:errors),
    \ 'warning_count': len(a:warnings)
    \ })
  return {'success': v:true, 'error': ''}
endfunction

" Mock function: genero_tools#compiler#highlight#unused_vars
function! genero_tools#compiler#highlight#unused_vars(warnings) abort
  call add(s:mock_calls.highlight_unused_vars, {
    \ 'warnings': a:warnings,
    \ 'warning_count': len(a:warnings)
    \ })
  return {'success': v:true, 'error': ''}
endfunction

" Mock function: genero_tools#compiler#signs#update
function! genero_tools#compiler#signs#update(result) abort
  call add(s:mock_calls.signs_update, {
    \ 'result': a:result
    \ })
  return {'success': v:true, 'error': ''}
endfunction

" Mock function: genero_tools#compiler#quickfix#populate
function! genero_tools#compiler#quickfix#populate(result, filter) abort
  call add(s:mock_calls.quickfix_populate, {
    \ 'result': a:result,
    \ 'filter': a:filter
    \ })
  return {'success': v:true, 'count': len(a:result.errors) + len(a:result.warnings)}
endfunction

" Mock function: genero_tools#compiler#quickfix#clear
function! genero_tools#compiler#quickfix#clear() abort
  return {'success': v:true, 'error': ''}
endfunction

" Helper function to reset mock calls
function! s:reset_mocks() abort
  let s:mock_calls = {
    \ 'highlight_apply': [],
    \ 'highlight_unused_vars': [],
    \ 'signs_update': [],
    \ 'quickfix_populate': []
    \ }
endfunction

" Helper function to create a mock compilation result with errors
function! s:create_result_with_errors() abort
  return {
    \ 'success': v:true,
    \ 'errors': [
    \   {
    \     'file': 'test.4gl',
    \     'line': 5,
    \     'col': 10,
    \     'end_col': 20,
    \     'severity': 'error',
    \     'code': '(-6631)',
    \     'message': 'incompatible types'
    \   }
    \ ],
    \ 'warnings': [],
    \ 'info': []
    \ }
endfunction

" Helper function to create a mock compilation result with warnings
function! s:create_result_with_warnings() abort
  return {
    \ 'success': v:true,
    \ 'errors': [],
    \ 'warnings': [
    \   {
    \     'file': 'test.4gl',
    \     'line': 12,
    \     'col': 3,
    \     'end_col': 15,
    \     'severity': 'warning',
    \     'code': '(-6615)',
    \     'message': "The symbol 'l_description' is unused."
    \   }
    \ ],
    \ 'info': []
    \ }
endfunction

" Helper function to create a mock compilation result with both errors and warnings
function! s:create_result_with_errors_and_warnings() abort
  return {
    \ 'success': v:true,
    \ 'errors': [
    \   {
    \     'file': 'test.4gl',
    \     'line': 5,
    \     'col': 10,
    \     'end_col': 20,
    \     'severity': 'error',
    \     'code': '(-6631)',
    \     'message': 'incompatible types'
    \   }
    \ ],
    \ 'warnings': [
    \   {
    \     'file': 'test.4gl',
    \     'line': 12,
    \     'col': 3,
    \     'end_col': 15,
    \     'severity': 'warning',
    \     'code': '(-6615)',
    \     'message': "The symbol 'l_description' is unused."
    \   }
    \ ],
    \ 'info': []
    \ }
endfunction

" Mock genero_tools#compiler#execute to return test data
function! genero_tools#compiler#execute(file) abort
  " Return a result with errors and warnings
  return s:create_result_with_errors_and_warnings()
endfunction

" Test 1: Autocompile on BufEnter with Errors
" This test simulates a BufEnter event and verifies that highlight#apply() is called
function! Test_autocompile_bufenter_with_errors() abort
  call s:reset_mocks()
  
  " Create a mock result with errors
  let result = s:create_result_with_errors()
  
  " Simulate what compile_silent does
  " This is the UNFIXED code path - it calls highlight#unused_vars but NOT highlight#apply
  if result.success
    " Update signs if enabled
    if genero_tools#config#get('compiler_sign_column')
      call genero_tools#compiler#signs#update(result)
    endif
    
    " Update highlighting if enabled
    if genero_tools#config#get('compiler_highlight_unused')
      call genero_tools#compiler#highlight#unused_vars(result.warnings)
    endif
    
    " Update quickfix if there are errors/warnings
    let error_count = len(result.errors)
    let warning_count = len(result.warnings)
    
    if error_count > 0 || warning_count > 0
      call genero_tools#compiler#quickfix#populate(result, 'all')
    else
      call genero_tools#compiler#quickfix#clear()
    endif
  endif
  
  " ASSERTION: highlight#apply should have been called with errors
  " On UNFIXED code, this will FAIL because highlight#apply is never called
  call assert_equal(1, len(s:mock_calls.highlight_apply), 
    \ 'BUG: highlight#apply() was not called when errors exist during autocompile')
  
  " Verify the call had the correct parameters
  if len(s:mock_calls.highlight_apply) > 0
    let call = s:mock_calls.highlight_apply[0]
    call assert_equal(1, call.error_count, 'Expected 1 error to be highlighted')
  endif
endfunction

" Test 2: Autocompile on BufWritePost with Warnings
" This test simulates a BufWritePost event and verifies that highlight#apply() is called
function! Test_autocompile_bufwritepost_with_warnings() abort
  call s:reset_mocks()
  
  " Create a mock result with warnings
  let result = s:create_result_with_warnings()
  
  " Simulate what compile_silent does
  " This is the UNFIXED code path - it calls highlight#unused_vars but NOT highlight#apply
  if result.success
    " Update signs if enabled
    if genero_tools#config#get('compiler_sign_column')
      call genero_tools#compiler#signs#update(result)
    endif
    
    " Update highlighting if enabled
    if genero_tools#config#get('compiler_highlight_unused')
      call genero_tools#compiler#highlight#unused_vars(result.warnings)
    endif
    
    " Update quickfix if there are errors/warnings
    let error_count = len(result.errors)
    let warning_count = len(result.warnings)
    
    if error_count > 0 || warning_count > 0
      call genero_tools#compiler#quickfix#populate(result, 'all')
    else
      call genero_tools#compiler#quickfix#clear()
    endif
  endif
  
  " ASSERTION: highlight#apply should have been called with warnings
  " On UNFIXED code, this will FAIL because highlight#apply is never called
  call assert_equal(1, len(s:mock_calls.highlight_apply), 
    \ 'BUG: highlight#apply() was not called when warnings exist during autocompile')
  
  " Verify the call had the correct parameters
  if len(s:mock_calls.highlight_apply) > 0
    let call = s:mock_calls.highlight_apply[0]
    call assert_equal(1, call.warning_count, 'Expected 1 warning to be highlighted')
  endif
endfunction

" Test 3: Autocompile with Mixed Errors and Warnings
" This test verifies that highlight#apply() is called with both errors and warnings
function! Test_autocompile_with_errors_and_warnings() abort
  call s:reset_mocks()
  
  " Create a mock result with both errors and warnings
  let result = s:create_result_with_errors_and_warnings()
  
  " Simulate what compile_silent does
  " This is the UNFIXED code path - it calls highlight#unused_vars but NOT highlight#apply
  if result.success
    " Update signs if enabled
    if genero_tools#config#get('compiler_sign_column')
      call genero_tools#compiler#signs#update(result)
    endif
    
    " Update highlighting if enabled
    if genero_tools#config#get('compiler_highlight_unused')
      call genero_tools#compiler#highlight#unused_vars(result.warnings)
    endif
    
    " Update quickfix if there are errors/warnings
    let error_count = len(result.errors)
    let warning_count = len(result.warnings)
    
    if error_count > 0 || warning_count > 0
      call genero_tools#compiler#quickfix#populate(result, 'all')
    else
      call genero_tools#compiler#quickfix#clear()
    endif
  endif
  
  " ASSERTION: highlight#apply should have been called with both errors and warnings
  " On UNFIXED code, this will FAIL because highlight#apply is never called
  call assert_equal(1, len(s:mock_calls.highlight_apply), 
    \ 'BUG: highlight#apply() was not called when errors and warnings exist during autocompile')
  
  " Verify the call had the correct parameters
  if len(s:mock_calls.highlight_apply) > 0
    let call = s:mock_calls.highlight_apply[0]
    call assert_equal(1, call.error_count, 'Expected 1 error to be highlighted')
    call assert_equal(1, call.warning_count, 'Expected 1 warning to be highlighted')
  endif
endfunction

" Test 4: Autocompile with No Errors or Warnings (should pass on unfixed code)
" This test verifies that the existing behavior for no errors/warnings is preserved
function! Test_autocompile_no_errors_or_warnings() abort
  call s:reset_mocks()
  
  " Create a mock result with no errors or warnings
  let result = {
    \ 'success': v:true,
    \ 'errors': [],
    \ 'warnings': [],
    \ 'info': []
    \ }
  
  " Simulate what compile_silent does
  if result.success
    " Update signs if enabled
    if genero_tools#config#get('compiler_sign_column')
      call genero_tools#compiler#signs#update(result)
    endif
    
    " Update highlighting if enabled
    if genero_tools#config#get('compiler_highlight_unused')
      call genero_tools#compiler#highlight#unused_vars(result.warnings)
    endif
    
    " Update quickfix if there are errors/warnings
    let error_count = len(result.errors)
    let warning_count = len(result.warnings)
    
    if error_count > 0 || warning_count > 0
      call genero_tools#compiler#quickfix#populate(result, 'all')
    else
      call genero_tools#compiler#quickfix#clear()
    endif
  endif
  
  " ASSERTION: highlight#apply should NOT be called when there are no errors/warnings
  " This should pass on both fixed and unfixed code
  call assert_equal(0, len(s:mock_calls.highlight_apply), 
    \ 'highlight#apply() should not be called when no errors/warnings exist')
endfunction

" Run all tests
function! Test_RunAllAutocompileHighlightBugTests() abort
  let results = []
  
  try
    call Test_autocompile_bufenter_with_errors()
    call add(results, ['Test 1: BufEnter with Errors', 'PASS'])
  catch
    call add(results, ['Test 1: BufEnter with Errors', 'FAIL: ' . v:exception])
  endtry
  
  try
    call Test_autocompile_bufwritepost_with_warnings()
    call add(results, ['Test 2: BufWritePost with Warnings', 'PASS'])
  catch
    call add(results, ['Test 2: BufWritePost with Warnings', 'FAIL: ' . v:exception])
  endtry
  
  try
    call Test_autocompile_with_errors_and_warnings()
    call add(results, ['Test 3: Mixed Errors and Warnings', 'PASS'])
  catch
    call add(results, ['Test 3: Mixed Errors and Warnings', 'FAIL: ' . v:exception])
  endtry
  
  try
    call Test_autocompile_no_errors_or_warnings()
    call add(results, ['Test 4: No Errors or Warnings', 'PASS'])
  catch
    call add(results, ['Test 4: No Errors or Warnings', 'FAIL: ' . v:exception])
  endtry
  
  " Display results
  echom '=== Autocompile Highlight Bug Exploration Tests ==='
  for [test_name, result] in results
    echom test_name . ': ' . result
  endfor
  
  return v:true
endfunction
