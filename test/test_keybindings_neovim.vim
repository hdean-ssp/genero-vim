" Test script for error navigation keybindings in Neovim 0.5+
" This script tests the Ctrl+. and Ctrl+, keybindings in Neovim

" Ensure we're in Neovim
if !has('nvim')
  echom 'ERROR: This test requires Neovim'
  quit!
endif

" Check Neovim version
let nvim_version = split(execute('version'), '\n')[0]
echom 'Testing in: ' . nvim_version

" Initialize test results
let g:test_results = {
  \ 'total': 0,
  \ 'passed': 0,
  \ 'failed': 0,
  \ 'tests': []
  \ }

" Helper function to record test result
function! RecordTest(name, passed, details) abort
  let g:test_results.total += 1
  if a:passed
    let g:test_results.passed += 1
    let status = '✓ PASS'
  else
    let g:test_results.failed += 1
    let status = '✗ FAIL'
  endif
  
  call add(g:test_results.tests, {
    \ 'name': a:name,
    \ 'status': status,
    \ 'details': a:details
    \ })
  
  echom status . ': ' . a:name
  if !empty(a:details)
    echom '  Details: ' . a:details
  endif
endfunction

" Helper function to create test quickfix list
function! CreateTestQuickfixList() abort
  let qf_list = [
    \ {'filename': 'test1.4gl', 'lnum': 10, 'col': 5, 'text': 'Error 1: Syntax error', 'type': 'E'},
    \ {'filename': 'test2.4gl', 'lnum': 20, 'col': 10, 'text': 'Error 2: Undefined variable', 'type': 'E'},
    \ {'filename': 'test3.4gl', 'lnum': 30, 'col': 15, 'text': 'Error 3: Type mismatch', 'type': 'E'}
    \ ]
  call setqflist(qf_list)
endfunction

" Helper function to clear quickfix list
function! ClearQuickfixList() abort
  call setqflist([])
endfunction

" Helper function to get current error position
function! GetCurrentErrorPosition() abort
  let current = getqflist({'idx': 0})
  return get(current, 'idx', 0)
endfunction

" ============================================================================
" TEST 1.4.1: Verify Ctrl+. triggers next error navigation
" ============================================================================
echom ''
echom '=== TEST 1.4.1: Verify Ctrl+. triggers next error navigation ==='

try
  " Create test quickfix list
  call CreateTestQuickfixList()
  
  " Jump to first error
  cfirst
  let pos_before = GetCurrentErrorPosition()
  
  " Call next_error function (simulating Ctrl+. keybinding)
  call genero_tools#compiler#commands#next_error()
  
  " Check if we moved to next error
  let pos_after = GetCurrentErrorPosition()
  
  if pos_after == pos_before + 1
    call RecordTest('1.4.1: Ctrl+. triggers next error', 1, 
      \ 'Moved from error ' . pos_before . ' to error ' . pos_after)
  else
    call RecordTest('1.4.1: Ctrl+. triggers next error', 0,
      \ 'Expected position ' . (pos_before + 1) . ' but got ' . pos_after)
  endif
catch
  call RecordTest('1.4.1: Ctrl+. triggers next error', 0,
    \ 'Exception: ' . v:exception)
endtry

" ============================================================================
" TEST 1.4.2: Verify Ctrl+, triggers previous error navigation
" ============================================================================
echom ''
echom '=== TEST 1.4.2: Verify Ctrl+, triggers previous error navigation ==='

try
  " Create test quickfix list
  call CreateTestQuickfixList()
  
  " Jump to last error
  clast
  let pos_before = GetCurrentErrorPosition()
  
  " Call prev_error function (simulating Ctrl+, keybinding)
  call genero_tools#compiler#commands#prev_error()
  
  " Check if we moved to previous error
  let pos_after = GetCurrentErrorPosition()
  
  if pos_after == pos_before - 1
    call RecordTest('1.4.2: Ctrl+, triggers previous error', 1,
      \ 'Moved from error ' . pos_before . ' to error ' . pos_after)
  else
    call RecordTest('1.4.2: Ctrl+, triggers previous error', 0,
      \ 'Expected position ' . (pos_before - 1) . ' but got ' . pos_after)
  endif
catch
  call RecordTest('1.4.2: Ctrl+, triggers previous error', 0,
    \ 'Exception: ' . v:exception)
