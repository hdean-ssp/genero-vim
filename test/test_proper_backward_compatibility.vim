" Test proper backward compatibility implementation
" This shows how to check for existing mappings before registering

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

" TEST 1: Create user mapping
try
  command! MyCustomCommand echo 'Custom command executed'
  nnoremap <silent> <C-.> :MyCustomCommand<CR>
  
  let mapping_before = maparg('<C-.>', 'n')
  call RecordTest('Step 1: User mapping created', 1,
    \ 'Mapping: ' . mapping_before)
catch
  call RecordTest('Step 1: User mapping created', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 2: Check if mapping exists before registering
try
  " This is the proper way to handle backward compatibility
  if empty(maparg('<C-.>', 'n'))
    " Only register if no mapping exists
    nnoremap <silent> <C-.> :call genero_tools#compiler#commands#next_error()<CR>
    call RecordTest('Step 2: Plugin mapping registered', 1,
      \ 'No existing mapping, plugin registered its own')
  else
    " User has a mapping, respect it
    call RecordTest('Step 2: Plugin mapping registered', 1,
      \ 'User mapping exists, plugin respects it')
  endif
catch
  call RecordTest('Step 2: Plugin mapping registered', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 3: Verify user mapping is preserved
try
  let mapping_after = maparg('<C-.>', 'n')
  
  if mapping_after =~? 'MyCustomCommand'
    call RecordTest('Step 3: User mapping preserved', 1,
      \ 'User mapping still in place: ' . mapping_after)
  else
    call RecordTest('Step 3: User mapping preserved', 0,
      \ 'User mapping was overridden: ' . mapping_after)
  endif
catch
  call RecordTest('Step 3: User mapping preserved', 0,
    \ 'Exception: ' . v:exception)
endtry

" Print results
let output_lines = [
  \ '========================================',
  \ 'PROPER BACKWARD COMPATIBILITY TEST',
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

call writefile(output_lines, 'TEST_PROPER_BACKWARD_COMPAT.txt')

for line in output_lines
  echom line
endfor

quit!
