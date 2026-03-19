" Comprehensive backward compatibility test for keybindings
" This test demonstrates that:
" 1. User-defined keybindings are preserved
" 2. Plugin keybindings are registered when no user mappings exist
" 3. The keybindings_enabled config is respected

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

" ============================================================================
" PART 1: Test that user-defined keybindings are preserved
" ============================================================================

" TEST 1.1: Create user mapping for Ctrl+.
try
  command! MyCustomNextError echo 'User custom next error'
  nnoremap <silent> <C-.> :MyCustomNextError<CR>
  
  let user_mapping = maparg('<C-.>', 'n')
  if !empty(user_mapping) && user_mapping =~? 'MyCustomNextError'
    call RecordTest('1.1: User Ctrl+. mapping created', 1,
      \ 'Mapping: ' . user_mapping)
  else
    call RecordTest('1.1: User Ctrl+. mapping created', 0,
      \ 'Failed to create user mapping')
  endif
catch
  call RecordTest('1.1: User Ctrl+. mapping created', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 1.2: Create user mapping for Ctrl+,
try
  command! MyCustomPrevError echo 'User custom prev error'
  nnoremap <silent> <C-,> :MyCustomPrevError<CR>
  
  let user_mapping = maparg('<C-,>', 'n')
  if !empty(user_mapping) && user_mapping =~? 'MyCustomPrevError'
    call RecordTest('1.2: User Ctrl+, mapping created', 1,
      \ 'Mapping: ' . user_mapping)
  else
    call RecordTest('1.2: User Ctrl+, mapping created', 0,
      \ 'Failed to create user mapping')
  endif
catch
  call RecordTest('1.2: User Ctrl+, mapping created', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 1.3: Store original mappings
try
  let original_dot_mapping = maparg('<C-.>', 'n')
  let original_comma_mapping = maparg('<C-,>', 'n')
  
  call RecordTest('1.3: Original mappings stored', 1,
    \ 'Dot: ' . original_dot_mapping . ' | Comma: ' . original_comma_mapping)
catch
  call RecordTest('1.3: Original mappings stored', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 1.4: Call plugin keybindings register
try
  if exists('*genero_tools#keybindings#register')
    call genero_tools#keybindings#register()
    call RecordTest('1.4: Plugin keybindings register called', 1,
      \ 'Function executed successfully')
  else
    call RecordTest('1.4: Plugin keybindings register called', 0,
      \ 'Function not found')
  endif
catch
  call RecordTest('1.4: Plugin keybindings register called', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 1.5: Verify user mappings are preserved
try
  let current_dot_mapping = maparg('<C-.>', 'n')
  let current_comma_mapping = maparg('<C-,>', 'n')
  
  if current_dot_mapping == original_dot_mapping && current_comma_mapping == original_comma_mapping
    call RecordTest('1.5: User mappings preserved', 1,
      \ 'Both mappings unchanged after plugin registration')
  else
    let details = 'Dot changed: ' . (current_dot_mapping != original_dot_mapping ? 'yes' : 'no') . ' | Comma changed: ' . (current_comma_mapping != original_comma_mapping ? 'yes' : 'no')
    call RecordTest('1.5: User mappings preserved', 0, details)
  endif
catch
  call RecordTest('1.5: User mappings preserved', 0,
    \ 'Exception: ' . v:exception)
endtry

" ============================================================================
" PART 2: Test that plugin keybindings are registered when no user mappings exist
" ============================================================================

" TEST 2.1: Clear existing mappings
try
  " Clear the user mappings we created
  nunmap <C-.>
  nunmap <C-,>
  
  let dot_mapping = maparg('<C-.>', 'n')
  let comma_mapping = maparg('<C-,>', 'n')
  
  if empty(dot_mapping) && empty(comma_mapping)
    call RecordTest('2.1: User mappings cleared', 1,
      \ 'Both mappings removed')
  else
    call RecordTest('2.1: User mappings cleared', 0,
      \ 'Mappings still exist')
  endif
catch
  call RecordTest('2.1: User mappings cleared', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 2.2: Call plugin keybindings register again
try
  if exists('*genero_tools#keybindings#register')
    call genero_tools#keybindings#register()
    call RecordTest('2.2: Plugin keybindings register called again', 1,
      \ 'Function executed successfully')
  else
    call RecordTest('2.2: Plugin keybindings register called again', 0,
      \ 'Function not found')
  endif
catch
  call RecordTest('2.2: Plugin keybindings register called again', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 2.3: Verify plugin keybindings are registered
try
  let dot_mapping = maparg('<C-.>', 'n')
  let comma_mapping = maparg('<C-,>', 'n')
  
  if !empty(dot_mapping) && !empty(comma_mapping)
    call RecordTest('2.3: Plugin keybindings registered', 1,
      \ 'Both Ctrl+. and Ctrl+, mappings registered')
  else
    let details = 'Ctrl+.: ' . (empty(dot_mapping) ? 'missing' : 'present') . ' | Ctrl+,: ' . (empty(comma_mapping) ? 'missing' : 'present')
    call RecordTest('2.3: Plugin keybindings registered', 0, details)
  endif
catch
  call RecordTest('2.3: Plugin keybindings registered', 0,
    \ 'Exception: ' . v:exception)
endtry

" ============================================================================
" PART 3: Test that keybindings_enabled config is respected
" ============================================================================

" TEST 3.1: Check keybindings_enabled config
try
  if exists('*genero_tools#config#get')
    let keybindings_enabled = genero_tools#config#get('keybindings_enabled')
    
    if keybindings_enabled == 1 || keybindings_enabled == v:true
      call RecordTest('3.1: keybindings_enabled config', 1,
        \ 'Config value: ' . keybindings_enabled . ' (enabled)')
    else
      call RecordTest('3.1: keybindings_enabled config', 0,
        \ 'Config value: ' . keybindings_enabled . ' (disabled)')
    endif
  else
    call RecordTest('3.1: keybindings_enabled config', 0,
      \ 'Config function not found')
  endif
catch
  call RecordTest('3.1: keybindings_enabled config', 0,
    \ 'Exception: ' . v:exception)
endtry

" TEST 3.2: Verify leader mappings are registered
try
  let gl_mapping = maparg('<leader>gl', 'n')
  let gf_mapping = maparg('<leader>gf', 'n')
  let gs_mapping = maparg('<leader>gs', 'n')
  let gm_mapping = maparg('<leader>gm', 'n')
  
  if !empty(gl_mapping) && !empty(gf_mapping) && !empty(gs_mapping) && !empty(gm_mapping)
    call RecordTest('3.2: Leader mappings registered', 1,
      \ 'All leader mappings present')
  else
    let details = 'gl: ' . (empty(gl_mapping) ? 'missing' : 'present') . ' | gf: ' . (empty(gf_mapping) ? 'missing' : 'present') . ' | gs: ' . (empty(gs_mapping) ? 'missing' : 'present') . ' | gm: ' . (empty(gm_mapping) ? 'missing' : 'present')
    call RecordTest('3.2: Leader mappings registered', 0, details)
  endif
catch
  call RecordTest('3.2: Leader mappings registered', 0,
    \ 'Exception: ' . v:exception)
endtry

" Print results
let output_lines = [
  \ '========================================',
  \ 'COMPREHENSIVE BACKWARD COMPATIBILITY TEST',
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

call writefile(output_lines, 'TEST_COMPREHENSIVE_BACKWARD_COMPAT.txt')

for line in output_lines
  echom line
endfor

quit!
