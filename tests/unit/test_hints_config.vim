" Genero-Tools Plugin - Hint Configuration System Tests
" Tests for autoload/genero_tools/hints/config.vim

function! Test_Hints_Config_Init_Sets_All_Defaults() abort
  " Given: Fresh configuration
  if exists('g:genero_tools_config')
    unlet g:genero_tools_config
  endif
  
  " When: Configuration is initialized
  call genero_tools#hints#config#init()
  
  " Then: All defaults are set
  call assert_equal(1, genero_tools#hints#config#get('hints_enabled'), 'hints_enabled should default to 1')
  call assert_equal('signs', genero_tools#hints#config#get('hints_display'), 'hints_display should default to signs')
  call assert_equal('warning', genero_tools#hints#config#get('hints_severity'), 'hints_severity should default to warning')
  call assert_equal(1, genero_tools#hints#config#get('hints_realtime'), 'hints_realtime should default to 1')
  call assert_equal(1, genero_tools#hints#config#get('hints_cache_enabled'), 'hints_cache_enabled should default to 1')
  call assert_equal(300, genero_tools#hints#config#get('hints_cache_ttl'), 'hints_cache_ttl should default to 300')
  call assert_equal(1, genero_tools#hints#config#get('auto_fix_enabled'), 'auto_fix_enabled should default to 1')
  call assert_equal(500, genero_tools#hints#config#get('hints_delay'), 'hints_delay should default to 500')
  call assert_equal(100, genero_tools#hints#config#get('max_line_length'), 'max_line_length should default to 100')
  call assert_equal(5, genero_tools#hints#config#get('max_nesting_depth'), 'max_nesting_depth should default to 5')
  call assert_equal(2, genero_tools#hints#config#get('max_blank_lines'), 'max_blank_lines should default to 2')
  call assert_equal('camelCase', genero_tools#hints#config#get('naming_convention_style'), 'naming_convention_style should default to camelCase')
endfunction

function! Test_Hints_Config_Get_Returns_Configured_Value() abort
  " Given: Configuration with custom value
  call genero_tools#hints#config#init()
  let g:genero_tools_config.max_line_length = 120
  
  " When: Getting configuration value
  let l:max_line_length = genero_tools#hints#config#get('max_line_length')
  
  " Then: Custom value is returned
  call assert_equal(120, l:max_line_length, 'max_line_length should be 120')
endfunction

function! Test_Hints_Config_Get_For_File_Returns_Config() abort
  " Given: Initialized configuration
  call genero_tools#hints#config#init()
  
  " When: Getting configuration for a file
  let l:config = genero_tools#hints#config#get_for_file('/tmp/test.4gl')
  
  " Then: Config is returned with all keys
  call assert_true(!empty(l:config), 'config should not be empty')
  call assert_true(has_key(l:config, 'hints_enabled'), 'config should have hints_enabled')
  call assert_true(has_key(l:config, 'max_line_length'), 'config should have max_line_length')
endfunction

function! Test_Hints_Config_Get_For_Buffer_Returns_Config() abort
  " Given: Initialized configuration and a buffer
  call genero_tools#hints#config#init()
  let l:bufnr = bufnr('%')
  
  " When: Getting configuration for a buffer
  let l:config = genero_tools#hints#config#get_for_buffer(l:bufnr)
  
  " Then: Config is returned
  call assert_true(!empty(l:config), 'config should not be empty')
  call assert_true(has_key(l:config, 'hints_enabled'), 'config should have hints_enabled')
endfunction

function! Test_Hints_Config_Validate_Detects_Invalid_Display_Mode() abort
  " Given: Configuration with invalid display mode
  let l:config = {'hints_display': 'invalid_mode'}
  
  " When: Validation runs
  let l:errors = genero_tools#hints#config#validate(l:config)
  
  " Then: Error is detected
  call assert_true(len(l:errors) > 0, 'should detect invalid display mode')
  call assert_true(l:errors[0] =~ 'hints_display', 'error should mention hints_display')
endfunction

function! Test_Hints_Config_Validate_Detects_Invalid_Severity() abort
  " Given: Configuration with invalid severity
  let l:config = {'hints_severity': 'invalid_severity'}
  
  " When: Validation runs
  let l:errors = genero_tools#hints#config#validate(l:config)
  
  " Then: Error is detected
  call assert_true(len(l:errors) > 0, 'should detect invalid severity')
  call assert_true(l:errors[0] =~ 'hints_severity', 'error should mention hints_severity')
endfunction

function! Test_Hints_Config_Validate_Detects_Invalid_Naming_Convention_Style() abort
  " Given: Configuration with invalid naming convention style
  let l:config = {'naming_convention_style': 'invalid_style'}
  
  " When: Validation runs
  let l:errors = genero_tools#hints#config#validate(l:config)
  
  " Then: Error is detected
  call assert_true(len(l:errors) > 0, 'should detect invalid naming convention style')
  call assert_true(l:errors[0] =~ 'naming_convention_style', 'error should mention naming_convention_style')
endfunction

function! Test_Hints_Config_Validate_Detects_Negative_Max_Line_Length() abort
  " Given: Configuration with negative max_line_length
  let l:config = {'max_line_length': -1}
  
  " When: Validation runs
  let l:errors = genero_tools#hints#config#validate(l:config)
  
  " Then: Error is detected
  call assert_true(len(l:errors) > 0, 'should detect negative max_line_length')
  call assert_true(l:errors[0] =~ 'max_line_length', 'error should mention max_line_length')
endfunction

function! Test_Hints_Config_Validate_Detects_Invalid_Max_Nesting_Depth() abort
  " Given: Configuration with invalid max_nesting_depth
  let l:config = {'max_nesting_depth': 0}
  
  " When: Validation runs
  let l:errors = genero_tools#hints#config#validate(l:config)
  
  " Then: Error is detected
  call assert_true(len(l:errors) > 0, 'should detect invalid max_nesting_depth')
  call assert_true(l:errors[0] =~ 'max_nesting_depth', 'error should mention max_nesting_depth')
endfunction

function! Test_Hints_Config_Validate_Detects_Negative_Hints_Delay() abort
  " Given: Configuration with negative hints_delay
  let l:config = {'hints_delay': -100}
  
  " When: Validation runs
  let l:errors = genero_tools#hints#config#validate(l:config)
  
  " Then: Error is detected
  call assert_true(len(l:errors) > 0, 'should detect negative hints_delay')
  call assert_true(l:errors[0] =~ 'hints_delay', 'error should mention hints_delay')
endfunction

function! Test_Hints_Config_Validate_Accepts_Valid_Config() abort
  " Given: Configuration with all valid values
  let l:config = {
    \ 'hints_display': 'signs',
    \ 'hints_severity': 'warning',
    \ 'naming_convention_style': 'camelCase',
    \ 'max_line_length': 100,
    \ 'max_nesting_depth': 5,
    \ 'max_blank_lines': 2,
    \ 'hints_delay': 500
    \ }
  
  " When: Validation runs
  let l:errors = genero_tools#hints#config#validate(l:config)
  
  " Then: No errors are detected
  call assert_equal(0, len(l:errors), 'should not detect errors for valid config')
endfunction

function! Test_Hints_Config_Pattern_Matches_Simple_Glob() abort
  " Given: A file path and a simple glob pattern
  let l:file_path = '/path/to/file.4gl'
  let l:pattern = '*.4gl'
  
  " When: Pattern matching is performed
  let l:matches = genero_tools#hints#config#pattern_matches(l:file_path, l:pattern)
  
  " Then: Pattern matches
  call assert_true(l:matches, 'should match simple glob pattern')
endfunction

function! Test_Hints_Config_Pattern_Matches_Recursive_Glob() abort
  " Given: A file path and a recursive glob pattern
  let l:file_path = '/path/to/subdir/file.4gl'
  let l:pattern = '**/*.4gl'
  
  " When: Pattern matching is performed
  let l:matches = genero_tools#hints#config#pattern_matches(l:file_path, l:pattern)
  
  " Then: Pattern matches
  call assert_true(l:matches, 'should match recursive glob pattern')
endfunction

function! Test_Hints_Config_Pattern_Does_Not_Match_Wrong_Extension() abort
  " Given: A file path and a pattern for different extension
  let l:file_path = '/path/to/file.vim'
  let l:pattern = '*.4gl'
  
  " When: Pattern matching is performed
  let l:matches = genero_tools#hints#config#pattern_matches(l:file_path, l:pattern)
  
  " Then: Pattern does not match
  call assert_false(l:matches, 'should not match wrong extension')
endfunction

function! Test_Hints_Config_Merge_Configs_Applies_Per_File_Rules() abort
  " Given: Base config and per-file config with matching rule
  let l:base_config = {'max_line_length': 100, 'hints_enabled': 1}
  let l:per_file_config = {
    \ 'rules': [
    \   {'pattern': '**/*.4gl', 'config': {'max_line_length': 120}}
    \ ]
    \ }
  
  " When: Configs are merged
  let l:merged = genero_tools#hints#config#merge_configs(l:base_config, l:per_file_config, '/path/to/file.4gl')
  
  " Then: Per-file config overrides base config
  call assert_equal(120, l:merged.max_line_length, 'per-file config should override base config')
  call assert_equal(1, l:merged.hints_enabled, 'base config should be preserved')
endfunction

function! Test_Hints_Config_Merge_Configs_Preserves_Base_When_No_Match() abort
  " Given: Base config and per-file config with non-matching rule
  let l:base_config = {'max_line_length': 100}
  let l:per_file_config = {
    \ 'rules': [
    \   {'pattern': '**/*.vim', 'config': {'max_line_length': 120}}
    \ ]
    \ }
  
  " When: Configs are merged
  let l:merged = genero_tools#hints#config#merge_configs(l:base_config, l:per_file_config, '/path/to/file.4gl')
  
  " Then: Base config is preserved
  call assert_equal(100, l:merged.max_line_length, 'base config should be preserved when no match')
endfunction

function! Test_Hints_Config_Load_Per_File_Returns_Dict() abort
  " Given: Configuration system initialized
  call genero_tools#hints#config#init()
  
  " When: Loading per-file configuration
  let l:per_file_config = genero_tools#hints#config#load_per_file()
  
  " Then: A dictionary is returned (may be empty if .genero-hints doesn't exist)
  call assert_equal(type({}), type(l:per_file_config), 'should return a dictionary')
endfunction

function! Test_Hints_Config_Get_Default_Returns_Correct_Defaults() abort
  " Given: Configuration system
  
  " When: Getting default values
  let l:hints_enabled = genero_tools#hints#config#get_default('hints_enabled')
  let l:hints_display = genero_tools#hints#config#get_default('hints_display')
  let l:max_line_length = genero_tools#hints#config#get_default('max_line_length')
  
  " Then: Correct defaults are returned
  call assert_equal(1, l:hints_enabled, 'hints_enabled default should be 1')
  call assert_equal('signs', l:hints_display, 'hints_display default should be signs')
  call assert_equal(100, l:max_line_length, 'max_line_length default should be 100')
endfunction

function! Test_Hints_Config_Init_Key_Sets_Value() abort
  " Given: Fresh configuration
  if exists('g:genero_tools_config')
    unlet g:genero_tools_config
  endif
  let g:genero_tools_config = {}
  
  " When: Initializing a key
  call genero_tools#hints#config#init_key('test_key', 'test_value')
  
  " Then: Key is set
  call assert_equal('test_value', g:genero_tools_config.test_key, 'key should be set')
endfunction

function! Test_Hints_Config_Init_Key_Preserves_Existing_Value() abort
  " Given: Configuration with existing key
  if exists('g:genero_tools_config')
    unlet g:genero_tools_config
  endif
  let g:genero_tools_config = {'test_key': 'existing_value'}
  
  " When: Initializing the same key with different value
  call genero_tools#hints#config#init_key('test_key', 'new_value')
  
  " Then: Existing value is preserved
  call assert_equal('existing_value', g:genero_tools_config.test_key, 'existing value should be preserved')
endfunction
