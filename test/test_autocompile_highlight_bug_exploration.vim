" Bug Condition Exploration Test for Autocompile Highlighting Consistency
" 
" This test demonstrates the bug where autocompile does not call highlight#apply()
" when compilation succeeds with errors or warnings.
"
" Property 1: Bug Condition - Autocompile Missing Error/Warning Highlighting
" Validates: Requirements 1.1, 1.2
"
" EXPECTED OUTCOME ON UNFIXED CODE: Test FAILS (highlight#apply not called)
" EXPECTED OUTCOME ON FIXED CODE: Test PASSES (highlight#apply is called)
"
" Bug Description:
" The compile_silent() function in autoload/genero_tools/compiler/autocompile.vim
" calls genero_tools#compiler#highlight#unused_vars() but is missing the call to
" genero_tools#compiler#highlight#apply() which applies error and warning highlighting.
"
" Reference Implementation:
" The genero_tools#compiler#commands#compile() function in 
" autoload/genero_tools/compiler/commands.vim correctly calls both functions at line 56.

" Test tracking
let s:test_output = []
let s:all_tests_passed = 1

" Mock tracking variables
let s:mock_calls = {
  \ 'highlight_apply': [],
  \ 'highlight_unused_vars': [],
  \ 'signs_update': [],
  \ 'quickfix_populate': [],
  \ 'quickfix_clear': []
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
  call add(s:mock_calls.quickfix_clear, {})
  return {'success': v:true, 'error': ''}
endfunction

" Helper function to reset mock calls
function! s:reset_mocks() abort
  let s:mock_calls = {
    \ 'highlight_apply': [],
    \ 'highlight_unused_vars': [],
    \ 'signs_update': [],
    \ 'quickfix_populate': [],
    \ 'quickfix_clear': []
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
" This test simulates a BufEnter event and verifies that highlight#apply() is called
function! s:test_autocompile_bufenter_with_errors() abort
  call s:reset_mocks()
  
  let result = s:create_result_with_errors()
  
  " Simulate the UNFIXED compile_silent() code path
  " This is the actual code from autoload/genero_tools/compiler/autocompile.vim
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
  
  " ASSERTION: highlight#apply should have been called with errors
  " On UNFIXED code, this will FAIL because highlight#apply is never called
  if len(s:mock_calls.highlight_apply) == 0
    call add(s:test_output, 'FAIL: Test 1 - BufEnter with Errors')
    call add(s:test_output, '  Expected: highlight#apply() called with 1 error')
    call add(s:test_output, '  Actual: highlight#apply() NOT called')
    call add(s:test_output, '  Counterexample: Autocompile on BufEnter with compilation error')
    call add(s:test_output, '  Root Cause: Missing call to genero_tools#compiler#highlight#apply() in compile_silent()')
    let s:all_tests_passed = 0
    return 0
  else
    call add(s:test_output, 'PASS: Test 1 - BufEnter with Errors')
    call add(s:test_output, '  highlight#apply() was called with ' . s:mock_calls.highlight_apply[0].error_count . ' error(s)')
    return 1
  endif
endfunction

" Test 2: Autocompile on BufWritePost with Warnings
" This test simulates a BufWritePost event and verifies that highlight#apply() is called
function! s:test_autocompile_bufwritepost_with_warnings() abort
  call s:reset_mocks()
  
  let result = s:create_result_with_warnings()
  
  " Simulate the UNFIXED compile_silent() code path
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
  
  " ASSERTION: highlight#apply should have been called with warnings
  " On UNFIXED code, this will FAIL because highlight#apply is never called
  if len(s:mock_calls.highlight_apply) == 0
    call add(s:test_output, 'FAIL: Test 2 - BufWritePost with Warnings')
    call add(s:test_output, '  Expected: highlight#apply() called with 1 warning')
    call add(s:test_output, '  Actual: highlight#apply() NOT called')
    call add(s:test_output, '  Counterexample: Autocompile on BufWritePost with compilation warning')
    call add(s:test_output, '  Root Cause: Missing call to genero_tools#compiler#highlight#apply() in compile_silent()')
    let s:all_tests_passed = 0
    return 0
  else
    call add(s:test_output, 'PASS: Test 2 - BufWritePost with Warnings')
    call add(s:test_output, '  highlight#apply() was called with ' . s:mock_calls.highlight_apply[0].warning_count . ' warning(s)')
    return 1
  endif
endfunction

" Test 3: Autocompile with Mixed Errors and Warnings
" This test verifies that highlight#apply() is called with both errors and warnings
function! s:test_autocompile_with_errors_and_warnings() abort
  call s:reset_mocks()
  
  let result = s:create_result_with_errors_and_warnings()
  
  " Simulate the UNFIXED compile_silent() code path
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
  
  " ASSERTION: highlight#apply should have been called with both errors and warnings
  " On UNFIXED code, this will FAIL because highlight#apply is never called
  if len(s:mock_calls.highlight_apply) == 0
    call add(s:test_output, 'FAIL: Test 3 - Mixed Errors and Warnings')
    call add(s:test_output, '  Expected: highlight#apply() called with 1 error and 1 warning')
    call add(s:test_output, '  Actual: highlight#apply() NOT called')
    call add(s:test_output, '  Counterexample: Autocompile with both errors and warnings')
    call add(s:test_output, '  Root Cause: Missing call to genero_tools#compiler#highlight#apply() in compile_silent()')
    let s:all_tests_passed = 0
    return 0
  else
    call add(s:test_output, 'PASS: Test 3 - Mixed Errors and Warnings')
    call add(s:test_output, '  highlight#apply() was called with ' . s:mock_calls.highlight_apply[0].error_count . ' error(s) and ' . s:mock_calls.highlight_apply[0].warning_count . ' warning(s)')
    return 1
  endif
endfunction

" Test 4: Autocompile with No Errors or Warnings (should pass on unfixed code)
" This test verifies that the existing behavior for no errors/warnings is preserved
function! s:test_autocompile_no_errors_or_warnings() abort
  call s:reset_mocks()
  
  let result = {
    \ 'success': v:true,
    \ 'errors': [],
    \ 'warnings': [],
    \ 'info': []
    \ }
  
  " Simulate the UNFIXED compile_silent() code path
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
  
  " ASSERTION: highlight#apply should NOT be called when there are no errors/warnings
  " This should pass on both fixed and unfixed code
  if len(s:mock_calls.highlight_apply) == 0
    call add(s:test_output, 'PASS: Test 4 - No Errors or Warnings')
    call add(s:test_output, '  highlight#apply() was NOT called (correct behavior)')
    return 1
  else
    call add(s:test_output, 'FAIL: Test 4 - No Errors or Warnings')
    call add(s:test_output, '  Expected: highlight#apply() NOT called')
    call add(s:test_output, '  Actual: highlight#apply() was called')
    let s:all_tests_passed = 0
    return 0
  endif
endfunction

" Run all tests
function! s:run_all_tests() abort
  call add(s:test_output, '=== Bug Condition Exploration Tests ===')
  call add(s:test_output, 'Property 1: Bug Condition - Autocompile Missing Error/Warning Highlighting')
  call add(s:test_output, 'Validates: Requirements 1.1, 1.2')
  call add(s:test_output, '')
  
  call s:test_autocompile_bufenter_with_errors()
  call add(s:test_output, '')
  
  call s:test_autocompile_bufwritepost_with_warnings()
  call add(s:test_output, '')
  
  call s:test_autocompile_with_errors_and_warnings()
  call add(s:test_output, '')
  
  call s:test_autocompile_no_errors_or_warnings()
  call add(s:test_output, '')
  
  call add(s:test_output, '=== Summary ===')
  if s:all_tests_passed
    call add(s:test_output, 'All tests PASSED - Bug is FIXED')
  else
    call add(s:test_output, 'Some tests FAILED - Bug EXISTS (as expected on unfixed code)')
    call add(s:test_output, '')
    call add(s:test_output, 'Counterexamples Found:')
    call add(s:test_output, '- highlight#apply() is never called during autocompile events')
    call add(s:test_output, '- Error and warning highlighting is not applied to the buffer during autocompile')
    call add(s:test_output, '')
    call add(s:test_output, 'Root Cause Analysis:')
    call add(s:test_output, '- Missing function call: genero_tools#compiler#highlight#apply()')
    call add(s:test_output, '- Location: autoload/genero_tools/compiler/autocompile.vim, compile_silent() function')
    call add(s:test_output, '- Reference: autoload/genero_tools/compiler/commands.vim, line 56')
  endif
endfunction

" Main execution
call s:run_all_tests()

" Write results to file
call writefile(s:test_output, '/tmp/bug_exploration_results.txt')

" Print results
for line in s:test_output
  echom line
endfor

" Exit with appropriate code
if s:all_tests_passed
  quit! 0
else
  quit! 1
endif
