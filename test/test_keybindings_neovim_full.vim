" Full test script for Neovim keybindings with proper plugin initialization
" This script tests the Ctrl+. and Ctrl+, keybindings in Neovim

" Ensure we're in Neovim
if !has('nvim')
  echom 'ERROR: This test requires Neovim'
  quit!
endif

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
    let status = 'PASS'
  else
    let g:test_results.failed += 1
    let status = 'FAIL'
  endif
  
  call add(g:test_results.tests, {
    \ 'name': a:name,
    \ 'status': status,
    \ 'details': a:details
    \ })
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

" TEST 1.4.1: Verify Ctrl+. triggers next error navigation
try
  call CreateTestQuickfixList()
  cfirst
  let pos_before = GetCurrentErrorPosition()
  call genero_tools#compiler#commands#next_error()
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

" TEST 1.4.2: Verify Ctrl+, triggers previous error navigation
try
  call CreateTestQuickfixList()
  clast
  let pos_before = GetCurrentErrorPosition()
  call genero_tools#compiler#commands#prev_error()
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

" TEST 1.4.3: Test with empty quickfix list
try
  call ClearQuickfixList()
  let result_next = genero_tools#compiler#quickfix#next()
  let next_success = !result_next.success && result_next.error =~? 'No errors to navigate'
  
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

" TEST 1.4.4: Test at boundaries (first/last error)
try
  call CreateTestQuickfixList()
  cfirst
  let result_at_first = genero_tools#compiler#quickfix#prev()
  let at_first_ok = !result_at_first.success && result_at_first.error =~? 'No previous error'
  
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

" VERIFY KEYBINDING REGISTRATION
try
  let keybindings_enabled = genero_tools#config#get('keybindings_enabled')
  
  if keybindings_enabled
    let mapping_next = maparg('<C-.>', 'n')
    let mapping_prev = maparg('<C-,>', 'n')
    
    if !empty(mapping_next)
      call RecordTest('Keybinding: Ctrl+. registered', 1, mapping_next)
    else
      call RecordTest('Keybinding: Ctrl+. registered', 0, 'Mapping not found')
    endif
    
    if !empty(mapping_prev)
      call RecordTest('Keybinding: Ctrl+, registered', 1, mapping_prev)
    else
      call RecordTest('Keybinding: Ctrl+, registered', 0, 'Mapping not found')
    endif
  else
    call RecordTest('Keybindings enabled', 0, 'Keybindings disabled in config')
  endif
catch
  call RecordTest('Keybinding registration check', 0, 'Exception: ' . v:exception)
endtry

" Print results to file
let output_lines = [
  \ '========================================',
  \ 'NEOVIM KEYBINDING TEST RESULTS',
  \ '========================================',
  \ 'Total Tests: ' . g:test_results.total,
  \ 'Passed: ' . g:test_results.passed,
  \ 'Failed: ' . g:test_results.failed,
  \ ''
  \ ]

for test in g:test_results.tests
  call add(output_lines, test.status . ': ' . test.name)
  if !empty(test.details)
    call add(output_lines, '  ' . test.details)
  endif
endfor

call writefile(output_lines, 'TEST_RESULTS_1_4.txt')

" Exit
quit!
