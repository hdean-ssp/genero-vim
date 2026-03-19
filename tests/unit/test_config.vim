" Genero-Tools Plugin - Configuration Tests
" Tests for autoload/genero_tools/config.vim

function! test_config_init_sets_defaults() abort
  " Given: Fresh configuration
  if exists('g:genero_tools_config')
    unlet g:genero_tools_config
  endif
  
  " When: Configuration is initialized
  call genero_tools#config#init()
  
  " Then: Defaults are set
  assert_equal(genero_tools#config#get('cache_enabled'), 1, 'cache_enabled should be 1')
  assert_equal(genero_tools#config#get('timeout'), 10000, 'timeout should be 10000')
  assert_equal(genero_tools#config#get('display_mode'), 'quickfix', 'display_mode should be quickfix')
  assert_equal(genero_tools#config#get('cache_ttl'), 3600, 'cache_ttl should be 3600')
  assert_equal(genero_tools#config#get('cache_max_size'), 100, 'cache_max_size should be 100')
endfunction

function! test_config_get_returns_configured_value() abort
  " Given: Configuration with custom value
  call genero_tools#config#init()
  let g:genero_tools_config.timeout = 20000
  
  " When: Getting configuration value
  let l:timeout = genero_tools#config#get('timeout')
  
  " Then: Custom value is returned
  assert_equal(l:timeout, 20000, 'timeout should be 20000')
endfunction

function! test_config_validation_fixes_invalid_timeout() abort
  " Given: Configuration with invalid timeout
  call genero_tools#config#init()
  let g:genero_tools_config.timeout = -1000
  
  " When: Validation runs
  call genero_tools#config#validate()
  
  " Then: Timeout is corrected to default
  assert_equal(genero_tools#config#get('timeout'), 10000, 'timeout should be corrected to 10000')
endfunction

function! test_config_validation_fixes_invalid_display_mode() abort
  " Given: Configuration with invalid display mode
  call genero_tools#config#init()
  let g:genero_tools_config.display_mode = 'invalid_mode'
  
  " When: Validation runs
  call genero_tools#config#validate()
  
  " Then: Display mode is corrected to default
  assert_equal(genero_tools#config#get('display_mode'), 'quickfix', 'display_mode should be corrected to quickfix')
endfunction

function! test_config_validation_fixes_invalid_cache_ttl() abort
  " Given: Configuration with invalid cache TTL
  call genero_tools#config#init()
  let g:genero_tools_config.cache_ttl = -100
  
  " When: Validation runs
  call genero_tools#config#validate()
  
  " Then: Cache TTL is corrected to default
  assert_equal(genero_tools#config#get('cache_ttl'), 3600, 'cache_ttl should be corrected to 3600')
endfunction

function! test_config_validation_fixes_invalid_cache_max_size() abort
  " Given: Configuration with invalid cache max size
  call genero_tools#config#init()
  let g:genero_tools_config.cache_max_size = 0
  
  " When: Validation runs
  call genero_tools#config#validate()
  
  " Then: Cache max size is corrected to default
  assert_equal(genero_tools#config#get('cache_max_size'), 100, 'cache_max_size should be corrected to 100')
endfunction

function! test_config_validation_fixes_invalid_result_limit() abort
  " Given: Configuration with invalid result limit
  call genero_tools#config#init()
  let g:genero_tools_config.result_limit = -500
  
  " When: Validation runs
  call genero_tools#config#validate()
  
  " Then: Result limit is corrected to default
  assert_equal(genero_tools#config#get('result_limit'), 1000, 'result_limit should be corrected to 1000')
endfunction

function! test_config_validation_fixes_invalid_pagination_size() abort
  " Given: Configuration with invalid pagination size
  call genero_tools#config#init()
  let g:genero_tools_config.pagination_size = 0
  
  " When: Validation runs
  call genero_tools#config#validate()
  
  " Then: Pagination size is corrected to default
  assert_equal(genero_tools#config#get('pagination_size'), 50, 'pagination_size should be corrected to 50')
endfunction

function! test_config_validation_fixes_invalid_floating_window_position() abort
  " Given: Configuration with invalid floating window position
  call genero_tools#config#init()
  let g:genero_tools_config.floating_window_position = 'invalid'
  
  " When: Validation runs
  call genero_tools#config#validate()
  
  " Then: Position is corrected to default
  assert_equal(genero_tools#config#get('floating_window_position'), 'center', 'floating_window_position should be corrected to center')
endfunction

function! test_config_validation_fixes_invalid_floating_window_border() abort
  " Given: Configuration with invalid floating window border
  call genero_tools#config#init()
  let g:genero_tools_config.floating_window_border = 'invalid'
  
  " When: Validation runs
  call genero_tools#config#validate()
  
  " Then: Border is corrected to default
  assert_equal(genero_tools#config#get('floating_window_border'), 'rounded', 'floating_window_border should be corrected to rounded')
endfunction

function! test_config_validation_fixes_invalid_startup_messages() abort
  " Given: Configuration with invalid startup messages
  call genero_tools#config#init()
  let g:genero_tools_config.startup_messages = 'invalid'
  
  " When: Validation runs
  call genero_tools#config#validate()
  
  " Then: Startup messages is corrected to default
  assert_equal(genero_tools#config#get('startup_messages'), 'silent', 'startup_messages should be corrected to silent')
endfunction

function! test_config_get_all_returns_all_settings() abort
  " Given: Initialized configuration
  call genero_tools#config#init()
  
  " When: Getting all configuration
  let l:all_config = genero_tools#config#get_all()
  
  " Then: All settings are returned
  assert_not_empty(l:all_config, 'config should not be empty')
  assert_equal(type(l:all_config), type({}), 'config should be a dictionary')
endfunction

function! test_config_codebase_markers_accepts_string() abort
  " Given: Configuration with string codebase marker
  if exists('g:genero_tools_config')
    unlet g:genero_tools_config
  endif
  let g:genero_tools_config = {}
  let g:genero_tools_config.codebase_markers = 'castle.sch'
  
  " When: Configuration is initialized
  call genero_tools#config#init()
  
  " Then: String is converted to list
  let l:markers = genero_tools#config#get('codebase_markers')
  assert_equal(type(l:markers), type([]), 'codebase_markers should be a list')
endfunction

function! test_config_codebase_markers_accepts_list() abort
  " Given: Configuration with list codebase markers
  if exists('g:genero_tools_config')
    unlet g:genero_tools_config
  endif
  let g:genero_tools_config = {}
  let g:genero_tools_config.codebase_markers = ['castle.sch', '.git']
  
  " When: Configuration is initialized
  call genero_tools#config#init()
  
  " Then: List is preserved
  let l:markers = genero_tools#config#get('codebase_markers')
  assert_equal(type(l:markers), type([]), 'codebase_markers should be a list')
  assert_equal(len(l:markers), 2, 'codebase_markers should have 2 items')
endfunction
