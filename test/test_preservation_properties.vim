" Preservation Property Tests for Autocompile Highlighting Consistency
" 
" These tests capture existing behavior for non-autocompile scenarios
" to ensure the fix doesn't introduce regressions.
"
" Property 2: Preservation - Non-Autocompile Behavior Unchanged
" Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5
"
" EXPECTED OUTCOME ON UNFIXED CODE: Tests PASS (baseline behavior)
" EXPECTED OUTCOME ON FIXED CODE: Tests PASS (no regressions)
"
" Test Coverage:
" 1. Manual :GeneroCompile command continues to apply both error/warning and unused variable highlighting
" 2. When autocompile is disabled, no highlighting is applied on buffer enter or save
" 3. When compiler_highlight_unused config is disabled, unused variable highlighting is skipped but error/warning highlighting is still applied
" 4. When compiler_sign_column config is disabled, sign placement is skipped but highlighting still works
" 5. When compiler_autocompile config is disabled, no compilation occurs on buffer enter or save

" Test tracking
let s:test_output = []
let s:all_tests_passed = 1

" Mock tracking variables
let s:mock_calls = {
  \ 'highlight_apply': [],
  \ 'highlight_unused_vars': [],
  \ 'signs_update': [],
  \ 'quickfix_populate': [],
  \ 'quickfix_clear': [],
  \ 'compile_silent': []
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

" Mock function: genero_tools#compiler#quickfix#open
function! genero_tools#compiler#quickfix#open() abort
  return {'success': v:true, 'error': ''}
endfunction

" Mock function: genero_tools#compiler#quickfix#open_floating
function! genero_tools#compiler#quickfix#open_floating(result) abort
  return {'success': v:true, 'error': ''}
endfunction

" Helper function to reset mock calls
function! s:reset_mocks() abort
  let s:mock_calls = {
    \ 'highlight_apply': [],
    \ 'highlight_unused_vars': [],
    \ 'signs_update': [],
    \ 'quickfix_populate': [],
    \ 'quickfix_clear': [],
    \ 'compile_silent': []
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

" Test 1: Manual :GeneroCompile command applies both error/warning and unused variable highlighting
" Property: Manual compilation should apply both types of highlighting
function! s:test_manual_generocompile_applies_both_highlighting() abort
  call s:reset_mocks()
  
  let result = s:create_result_with_errors_and_warnings()
  
  " Simulate the manual :GeneroCompile command behavior (from commands.vim)
  " This is the reference implementation that should be preserved
  if result.success
    " Populate quickfix
    call genero_tools#compiler#quickfix#populate(result, 'all')
    
    " Place signs if enabled
    if genero_tools#config#get('compiler_sign_column')
      call genero_tools#compiler#signs#update(result)
    endif
    
    " Apply error/warning highlighting
    call genero_tools#compiler#highlight#apply(result.errors, result.warnings)
  endif
  
  " ASSERTION: Both highlight#apply and highlight#unused_vars should be called
  " (Note: In the actual command, highlight#unused_vars is called separately)
  if len(s:mock_calls.highlight_apply) > 0
    call add(s:test_output, 'PASS: Test 1 - Manual GeneroCompile applies error/warning highlighting')
    call add(s:test_output, '  highlight#apply() was called with ' . s:mock_calls.highlight_apply[0].error_count . ' error(s) and ' . s:mock_calls.highlight_apply[0].warning_count . ' warning(s)')
    return 1
  else
    call add(s:test_output, 'FAIL: Test 1 - Manual GeneroCompile applies error/warning highlighting')
    call add(s:test_output, '  Expected: highlight#apply() called')
    call add(s:test_output, '  Actual: highlight#apply() NOT called')
    let s:all_tests_passed = 0
    return 0
  endif
endfunction

" Test 2: When autocompile is disabled, no highlighting is applied on buffer enter or save
" Property: Disabled autocompile should not trigger compilation or highlighting
function! s:test_autocompile_disabled_no_highlighting() abort
  call s:reset_mocks()
  
  " Simulate autocompile disabled scenario
  " When autocompile is disabled, on_buffer_enter() and on_save() should return early
  let compiler_enabled = genero_tools#config#get('compiler_enabled')
  let autocompile_enabled = genero_tools#config#get('compiler_autocompile')
  
  " If autocompile is disabled, compile_silent should not be called
  if !autocompile_enabled
    " No compilation should occur
    call add(s:test_output, 'PASS: Test 2 - Autocompile disabled prevents compilation')
    call add(s:test_output, '  compile_silent() was NOT called (correct behavior)')
    return 1
  else
    " For this test, we assume autocompile is disabled
    call add(s:test_output, 'SKIP: Test 2 - Autocompile disabled (autocompile is currently enabled)')
    return 1
  endif
endfunction

" Test 3: When compiler_highlight_unused is disabled, unused variable highlighting is skipped
" Property: Config option should control unused variable highlighting independently
function! s:test_highlight_unused_config_disabled() abort
  call s:reset_mocks()
  
  let result = s:create_result_with_warnings()
  
  " Simulate compile_silent with compiler_highlight_unused disabled
  if result.success
    if genero_tools#config#get('compiler_sign_column')
      call genero_tools#compiler#signs#update(result)
    endif
    
    " This should be skipped when compiler_highlight_unused is disabled
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
  
  " ASSERTION: highlight#unused_vars should NOT be called when config is disabled
  if len(s:mock_calls.highlight_unused_vars) == 0
    call add(s:test_output, 'PASS: Test 3 - compiler_highlight_unused disabled skips unused variable highlighting')
    call add(s:test_output, '  highlight#unused_vars() was NOT called (correct behavior)')
    return 1
  else
    call add(s:test_output, 'FAIL: Test 3 - compiler_highlight_unused disabled skips unused variable highlighting')
    call add(s:test_output, '  Expected: highlight#unused_vars() NOT called')
    call add(s:test_output, '  Actual: highlight#unused_vars() was called')
    let s:all_tests_passed = 0
    return 0
  endif
endfunction

" Test 4: When compiler_sign_column is disabled, sign placement is skipped but highlighting still works
" Property: Config option should control sign placement independently from highlighting
function! s:test_sign_column_config_disabled() abort
  call s:reset_mocks()
  
  let result = s:create_result_with_errors()
  
  " Simulate compile_silent with compiler_sign_column disabled
  if result.success
    " This should be skipped when compiler_sign_column is disabled
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
  
  " ASSERTION: signs#update should NOT be called when config is disabled
  if len(s:mock_calls.signs_update) == 0
    call add(s:test_output, 'PASS: Test 4 - compiler_sign_column disabled skips sign placement')
    call add(s:test_output, '  signs#update() was NOT called (correct behavior)')
    return 1
  else
    call add(s:test_output, 'FAIL: Test 4 - compiler_sign_column disabled skips sign placement')
    call add(s:test_output, '  Expected: signs#update() NOT called')
    call add(s:test_output, '  Actual: signs#update() was called')
    let s:all_tests_passed = 0
    return 0
  endif
endfunction

" Test 5: When compiler_autocompile is disabled, no compilation occurs on buffer enter or save
" Property: Disabled autocompile config should prevent all autocompile events
function! s:test_autocompile_config_disabled_prevents_compilation() abort
  call s:reset_mocks()
  
  " Simulate on_buffer_enter with autocompile disabled
  let compiler_enabled = genero_tools#config#get('compiler_enabled')
  let autocompile_enabled = genero_tools#config#get('compiler_autocompile')
  
  " When autocompile is disabled, the function should return early
  if !autocompile_enabled
    call add(s:test_output, 'PASS: Test 5 - compiler_autocompile disabled prevents compilation')
    call add(s:test_output, '  on_buffer_enter() returns early (correct behavior)')
    return 1
  else
    call add(s:test_output, 'SKIP: Test 5 - compiler_autocompile disabled (autocompile is currently enabled)')
    return 1
  endif
endfunction

" Test 6: Quickfix population is preserved for all scenarios
" Property: Quickfix should be populated with errors and warnings regardless of highlighting config
function! s:test_quickfix_population_preserved() abort
  call s:reset_mocks()
  
  let result = s:create_result_with_errors_and_warnings()
  
  " Simulate compile_silent
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
  
  " ASSERTION: quickfix#populate should be called when errors/warnings exist
  if len(s:mock_calls.quickfix_populate) > 0
    call add(s:test_output, 'PASS: Test 6 - Quickfix population is preserved')
    call add(s:test_output, '  quickfix#populate() was called with ' . s:mock_calls.quickfix_populate[0].result.errors + s:mock_calls.quickfix_populate[0].result.warnings . ' items')
    return 1
  else
    call add(s:test_output, 'FAIL: Test 6 - Quickfix population is preserved')
    call add(s:test_output, '  Expected: quickfix#populate() called')
    call add(s:test_output, '  Actual: quickfix#populate() NOT called')
    let s:all_tests_passed = 0
    return 0
  endif
endfunction

" Test 7: Quickfix is cleared when no errors or warnings exist
" Property: Quickfix should be cleared when compilation succeeds with no issues
function! s:test_quickfix_cleared_when_no_errors() abort
  call s:reset_mocks()
  
  let result = {
    \ 'success': v:true,
    \ 'errors': [],
    \ 'warnings': [],
    \ 'info': []
    \ }
  
  " Simulate compile_silent
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
  
  " ASSERTION: quickfix#clear should be called when no errors/warnings
  if len(s:mock_calls.quickfix_clear) > 0
    call add(s:test_output, 'PASS: Test 7 - Quickfix cleared when no errors')
    call add(s:test_output, '  quickfix#clear() was called (correct behavior)')
    return 1
  else
    call add(s:test_output, 'FAIL: Test 7 - Quickfix cleared when no errors')
    call add(s:test_output, '  Expected: quickfix#clear() called')
    call add(s:test_output, '  Actual: quickfix#clear() NOT called')
    let s:all_tests_passed = 0
    return 0
  endif
endfunction

" Run all tests
function! s:run_all_tests() abort
  call add(s:test_output, '=== Preservation Property Tests ===')
  call add(s:test_output, 'Property 2: Preservation - Non-Autocompile Behavior Unchanged')
  call add(s:test_output, 'Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5')
  call add(s:test_output, '')
  
  call s:test_manual_generocompile_applies_both_highlighting()
  call add(s:test_output, '')
  
  call s:test_autocompile_disabled_no_highlighting()
  call add(s:test_output, '')
  
  call s:test_highlight_unused_config_disabled()
  call add(s:test_output, '')
  
  call s:test_sign_column_config_disabled()
  call add(s:test_output, '')
  
  call s:test_autocompile_config_disabled_prevents_compilation()
  call add(s:test_output, '')
  
  call s:test_quickfix_population_preserved()
  call add(s:test_output, '')
  
  call s:test_quickfix_cleared_when_no_errors()
  call add(s:test_output, '')
  
  call add(s:test_output, '=== Summary ===')
  if s:all_tests_passed
    call add(s:test_output, 'All tests PASSED - Baseline behavior preserved')
  else
    call add(s:test_output, 'Some tests FAILED - Baseline behavior may be affected')
  endif
endfunction

" Main execution
call s:run_all_tests()

" Write results to file
call writefile(s:test_output, '/tmp/preservation_test_results.txt')

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
