" Tests for Lua UI module
" Tests lua/genero_tools/ui.lua functionality

function! test_lua_ui_module_loads() abort
  " Given: Neovim environment
  if !has('nvim')
    return
  endif
  
  " When: Loading UI module
  try
    call luaeval('require("genero_tools.ui")')
    assert_true(1, 'UI module should load')
  catch
    assert_false(1, 'UI module should load without error: ' . v:exception)
  endtry
endfunction

function! test_lua_ui_has_show_floating_window() abort
  " Given: UI module loaded
  if !has('nvim')
    return
  endif
  
  " When: Checking for show_floating_window function
  try
    let l:has_func = luaeval('require("genero_tools.ui").show_floating_window ~= nil')
    assert_true(l:has_func, 'UI module should have show_floating_window function')
  catch
    assert_false(1, 'should not error checking for function: ' . v:exception)
  endtry
endfunction

function! test_lua_ui_has_show_popup_menu() abort
  " Given: UI module loaded
  if !has('nvim')
    return
  endif
  
  " When: Checking for show_popup_menu function
  try
    let l:has_func = luaeval('require("genero_tools.ui").show_popup_menu ~= nil')
    assert_true(l:has_func, 'UI module should have show_popup_menu function')
  catch
    assert_false(1, 'should not error checking for function: ' . v:exception)
  endtry
endfunction

function! test_lua_ui_has_notify() abort
  " Given: UI module loaded
  if !has('nvim')
    return
  endif
  
  " When: Checking for notify function
  try
    let l:has_func = luaeval('require("genero_tools.ui").notify ~= nil')
    assert_true(l:has_func, 'UI module should have notify function')
  catch
    assert_false(1, 'should not error checking for function: ' . v:exception)
  endtry
endfunction

function! test_lua_ui_has_show_progress() abort
  " Given: UI module loaded
  if !has('nvim')
    return
  endif
  
  " When: Checking for show_progress function
  try
    let l:has_func = luaeval('require("genero_tools.ui").show_progress ~= nil')
    assert_true(l:has_func, 'UI module should have show_progress function')
  catch
    assert_false(1, 'should not error checking for function: ' . v:exception)
  endtry
endfunction

function! test_lua_ui_has_show_split() abort
  " Given: UI module loaded
  if !has('nvim')
    return
  endif
  
  " When: Checking for show_split function
  try
    let l:has_func = luaeval('require("genero_tools.ui").show_split ~= nil')
    assert_true(l:has_func, 'UI module should have show_split function')
  catch
    assert_false(1, 'should not error checking for function: ' . v:exception)
  endtry
endfunction

function! test_lua_ui_has_highlight_pattern() abort
  " Given: UI module loaded
  if !has('nvim')
    return
  endif
  
  " When: Checking for highlight_pattern function
  try
    let l:has_func = luaeval('require("genero_tools.ui").highlight_pattern ~= nil')
    assert_true(l:has_func, 'UI module should have highlight_pattern function')
  catch
    assert_false(1, 'should not error checking for function: ' . v:exception)
  endtry
endfunction

function! test_lua_ui_has_setup_floating_window_keys() abort
  " Given: UI module loaded
  if !has('nvim')
    return
  endif
  
  " When: Checking for setup_floating_window_keys function
  try
    let l:has_func = luaeval('require("genero_tools.ui").setup_floating_window_keys ~= nil')
    assert_true(l:has_func, 'UI module should have setup_floating_window_keys function')
  catch
    assert_false(1, 'should not error checking for function: ' . v:exception)
  endtry
endfunction
