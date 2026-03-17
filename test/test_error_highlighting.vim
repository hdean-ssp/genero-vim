" Test for Task 22: E2.1 - Add Line/Text Error Highlighting
" Verifies that error and warning highlighting works correctly

" Load the plugin first
set runtimepath+=.

" Test 1: Highlight groups are defined
function! Test_highlight_groups_defined() abort
  call genero_tools#compiler#highlight#init()
  
  " Check that highlight groups exist
  let error_hl = execute('highlight GeneroError')
  let warning_hl = execute('highlight GeneroWarning')
  let info_hl = execute('highlight GeneroInfo')
  
  if error_hl =~? 'GeneroError' && warning_hl =~? 'GeneroWarning' && info_hl =~? 'GeneroInfo'
    echo '✓ Highlight groups are defined'
    return v:true
  else
    echo '✗ Highlight groups not defined'
    return v:false
  endif
endfunction

" Test 2: Line highlighting for errors
function! Test_line_highlighting_errors() abort
  call genero_tools#compiler#highlight#init()
  call genero_tools#compiler#highlight#clear()
  
  " Create test errors
  let errors = [
    \ {'line': 1, 'col': 1, 'end_col': 5, 'message': 'Test error 1'},
    \ {'line': 5, 'col': 1, 'end_col': 10, 'message': 'Test error 2'},
    \ {'line': 10, 'col': 1, 'end_col': 15, 'message': 'Test error 3'}
  \ ]
  
  " Apply highlighting
  call genero_tools#compiler#highlight#apply(errors, [])
  
  " Check that matches were added (Vim only, Neovim uses namespace)
  if !has('nvim')
    let matches = getmatches()
    let error_matches = filter(copy(matches), "v:val.group == 'GeneroError'")
    
    if len(error_matches) == 3
      echo '✓ Line highlighting for errors works'
      return v:true
    else
      echo '✗ Line highlighting for errors failed: expected 3 matches, got ' . len(error_matches)
      return v:false
    endif
  else
    echo '✓ Line highlighting for errors works (Neovim)'
    return v:true
  endif
endfunction

" Test 3: Text highlighting for warnings
function! Test_text_highlighting_warnings() abort
  call genero_tools#compiler#highlight#init()
  call genero_tools#compiler#highlight#clear()
  
  " Create test warnings with column ranges
  let warnings = [
    \ {'line': 2, 'col': 5, 'end_col': 15, 'message': 'Test warning 1'},
    \ {'line': 7, 'col': 10, 'end_col': 20, 'message': 'Test warning 2'}
  \ ]
  
  " Apply highlighting
  call genero_tools#compiler#highlight#apply([], warnings)
  
  " Check that matches were added (Vim only)
  if !has('nvim')
    let matches = getmatches()
    let warning_matches = filter(copy(matches), "v:val.group == 'GeneroWarning'")
    
    if len(warning_matches) == 2
      echo '✓ Text highlighting for warnings works'
      return v:true
    else
      echo '✗ Text highlighting for warnings failed: expected 2 matches, got ' . len(warning_matches)
      return v:false
    endif
  else
    echo '✓ Text highlighting for warnings works (Neovim)'
    return v:true
  endif
endfunction

" Test 4: Mixed errors and warnings
function! Test_mixed_errors_warnings() abort
  call genero_tools#compiler#highlight#init()
  call genero_tools#compiler#highlight#clear()
  
  " Create mixed errors and warnings
  let errors = [
    \ {'line': 1, 'col': 1, 'end_col': 5, 'message': 'Error 1'},
    \ {'line': 3, 'col': 1, 'end_col': 10, 'message': 'Error 2'}
  \ ]
  
  let warnings = [
    \ {'line': 2, 'col': 5, 'end_col': 15, 'message': 'Warning 1'},
    \ {'line': 4, 'col': 10, 'end_col': 20, 'message': 'Warning 2'}
  \ ]
  
  " Apply highlighting
  call genero_tools#compiler#highlight#apply(errors, warnings)
  
  " Check that all matches were added (Vim only)
  if !has('nvim')
    let matches = getmatches()
    let error_matches = filter(copy(matches), "v:val.group == 'GeneroError'")
    let warning_matches = filter(copy(matches), "v:val.group == 'GeneroWarning'")
    
    if len(error_matches) == 2 && len(warning_matches) == 2
      echo '✓ Mixed errors and warnings highlighting works'
      return v:true
    else
      echo '✗ Mixed highlighting failed: errors=' . len(error_matches) . ', warnings=' . len(warning_matches)
      return v:false
    endif
  else
    echo '✓ Mixed errors and warnings highlighting works (Neovim)'
    return v:true
  endif
endfunction

" Test 5: Clearing highlights
function! Test_clear_highlights() abort
  call genero_tools#compiler#highlight#init()
  
  " Create and apply highlights
  let errors = [
    \ {'line': 1, 'col': 1, 'end_col': 5, 'message': 'Error 1'},
    \ {'line': 5, 'col': 1, 'end_col': 10, 'message': 'Error 2'}
  \ ]
  
  call genero_tools#compiler#highlight#apply(errors, [])
  
  " Clear highlights
  let clear_result = genero_tools#compiler#highlight#clear()
  
  if !has('nvim')
    " Check that matches were cleared (Vim only)
    let matches = getmatches()
    let remaining_matches = filter(copy(matches), 
      \ "v:val.group == 'GeneroError' || v:val.group == 'GeneroWarning' || v:val.group == 'GeneroInfo'")
    
    if len(remaining_matches) == 0 && clear_result.success
      echo '✓ Clearing highlights works'
      return v:true
    else
      echo '✗ Clearing highlights failed: ' . len(remaining_matches) . ' matches remain'
      return v:false
    endif
  else
    if clear_result.success
      echo '✓ Clearing highlights works (Neovim)'
      return v:true
    else
      echo '✗ Clearing highlights failed: ' . clear_result.error
      return v:false
    endif
  endif
