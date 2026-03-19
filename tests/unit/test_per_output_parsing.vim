" Genero-Tools Plugin - Tests for .per File Output Parsing

" Mock fglform output format (same as fglcomp)
" Format: filename:start_line:start_col:end_line:end_col:severity:(-code) message

" Test parsing fglform error output
function! Test_per_parse_fglform_error() abort
  let output = 'form.per:10:5:10:15:error:(-1234) Invalid form definition'
  let result = genero_tools#compiler#parse_v310(output, 'per')
  
  call assert_equal(1, result.success, 'Parsing should succeed')
  call assert_equal(1, len(result.errors), 'Should have 1 error')
  call assert_equal(0, len(result.warnings), 'Should have 0 warnings')
  
  let error = result.errors[0]
  call assert_equal('form.per', error.file, 'File should be form.per')
  call assert_equal(10, error.line, 'Line should be 10')
  call assert_equal(5, error.col, 'Column should be 5')
  call assert_equal('Invalid form definition', error.message, 'Message should match')
endfunction

" Test parsing fglform warning output
function! Test_per_parse_fglform_warning() abort
  let output = 'form.per:20:1:20:10:warning:(-5678) Unused variable'
  let result = genero_tools#compiler#parse_v310(output, 'per')
  
  call assert_equal(1, result.success, 'Parsing should succeed')
  call assert_equal(0, len(result.errors), 'Should have 0 errors')
  call assert_equal(1, len(result.warnings), 'Should have 1 warning')
  
  let warning = result.warnings[0]
  call assert_equal('form.per', warning.file, 'File should be form.per')
  call assert_equal(20, warning.line, 'Line should be 20')
  call assert_equal('Unused variable', warning.message, 'Message should match')
endfunction

" Test parsing multiple fglform errors
function! Test_per_parse_multiple_errors() abort
  let output = "form.per:10:5:10:15:error:(-1234) Invalid form definition\n"
        \ . "form.per:20:1:20:10:warning:(-5678) Unused variable\n"
        \ . "form.per:30:8:30:20:error:(-9999) Syntax error"
  
  let result = genero_tools#compiler#parse_v310(output, 'per')
  
  call assert_equal(1, result.success, 'Parsing should succeed')
  call assert_equal(2, len(result.errors), 'Should have 2 errors')
  call assert_equal(1, len(result.warnings), 'Should have 1 warning')
  
  " Check first error
  call assert_equal(10, result.errors[0].line, 'First error should be at line 10')
  
  " Check warning
  call assert_equal(20, result.warnings[0].line, 'Warning should be at line 20')
  
  " Check second error
  call assert_equal(30, result.errors[1].line, 'Second error should be at line 30')
endfunction

" Test parsing empty output
function! Test_per_parse_empty_output() abort
  let output = ''
  let result = genero_tools#compiler#parse_v310(output, 'per')
  
  call assert_equal(1, result.success, 'Parsing should succeed')
  call assert_equal(0, len(result.errors), 'Should have 0 errors')
  call assert_equal(0, len(result.warnings), 'Should have 0 warnings')
endfunction

" Test parsing output with blank lines
function! Test_per_parse_output_with_blanks() abort
  let output = "form.per:10:5:10:15:error:(-1234) Invalid form definition\n"
        \ . "\n"
        \ . "form.per:20:1:20:10:warning:(-5678) Unused variable\n"
        \ . "\n"
  
  let result = genero_tools#compiler#parse_v310(output, 'per')
  
  call assert_equal(1, result.success, 'Parsing should succeed')
  call assert_equal(1, len(result.errors), 'Should have 1 error')
  call assert_equal(1, len(result.warnings), 'Should have 1 warning')
endfunction

" Test parsing fglform info output
function! Test_per_parse_fglform_info() abort
  let output = 'form.per:5:1:5:20:info:(-0001) Compilation successful'
  let result = genero_tools#compiler#parse_v310(output, 'per')
  
  call assert_equal(1, result.success, 'Parsing should succeed')
  call assert_equal(0, len(result.errors), 'Should have 0 errors')
  call assert_equal(0, len(result.warnings), 'Should have 0 warnings')
  call assert_equal(1, len(result.info), 'Should have 1 info message')
  
  let info = result.info[0]
  call assert_equal('form.per', info.file, 'File should be form.per')
  call assert_equal('Compilation successful', info.message, 'Message should match')
endfunction

" Test that per and fgl files use same parser
function! Test_per_and_fgl_same_parser() abort
  let per_output = 'form.per:10:5:10:15:error:(-1234) Invalid form definition'
  let fgl_output = 'main.4gl:10:5:10:15:error:(-1234) Invalid form definition'
  
  let per_result = genero_tools#compiler#parse_v310(per_output, 'per')
  let fgl_result = genero_tools#compiler#parse_v310(fgl_output, 'fgl')
  
  " Both should parse successfully
  call assert_equal(1, per_result.success, 'Per parsing should succeed')
  call assert_equal(1, fgl_result.success, 'FGL parsing should succeed')
  
  " Both should have same number of errors
  call assert_equal(len(per_result.errors), len(fgl_result.errors), 'Should have same error count')
  
  " Error messages should be identical (except filename)
  call assert_equal(per_result.errors[0].message, fgl_result.errors[0].message, 'Messages should match')
  call assert_equal(per_result.errors[0].line, fgl_result.errors[0].line, 'Lines should match')
endfunction

