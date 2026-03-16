#!/bin/bash

# Test the compiler parser with real output

cat > /tmp/test_parse.vim << 'EOF'
" Load the compiler module
source autoload/genero_tools/compiler.vim

" Test data
let s:test_output = 'con01_G.4gl:1811:9:1811:21:warning:(-6615) The symbol ''l_description'' is unused.
con01_G.4gl:1812:9:1812:17:warning:(-6615) The symbol ''l_premium'' is unused.
con01_G.4gl:258:44:258:52:warning:(-8059) SQL statement or language instruction with vendor proprietary SQL syntax.'

let result = genero_tools#compiler#parse_v310(s:test_output)

echo "Parsing Results:"
echo "==============="
echo "Success: " . result.success
echo "Warnings: " . len(result.warnings)
echo "Errors: " . len(result.errors)
echo ""

if len(result.warnings) > 0
  echo "First warning:"
  let w = result.warnings[0]
  echo "  File: " . w.file
  echo "  Line: " . w.line
  echo "  Col: " . w.col
  echo "  End Line: " . w.end_line
  echo "  End Col: " . w.end_col
  echo "  Severity: " . w.severity
  echo "  Code: " . w.code
  echo "  Message: " . w.message
endif

quit!
EOF

vim -u NONE -N -es -S /tmp/test_parse.vim 2>&1