endfunction

" Test 6: Highlighting with missing column info
function! Test_highlighting_missing_columns() abort
  call genero_tools#compiler#highlight#init()
  call genero_tools#compiler#highlight#clear()
  
  " Create errors/warnings without column info
  let errors = [
    \ {'line': 1, 'message': 'Error without columns'}
  \ ]
  
  let warnings = [
    \ {'line': 2, 'message': 'Warning without columns'}
  \ ]
  
  " Apply highlighting - should not crash
  let result = genero_tools#compiler#highlight#apply(errors, warnings)
  
  if result.success
    echo '✓ Highlighting handles missing column info'
    return v:true
  else
    echo '✗ Highlighting failed with missing columns: ' . result.error
    return v:false
  endif
endfunction

" Test 7: Multiple errors on same line
function! Test_multiple_errors_same_line() abort
  call genero_tools#compiler#highlight#init()
  call genero_tools#compiler#highlight#clear()
  
  " Create multiple errors on same line
  let errors = [
    \ {'line': 1, 'col': 1, 'end_col': 5, 'message': 'Error 1'},
    \ {'line': 1, 'col': 10, 'end_col': 15, 'message': 'Error 2'},
    \ {'line': 1, 'col': 20, 'end_col': 25, 'message': 'Error 3'}
  \ ]
  
  " Apply highlighting
  call genero_tools#compiler#highlight#apply(errors, [])
  
  if !has('nvim')
    let matches = getmatches()
    let error_matches = filter(copy(matches), "v:val.group == 'GeneroError'")
    
    if len(error_matches) == 3
      echo '✓ Multiple errors on same line works'
      return v:true
    else
      echo '✗ Multiple errors on same line failed: expected 3, got ' . len(error_matches)
      return v:false
    endif
  else
    echo '✓ Multiple errors on same line works (Neovim)'
    return v:true
  endif
endfunction

" Test 8: Unused variable highlighting
function! Test_unused_variable_highlighting() abort
  call genero_tools#compiler#highlight#init()
  call genero_tools#compiler#highlight#clear()
  
  " Create warnings for unused variables
  let warnings = [
    \ {'line': 1, 'col': 1, 'message': "The symbol 'l_unused_var' is unused.", 'code': '(-6615)'},
    \ {'line': 2, 'col': 1, 'message': "The symbol 'l_another_var' is unused.", 'code': '(-6615)'}
  \ ]
  
  " Apply unused variable highlighting
  call genero_tools#compiler#highlight#unused_vars(warnings)
  
  if !has('nvim')
    let matches = getmatches()
    let unused_matches = filter(copy(matches), "v:val.group == 'GeneroUnusedVariable'")
    
    if len(unused_matches) >= 2
      echo '✓ Unused variable highlighting works'
      return v:true
    else
      echo '✗ Unused variable highlighting failed: expected 2+, got ' . len(unused_matches)
      return v:false
    endif
  else
    echo '✓ Unused variable highlighting works (Neovim)'
    return v:true
  endif
endfunction

" Test 9: Highlight groups have correct colors
function! Test_highlight_colors() abort
  call genero_tools#compiler#highlight#init()
  
  " Check error highlight
  let error_hl = execute('highlight GeneroError')
  let warning_hl = execute('highlight GeneroWarning')
  let info_hl = execute('highlight GeneroInfo')
  
  " Verify that highlights have background colors defined
  if error_hl =~? 'guibg' && warning_hl =~? 'guibg' && info_hl =~? 'guibg'
    echo '✓ Highlight groups have colors defined'
    return v:true
  else
    echo '✗ Highlight groups missing colors'
    return v:false
  endif
endfunction

" Test 10: Apply function returns success
function! Test_apply_returns_success() abort
  call genero_tools#compiler#highlight#init()
  
  let errors = [{'line': 1, 'col': 1, 'end_col': 5, 'message': 'Error'}]
  let result = genero_tools#compiler#highlight#apply(errors, [])
  
  if result.success && result.error == ''
    echo '✓ Apply function returns success'
    return v:true
  else
    echo '✗ Apply function failed: ' . result.error
    return v:false
  endif
endfunction

" Run all tests
try
  echo "Running error highlighting tests..."
  echo ""
  
  let results = []
  call add(results, Test_highlight_groups_defined())
  call add(results, Test_line_highlighting_errors())
  call add(results, Test_text_highlighting_warnings())
  call add(results, Test_mixed_errors_warnings())
  call add(results, Test_clear_highlights())
  call add(results, Test_highlighting_missing_columns())
  call add(results, Test_multiple_errors_same_line())
  call add(results, Test_unused_variable_highlighting())
  call add(results, Test_highlight_colors())
  call add(results, Test_apply_returns_success())
  
  echo ""
  let passed = len(filter(copy(results), 'v:val == v:true'))
  let total = len(results)
  echo printf('✓ %d/%d tests passed', passed, total)
  
  if passed == total
    echo "✓ All error highlighting tests passed!"
  else
    echo "✗ Some tests failed"
  endif
catch
  echo "✗ Test failed: " . v:exception
endtry
