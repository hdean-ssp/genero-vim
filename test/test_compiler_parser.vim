" Test compiler output parser with real examples

" Load the compiler module
source autoload/genero_tools/compiler.vim

" Test data: Real compiler output from con01_G.4gl
let s:test_output = "con01_G.4gl:1999:10:1999:17:error:(-4369) The symbol 'Inerface' does not represent a defined variable.\n" .
  \ "con01_G.4gl:1811:9:1811:21:warning:(-6615) The symbol 'l_description' is unused.\n" .
  \ "con01_G.4gl:1812:9:1812:17:warning:(-6615) The symbol 'l_premium' is unused.\n" .
  \ "con01_G.4gl:1657:10:1657:18:warning:(-6615) The symbol 'l_gui_map' is unused.\n" .
  \ "con01_G.4gl:1658:10:1658:17:warning:(-6615) The symbol 'l_status' is unused.\n" .
  \ "con01_G.4gl:1104:9:1104:17:warning:(-6615) The symbol 'l_premium' is unused.\n" .
  \ "con01_G.4gl:1105:9:1105:18:warning:(-6615) The symbol 'l_ipt_rate' is unused.\n" .
  \ "con01_G.4gl:1106:9:1106:24:warning:(-6615) The symbol 'l_inception_date' is unused.\n" .
  \ "con01_G.4gl:379:9:379:17:warning:(-6615) The symbol 'l_command' is unused.\n" .
  \ "con01_G.4gl:221:9:221:20:warning:(-6615) The symbol 'l_rec_search' is unused.\n" .
  \ "con01_G.4gl:150:10:150:17:warning:(-6615) The symbol 'l_rtcode' is unused.\n" .
  \ "con01_G.4gl:151:10:151:20:warning:(-6615) The symbol 'l_debug_str' is unused.\n" .
  \ "con01_G.4gl:152:10:152:20:warning:(-6615) The symbol 'l_access_no' is unused.\n" .
  \ "con01_G.4gl:258:44:258:52:warning:(-8059) SQL statement or language instruction with vendor proprietary SQL syntax.\n" .
  \ "con01_G.4gl:269:6:269:20:warning:(-8059) SQL statement or language instruction with vendor proprietary SQL syntax.\n" .
  \ "con01_G.4gl:270:6:270:23:warning:(-8059) SQL statement or language instruction with vendor proprietary SQL syntax.\n" .
  \ "con01_G.4gl:1139:9:1139:28:warning:(-8059) SQL statement or language instruction with vendor proprietary SQL syntax.\n" .
  \ "con01_G.4gl:1142:10:1142:30:warning:(-8059) SQL statement or language instruction with vendor proprietary SQL syntax.\n" .
  \ "con01_G.4gl:1210:14:1210:19:warning:(-8059) SQL statement or language instruction with vendor proprietary SQL syntax.\n" .
  \ "con01_G.4gl:1618:10:1618:15:warning:(-8059) SQL statement or language instruction with vendor proprietary SQL syntax.\n" .
  \ "con01_G.4gl:1626:13:1626:18:warning:(-8059) SQL statement or language instruction with vendor proprietary SQL syntax."

function! TestParserBasic() abort
  echo "Testing basic parser functionality..."
  
  let result = genero_tools#compiler#parse_v310(s:test_output)
  
  " Verify parsing succeeded
  if result.success != v:true
    throw 'Parser should succeed'
  endif
  
  " Verify error count
  let error_count = len(result.errors)
  if error_count != 1
    throw 'Should parse 1 error, got ' . error_count
  endif
  
  " Verify warning count
  let warning_count = len(result.warnings)
  if warning_count != 20
    throw 'Should parse 20 warnings, got ' . warning_count
  endif
  
  echo "✓ Basic parser test passed"
endfunction

