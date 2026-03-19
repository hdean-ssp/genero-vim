" Test backward compatibility for keybindings
" This script tests that user-defined keybindings are not overridden by the plugin

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

" TEST 3.1.1: Create test vimrc with custom Ctrl+. mapping
try
  " Define a custom command that will be mapped to Ctrl+.
  command! MyCustomCommand echo 'Custom command executed'
  
  " Create a custom mapping for Ctrl+. to our custom command
  nnoremap <silent> <C-.> :MyCustomCommand<CR>
  
  " Verify the mapping was created
  let mapping = maparg('<C-.>', 'n')
  if !empty(mapping)
    call RecordTest('3.1.1: Custom Ctrl+. mapping created', 1,
      \ 'Custom mapping found: ' . mapping)
  else
    call RecordTest('3.1.1: Custom Ctrl+. mapping created', 0,
      \ 'Failed to create custom mapping')
  endif
catch
  call RecordTest('3.1.1: Custom Ctrl+. mapping created', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 3.1.2: Verify plugin respects user's mapping
try
  " Store the original mapping
  let original_mapping = maparg('<C-.>', 'n')
  
  " Now simulate plugin initialization by calling the keybindings register function
  " First, check if the function exists
  if exists('*genero_tools#keybindings#register')
    " Call the plugin's keybinding registration
    call genero_tools#keybindings#register()
    
    " Check if the mapping was preserved
    let current_mapping = maparg('<C-.>', 'n')
    
    " The mapping should still be our custom one, not the plugin's
    if current_mapping == original_mapping
      call RecordTest('3.1.2: Plugin respects user mapping', 1,
        \ 'User mapping preserved after plugin initialization')
    else
      call RecordTest('3.1.2: Plugin respects user mapping', 0,
        \ 'Mapping was changed. Original: ' . original_mapping . ' | Current: ' . current_mapping)
    endif
  else
    call RecordTest('3.1.2: Plugin respects user mapping', 0,
      \ 'genero_tools#keybindings#register function not found')
  endif
catch
  call RecordTest('3.1.2: Plugin respects user mapping', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 3.1.3: Verify keybindings_enabled config is respected
try
  " Check if keybindings_enabled config exists
  if exists('*genero_tools#config#get')
    let keybindings_enabled = genero_tools#config#get('keybindings_enabled')
    
    if keybindings_enabled == 1 || keybindings_enabled == 0
      call RecordTest('3.1.3: keybindings_enabled config exists', 1,
        \ 'Config value: ' . keybindings_enabled)
    else
      call RecordTest('3.1.3: keybindings_enabled config exists', 0,
        \ 'Unexpected config value: ' . keybindings_enabled)
    endif
  else
    call RecordTest('3.1.3: keybindings_enabled config exists', 0,
      \ 'genero_tools#config#get function not found')
  endif
catch
  call RecordTest('3.1.3: keybindings_enabled config exists', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 3.1.4: Verify custom Ctrl+, mapping is also preserved
try
  " Define a custom command for Ctrl+,
  command! MyPrevCommand echo 'Custom prev command executed'
  
  " Create a custom mapping for Ctrl+, to our custom command
  nnoremap <silent> <C-,> :MyPrevCommand<CR>
  
  " Store the original mapping
  let original_prev_mapping = maparg('<C-,>', 'n')
  
  " Call the plugin's keybinding registration
  if exists('*genero_tools#keybindings#register')
    call genero_tools#keybindings#register()
    
    " Check if the mapping was preserved
    let current_prev_mapping = maparg('<C-,>', 'n')
    
    if current_prev_mapping == original_prev_mapping
      call RecordTest('3.1.4: Plugin respects Ctrl+, mapping', 1,
        \ 'User mapping for Ctrl+, preserved')
    else
      call RecordTest('3.1.4: Plugin respects Ctrl+, mapping', 0,
        \ 'Mapping was changed. Original: ' . original_prev_mapping . ' | Current: ' . current_prev_mapping)
    endif
  else
    call RecordTest('3.1.4: Plugin respects Ctrl+, mapping', 0,
      \ 'genero_tools#keybindings#register function not found')
  endif
catch
  call RecordTest('3.1.4: Plugin respects Ctrl+, mapping', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 3.1.5: Verify no conflicts with other keybindings
try
  " Check that our custom mappings are still in place
  let ctrl_dot_mapping = maparg('<C-.>', 'n')
  let ctrl_comma_mapping = maparg('<C-,>', 'n')
  
  if !empty(ctrl_dot_mapping) && !empty(ctrl_comma_mapping)
    call RecordTest('3.1.5: No keybinding conflicts', 1,
      \ 'Both custom mappings preserved')
  else
    let details = 'Ctrl+.: ' . (empty(ctrl_dot_mapping) ? 'missing' : 'present') . ' | Ctrl+,: ' . (empty(ctrl_comma_mapping) ? 'missing' : 'present')
    call RecordTest('3.1.5: No keybinding conflicts', 0, details)
  endif
catch
  call RecordTest('3.1.5: No keybinding conflicts', 0,
    \ 'Exception: ' . v:exception)
endtry

" Print results
let output_lines = [
  \ '========================================',
  \ 'BACKWARD COMPATIBILITY KEYBINDING TEST',
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
call add(output_lines, '')
call add(output_lines, 'Test Summary:')
call add(output_lines, '  Task 3.1: Test that user-defined keybindings are not overridden')
call add(output_lines, '  Status: ' . (g:test_results.failed == 0 ? 'PASS' : 'FAIL'))

call writefile(output_lines, 'TEST_RESULTS_3_1.txt')

" Print to console as well
for line in output_lines
  echom line
endfor

" Exit
quit!