" Test parsing with special characters in message
function! Test_per_parse_special_chars() abort
  let output = "form.per:10:5:10:15:error:(-1234) Invalid form: 'myform' not found"
  let result = genero_tools#compiler#parse_v310(output, 'per')
  
  call assert_equal(1, result.success, 'Parsing should succeed')
  call assert_equal(1, len(result.errors), 'Should have 1 error')
  call assert_equal("Invalid form: 'myform' not found", result.errors[0].message, 'Message with quotes should parse')
endfunction

" Test parsing with long error messages
function! Test_per_parse_long_message() abort
  let long_msg = 'This is a very long error message that spans multiple words and contains detailed information about the compilation error'
  let output = 'form.per:10:5:10:15:error:(-1234) ' . long_msg
  let result = genero_tools#compiler#parse_v310(output, 'per')
  
  call assert_equal(1, result.success, 'Parsing should succeed')
  call assert_equal(1, len(result.errors), 'Should have 1 error')
  call assert_equal(long_msg, result.errors[0].message, 'Long message should be preserved')
endfunction

" Test parsing real fglform output (concatenated without newlines)
function! Test_per_parse_real_fglform_output() abort
  " Real output from fglform command - concatenated without newlines
  let output = 'cert001_G.per:43:11:43:13:error:(-6803) A grammatical error has been found at ''f01'', expecting ''=''.' .
        \ 'cert001_G.per:44:6:44:11:error:(-6803) A grammatical error has been found at ''ACTION'', expecting AUTONEXT CENTURY CLASS COLOR COMMENT COMMENTS COMPLETER CONFIG DEFAULT DISPLAY DOWNSHIFT FONTPITCH FORMAT HIDDEN IMAGECOLUMN INCLUDE INVISIBLE JUSTIFY KEY NOENTRY NOT NOUPDATE OPTIONS PICTURE PLACEHOLDER PROGRAM QUERYCLEAR REQUIRED REVERSE RIGHT SAMPLE SCROLL SIZEPOLICY STYLE TABINDEX TAG TITLE UNHIDABLE UNMOVABLE UNSIZABLE UNSORTABLE UPSHIFT VALIDATE VERIFY WIDGET WIDTH WORDWRAP ZEROFILL KEYBOARDHINT.' .
        \ 'cert001_G.per:44:17:44:21:error:(-6803) A grammatical error has been found at ''IMAGE'', expecting AUTONEXT CENTURY CLASS COLOR COMMENT COMMENTS COMPLETER CONFIG DEFAULT DISPLAY DOWNSHIFT FONTPITCH FORMAT HIDDEN IMAGECOLUMN INCLUDE INVISIBLE JUSTIFY KEY NOENTRY NOT NOUPDATE OPTIONS PICTURE PLACEHOLDER PROGRAM QUERYCLEAR REQUIRED REVERSE RIGHT SAMPLE SCROLL SIZEPOLICY STYLE TABINDEX TAG TITLE UNHIDABLE UNMOVABLE UNSIZABLE UNSORTABLE UPSHIFT VALIDATE VERIFY WIDGET WIDTH WORDWRAP ZEROFILL KEYBOARDHINT.'
  
  let result = genero_tools#compiler#parse_v310(output, 'per')
  
  call assert_equal(1, result.success, 'Parsing should succeed')
  call assert_equal(3, len(result.errors), 'Should have 3 errors')
  call assert_equal(0, len(result.warnings), 'Should have 0 warnings')
  
  " Check first error
  call assert_equal('cert001_G.per', result.errors[0].file, 'File should be cert001_G.per')
  call assert_equal(43, result.errors[0].line, 'First error should be at line 43')
  call assert_equal(11, result.errors[0].col, 'First error should be at column 11')
  call assert_equal("A grammatical error has been found at 'f01', expecting '='.", result.errors[0].message, 'First error message should match')
  
  " Check second error
  call assert_equal(44, result.errors[1].line, 'Second error should be at line 44')
  call assert_equal(6, result.errors[1].col, 'Second error should be at column 6')
  
  " Check third error
  call assert_equal(44, result.errors[2].line, 'Third error should be at line 44')
  call assert_equal(17, result.errors[2].col, 'Third error should be at column 17')
endfunction

" Test that real fglform output is parsed same as fglcomp
function! Test_per_real_output_same_as_fglcomp() abort
  " Same output format for both compilers
  let per_output = 'form.per:10:5:10:15:error:(-6803) A grammatical error has been found at ''test'', expecting ''=''.'
  let fgl_output = 'main.4gl:10:5:10:15:error:(-6803) A grammatical error has been found at ''test'', expecting ''=''.'
  
  let per_result = genero_tools#compiler#parse_v310(per_output, 'per')
  let fgl_result = genero_tools#compiler#parse_v310(fgl_output, 'fgl')
  
  " Both should parse successfully
  call assert_equal(1, per_result.success, 'Per parsing should succeed')
  call assert_equal(1, fgl_result.success, 'FGL parsing should succeed')
  
  " Both should have same error count
  call assert_equal(len(per_result.errors), len(fgl_result.errors), 'Should have same error count')
  
  " Error details should match (except filename)
  call assert_equal(per_result.errors[0].line, fgl_result.errors[0].line, 'Lines should match')
  call assert_equal(per_result.errors[0].col, fgl_result.errors[0].col, 'Columns should match')
  call assert_equal(per_result.errors[0].message, fgl_result.errors[0].message, 'Messages should match')
endfunction

