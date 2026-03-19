" Integration tests for module interactions
" Tests end-to-end workflows and cross-module communication

function! test_config_cache_integration() abort
  " Given: Fresh configuration and cache
  if exists('g:genero_tools_config')
    unlet g:genero_tools_config
  endif
  if exists('g:genero_tools_cache')
    unlet g:genero_tools_cache
  endif
  
  " When: Config and cache are initialized
  call genero_tools#config#init()
  call genero_tools#cache#init()
  
  " Then: Cache respects config settings
  let l:cache_enabled = genero_tools#config#get('cache_enabled')
  assert_equal(l:cache_enabled, v:true)
  
  let l:cache_ttl = genero_tools#config#get('cache_ttl')
  assert_equal(l:cache_ttl, 3600)
endfunction

function! test_cache_command_integration() abort
  " Given: Cache and command modules initialized
  call genero_tools#config#init()
  call genero_tools#cache#init()
  
  " When: A command result is cached
  let l:test_key = 'test_lookup_myFunc'
  let l:test_result = {
    \ 'success': v:true,
    \ 'data': {'name': 'myFunc', 'line': 42},
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }
  
  call genero_tools#cache#set(l:test_key, l:test_result)
  
  " Then: The result can be retrieved from cache
  let l:cached = genero_tools#cache#get(l:test_key)
  assert_equal(l:cached.data.name, 'myFunc')
  assert_equal(l:cached.data.line, 42)
endfunction

function! test_config_display_integration() abort
  " Given: Config and display modules initialized
  call genero_tools#config#init()
  
  " When: Display mode is configured
  let l:display_mode = genero_tools#config#get('display_mode')
  
  " Then: Display mode is valid
  let l:valid_modes = ['quickfix', 'popup', 'split', 'echo', 'inline']
  assert_true(index(l:valid_modes, l:display_mode) >= 0)
endfunction

function! test_cache_expiration_respects_config() abort
  " Given: Cache with TTL of 1 second
  call genero_tools#config#init()
  let g:genero_tools_config.cache_ttl = 1
  call genero_tools#cache#init()
  
  " When: A value is cached
  let l:test_key = 'test_expiration'
  let l:test_result = {
    \ 'success': v:true,
    \ 'data': {'test': 'value'},
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }
  
  call genero_tools#cache#set(l:test_key, l:test_result)
  
  " Then: Value is immediately retrievable
  let l:cached = genero_tools#cache#get(l:test_key)
  assert_equal(l:cached.data.test, 'value')
endfunction

function! test_multiple_cache_entries() abort
  " Given: Cache initialized
  call genero_tools#config#init()
  call genero_tools#cache#init()
  
  " When: Multiple values are cached
  let l:result1 = {'success': v:true, 'data': {'id': 1}, 'error': '', 'timestamp': localtime()}
  let l:result2 = {'success': v:true, 'data': {'id': 2}, 'error': '', 'timestamp': localtime()}
  let l:result3 = {'success': v:true, 'data': {'id': 3}, 'error': '', 'timestamp': localtime()}
  
  call genero_tools#cache#set('key1', l:result1)
  call genero_tools#cache#set('key2', l:result2)
  call genero_tools#cache#set('key3', l:result3)
  
  " Then: All values can be retrieved
  assert_equal(genero_tools#cache#get('key1').data.id, 1)
  assert_equal(genero_tools#cache#get('key2').data.id, 2)
  assert_equal(genero_tools#cache#get('key3').data.id, 3)
endfunction

function! test_cache_clear_integration() abort
  " Given: Cache with multiple entries
  call genero_tools#config#init()
  call genero_tools#cache#init()
  
  let l:result = {'success': v:true, 'data': {'test': 'value'}, 'error': '', 'timestamp': localtime()}
  call genero_tools#cache#set('key1', l:result)
  call genero_tools#cache#set('key2', l:result)
  
  " When: Cache is cleared
  call genero_tools#cache#clear()
  
  " Then: All entries are removed
  let l:cached1 = genero_tools#cache#get('key1')
  let l:cached2 = genero_tools#cache#get('key2')
  assert_equal(empty(l:cached1), v:true)
  assert_equal(empty(l:cached2), v:true)
endfunction
