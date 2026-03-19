" Tests for Lua UI module
" Tests lua/genero_tools/ui.lua functionality

function! Test_Lua_Ui_Module_Loads() abort
  " Given: Neovim environment
  if !has('nvim')
    return
  endif
  
  " When: Loading UI module
  try
    call luaeval('require("genero_tools.ui")')
    call assert_true(1, 'UI module should load')
  catch
    call assert_false(1, 'UI module should load without error: ' . v:exception)
  endtry
endfunction

function! Test_Lua_Ui_Has_Show_Floating_Window() abort
  " Given: UI module loaded
  if !has('nvim')
    return
  endif
  
  " When: Checking for show_floating_window function
  try
    let l:has_func = luaeval('require("genero_tools.ui").show_floating_window ~= nil')
    call assert_true(l:has_func, 'UI module should have show_floating_window function')
  catch
    call assert_false(1, 'should not error checking for function: ' . v:exception)
  endtry
endfunction

function! Test_Lua_Ui_Has_Show_Popup_Menu() abort
  " Given: UI module loaded
  if !has('nvim')
    return
  endif
  
  " When: Checking for show_popup_menu function
  try
    let l:has_func = luaeval('require("genero_tools.ui").show_popup_menu ~= nil')
    call assert_true(l:has_func, 'UI module should have show_popup_menu function')
  catch
    call assert_false(1, 'should not error checking for function: ' . v:exception)
  endtry
endfunction

function! Test_Lua_Ui_Has_Notify() abort
  " Given: UI module loaded
  if !has('nvim')
    return
  endif
  
  " When: Checking for notify function
  try
    let l:has_func = luaeval('require("genero_tools.ui").notify ~= nil')
    call assert_true(l:has_func, 'UI module should have notify function')
  catch
    call assert_false(1, 'should not error checking for function: ' . v:exception)
  endtry
endfunction

function! Test_Lua_Ui_Has_Show_Progress() abort
  " Given: UI module loaded
  if !has('nvim')
    return
  endif
  
  " When: Checking for show_progress function
  try
    let l:has_func = luaeval('require("genero_tools.ui").show_progress ~= nil')
    call assert_true(l:has_func, 'UI module should have show_progress function')
  catch
    call assert_false(1, 'should not error checking for function: ' . v:exception)
  endtry
endfunction

function! Test_Lua_Ui_Has_Show_Split() abort
  " Given: UI module loaded
  if !has('nvim')
    return
  endif
  
  " When: Checking for show_split function
  try
    let l:has_func = luaeval('require("genero_tools.ui").show_split ~= nil')
    call assert_true(l:has_func, 'UI module should have show_split function')
  catch
    call assert_false(1, 'should not error checking for function: ' . v:exception)
  endtry
endfunction

function! Test_Lua_Ui_Has_Highlight_Pattern() abort
  " Given: UI module loaded
  if !has('nvim')
    return
  endif
  
  " When: Checking for highlight_pattern function
  try
    let l:has_func = luaeval('require("genero_tools.ui").highlight_pattern ~= nil')
    call assert_true(l:has_func, 'UI module should have highlight_pattern function')
  catch
    call assert_false(1, 'should not error checking for function: ' . v:exception)
  endtry
endfunction

function! Test_Lua_Ui_Has_Setup_Floating_Window_Keys() abort
  " Given: UI module loaded
  if !has('nvim')
    return
  endif
  
  " When: Checking for setup_floating_window_keys function
  try
    let l:has_func = luaeval('require("genero_tools.ui").setup_floating_window_keys ~= nil')
    call assert_true(l:has_func, 'UI module should have setup_floating_window_keys function')
  catch
    call assert_false(1, 'should not error checking for function: ' . v:exception)
  endtry
endfunction
