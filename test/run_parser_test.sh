#!/bin/bash
# Run the compiler parser tests

cd "$(dirname "$0")/.." || exit 1

vim -u NONE -N -es -c "source test/test_compiler_parser.vim" -c "qa!" 2>&1
