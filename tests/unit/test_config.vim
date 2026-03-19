" Genero-Tools Plugin - Configuration Tests
" Tests for autoload/genero_tools/config.vim

function! Test_Config_Init_Sets_Defaults() abort
  " Given: Fresh configuration
  if exists('g:genero_tools_config')
    unlet g:genero_tools_config
  endif
  
  " When: Configuration is initialized
  call genero_tools#config#init()
  
  " Then: Defaults are set
  call assert_equal(genero_tools#config#get('cache_enabled'), 1, 'cache_enabled should be 1')
  call assert_equal(genero_tools#config#get('timeout'), 10000, 'timeout should be 10000')
  call assert_equal(genero_tools#config#get('display_mode'), 'quickfix', 'display_mode should be quickfix')
  call assert_equal(genero_tools#config#get('cache_ttl'), 3600, 'cache_ttl should be 3600')
  call assert_equal(genero_tools#config#get('cache_max_size'), 100, 'cache_max_size should be 100')
endfunction

function! Test_Config_Get_Returns_Configured_Value() abort
  " Given: Configuration with custom value
  call genero_tools#config#init()
  let g:genero_tools_config.timeout = 20000
  
  " When: Getting configuration value
  let l:timeout = genero_tools#config#get('timeout')
  
  " Then: Custom value is returned
  call assert_equal(l:timeout, 20000, 'timeout should be 20000')
endfunction

function! Test_Config_Validation_Fixes_Invalid_Timeout() abort
  " Given: Configuration with invalid timeout
  call genero_tools#config#init()
  let g:genero_tools_config.timeout = -1000
  
  " When: Validation runs
  call genero_tools#config#validate()
  
  " Then: Timeout is corrected to default
  call assert_equal(genero_tools#config#get('timeout'), 10000, 'timeout should be corrected to 10000')
endfunction

function! Test_Config_Validation_Fixes_Invalid_Display_Mode() abort
  " Given: Configuration with invalid display mode
  call genero_tools#config#init()
  let g:genero_tools_config.display_mode = 'invalid_mode'
  
  " When: Validation runs
  call genero_tools#config#validate()
  
  " Then: Display mode is corrected to default
  call assert_equal(genero_tools#config#get('display_mode'), 'quickfix', 'display_mode should be corrected to quickfix')
endfunction

function! Test_Config_Validation_Fixes_Invalid_Cache_Ttl() abort
  " Given: Configuration with invalid cache TTL
  call genero_tools#config#init()
  let g:genero_tools_config.cache_ttl = -100
  
  " When: Validation runs
  call genero_tools#config#validate()
  
  " Then: Cache TTL is corrected to default
  call assert_equal(genero_tools#config#get('cache_ttl'), 3600, 'cache_ttl should be corrected to 3600')
endfunction

function! Test_Config_Validation_Fixes_Invalid_Cache_Max_Size() abort
  " Given: Configuration with invalid cache max size
  call genero_tools#config#init()
  let g:genero_tools_config.cache_max_size = 0
  
  " When: Validation runs
  call genero_tools#config#validate()
  
  " Then: Cache max size is corrected to default
  call assert_equal(genero_tools#config#get('cache_max_size'), 100, 'cache_max_size should be corrected to 100')
endfunction

function! Test_Config_Validation_Fixes_Invalid_Result_Limit() abort
  " Given: Configuration with invalid result limit
  call genero_tools#config#init()
  let g:genero_tools_config.result_limit = -500
  
  " When: Validation runs
  call genero_tools#config#validate()
  
  " Then: Result limit is corrected to default
  call assert_equal(genero_tools#config#get('result_limit'), 1000, 'result_limit should be corrected to 1000')
endfunction

function! Test_Config_Validation_Fixes_Invalid_Pagination_Size() abort
  " Given: Configuration with invalid pagination size
  call genero_tools#config#init()
  let g:genero_tools_config.pagination_size = 0
  
  " When: Validation runs
  call genero_tools#config#validate()
  
  " Then: Pagination size is corrected to default
  call assert_equal(genero_tools#config#get('pagination_size'), 50, 'pagination_size should be corrected to 50')
endfunction

function! Test_Config_Validation_Fixes_Invalid_Floating_Window_Position() abort
  " Given: Configuration with invalid floating window position
  call genero_tools#config#init()
  let g:genero_tools_config.floating_window_position = 'invalid'
  
  " When: Validation runs
  call genero_tools#config#validate()
  
  " Then: Position is corrected to default
  call assert_equal(genero_tools#config#get('floating_window_position'), 'center', 'floating_window_position should be corrected to center')
endfunction

function! Test_Config_Validation_Fixes_Invalid_Floating_Window_Border() abort
  " Given: Configuration with invalid floating window border
  call genero_tools#config#init()
  let g:genero_tools_config.floating_window_border = 'invalid'
  
  " When: Validation runs
  call genero_tools#config#validate()
  
  " Then: Border is corrected to default
  call assert_equal(genero_tools#config#get('floating_window_border'), 'rounded', 'floating_window_border should be corrected to rounded')
endfunction

function! Test_Config_Validation_Fixes_Invalid_Startup_Messages() abort
  " Given: Configuration with invalid startup messages
  call genero_tools#config#init()
  let g:genero_tools_config.startup_messages = 'invalid'
  
  " When: Validation runs
  call genero_tools#config#validate()
  
  " Then: Startup messages is corrected to default
  call assert_equal(genero_tools#config#get('startup_messages'), 'silent', 'startup_messages should be corrected to silent')
endfunction

function! Test_Config_Get_All_Returns_All_Settings() abort
  " Given: Initialized configuration
  call genero_tools#config#init()
  
  " When: Getting all configuration
  let l:all_config = genero_tools#config#get_all()
  
  " Then: All settings are returned
  call assert_not_empty(l:all_config, 'config should not be empty')
  call assert_equal(type(l:all_config), type({}), 'config should be a dictionary')
endfunction

function! Test_Config_Codebase_Markers_Accepts_String() abort
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
  call assert_equal(type(l:markers), type([]), 'codebase_markers should be a list')
endfunction

function! Test_Config_Codebase_Markers_Accepts_List() abort
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
  call assert_equal(type(l:markers), type([]), 'codebase_markers should be a list')
  call assert_equal(len(l:markers), 2, 'codebase_markers should have 2 items')
endfunction
