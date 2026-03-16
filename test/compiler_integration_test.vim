" Tests for compiler integration

" Test 1: Compiler configuration initialization
function! Test_compiler_config_init() abort
  call genero_tools#compiler#init()
  
  " Verify config is initialized
  call assert_true(exists('g:genero_tools_compiler_config'))
  call assert_equal(v:false, g:genero_tools_compiler_config.enabled)
  call assert_equal('fglcomp', g:genero_tools_compiler_config.command)
  call assert_equal('.', g:genero_tools_compiler_config.source_dir)
  call assert_equal('auto', g:genero_tools_compiler_config.compiler_version)
  call assert_equal(v:true, g:genero_tools_compiler_config.show_warnings)
  call assert_equal(v:true, g:genero_tools_compiler_config.show_errors)
  call assert_equal(v:true, g:genero_tools_compiler_config.highlight_unused)
  call assert_equal(v:true, g:genero_tools_compiler_config.sign_column)
endfunction

" Test 2: Compiler version detection
function! Test_compiler_version_detection() abort
  call genero_tools#compiler#init()
  
  " Test get_version with 'auto' setting
  let compiler_ver = genero_tools#compiler#get_version()
  
  " Should return a version string (either detected or default)
  call assert_true(!empty(compiler_ver))
  call assert_match('\d\+\.\d\+', compiler_ver)
endfunction

" Test 3: Parse v3.10 output format
function! Test_parse_v310_output() abort
  let output = "test.4gl:5:10:5:20:error:(-6631) incompatible types, found: CHAR, required: STRING.\n" .
               \ "test.4gl:12:3:12:15:warning:(-8452) Unqualified imported symbol.\n" .
               \ "test.4gl:25:1:25:30:error:(-6632) undefined variable 'myVar'."
  
  let result = genero_tools#compiler#parse_v310(output)
  
  call assert_equal(v:true, result.success)
  call assert_equal(2, len(result.errors))
  call assert_equal(1, len(result.warnings))
  call assert_equal(0, len(result.info))
  
  " Check first error
  call assert_equal('test.4gl', result.errors[0].file)
  call assert_equal(5, result.errors[0].line)
  call assert_equal(10, result.errors[0].col)
  call assert_equal('error', result.errors[0].severity)
  call assert_match('incompatible types', result.errors[0].message)
  
  " Check warning
  call assert_equal('test.4gl', result.warnings[0].file)
  call assert_equal(12, result.warnings[0].line)
  call assert_equal('warning', result.warnings[0].severity)
endfunction

" Test 4: Parse empty output
function! Test_parse_empty_output() abort
  let output = ""
  
  let result = genero_tools#compiler#parse_v310(output)
  
  call assert_equal(v:true, result.success)
  call assert_equal(0, len(result.errors))
  call assert_equal(0, len(result.warnings))
  call assert_equal(0, len(result.info))
endfunction

" Test 5: Quickfix entry formatting
function! Test_quickfix_format_entry() abort
  let entry = {
    \ 'file': 'test.4gl',
    \ 'line': 5,
    \ 'col': 10,
    \ 'message': 'incompatible types'
    \ }
  
  let qf_entry = genero_tools#compiler#quickfix#format_entry(entry, 'E')
  
  call assert_equal('test.4gl', qf_entry.filename)
  call assert_equal(5, qf_entry.lnum)
  call assert_equal(10, qf_entry.col)
  call assert_equal('incompatible types', qf_entry.text)
  call assert_equal('E', qf_entry.type)
endfunction

" Test 6: Quickfix populate with all severities
function! Test_quickfix_populate_all() abort
  let result = {
    \ 'success': v:true,
    \ 'errors': [
    \   {'file': 'test.4gl', 'line': 5, 'col': 10, 'message': 'error 1'},
    \   {'file': 'test.4gl', 'line': 10, 'col': 5, 'message': 'error 2'}
    \ ],
    \ 'warnings': [
    \   {'file': 'test.4gl', 'line': 15, 'col': 3, 'message': 'warning 1'}
    \ ],
    \ 'info': [
    \   {'file': 'test.4gl', 'line': 20, 'col': 1, 'message': 'info 1'}
    \ ]
    \ }
  
  let qf_result = genero_tools#compiler#quickfix#populate(result, 'all')
  
  call assert_equal(v:true, qf_result.success)
  call assert_equal(4, qf_result.count)
endfunction

" Test 7: Quickfix populate with error filter
function! Test_quickfix_populate_errors_only() abort
  let result = {
    \ 'success': v:true,
    \ 'errors': [
    \   {'file': 'test.4gl', 'line': 5, 'col': 10, 'message': 'error 1'}
    \ ],
    \ 'warnings': [
    \   {'file': 'test.4gl', 'line': 15, 'col': 3, 'message': 'warning 1'}
    \ ],
    \ 'info': []
    \ }
  
  let qf_result = genero_tools#compiler#quickfix#populate(result, 'errors')
  
  call assert_equal(v:true, qf_result.success)
  call assert_equal(1, qf_result.count)
endfunction

" Test 8: Quickfix populate with warning filter
function! Test_quickfix_populate_warnings_only() abort
  let result = {
    \ 'success': v:true,
    \ 'errors': [
    \   {'file': 'test.4gl', 'line': 5, 'col': 10, 'message': 'error 1'}
    \ ],
    \ 'warnings': [
    \   {'file': 'test.4gl', 'line': 15, 'col': 3, 'message': 'warning 1'}
    \ ],
    \ 'info': []
    \ }
  
  let qf_result = genero_tools#compiler#quickfix#populate(result, 'warnings')
  
  call assert_equal(v:true, qf_result.success)
  call assert_equal(1, qf_result.count)
endfunction

" Test 9: Config defaults include compiler options
function! Test_config_defaults_include_compiler() abort
  call genero_tools#config#init()
  
  call assert_equal(v:false, genero_tools#config#get('compiler_enabled'))
  call assert_equal('fglcomp', genero_tools#config#get('compiler_command'))
  call assert_equal('.', genero_tools#config#get('compiler_source_dir'))
  call assert_equal('auto', genero_tools#config#get('compiler_version'))
  call assert_equal(v:true, genero_tools#config#get('compiler_show_warnings'))
  call assert_equal(v:true, genero_tools#config#get('compiler_show_errors'))
  call assert_equal(v:true, genero_tools#config#get('compiler_highlight_unused'))
  call assert_equal(v:true, genero_tools#config#get('compiler_sign_column'))
endfunction

" Test 10: Parse output dispatcher routes to correct parser
function! Test_parse_output_dispatcher() abort
  let output = "test.4gl:5:10:5:20:error:(-6631) test error"
  
  " Test with 3.10 version
  let result_310 = genero_tools#compiler#parse_output(output, '3.10')
  call assert_equal(v:true, result_310.success)
  call assert_equal(1, len(result_310.errors))
  
  " Test with 3.20 version (should use same parser for now)
  let result_320 = genero_tools#compiler#parse_output(output, '3.20')
  call assert_equal(v:true, result_320.success)
  call assert_equal(1, len(result_320.errors))
  
  " Test with unknown version (should default to 3.10)
  let result_unknown = genero_tools#compiler#parse_output(output, '4.00')
  call assert_equal(v:true, result_unknown.success)
  call assert_equal(1, len(result_unknown.errors))
endfunction
