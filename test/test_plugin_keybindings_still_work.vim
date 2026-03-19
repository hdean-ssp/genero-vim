" Test that plugin keybindings still work when no user mappings exist

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

" TEST 1: Verify plugin keybindings are registered
try
  if exists('*genero_tools#keybindings#register')
    call genero_tools#keybindings#register()
    call RecordTest('Step 1: Plugin keybindings registered', 1,
      \ 'Function called successfully')
  else
    call RecordTest('Step 1: Plugin keybindings registered', 0,
      \ 'Function not found')
  endif
catch
  call RecordTest('Step 1: Plugin keybindings registered', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 2: Verify Ctrl+. mapping exists
try
  let mapping = maparg('<C-.>', 'n')
  if !empty(mapping) && mapping =~? 'next_error'
    call RecordTest('Step 2: Ctrl+. mapping registered', 1,
      \ 'Mapping: ' . mapping)
  else
    call RecordTest('Step 2: Ctrl+. mapping registered', 0,
      \ 'Mapping not found or incorrect: ' . mapping)
  endif
catch
  call RecordTest('Step 2: Ctrl+. mapping registered', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 3: Verify Ctrl+, mapping exists
try
  let mapping = maparg('<C-,>', 'n')
  if !empty(mapping) && mapping =~? 'prev_error'
    call RecordTest('Step 3: Ctrl+, mapping registered', 1,
      \ 'Mapping: ' . mapping)
  else
    call RecordTest('Step 3: Ctrl+, mapping registered', 0,
      \ 'Mapping not found or incorrect: ' . mapping)
  endif
catch
  call RecordTest('Step 3: Ctrl+, mapping registered', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 4: Verify Ctrl+N mapping exists
try
  let mapping = maparg('<C-n>', 'i')
  if !empty(mapping) && mapping =~? 'C-x.*C-o'
    call RecordTest('Step 4: Ctrl+N mapping registered', 1,
      \ 'Mapping: ' . mapping)
  else
    call RecordTest('Step 4: Ctrl+N mapping registered', 0,
      \ 'Mapping not found or incorrect: ' . mapping)
  endif
catch
  call RecordTest('Step 4: Ctrl+N mapping registered', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 5: Verify leader mappings exist
try
  let gl_mapping = maparg('<leader>gl', 'n')
  let gf_mapping = maparg('<leader>gf', 'n')
  let gs_mapping = maparg('<leader>gs', 'n')
  let gm_mapping = maparg('<leader>gm', 'n')
  
  if !empty(gl_mapping) && !empty(gf_mapping) && !empty(gs_mapping) && !empty(gm_mapping)
    call RecordTest('Step 5: Leader mappings registered', 1,
      \ 'All leader mappings found')
  else
    let details = 'gl: ' . (empty(gl_mapping) ? 'missing' : 'present') . ' | gf: ' . (empty(gf_mapping) ? 'missing' : 'present') . ' | gs: ' . (empty(gs_mapping) ? 'missing' : 'present') . ' | gm: ' . (empty(gm_mapping) ? 'missing' : 'present')
    call RecordTest('Step 5: Leader mappings registered', 0, details)
  endif
catch
  call RecordTest('Step 5: Leader mappings registered', 0,
    \ 'Exception: ' . v:exception)
endtry

" Print results
let output_lines = [
  \ '========================================',
  \ 'PLUGIN KEYBINDINGS FUNCTIONALITY TEST',
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

call writefile(output_lines, 'TEST_PLUGIN_KEYBINDINGS_WORK.txt')

for line in output_lines
  echom line
endfor

quit!
