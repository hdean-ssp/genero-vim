" Test keybindings configuration

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

" TEST 1: Check if keybindings_enabled config exists
try
  if exists('*genero_tools#config#get')
    let keybindings_enabled = genero_tools#config#get('keybindings_enabled')
    call RecordTest('Step 1: Config function exists', 1,
      \ 'keybindings_enabled = ' . keybindings_enabled)
  else
    call RecordTest('Step 1: Config function exists', 0,
      \ 'genero_tools#config#get not found')
  endif
catch
  call RecordTest('Step 1: Config function exists', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 2: Check if keybindings register function exists
try
  if exists('*genero_tools#keybindings#register')
    call RecordTest('Step 2: Keybindings register function exists', 1,
      \ 'Function found')
  else
    call RecordTest('Step 2: Keybindings register function exists', 0,
      \ 'Function not found')
  endif
catch
  call RecordTest('Step 2: Keybindings register function exists', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 3: Check if plugin initialization calls keybindings register
try
  " Check if the plugin was loaded
  if exists('g:loaded_genero_tools')
    call RecordTest('Step 3: Plugin loaded', 1,
      \ 'g:loaded_genero_tools = ' . g:loaded_genero_tools)
  else
    call RecordTest('Step 3: Plugin loaded', 0,
      \ 'Plugin not loaded')
  endif
catch
  call RecordTest('Step 3: Plugin loaded', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 4: Manually check Ctrl+. mapping
try
  let mapping = maparg('<C-.>', 'n')
  if !empty(mapping)
    call RecordTest('Step 4: Ctrl+. mapping exists', 1,
      \ 'Mapping: ' . mapping)
  else
    call RecordTest('Step 4: Ctrl+. mapping exists', 0,
      \ 'No mapping found')
  endif
catch
  call RecordTest('Step 4: Ctrl+. mapping exists', 0,
    \ 'Exception: ' . v:exception)
endtry

" Print results
let output_lines = [
  \ '========================================',
  \ 'KEYBINDINGS CONFIGURATION TEST',
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

call writefile(output_lines, 'TEST_KEYBINDINGS_CONFIG.txt')

for line in output_lines
  echom line
endfor

quit!
