" Full parser test with all examples
source autoload/genero_tools/compiler.vim

let test_output = "con01_G.4gl:1999:10:1999:17:error:(-4369) The symbol 'Inerface' does not represent a defined variable.\n" .
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

let result = genero_tools#compiler#parse_v310(test_output)

let output = []
call add(output, "Full Parser Test Results")
call add(output, "=======================")
call add(output, "")
call add(output, "Overall:")
call add(output, "  Success: " . result.success)
call add(output, "  Total errors: " . len(result.errors))
call add(output, "  Total warnings: " . len(result.warnings))
call add(output, "")

" Show errors
if len(result.errors) > 0
  call add(output, "Errors (code -4369):")
  for error in result.errors
    call add(output, "  Line " . error.line . ": " . error.message)
  endfor
  call add(output, "")
endif

" Filter for unused variables
let unused_warnings = filter(copy(result.warnings), 
  \ "v:val.message =~? 'unused' && v:val.code == '(-6615)'")
call add(output, "Unused Variables (code -6615):")
call add(output, "  Count: " . len(unused_warnings))

" Extract variable names
let var_names = []
for warning in unused_warnings
  let var_match = matchstr(warning.message, "symbol '\\zs[^']*\\ze'")
  if !empty(var_match)
    call add(var_names, var_match)
  endif
endfor

for var_name in var_names
  call add(output, "    - " . var_name)
endfor

call add(output, "")

" Filter for SQL warnings
let sql_warnings = filter(copy(result.warnings), 
  \ "v:val.message =~? 'SQL' && v:val.code == '(-8059)'")
call add(output, "SQL Warnings (code -8059):")
call add(output, "  Count: " . len(sql_warnings))

for warning in sql_warnings
  call add(output, "    Line " . warning.line . ": " . warning.message)
endfor

call writefile(output, '/tmp/full_parser_test.txt')
quit!
