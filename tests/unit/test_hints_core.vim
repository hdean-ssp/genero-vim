" Genero-Tools Plugin - Hint Engine Core Tests
" Tests for autoload/genero_tools/hints.vim

function! Test_Hints_Init_Initializes_State() abort
  " Given: Fresh hint system
  " When: Initializing hint system
  call genero_tools#hints#init()
  
  " Then: State is initialized
  call assert_equal(1, g:genero_tools_hints_state.initialized, 'hint system should be initialized')
endfunction

function! Test_Hints_Init_Registers_Detectors() abort
  " Given: Fresh hint system
  " When: Initializing hint system
  call genero_tools#hints#init()
  
  " Then: All detectors are registered
  call assert_true(has_key(g:genero_tools_hints_state.detectors, 'whitespace'), 'whitespace detector should be registered')
  call assert_true(has_key(g:genero_tools_hints_state.detectors, 'keyword'), 'keyword detector should be registered')
  call assert_true(has_key(g:genero_tools_hints_state.detectors, 'structure'), 'structure detector should be registered')
  call assert_true(has_key(g:genero_tools_hints_state.detectors, 'genero'), 'genero detector should be registered')
endfunction

function! Test_Create_Hint_Returns_Valid_Hint() abort
  " Given: Hint parameters
  " When: Creating a hint
  let l:hint = genero_tools#hints#create_hint(10, 5, 'Test message', 'test', 'test_check', 'warning')
  
  " Then: Hint has all required fields
  call assert_equal(10, l:hint.line, 'hint should have correct line')
  call assert_equal(5, l:hint.column, 'hint should have correct column')
  call assert_equal('Test message', l:hint.message, 'hint should have correct message')
  call assert_equal('test', l:hint.category, 'hint should have correct category')
  call assert_equal('test_check', l:hint.check, 'hint should have correct check')
  call assert_equal('warning', l:hint.severity, 'hint should have correct severity')
endfunction

function! Test_Register_Detector_Adds_Detector() abort
  " Given: Hint system initialized
  call genero_tools#hints#init()
  
  " When: Registering a test detector
  function! TestDetector(bufnr, config) abort
    return []
  endfunction
  call genero_tools#hints#register_detector('test_detector', function('TestDetector'))
  
  " Then: Detector is registered
  call assert_true(has_key(g:genero_tools_hints_state.detectors, 'test_detector'), 'detector should be registered')
endfunction

function! Test_Config_Init_Sets_Defaults() abort
  " Given: Fresh configuration
  " When: Initializing configuration
  call genero_tools#hints#config#init()
  
  " Then: Default values are set
  call assert_equal(1, genero_tools#hints#config#get('hints_enabled'), 'hints_enabled should default to 1')
  call assert_equal('signs', genero_tools#hints#config#get('hints_display'), 'hints_display should default to signs')
  call assert_equal('warning', genero_tools#hints#config#get('hints_severity'), 'hints_severity should default to warning')
  call assert_equal(1, genero_tools#hints#config#get('hints_realtime'), 'hints_realtime should default to 1')
  call assert_equal(1, genero_tools#hints#config#get('hints_cache_enabled'), 'hints_cache_enabled should default to 1')
  call assert_equal(300, genero_tools#hints#config#get('hints_cache_ttl'), 'hints_cache_ttl should default to 300')
  call assert_equal(1, genero_tools#hints#config#get('auto_fix_enabled'), 'auto_fix_enabled should default to 1')
  call assert_equal(500, genero_tools#hints#config#get('hints_delay'), 'hints_delay should default to 500')
endfunction

function! Test_Cache_Init_Creates_Cache() abort
  " Given: Fresh cache system
  " When: Initializing cache
  call genero_tools#hints#cache#init()
  
  " Then: Cache structures exist
  call assert_true(exists('g:genero_tools_hints_cache'), 'cache should exist')
  call assert_true(exists('g:genero_tools_hints_cache_times'), 'cache times should exist')
endfunction

function! Test_Display_Init_Defines_Signs() abort
  " Given: Fresh display system
  " When: Initializing display
  call genero_tools#hints#display#init()
  
  " Then: Hint signs are defined
  let l:signs = sign_getdefined()
  let l:sign_names = map(copy(l:signs), 'v:val.name')
  
  call assert_true(index(l:sign_names, 'GeneroHintInfo') >= 0, 'GeneroHintInfo sign should be defined')
  call assert_true(index(l:sign_names, 'GeneroHintWarning') >= 0, 'GeneroHintWarning sign should be defined')
  call assert_true(index(l:sign_names, 'GeneroHintStyle') >= 0, 'GeneroHintStyle sign should be defined')
endfunction

function! Test_Whitespace_Detector_Detects_Trailing_Space() abort
  " Given: Buffer with trailing whitespace
  let l:bufnr = bufnr('%')
  call setbufline(l:bufnr, 1, 'test line with trailing space ')
  
  " When: Running whitespace detector
  let l:config = genero_tools#hints#config#get_for_buffer(l:bufnr)
  let l:hints = genero_tools#hints#whitespace#detect(l:bufnr, l:config)
  
  " Then: Trailing whitespace is detected
  call assert_true(len(l:hints) > 0, 'should detect trailing whitespace')
  call assert_equal('trailing_whitespace', l:hints[0].check, 'should identify as trailing_whitespace')
endfunction

function! Test_Keyword_Detector_Detects_Lowercase_Keyword() abort
  " Given: Buffer with lowercase keyword
  let l:bufnr = bufnr('%')
  call setbufline(l:bufnr, 1, 'if x = 1 then')
  
  " When: Running keyword detector
  let l:config = genero_tools#hints#config#get_for_buffer(l:bufnr)
  let l:hints = genero_tools#hints#keyword#detect(l:bufnr, l:config)
  
  " Then: Lowercase keyword is detected
  call assert_true(len(l:hints) > 0, 'should detect lowercase keyword')
  call assert_equal('lowercase_keywords', l:hints[0].check, 'should identify as lowercase_keywords')
endfunction

function! Test_Structure_Detector_Returns_List() abort
  " Given: Buffer with code
  let l:bufnr = bufnr('%')
  call setbufline(l:bufnr, 1, 'IF x = 1 THEN')
  
  " When: Running structure detector
  let l:config = genero_tools#hints#config#get_for_buffer(l:bufnr)
  let l:hints = genero_tools#hints#structure#detect(l:bufnr, l:config)
  
  " Then: Returns a list
  call assert_equal(type([]), type(l:hints), 'should return a list')
endfunction

function! Test_Genero_Detector_Detects_Deprecated_Function() abort
  " Given: Buffer with deprecated function
  let l:bufnr = bufnr('%')
  call setbufline(l:bufnr, 1, 'call fgl_getenv("PATH")')
  
  " When: Running genero detector
  let l:config = genero_tools#hints#config#get_for_buffer(l:bufnr)
  let l:hints = genero_tools#hints#genero#detect(l:bufnr, l:config)
  
  " Then: Deprecated function is detected
  call assert_true(len(l:hints) > 0, 'should detect deprecated function')
  call assert_equal('deprecated_functions', l:hints[0].check, 'should identify as deprecated_functions')
endfunction
