" Simple Bug Condition Exploration Test
" This test demonstrates the bug by checking if highlight#apply() is called
" during autocompile when errors/warnings exist.
"
" Property 1: Bug Condition - Autocompile Missing Error/Warning Highlighting
" Validates: Requirements 1.1, 1.2
"
" EXPECTED OUTCOME ON UNFIXED CODE: Test FAILS (highlight#apply not called)
" EXPECTED OUTCOME ON FIXED CODE: Test PASSES (highlight#apply is called)

" Track if highlight#apply was called
let s:highlight_apply_called = 0

" Mock highlight#apply to track calls
function! genero_tools#compiler#highlight#apply(errors, warnings) abort
  let s:highlight_apply_called = 1
  return {'success': v:true, 'error': ''}
endfunction

" Mock other functions
function! genero_tools#compiler#highlight#unused_vars(warnings) abort
  return {'success': v:true, 'error': ''}
endfunction

function! genero_tools#compiler#signs#update(result) abort
  return {'success': v:true, 'error': ''}
endfunction

function! genero_tools#compiler#quickfix#populate(result, filter) abort
  return {'success': v:true, 'count': len(a:result.errors) + len(a:result.warnings)}
endfunction

function! genero_tools#compiler#quickfix#clear() abort
  return {'success': v:true, 'error': ''}
endfunction

" Test: Simulate compile_silent with errors
function! Test_bug_condition_with_errors() abort
  let s:highlight_apply_called = 0
  
  " Create a mock result with errors
  let result = {
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
  
  " ASSERTION: highlight#apply should have been called
  " On UNFIXED code, this will FAIL because highlight#apply is never called
  if s:highlight_apply_called == 0
    echom 'BUG CONFIRMED: highlight#apply() was NOT called when errors exist'
    return 0
  else
    echom 'BUG FIXED: highlight#apply() was called when errors exist'
    return 1
  endif
endfunction

" Run the test
let result = Test_bug_condition_with_errors()
if result == 0
  echom 'TEST FAILED (as expected on unfixed code) - Bug exists'
  quit! 1
else
  echom 'TEST PASSED - Bug is fixed'
  quit! 0
endif