function! TestParserUnusedVars() abort
  echo "Testing unused variable detection..."
  
  let result = genero_tools#compiler#parse_v310(s:test_output)
  
  " Filter for unused variable warnings
  let unused_warnings = filter(copy(result.warnings), 
    \ "v:val.message =~? 'unused' && v:val.code == '(-6615)'")
  
  " Should have 12 unused variable warnings
  if len(unused_warnings) != 12
    throw 'Should detect 12 unused variables, got ' . len(unused_warnings)
  endif
  
  " Verify first unused variable
  let first = unused_warnings[0]
  if first.file != 'con01_G.4gl'
    throw 'File should be con01_G.4gl, got ' . first.file
  endif
  if first.line != 1811
    throw 'Line should be 1811, got ' . first.line
  endif
  if first.col != 9
    throw 'Column should be 9, got ' . first.col
  endif
  if first.end_line != 1811
    throw 'End line should be 1811, got ' . first.end_line
  endif
  if first.end_col != 21
    throw 'End column should be 21, got ' . first.end_col
  endif
  if first.severity != 'warning'
    throw 'Severity should be warning, got ' . first.severity
  endif
  if first.code != '(-6615)'
    throw 'Code should be (-6615), got ' . first.code
  endif
  
  echo "✓ Unused variable detection test passed"
endfunction

function! TestParserSQLWarnings() abort
  echo "Testing SQL warning detection..."
  
  let result = genero_tools#compiler#parse_v310(s:test_output)
  
  " Filter for SQL warnings
  let sql_warnings = filter(copy(result.warnings), 
    \ "v:val.message =~? 'SQL' && v:val.code == '(-8059)'")
  
  " Should have 8 SQL warnings
  if len(sql_warnings) != 8
    throw 'Should detect 8 SQL warnings, got ' . len(sql_warnings)
  endif
  
  echo "✓ SQL warning detection test passed"
endfunction

function! TestParserVariableExtraction() abort
  echo "Testing variable name extraction..."
  
  let result = genero_tools#compiler#parse_v310(s:test_output)
  
  " Get unused variable warnings
  let unused_warnings = filter(copy(result.warnings), 
    \ "v:val.message =~? 'unused' && v:val.code == '(-6615)'")
  
  " Extract variable names
  let var_names = []
  for warning in unused_warnings
    let var_match = matchstr(warning.message, "symbol '\\zs[^']*\\ze'")
    if !empty(var_match)
      call add(var_names, var_match)
    endif
  endfor
  
  " Verify we extracted all variable names
  if len(var_names) != 12
    throw 'Should extract 12 variable names, got ' . len(var_names)
  endif
  
  " Verify specific variable names
  if var_names[0] != 'l_description'
    throw 'First variable should be l_description, got ' . var_names[0]
  endif
  if var_names[1] != 'l_premium'
    throw 'Second variable should be l_premium, got ' . var_names[1]
  endif
  if var_names[2] != 'l_gui_map'
    throw 'Third variable should be l_gui_map, got ' . var_names[2]
  endif
  
  echo "✓ Variable name extraction test passed"
endfunction

function! TestParserErrors() abort
  echo "Testing error parsing..."
  
  let result = genero_tools#compiler#parse_v310(s:test_output)
  
  " Should have 1 error
  if len(result.errors) != 1
    throw 'Should detect 1 error, got ' . len(result.errors)
  endif
  
  " Verify error details
  let error = result.errors[0]
  if error.file != 'con01_G.4gl'
    throw 'Error file should be con01_G.4gl, got ' . error.file
  endif
  if error.line != 1999
    throw 'Error line should be 1999, got ' . error.line
  endif
  if error.col != 10
    throw 'Error col should be 10, got ' . error.col
  endif
  if error.end_line != 1999
    throw 'Error end_line should be 1999, got ' . error.end_line
  endif
  if error.end_col != 17
    throw 'Error end_col should be 17, got ' . error.end_col
  endif
  if error.severity != 'error'
    throw 'Error severity should be error, got ' . error.severity
  endif
  if error.code != '(-4369)'
    throw 'Error code should be (-4369), got ' . error.code
  endif
  if error.message !~? 'Inerface'
    throw 'Error message should contain Inerface, got ' . error.message
  endif
  
  echo "✓ Error parsing test passed"
endfunction

" Run all tests
try
  call TestParserBasic()
  call TestParserUnusedVars()
  call TestParserSQLWarnings()
  call TestParserVariableExtraction()
  call TestParserErrors()
  echo ""
  echo "✓ All parser tests passed!"
catch
  echo "✗ Test failed: " . v:exception
endtry
