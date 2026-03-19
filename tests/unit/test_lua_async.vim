" Tests for Lua async module
" Tests lua/genero_tools/async.lua functionality

function! Test_Lua_Async_Module_Loads() abort
  " Given: Neovim environment
  if !has('nvim')
    return
  endif
  
  " When: Loading async module
  try
    call luaeval('require("genero_tools.async")')
    call assert_true(1, 'async module should load')
  catch
    call assert_false(1, 'async module should load without error: ' . v:exception)
  endtry
endfunction

function! Test_Lua_Async_Has_Execute_Async() abort
  " Given: Async module loaded
  if !has('nvim')
    return
  endif
  
  " When: Checking for execute_async function
  try
    let l:has_func = luaeval('require("genero_tools.async").execute_async ~= nil')
    call assert_true(l:has_func, 'async module should have execute_async function')
  catch
    call assert_false(1, 'should not error checking for function: ' . v:exception)
  endtry
endfunction

function! Test_Lua_Async_Has_Parse_Output() abort
  " Given: Async module loaded
  if !has('nvim')
    return
  endif
  
  " When: Checking for parse_output function
  try
    let l:has_func = luaeval('require("genero_tools.async").parse_output ~= nil')
    call assert_true(l:has_func, 'async module should have parse_output function')
  catch
    call assert_false(1, 'should not error checking for function: ' . v:exception)
  endtry
endfunction

function! Test_Lua_Async_Parse_Output_Success() abort
  " Given: Async module loaded
  if !has('nvim')
    return
  endif
  
  " When: Parsing successful output
  try
    let l:result = luaeval('require("genero_tools.async").parse_output({"test"}, {}, 0)')
    call assert_equal(l:result.success, 1, 'parse_output should return success=true for exit_code=0')
  catch
    call assert_false(1, 'parse_output should work: ' . v:exception)
  endtry
endfunction

function! Test_Lua_Async_Parse_Output_Failure() abort
  " Given: Async module loaded
  if !has('nvim')
    return
  endif
  
  " When: Parsing failed output
  try
    let l:result = luaeval('require("genero_tools.async").parse_output({}, {"error"}, 1)')
    call assert_equal(l:result.success, 0, 'parse_output should return success=false for non-zero exit_code')
  catch
    call assert_false(1, 'parse_output should work: ' . v:exception)
  endtry
endfunction

function! Test_Lua_Async_Has_Debounce() abort
  " Given: Async module loaded
  if !has('nvim')
    return
  endif
  
  " When: Checking for debounce function
  try
    let l:has_func = luaeval('require("genero_tools.async").debounce ~= nil')
    call assert_true(l:has_func, 'async module should have debounce function')
  catch
    call assert_false(1, 'should not error checking for function: ' . v:exception)
  endtry
endfunction

function! Test_Lua_Async_Has_Throttle() abort
  " Given: Async module loaded
  if !has('nvim')
    return
  endif
  
  " When: Checking for throttle function
  try
    let l:has_func = luaeval('require("genero_tools.async").throttle ~= nil')
    call assert_true(l:has_func, 'async module should have throttle function')
  catch
    call assert_false(1, 'should not error checking for function: ' . v:exception)
  endtry
endfunction
