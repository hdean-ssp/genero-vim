" Test script for Ctrl+N autocomplete keybinding
" This script tests that Ctrl+N triggers omnifunc completion in insert mode

" Ensure we're in Neovim or Vim 8+
if !has('nvim') && v:version < 800
  echom 'ERROR: This test requires Vim 8+ or Neovim'
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

" TEST 2.1.1: Verify Ctrl+N keybinding is registered
try
  let mapping = maparg('<C-n>', 'i')
  
  if !empty(mapping)
    call RecordTest('2.1.1: Ctrl+N keybinding registered', 1,
      \ 'Mapping found: ' . mapping)
  else
    call RecordTest('2.1.1: Ctrl+N keybinding registered', 0,
      \ 'No mapping found for <C-n> in insert mode')
  endif
catch
  call RecordTest('2.1.1: Ctrl+N keybinding registered', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 2.1.2: Verify Ctrl+N maps to omnifunc completion
try
  let mapping = maparg('<C-n>', 'i')
  
  " Check if mapping contains the omnifunc completion sequence
  if mapping =~? '<C-x><C-o>' || mapping =~? 'C-x.*C-o'
    call RecordTest('2.1.2: Ctrl+N maps to omnifunc', 1,
      \ 'Mapping correctly maps to <C-x><C-o>')
  else
    call RecordTest('2.1.2: Ctrl+N maps to omnifunc', 0,
      \ 'Mapping does not contain omnifunc sequence: ' . mapping)
  endif
catch
  call RecordTest('2.1.2: Ctrl+N maps to omnifunc', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 2.1.3: Verify Ctrl+N only works in insert mode
try
  let insert_mapping = maparg('<C-n>', 'i')
  let normal_mapping = maparg('<C-n>', 'n')
  let visual_mapping = maparg('<C-n>', 'v')
  
  let insert_ok = !empty(insert_mapping)
  let normal_ok = empty(normal_mapping)
  let visual_ok = empty(visual_mapping)
  
  if insert_ok && normal_ok && visual_ok
    call RecordTest('2.1.3: Ctrl+N mode-specific', 1,
      \ 'Mapping only exists in insert mode')
  else
    let details = 'insert: ' . (insert_ok ? 'yes' : 'no') . 
                  ' | normal: ' . (normal_ok ? 'no' : 'yes') .
                  ' | visual: ' . (visual_ok ? 'no' : 'yes')
    call RecordTest('2.1.3: Ctrl+N mode-specific', 0, details)
  endif
catch
  call RecordTest('2.1.3: Ctrl+N mode-specific', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 2.1.4: Verify keybinding is silent (no echo)
try
  let mapping = maparg('<C-n>', 'i')
  
  " Check if mapping is marked as silent
  if mapping =~? '<silent>'
    call RecordTest('2.1.4: Ctrl+N is silent', 1,
      \ 'Mapping is marked as silent')
  else
    call RecordTest('2.1.4: Ctrl+N is silent', 0,
      \ 'Mapping is not marked as silent')
  endif
catch
  call RecordTest('2.1.4: Ctrl+N is silent', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 2.1.5: Verify keybinding registration in genero_tools
try
  let keybindings_enabled = genero_tools#config#get('keybindings_enabled')
  
  if keybindings_enabled
    let mapping = maparg('<C-n>', 'i')
    if !empty(mapping)
      call RecordTest('2.1.5: Keybinding registered by plugin', 1,
        \ 'Ctrl+N registered when keybindings_enabled=1')
    else
      call RecordTest('2.1.5: Keybinding registered by plugin', 0,
        \ 'Mapping not found despite keybindings_enabled=1')
    endif
  else
    call RecordTest('2.1.5: Keybinding registration check', 0,
      \ 'Keybindings disabled in config')
  endif
catch
  call RecordTest('2.1.5: Keybinding registration check', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 2.1.6: Verify Ctrl+N doesn't conflict with other keybindings
try
  " Check if Ctrl+N is used elsewhere
  let normal_mapping = maparg('<C-n>', 'n')
  let visual_mapping = maparg('<C-n>', 'v')
  let command_mapping = maparg('<C-n>', 'c')
  
  let conflicts = []
  if !empty(normal_mapping)
    call add(conflicts, 'normal mode')
  endif
  if !empty(visual_mapping)
    call add(conflicts, 'visual mode')
  endif
  if !empty(command_mapping)
    call add(conflicts, 'command mode')
  endif
  
  if empty(conflicts)
    call RecordTest('2.1.6: No keybinding conflicts', 1,
      \ 'Ctrl+N only mapped in insert mode')
  else
    call RecordTest('2.1.6: No keybinding conflicts', 0,
      \ 'Conflicts found in: ' . join(conflicts, ', '))
  endif
catch
  call RecordTest('2.1.6: No keybinding conflicts', 0,
    \ 'Exception: ' . v:exception)
endtry

" Print results
let output_lines = [
  \ '========================================',
  \ 'AUTOCOMPLETE KEYBINDING TEST RESULTS',
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

call add(output_lines, '')
call add(output_lines, 'Environment:')
call add(output_lines, '  Editor: ' . (has('nvim') ? 'Neovim ' . v:version : 'Vim ' . v:version))
call add(output_lines, '  OS: ' . system('uname -s'))

call writefile(output_lines, 'TEST_RESULTS_2_1_3.txt')

" Print to console
for line in output_lines
  echom line
endfor

" Exit
quit!
