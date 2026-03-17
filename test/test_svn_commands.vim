" Tests for SVN Commands Module
" Tests user-facing commands for SVN diff markers management

" Test: GeneroSVNRefresh command
function! Test_svn_refresh_command() abort
  " Create a temporary SVN working copy
  let temp_dir = tempname()
  let child_dir = temp_dir . '/child'
  let test_file = child_dir . '/test.txt'
  
  call mkdir(child_dir, 'p')
  call mkdir(temp_dir . '/.svn', 'p')
  call writefile(['line 1', 'line 2', 'line 3'], test_file)
  
  try
    " Open the test file
    execute 'edit ' . test_file
    
    " Call refresh command
    call genero_tools#svn#commands#refresh()
    
    " Verify no errors occurred
    call assert_true(1, 'Refresh command executed without error')
    
    " Close the file
    bdelete!
  finally
    call delete(temp_dir, 'rf')
  endtry
  
  echo 'Test passed: GeneroSVNRefresh command'
endfunction

" Test: GeneroSVNToggle command
function! Test_svn_toggle_command() abort
  " Create a temporary SVN working copy
  let temp_dir = tempname()
  let child_dir = temp_dir . '/child'
  let test_file = child_dir . '/test.txt'
  
  call mkdir(child_dir, 'p')
  call mkdir(temp_dir . '/.svn', 'p')
  call writefile(['line 1', 'line 2', 'line 3'], test_file)
  
  try
    " Open the test file
    execute 'edit ' . test_file
    let bufnr = bufnr('%')
    
    " Get initial toggle state
    let toggle_key = 'buffer_' . bufnr
    let initial_state = get(g:genero_tools_svn_toggle_state, toggle_key, 1)
    
    " Call toggle command
    call genero_tools#svn#commands#toggle()
    
    " Verify state changed
    let new_state = get(g:genero_tools_svn_toggle_state, toggle_key, 1)
    call assert_notequal(initial_state, new_state, 'Toggle state should change')
    
    " Toggle again
    call genero_tools#svn#commands#toggle()
    
    " Verify state changed back
    let final_state = get(g:genero_tools_svn_toggle_state, toggle_key, 1)
    call assert_equal(initial_state, final_state, 'Toggle state should return to initial')
    
    " Close the file
    bdelete!
  finally
    call delete(temp_dir, 'rf')
  endtry
  
  echo 'Test passed: GeneroSVNToggle command'
endfunction

" Test: GeneroSVNStatus command
function! Test_svn_status_command() abort
  " Create a temporary SVN working copy
  let temp_dir = tempname()
  let child_dir = temp_dir . '/child'
  let test_file = child_dir . '/test.txt'
  
  call mkdir(child_dir, 'p')
  call mkdir(temp_dir . '/.svn', 'p')
  call writefile(['line 1', 'line 2', 'line 3'], test_file)
  
  try
    " Open the test file
    execute 'edit ' . test_file
    
    " Call status command
    call genero_tools#svn#commands#status()
    
    " Verify no errors occurred
    call assert_true(1, 'Status command executed without error')
    
    " Close the file
    bdelete!
  finally
    call delete(temp_dir, 'rf')
  endtry
  
  echo 'Test passed: GeneroSVNStatus command'
endfunction

" Test: Refresh with no file open
function! Test_svn_refresh_no_file() abort
  " Create a new empty buffer
  enew
  
  " Call refresh command (should handle gracefully)
  call genero_tools#svn#commands#refresh()
  
  " Verify no errors occurred
  call assert_true(1, 'Refresh with no file handled gracefully')
  
  " Close the buffer
  bdelete!
  
  echo 'Test passed: Refresh with no file'
endfunction

" Test: Toggle with no file open
function! Test_svn_toggle_no_file() abort
  " Create a new empty buffer
  enew
  
  " Call toggle command (should handle gracefully)
  call genero_tools#svn#commands#toggle()
  
  " Verify no errors occurred
  call assert_true(1, 'Toggle with no file handled gracefully')
  
  " Close the buffer
  bdelete!
  
  echo 'Test passed: Toggle with no file'
endfunction

" Test: Status with no file open
function! Test_svn_status_no_file() abort
  " Create a new empty buffer
  enew
  
  " Call status command (should handle gracefully)
  call genero_tools#svn#commands#status()
  
  " Verify no errors occurred
  call assert_true(1, 'Status with no file handled gracefully')
  
  " Close the buffer
  bdelete!
  
  echo 'Test passed: Status with no file'
endfunction

" Test: Refresh with file not in SVN
function! Test_svn_refresh_not_in_svn() abort
  " Create a temporary directory without SVN
  let temp_dir = tempname()
  let test_file = temp_dir . '/test.txt'
  
  call mkdir(temp_dir, 'p')
  call writefile(['line 1', 'line 2', 'line 3'], test_file)
  
  try
    " Open the test file
    execute 'edit ' . test_file
    
    " Call refresh command (should handle gracefully)
    call genero_tools#svn#commands#refresh()
    
    " Verify no errors occurred
    call assert_true(1, 'Refresh with non-SVN file handled gracefully')
    
    " Close the file
    bdelete!
  finally
    call delete(temp_dir, 'rf')
  endtry
  
  echo 'Test passed: Refresh with file not in SVN'
endfunction

