" Test to understand mapping override behavior

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

" TEST 2: Check what happens when plugin tries to register
try
  " This is what the plugin does
  nnoremap <silent> <C-.> :call genero_tools#compiler#commands#next_error()<CR>
  
  let mapping_after = maparg('<C-.>', 'n')
  call RecordTest('Step 2: Plugin mapping registered', 1,
    \ 'Mapping: ' . mapping_after)
catch
  call RecordTest('Step 2: Plugin mapping registered', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 3: Compare mappings
try
  let mapping_before = maparg('<C-.>', 'n')
  
  if mapping_before =~? 'next_error'
    call RecordTest('Step 3: Mapping comparison', 1,
      \ 'Plugin mapping OVERRODE user mapping')
  else
    call RecordTest('Step 3: Mapping comparison', 0,
      \ 'Unexpected mapping: ' . mapping_before)
  endif
catch
  call RecordTest('Step 3: Mapping comparison', 0,
    \ 'Exception: ' . v:exception)
endtry

" Print results
let output_lines = [
  \ '========================================',
  \ 'MAPPING OVERRIDE BEHAVIOR TEST',
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

call writefile(output_lines, 'TEST_MAPPING_OVERRIDE.txt')

for line in output_lines
  echom line
endfor

quit!
