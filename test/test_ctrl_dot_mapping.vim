" Test if Ctrl+. and Ctrl+, can be mapped

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

" TEST 1: Try to map Ctrl+.
try
  nnoremap <silent> <C-.> :echo 'Ctrl+. pressed'<CR>
  let mapping = maparg('<C-.>', 'n')
  if !empty(mapping)
    call RecordTest('Step 1: Ctrl+. mapping created', 1,
      \ 'Mapping: ' . mapping)
  else
    call RecordTest('Step 1: Ctrl+. mapping created', 0,
      \ 'Mapping not found after creation')
  endif
catch
  call RecordTest('Step 1: Ctrl+. mapping created', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 2: Try to map Ctrl+,
try
  nnoremap <silent> <C-,> :echo 'Ctrl+, pressed'<CR>
  let mapping = maparg('<C-,>', 'n')
  if !empty(mapping)
    call RecordTest('Step 2: Ctrl+, mapping created', 1,
      \ 'Mapping: ' . mapping)
  else
    call RecordTest('Step 2: Ctrl+, mapping created', 0,
      \ 'Mapping not found after creation')
  endif
catch
  call RecordTest('Step 2: Ctrl+, mapping created', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 3: Check if mappings persist
try
  let dot_mapping = maparg('<C-.>', 'n')
  let comma_mapping = maparg('<C-,>', 'n')
  
  if !empty(dot_mapping) && !empty(comma_mapping)
    call RecordTest('Step 3: Mappings persist', 1,
      \ 'Both mappings found')
  else
    let details = 'Ctrl+.: ' . (empty(dot_mapping) ? 'missing' : 'present') . ' | Ctrl+,: ' . (empty(comma_mapping) ? 'missing' : 'present')
    call RecordTest('Step 3: Mappings persist', 0, details)
  endif
catch
  call RecordTest('Step 3: Mappings persist', 0,
    \ 'Exception: ' . v:exception)
endtry

" Print results
let output_lines = [
  \ '========================================',
  \ 'CTRL+. AND CTRL+, MAPPING TEST',
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

call writefile(output_lines, 'TEST_CTRL_DOT_MAPPING.txt')

for line in output_lines
  echom line
endfor

quit!