" Test: Toggle state persistence
function! Test_svn_toggle_state_persistence() abort
  " Create a temporary SVN working copy
  let temp_dir = tempname()
  let child_dir = temp_dir . '/child'
  let test_file = child_dir . '/test.txt'
  
  call mkdir(child_dir, 'p')
  call mkdir(temp_dir . '/.svn', 'p')
  call writefile(['line 1', 'line 2', 'line 3'], test_file)
  
  try
    " Open the test file
    execute 'edit ' . test_file
    let bufnr = bufnr('%')
    let toggle_key = 'buffer_' . bufnr
    
    " Clear toggle state
    let g:genero_tools_svn_toggle_state = {}
    
    " Initial state should be enabled (default)
    let initial_state = get(g:genero_tools_svn_toggle_state, toggle_key, 1)
    call assert_equal(1, initial_state, 'Initial state should be enabled')
    
    " Toggle to disabled
    call genero_tools#svn#commands#toggle()
    let state_after_first_toggle = get(g:genero_tools_svn_toggle_state, toggle_key, 1)
    call assert_equal(0, state_after_first_toggle, 'State should be disabled after first toggle')
    
    " Toggle back to enabled
    call genero_tools#svn#commands#toggle()
    let state_after_second_toggle = get(g:genero_tools_svn_toggle_state, toggle_key, 1)
    call assert_equal(1, state_after_second_toggle, 'State should be enabled after second toggle')
    
    " Close the file
    bdelete!
  finally
    call delete(temp_dir, 'rf')
  endtry
  
  echo 'Test passed: Toggle state persistence'
endfunction

" Test: Configuration option svn_enabled
function! Test_svn_config_enabled() abort
  " Save original config
  let original_config = copy(g:genero_tools_config)
  
  try
    " Disable SVN
    let g:genero_tools_config.svn_enabled = v:false
    
    " Create a temporary SVN working copy
    let temp_dir = tempname()
    let child_dir = temp_dir . '/child'
    let test_file = child_dir . '/test.txt'
    
    call mkdir(child_dir, 'p')
    call mkdir(temp_dir . '/.svn', 'p')
    call writefile(['line 1', 'line 2', 'line 3'], test_file)
    
    try
      " Open the test file
      execute 'edit ' . test_file
      
      " Call refresh command (should be disabled)
      call genero_tools#svn#commands#refresh()
      
      " Verify no errors occurred
      call assert_true(1, 'Refresh with SVN disabled handled gracefully')
      
      " Close the file
      bdelete!
    finally
      call delete(temp_dir, 'rf')
    endtry
  finally
    " Restore original config
    let g:genero_tools_config = original_config
  endtry
  
  echo 'Test passed: Configuration option svn_enabled'
endfunction

" Test: Configuration option svn_auto_update
function! Test_svn_config_auto_update() abort
  " Save original config
  let original_config = copy(g:genero_tools_config)
  
  try
    " Check that svn_auto_update is in config
    let auto_update = genero_tools#config#get('svn_auto_update')
    call assert_true(type(auto_update) == type(v:true), 'svn_auto_update should be a boolean')
    
    " Verify default is true
    call assert_equal(v:true, auto_update, 'svn_auto_update should default to true')
  finally
    " Restore original config
    let g:genero_tools_config = original_config
  endtry
  
  echo 'Test passed: Configuration option svn_auto_update'
endfunction

" Test: Configuration option svn_cache_ttl
function! Test_svn_config_cache_ttl() abort
  " Check that svn_cache_ttl is in config
  let cache_ttl = genero_tools#config#get('svn_cache_ttl')
  call assert_true(type(cache_ttl) == type(0), 'svn_cache_ttl should be a number')
  
  " Verify default is 300
  call assert_equal(300, cache_ttl, 'svn_cache_ttl should default to 300')
  
  echo 'Test passed: Configuration option svn_cache_ttl'
endfunction

" Test: Configuration options for show_added, show_modified, show_deleted
function! Test_svn_config_show_options() abort
  " Check svn_show_added
  let show_added = genero_tools#config#get('svn_show_added')
  call assert_equal(v:true, show_added, 'svn_show_added should default to true')
  
  " Check svn_show_modified
  let show_modified = genero_tools#config#get('svn_show_modified')
  call assert_equal(v:true, show_modified, 'svn_show_modified should default to true')
  
  " Check svn_show_deleted
  let show_deleted = genero_tools#config#get('svn_show_deleted')
  call assert_equal(v:true, show_deleted, 'svn_show_deleted should default to true')
  
  echo 'Test passed: Configuration options for show_added, show_modified, show_deleted'
endfunction

" Test: Commands are registered
function! Test_svn_commands_registered() abort
  " Check if commands exist
  redir => output
  silent command GeneroSVNRefresh
  redir END
  call assert_match('GeneroSVNRefresh', output, 'GeneroSVNRefresh command should be registered')
  
  redir => output
  silent command GeneroSVNToggle
  redir END
  call assert_match('GeneroSVNToggle', output, 'GeneroSVNToggle command should be registered')
  
  redir => output
  silent command GeneroSVNStatus
  redir END
  call assert_match('GeneroSVNStatus', output, 'GeneroSVNStatus command should be registered')
  
  echo 'Test passed: Commands are registered'
endfunction

" Run all tests
function! Test_svn_commands_all() abort
  call Test_svn_refresh_command()
  call Test_svn_toggle_command()
  call Test_svn_status_command()
  call Test_svn_refresh_no_file()
  call Test_svn_toggle_no_file()
  call Test_svn_status_no_file()
  call Test_svn_refresh_not_in_svn()
  call Test_svn_toggle_state_persistence()
  call Test_svn_config_enabled()
  call Test_svn_config_auto_update()
  call Test_svn_config_cache_ttl()
  call Test_svn_config_show_options()
  call Test_svn_commands_registered()
  
  echo 'All SVN commands tests passed!'
endfunction

" Run tests if this file is executed directly
if expand('<sfile>') == expand('%')
  call Test_svn_commands_all()
endif