endtry

" ============================================================================
" TEST 1.4.3: Test with empty quickfix list
" ============================================================================
echom ''
echom '=== TEST 1.4.3: Test with empty quickfix list ==='

try
  " Clear quickfix list
  call ClearQuickfixList()
  
  " Try to navigate next (should fail gracefully)
  let result_next = genero_tools#compiler#quickfix#next()
  let next_success = !result_next.success && result_next.error =~? 'No errors to navigate'
  
  " Try to navigate previous (should fail gracefully)
  let result_prev = genero_tools#compiler#quickfix#prev()
  let prev_success = !result_prev.success && result_prev.error =~? 'No errors to navigate'
  
  if next_success && prev_success
    call RecordTest('1.4.3: Empty quickfix list handling', 1,
      \ 'Both next and prev show appropriate error messages')
  else
    let details = 'next_error: ' . result_next.error . ' | prev_error: ' . result_prev.error
    call RecordTest('1.4.3: Empty quickfix list handling', 0, details)
  endif
catch
  call RecordTest('1.4.3: Empty quickfix list handling', 0,
    \ 'Exception: ' . v:exception)
endtry

" ============================================================================
" TEST 1.4.4: Test at boundaries (first/last error)
" ============================================================================
echom ''
echom '=== TEST 1.4.4: Test at boundaries (first/last error) ==='

try
  " Create test quickfix list
  call CreateTestQuickfixList()
  
  " Test at first error - try to go previous
  cfirst
  let result_at_first = genero_tools#compiler#quickfix#prev()
  let at_first_ok = !result_at_first.success && result_at_first.error =~? 'No previous error'
  
  " Test at last error - try to go next
  clast
  let result_at_last = genero_tools#compiler#quickfix#next()
  let at_last_ok = !result_at_last.success && result_at_last.error =~? 'No next error'
  
  if at_first_ok && at_last_ok
    call RecordTest('1.4.4: Boundary conditions', 1,
      \ 'Both first and last boundaries handled correctly')
  else
    let details = 'at_first: ' . result_at_first.error . ' | at_last: ' . result_at_last.error
    call RecordTest('1.4.4: Boundary conditions', 0, details)
  endif
catch
  call RecordTest('1.4.4: Boundary conditions', 0,
    \ 'Exception: ' . v:exception)
endtry

" ============================================================================
" VERIFY KEYBINDING REGISTRATION
" ============================================================================
echom ''
echom '=== VERIFY KEYBINDING REGISTRATION ==='

try
  " Check if keybindings are registered
  let keybindings_enabled = genero_tools#config#get('keybindings_enabled')
  
  if keybindings_enabled
    echom '✓ Keybindings are enabled in configuration'
    
    " Try to get the mapping info
    let mapping_next = maparg('<C-.>', 'n')
    let mapping_prev = maparg('<C-,>', 'n')
    
    if !empty(mapping_next)
      echom '✓ Ctrl+. is mapped to: ' . mapping_next
    else
      echom '✗ Ctrl+. mapping not found'
    endif
    
    if !empty(mapping_prev)
      echom '✓ Ctrl+, is mapped to: ' . mapping_prev
    else
      echom '✗ Ctrl+, mapping not found'
    endif
  else
    echom '✗ Keybindings are disabled in configuration'
  endif
catch
  echom 'Exception checking keybindings: ' . v:exception
endtry

" ============================================================================
" PRINT TEST SUMMARY
" ============================================================================
echom ''
echom '========================================='
echom 'TEST SUMMARY FOR NEOVIM 0.5+'
echom '========================================='
echom 'Total Tests: ' . g:test_results.total
echom 'Passed: ' . g:test_results.passed
echom 'Failed: ' . g:test_results.failed
echom ''

if g:test_results.failed == 0
  echom '✓ ALL TESTS PASSED'
else
  echom '✗ SOME TESTS FAILED'
endif

echom ''
echom 'Test Details:'
for test in g:test_results.tests
  echom test.status . ' ' . test.name
  if !empty(test.details)
    echom '  ' . test.details
  endif
endfor

" Exit with appropriate code
if g:test_results.failed == 0
  echom ''
  echom 'Neovim keybinding tests completed successfully!'
  quit!
else
  echom ''
  echom 'Neovim keybinding tests failed!'
  quit! 1
endif
