" Debug parser test
source autoload/genero_tools/compiler.vim

" Test with one line
let test_line = "con01_G.4gl:1811:9:1811:21:warning:(-6615) The symbol 'l_description' is unused."
let result = genero_tools#compiler#parse_v310(test_line)

" Write results to file
let output = []
call add(output, "Test Results:")
call add(output, "=============")
call add(output, "Success: " . result.success)
call add(output, "Warnings parsed: " . len(result.warnings))
call add(output, "Errors parsed: " . len(result.errors))

if len(result.warnings) > 0
  let w = result.warnings[0]
  call add(output, "")
  call add(output, "First warning details:")
  call add(output, "  File: " . w.file)
  call add(output, "  Line: " . w.line)
  call add(output, "  Col: " . w.col)
  call add(output, "  End Line: " . w.end_line)
  call add(output, "  End Col: " . w.end_col)
  call add(output, "  Severity: " . w.severity)
  call add(output, "  Code: " . w.code)
  call add(output, "  Message: " . w.message)
else
  call add(output, "ERROR: No warnings parsed!")
endif

call writefile(output, '/tmp/parser_test_output.txt')
quit!
