" Tests for Lua async module
" Tests lua/genero_tools/async.lua functionality

function! test_lua_async_module_loads() abort
  " Given: Neovim environment
  if !has('nvim')
    return
  endif
  
  " When: Loading async module
  try
    call luaeval('require("genero_tools.async")')
    assert_true(1, 'async module should load')
  catch
    assert_false(1, 'async module should load without error: ' . v:exception)
  endtry
endfunction

function! test_lua_async_has_execute_async() abort
  " Given: Async module loaded
  if !has('nvim')
    return
  endif
  
  " When: Checking for execute_async function
  try
    let l:has_func = luaeval('require("genero_tools.async").execute_async ~= nil')
    assert_true(l:has_func, 'async module should have execute_async function')
  catch
    assert_false(1, 'should not error checking for function: ' . v:exception)
  endtry
endfunction

function! test_lua_async_has_parse_output() abort
  " Given: Async module loaded
  if !has('nvim')
    return
  endif
  
  " When: Checking for parse_output function
  try
    let l:has_func = luaeval('require("genero_tools.async").parse_output ~= nil')
    assert_true(l:has_func, 'async module should have parse_output function')
  catch
    assert_false(1, 'should not error checking for function: ' . v:exception)
  endtry
endfunction

function! test_lua_async_parse_output_success() abort
  " Given: Async module loaded
  if !has('nvim')
    return
  endif
  
  " When: Parsing successful output
  try
    let l:result = luaeval('require("genero_tools.async").parse_output({"test"}, {}, 0)')
    assert_equal(l:result.success, 1, 'parse_output should return success=true for exit_code=0')
  catch
    assert_false(1, 'parse_output should work: ' . v:exception)
  endtry
endfunction

function! test_lua_async_parse_output_failure() abort
  " Given: Async module loaded
  if !has('nvim')
    return
  endif
  
  " When: Parsing failed output
  try
    let l:result = luaeval('require("genero_tools.async").parse_output({}, {"error"}, 1)')
    assert_equal(l:result.success, 0, 'parse_output should return success=false for non-zero exit_code')
  catch
    assert_false(1, 'parse_output should work: ' . v:exception)
  endtry
endfunction

function! test_lua_async_has_debounce() abort
  " Given: Async module loaded
  if !has('nvim')
    return
  endif
  
  " When: Checking for debounce function
  try
    let l:has_func = luaeval('require("genero_tools.async").debounce ~= nil')
    assert_true(l:has_func, 'async module should have debounce function')
  catch
    assert_false(1, 'should not error checking for function: ' . v:exception)
  endtry
endfunction

function! test_lua_async_has_throttle() abort
  " Given: Async module loaded
  if !has('nvim')
    return
  endif
  
  " When: Checking for throttle function
  try
    let l:has_func = luaeval('require("genero_tools.async").throttle ~= nil')
    assert_true(l:has_func, 'async module should have throttle function')
  catch
    assert_false(1, 'should not error checking for function: ' . v:exception)
  endtry
endfunction
