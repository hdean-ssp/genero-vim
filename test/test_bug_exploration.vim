" Bug Condition Exploration Test for Autocompile Highlighting Consistency
" 
" This test demonstrates the bug where autocompile does not call highlight#apply()
" when compilation succeeds with errors or warnings.
"
" Property 1: Bug Condition - Autocompile Missing Error/Warning Highlighting
" Validates: Requirements 1.1, 1.2

" Initialize test results
let s:test_results = []
let s:test_failed = 0

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

" Test 1: Autocompile on BufEnter with Errors
function! s:test_autocompile_bufenter_with_errors() abort
  call s:reset_mocks()
  
  let result = s:create_result_with_errors()
  
  " Simulate the UNFIXED compile_silent() behavior
  if result.success
    if genero_tools#config#get('compiler_sign_column')
      call genero_tools#compiler#signs#update(result)
    endif
    
    if genero_tools#config#get('compiler_highlight_unused')
      call genero_tools#compiler#highlight#unused_vars(result.warnings)
    endif
    
    let error_count = len(result.errors)
    let warning_count = len(result.warnings)
    
    if error_count > 0 || warning_count > 0
      call genero_tools#compiler#quickfix#populate(result, 'all')
    else
      call genero_tools#compiler#quickfix#clear()
    endif
  endif
  
  " Check if highlight#apply was called
  if len(s:mock_calls.highlight_apply) == 0
    call add(s:test_results, 'FAIL: Test 1 - BufEnter with Errors: highlight#apply() was NOT called (BUG CONFIRMED)')
    let s:test_failed = 1
    return 0
  else
    call add(s:test_results, 'PASS: Test 1 - BufEnter with Errors: highlight#apply() was called')
    return 1
  endif
endfunction

" Test 2: Autocompile on BufWritePost with Warnings
function! s:test_autocompile_bufwritepost_with_warnings() abort
  call s:reset_mocks()
  
  let result = s:create_result_with_warnings()
  
  " Simulate the UNFIXED compile_silent() behavior
  if result.success
    if genero_tools#config#get('compiler_sign_column')
      call genero_tools#compiler#signs#update(result)
    endif
    
    if genero_tools#config#get('compiler_highlight_unused')
      call genero_tools#compiler#highlight#unused_vars(result.warnings)
    endif
    
    let error_count = len(result.errors)
    let warning_count = len(result.warnings)
    
    if error_count > 0 || warning_count > 0
      call genero_tools#compiler#quickfix#populate(result, 'all')
    else
      call genero_tools#compiler#quickfix#clear()
    endif
  endif
  
  " Check if highlight#apply was called
  if len(s:mock_calls.highlight_apply) == 0
    call add(s:test_results, 'FAIL: Test 2 - BufWritePost with Warnings: highlight#apply() was NOT called (BUG CONFIRMED)')
    let s:test_failed = 1
    return 0
  else
    call add(s:test_results, 'PASS: Test 2 - BufWritePost with Warnings: highlight#apply() was called')
    return 1
  endif
endfunction

" Test 3: Autocompile with Mixed Errors and Warnings
function! s:test_autocompile_with_errors_and_warnings() abort
  call s:reset_mocks()
  
  let result = s:create_result_with_errors_and_warnings()
  
  " Simulate the UNFIXED compile_silent() behavior
  if result.success
    if genero_tools#config#get('compiler_sign_column')
      call genero_tools#compiler#signs#update(result)
    endif
    
    if genero_tools#config#get('compiler_highlight_unused')
      call genero_tools#compiler#highlight#unused_vars(result.warnings)
    endif
    
    let error_count = len(result.errors)
    let warning_count = len(result.warnings)
    
    if error_count > 0 || warning_count > 0
      call genero_tools#compiler#quickfix#populate(result, 'all')
    else
      call genero_tools#compiler#quickfix#clear()
    endif
  endif
  
  " Check if highlight#apply was called
  if len(s:mock_calls.highlight_apply) == 0
    call add(s:test_results, 'FAIL: Test 3 - Mixed Errors and Warnings: highlight#apply() was NOT called (BUG CONFIRMED)')
    let s:test_failed = 1
    return 0
  else
    call add(s:test_results, 'PASS: Test 3 - Mixed Errors and Warnings: highlight#apply() was called')
    return 1
  endif
endfunction

" Test 4: Autocompile with No Errors or Warnings
function! s:test_autocompile_no_errors_or_warnings() abort
  call s:reset_mocks()
  
  let result = {
    \ 'success': v:true,
    \ 'errors': [],
    \ 'warnings': [],
    \ 'info': []
    \ }
  
  " Simulate the UNFIXED compile_silent() behavior
  if result.success
    if genero_tools#config#get('compiler_sign_column')
      call genero_tools#compiler#signs#update(result)
    endif
    
    if genero_tools#config#get('compiler_highlight_unused')
      call genero_tools#compiler#highlight#unused_vars(result.warnings)
    endif
    
    let error_count = len(result.errors)
    let warning_count = len(result.warnings)
    
    if error_count > 0 || warning_count > 0
      call genero_tools#compiler#quickfix#populate(result, 'all')
    else
      call genero_tools#compiler#quickfix#clear()
    endif
  endif
  
  " Check if highlight#apply was NOT called (correct behavior)
  if len(s:mock_calls.highlight_apply) == 0
    call add(s:test_results, 'PASS: Test 4 - No Errors or Warnings: highlight#apply() was NOT called (correct)')
    return 1
  else
    call add(s:test_results, 'FAIL: Test 4 - No Errors or Warnings: highlight#apply() was called (should not be)')
    let s:test_failed = 1
    return 0
  endif
endfunction

" Run all tests
function! s:run_all_tests() abort
  call s:test_autocompile_bufenter_with_errors()
  call s:test_autocompile_bufwritepost_with_warnings()
  call s:test_autocompile_with_errors_and_warnings()
  call s:test_autocompile_no_errors_or_warnings()
endfunction

" Main execution
call s:run_all_tests()

" Write results to file
call writefile(s:test_results, '/tmp/bug_test_results.txt')

" Exit with appropriate code
if s:test_failed
  quit! 1
else
  quit! 0
endif
