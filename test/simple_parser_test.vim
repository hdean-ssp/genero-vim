" Simple parser test
source autoload/genero_tools/compiler.vim

" Test with one line
let test_line = "con01_G.4gl:1811:9:1811:21:warning:(-6615) The symbol 'l_description' is unused."
let result = genero_tools#compiler#parse_v310(test_line)

echo "Test Results:"
echo "============="
echo "Success: " . result.success
echo "Warnings parsed: " . len(result.warnings)
echo "Errors parsed: " . len(result.errors)

if len(result.warnings) > 0
  let w = result.warnings[0]
  echo ""
  echo "First warning details:"
  echo "  File: " . w.file
  echo "  Line: " . w.line
  echo "  Col: " . w.col
  echo "  End Line: " . w.end_line
  echo "  End Col: " . w.end_col
  echo "  Severity: " . w.severity
  echo "  Code: " . w.code
  echo "  Message: " . w.message
else
  echo "ERROR: No warnings parsed!"
endif

quit!
