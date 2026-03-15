#!/bin/bash

# Run compiler integration tests
vim -u NONE -N -es \
  -c "set nocompatible" \
  -c "source autoload/genero_tools/config.vim" \
  -c "source autoload/genero_tools/command.vim" \
  -c "source autoload/genero_tools/compiler.vim" \
  -c "source autoload/genero_tools/compiler/signs.vim" \
  -c "source autoload/genero_tools/compiler/quickfix.vim" \
  -c "source autoload/genero_tools/compiler/highlight.vim" \
  -c "source test/compiler_integration_test.vim" \
  -c "call Test_compiler_config_init()" \
  -c "call Test_compiler_version_detection()" \
  -c "call Test_parse_v310_output()" \
  -c "call Test_parse_empty_output()" \
  -c "call Test_quickfix_format_entry()" \
  -c "call Test_quickfix_populate_all()" \
  -c "call Test_quickfix_populate_errors_only()" \
  -c "call Test_quickfix_populate_warnings_only()" \
  -c "call Test_config_defaults_include_compiler()" \
  -c "call Test_parse_output_dispatcher()" \
  -c "qa!" 2>&1
