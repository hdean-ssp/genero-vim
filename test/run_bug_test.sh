#!/bin/bash

# Run the bug condition exploration test
vim -u NONE -N -es \
  -c "source test/test_autocompile_highlight_bug.vim" \
  -c "call Test_RunAllAutocompileHighlightBugTests()" \
  -c "qa!" 2>&1
