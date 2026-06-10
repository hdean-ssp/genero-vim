# Implementation Plan: Comprehensive Test Suite for Genero-Tools Plugin

## Overview

Build the complete test infrastructure from the ground up, focusing on Neovim with plenary.nvim as the primary test framework. VimScript/vader.vim tests are retained only where they test the VimScript layer that underpins Neovim functionality (parsers, cache, config, compat). Pure Vim-only tests are struck through and deprioritised.

The design specifies six correctness properties (compiler parser round-trip, SVN diff parser correctness, cache set-get round-trip, cache size invariant, config validation completeness, compiler file-type routing). Property tests are placed close to the implementation tasks they validate.

Fixtures use the existing `sample_codebase/` directory rather than creating new test files. The fixture tasks below document which sample files serve which test purpose.

---

## Tasks

- [x] 1. Create test directory skeleton and runner scripts
  - Create `tests/` directory with all subdirectories: `mocks/`, `fixtures/compiler_output/`, `fixtures/svn_diff/`, `helpers/`, `vader/unit/`, `vader/property/`, `lua/unit/`, `lua/integration/`, `lua/property/`, `results/`
  - Write `tests/run_tests.sh`: detect available `nvim` binary, prepend `tests/mocks/` to `PATH`, invoke `run_lua_tests.sh` (and optionally `run_vim_tests.sh` for VimScript layer tests), aggregate exit codes, print summary
  - Write `tests/run_lua_tests.sh`: run all `*_spec.lua` files under `tests/lua/` using `nvim --headless -c "PlenaryBustedDirectory tests/lua/"`, support `--file <path>`, exit 1 on any failure
  - Write `tests/run_vim_tests.sh`: run all `.vader` files under `tests/vader/` using `nvim -u tests/vimrc -c "Vader! ..."`, support `--file <path>`, exit 1 on any failure (Neovim only — no plain Vim support needed)
  - Write `tests/vimrc`: minimal config for vader execution under Neovim — adds plugin root and vader.vim to `runtimepath`, enables filetype/syntax, sources helper files from `tests/helpers/`
  - Write `tests/init.lua`: minimal Neovim config that appends plugin root and plenary.nvim to `runtimepath`
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.6_

- [x] 2. Implement mock executables
  - [x] 2.1 Write `tests/mocks/fglcomp`: shell script that prints `$MOCK_FGLCOMP_OUTPUT` and exits with `$MOCK_FGLCOMP_EXIT` (defaults: empty output, exit 0); mark executable
  - [x] 2.2 Write `tests/mocks/fglform`: same pattern using `$MOCK_FGLFORM_OUTPUT` / `$MOCK_FGLFORM_EXIT`; mark executable
  - [x] 2.3 Write `tests/mocks/svn`: shell script that handles `diff`, `info`, `status` subcommands, prints `$MOCK_SVN_OUTPUT`, exits with `$MOCK_SVN_EXIT`; mark executable
  - [x] 2.4 Write `tests/mocks/query.sh`: shell script that prints `$MOCK_QUERY_OUTPUT` (default `[]`) and exits with `$MOCK_QUERY_EXIT`; mark executable
  - _Requirements: 23.1, 23.2, 23.3, 23.4_

- [x] 3. Document and map sample_codebase fixtures
  - [x] 3.1 Document fixture mapping in `tests/fixtures/README.md`: map each `sample_codebase/` file to its test purpose — `simple_functions.4gl` (navigation/autocomplete unit tests — contains `add_numbers`, `get_user_name`, `no_params_no_return`, `display_message`), `customer_main.4gl` (module-scoped navigation, multiple functions, record types), `edge_cases.4gl` (parser edge cases — long params, nested calls, control flow), `whitespace_variations.4gl` (hints tests — mixed whitespace, tabs), `customer_db.4gl` / `customer_validate.4gl` (integration tests — cross-file references), `multiline_params.4gl` (autocomplete signature tests), `customer.m3` / `reporting.m3` (module file tests), `modules/test.m3` / `modules/multiline.m3` (module picker tests)
  - [x] 3.2 Write `tests/fixtures/compiler_output/errors_v310.txt`: three fglcomp 3.10 error lines in full format (`file:line:col:end_line:end_col:error:(-code) message`) referencing `sample_codebase/simple_functions.4gl` line numbers
  - [x] 3.3 Write `tests/fixtures/compiler_output/warnings_v310.txt`: two fglcomp 3.10 warning lines referencing `sample_codebase/customer_main.4gl`
  - [x] 3.4 Write `tests/fixtures/compiler_output/errors_v320.txt`: three fglcomp 3.20 format error lines
  - [x] 3.5 Write `tests/fixtures/compiler_output/mixed.txt`: file containing both errors and warnings across multiple sample files
  - [x] 3.6 Write `tests/fixtures/svn_diff/added_lines.diff`: unified diff against `sample_codebase/simple_functions.4gl` with three added lines at known line numbers
  - [x] 3.7 Write `tests/fixtures/svn_diff/deleted_lines.diff`: unified diff with two deleted lines at known line numbers
  - [x] 3.8 Write `tests/fixtures/svn_diff/modified_lines.diff`: unified diff with one deleted + one added line (modification)
  - [x] 3.9 Write `tests/fixtures/svn_diff/mixed_changes.diff`: unified diff combining adds, deletes, and modifications
  - _Requirements: 23.5, 23.6, 23.7, 23.8_

- [x] 4. Implement VimScript test helper modules
  - [x] 4.1 Write `tests/helpers/setup.vim`: implement `TestSetup()` (reset `g:genero_tools_config`, clear all caches, `%bdelete!`, reset all mock env vars), `TestTeardown()` (close buffers, clear caches, unlet config), `TestCreateTempFile(content, extension)`, `TestDeleteTempFile(path)`; include `TestOpenSampleFile(relative_path)` helper that opens a file from `sample_codebase/` by path relative to repo root
  - [x] 4.2 Write `tests/helpers/assertions.vim`: implement `AssertEqual(expected, actual, msg)`, `AssertContains(list, item, msg)`, `AssertHasKey(dict, key, msg)`, `AssertMatch(pattern, str, msg)`, `AssertTrue(expr, msg)`, `AssertFalse(expr, msg)`
  - [x] 4.3 Write `tests/helpers/mock_config.vim`: implement `MockConfigSet(key, value)`, `MockConfigReset()`, `MockConfigGetAll()`
  - [x] 4.4 Write `tests/helpers/generators.vim`: implement `TestGenCompilerError(seed)`, `TestGenCompilerWarning(seed)`, `TestGenSvnDiff(added_lines, deleted_lines)`, `TestParseExpectedFromSeed(seed)`
  - _Requirements: 1.7, 23.9, 23.10, 25.1, 25.2, 25.3, 25.4, 25.5_

- [x] 5. Write VimScript unit tests — compiler parser
  - [x] 5.1 Write `tests/vader/unit/compiler_parser.vader`: test `genero_tools#compiler#parse_v310` with full-format error line, simple-format error line, warning line, info line, empty string input, and malformed input; use `Before:`/`After:` blocks calling `TestSetup()`/`TestTeardown()`; use line content from `tests/fixtures/compiler_output/errors_v310.txt`
  - [x]* 5.2 Write property test for compiler parser round-trip (`tests/vader/property/compiler_parser_props.vader`): loop 100 iterations over seeds 0–99, generate a line with `TestGenCompilerError(seed)`, parse it, assert `file`/`line`/`col`/`severity`/`message` match `TestParseExpectedFromSeed(seed)`; tag: `Feature: new-test-suite, Property 1: compiler parser round-trip`
  - [x] 5.3 Add file-type detection section to `tests/vader/unit/compiler_parser.vader`: test `genero_tools#compiler#detect_file_type` with `.4gl`, `.m3`, `.m4`, `.per` paths
  - [x]* 5.4 Write property test for compiler file-type routing (`tests/vader/property/compiler_parser_props.vader`): generate 50 `.4gl`/`.m3`/`.m4` paths and 50 `.per` paths, assert routing returns `'fgl'` or `'per'` respectively; tag: `Feature: new-test-suite, Property 6: compiler file-type routing`
  - _Requirements: 4.3, 4.4, 18.1, 18.2, 18.6_

- [x] 6. Write VimScript unit tests — SVN parser
  - [x] 6.1 Write `tests/vader/unit/svn_parser.vader`: test `genero_tools#svn#parser#parse_diff` with each fixture diff file; assert `added`, `deleted`, `modified` lists match known values; test empty diff input; test malformed diff input
  - [x]* 6.2 Write property test for SVN diff parser correctness (`tests/vader/property/svn_parser_props.vader`): loop 100 iterations, generate diff with `TestGenSvnDiff(added, deleted)`, parse result, assert `added` and `deleted` lists exactly match inputs; tag: `Feature: new-test-suite, Property 2: SVN diff parser correctness`
  - _Requirements: 9.1, 9.2, 9.3, 18.3, 18.4, 18.5_

- [x] 7. Write VimScript unit tests — cache
  - [x] 7.1 Write `tests/vader/unit/cache.vader`: test `genero_tools#cache#set` + `genero_tools#cache#get` round-trip with string, list, and dict values; test TTL expiration; test `genero_tools#cache#clear`; test `genero_tools#cache#stats`
  - [x]* 7.2 Write property test for cache set-get round-trip (`tests/vader/property/cache_props.vader`): loop 100 iterations, assert get immediately after set returns original value; tag: `Feature: new-test-suite, Property 3: cache set-get round-trip`
  - [x]* 7.3 Write property test for cache size invariant (`tests/vader/property/cache_props.vader`): configure `cache_max_size = 10`, insert 100 entries, assert `len(g:genero_tools_cache) <= 10` after each insert; tag: `Feature: new-test-suite, Property 4: cache size invariant`
  - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5, 14.6, 14.7_

- [x] 8. Write VimScript unit tests — configuration
  - [x] 8.1 Write `tests/vader/unit/config.vader`: test `genero_tools#config#init` applies all defaults; test `genero_tools#config#validate` rejects invalid values; test user config merges with defaults
  - [x]* 8.2 Write property test for configuration validation (`tests/vader/property/config_validation_props.vader`): loop 100 iterations with out-of-range values, assert `validate()` always produces a config where all fields satisfy constraints; tag: `Feature: new-test-suite, Property 5: configuration validation always produces valid state`
  - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.7_

- [x] 9. Write VimScript unit tests — compatibility layer (Neovim-focused)
  - Write `tests/vader/unit/compat.vader`: run under Neovim only (`if !has('nvim') | finish | endif`); test `genero_tools#compat#is_neovim()` returns 1; test `genero_tools#compat#has_floating_windows()` returns 1 on Neovim 0.9+; test `genero_tools#compat#normalize_display_mode()` accepts Neovim-specific modes; test `genero_tools#compat#get_supported_display_modes()` returns non-empty list
  - _Requirements: 2.6, 2.7, 20.4_

- [x] 10. Write VimScript unit tests — hints
  - Write `tests/vader/unit/hints.vader`: open `sample_codebase/whitespace_variations.4gl` (contains mixed tabs/spaces), assert hint is detected; open `sample_codebase/customer_main.4gl` (contains `#TMPHD` debug markers and lowercase constructs), assert relevant hints detected; test auto-fix for trailing whitespace; test hint navigation (`next`, `previous`)
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.9, 8.10_

- [x] 11. Write VimScript unit tests — navigation
  - Write `tests/vader/unit/navigation.vader`: open `sample_codebase/simple_functions.4gl`, call `genero_tools#navigation#goto_definition` for `add_numbers`, assert cursor moves to correct line; open `sample_codebase/customer_main.4gl`, test module-scoped lookup for `customer_search_by_name`; test not-found error when function does not exist; use `sample_codebase/customer.m3` for module-scoped tests
  - _Requirements: 3.1, 3.2, 3.5, 3.6, 3.7, 3.8_

- [ ] 12. ~~Write VimScript unit tests — keybindings~~
  - ~~Write `tests/vader/unit/keybindings.vader`: assert F5 mapping invokes `GeneroCompile`; assert `<C-,>` invokes `GeneroPrevError`; assert `<C-.>` invokes `GeneroNextError`; assert `<C-Space>` in insert mode triggers completion; assert `gd`, `gp`, `gr` invoke correct commands; test `g:genero_tools_keybindings_enabled = 0` disables all mappings; test user override of a default mapping is respected~~
  - _Deprioritised: keybinding behaviour is better validated through Neovim integration tests (tasks 20+) and manual testing. Retain for future if regression coverage is needed._

- [x] 13. Write VimScript unit tests — error handling
  - Write `tests/vader/unit/error_handling.vader`: set `MOCK_QUERY_EXIT=1`, invoke a navigation command, assert error message contains module prefix; set `MOCK_FGLCOMP_EXIT=1`, invoke compile, assert compiler-not-found error is displayed; set `MOCK_QUERY_OUTPUT` to malformed JSON, invoke autocomplete, assert graceful degradation; test timeout error message format
  - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6, 15.7_

- [ ] 14. Checkpoint — run all VimScript layer tests
  - Run `./tests/run_vim_tests.sh` under Neovim and confirm all vader tests pass. These tests validate the VimScript layer that the Lua layer depends on.

- [ ] 15. ~~Write VimScript integration tests — compiler quickfix and signs~~
  - ~~Write `tests/vader/integration/compiler_quickfix.vader`~~; ~~Write `tests/vader/integration/compiler_signs.vader`~~; ~~Write `tests/vader/integration/autocompile.vader`~~
  - _Deprioritised: compiler quickfix and sign integration is covered by Neovim Lua integration tests (tasks 27+) which test the full stack end-to-end. VimScript-layer parser correctness is covered by tasks 5–6._

- [ ] 16. ~~Write VimScript integration tests — SVN signs~~
  - ~~Write `tests/vader/integration/svn_signs.vader`~~; ~~Write `tests/vader/integration/unified_signs.vader`~~
  - _Deprioritised: SVN sign integration covered by Neovim Lua integration tests. SVN parser correctness covered by task 6._

- [ ] 17. ~~Write VimScript integration tests — feature interactions~~
  - ~~Write `tests/vader/integration/feature_interaction.vader`~~
  - _Deprioritised: feature interaction testing is handled in Lua integration tests (tasks 27–29) which run under Neovim and test the full plugin stack._

- [ ] 18. ~~Write version compatibility tests — Vim 7.4 and Vim 8.2~~
  - ~~Write `tests/compat/vim74_compat.vader`~~; ~~Write `tests/compat/vim82_compat.vader`~~
  - _Deprioritised: plain Vim compatibility is out of scope for this test suite. Focus is Neovim._
  - [x] 18.3 Write `tests/compat/neovim_compat.vader`: guard with `if !has('nvim') | finish | endif`; test `has_floating_windows()` returns true on Neovim 0.9+; test `normalize_display_mode()` accepts Neovim-specific modes; test Lua bridge functions are callable from VimScript
  - _Requirements: 2.3, 2.6, 2.7, 2.8, 20.3, 20.4_

- [x] 19. Write Lua unit tests — async module
  - Write `tests/lua/unit/async_spec.lua`: test `genero_tools.async.parse_output` returns `{success=true}` for exit code 0 with valid JSON; test returns `{success=false, error=...}` for exit code 1; test returns `{success=false}` for malformed JSON; test async job starts without blocking (use `vim.wait` with short timeout); test timeout handling produces error result
  - _Requirements: 13.1, 13.2, 13.3, 13.5_

- [x] 20. Write Lua unit tests — Telescope pickers
  - Write `tests/lua/unit/telescope_spec.lua`: mock `telescope.nvim` require; test `genero_tools.telescope.file_functions` calls picker with correct entry list when buffer contains `sample_codebase/simple_functions.4gl` content (expect entries for `add_numbers`, `get_user_name`, `no_params_no_return`, `display_message`); test `module_functions` picker using `sample_codebase/customer.m3`; test `module_files` picker lists sibling files in `sample_codebase/`; test `diagnostics` picker uses quickfix list; test fallback message when telescope is not installed
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.7_

- [x] 21. Write Lua unit tests — nvim-cmp source
  - Write `tests/lua/unit/cmp_source_spec.lua`: test `genero_tools.cmp_source:complete` calls mock query and returns items with `label` and `detail` fields; test partial match filtering using function names from `sample_codebase/simple_functions.4gl`; test empty result when mock returns `[]`; test cmp source is registered correctly; test fallback when nvim-cmp is not installed
  - _Requirements: 5.2, 5.3, 5.4, 5.5, 5.6, 5.8_

- [x] 22. Write Lua unit tests — Lualine components
  - Write `tests/lua/unit/lualine_spec.lua`: open `sample_codebase/customer_main.4gl`, position cursor inside `customer_search_by_name`, test `genero_tools.lualine.breadcrumbs()` returns `"customer_search_by_name"`; test `genero_tools.lualine.diagnostics()` returns formatted error/warning counts after loading mock compiler output; test `genero_tools.lualine.svn_status()` returns non-empty string when mock SVN diff is set; test `genero_tools.lualine.cache_stats()` returns formatted stats string; test fallback when lualine is not installed
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.7_

- [x] 23. Write Lua unit tests — snippets
  - Write `tests/lua/unit/snippets_spec.lua`: test snippet expansion produces correct text for a known trigger; test placeholder positions are correct after expansion; test smart expansion populates parameters from a mock function signature matching patterns in `sample_codebase/multiline_params.4gl`; test custom snippet appears in snippet list; test LuaSnip integration registers snippets correctly
  - _Requirements: 7.1, 7.2, 7.3, 7.5, 7.8_

- [x] 24. Write Lua unit tests — UI helpers
  - Write `tests/lua/unit/ui_spec.lua`: test `genero_tools.ui.show_float` opens a floating window with correct content; test `genero_tools.ui.show_error` displays error in correct location; open `sample_codebase/whitespace_variations.4gl`, test virtual text hints appear on correct lines; test virtual text is cleared after `GeneroClearHints`
  - _Requirements: 3.3, 8.6, 8.7_

- [x] 25. Write Lua property tests — parser round-trip
  - Write `tests/lua/property/parser_props_spec.lua`: implement `generate_svn_diff(seed)` helper returning `{diff_string, expected}`; loop 100 iterations calling `vim.fn['genero_tools#svn#parser#parse_diff']` and asserting `added`/`deleted` match expected; implement `generate_compiler_line(seed)` and loop 100 iterations calling the VimScript parser via `vim.fn`, asserting field values match; tag each test: `Feature: new-test-suite, Property 1` and `Property 2`
  - _Requirements: 18.1, 18.2, 18.3, 18.4, 18.5, 18.8_

- [ ] 26. Checkpoint — run all Lua unit tests
  - Run `./tests/run_lua_tests.sh` and confirm all plenary unit tests pass on Neovim.

- [x] 27. Write Lua integration tests — compiler quickfix and signs end-to-end
  - Write `tests/lua/integration/compiler_integration_spec.lua`: set `MOCK_FGLCOMP_OUTPUT` to content of `tests/fixtures/compiler_output/errors_v310.txt`, open `sample_codebase/simple_functions.4gl`, invoke `GeneroCompile`, assert quickfix list has correct entries with correct filenames and line numbers; assert sign column shows error markers on correct lines; test warning markers from `warnings_v310.txt`; test error navigation commands (`cnext`, `cprev`); test sign column cleared after `GeneroClearErrors`; test `.per` file triggers `fglform` mock
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.10_

- [x] 28. Write Lua integration tests — SVN signs end-to-end
  - Write `tests/lua/integration/svn_integration_spec.lua`: set `MOCK_SVN_OUTPUT` to content of `tests/fixtures/svn_diff/added_lines.diff`, open `sample_codebase/simple_functions.4gl`, trigger SVN refresh, assert added-line signs appear on correct lines; repeat for deleted and modified fixtures; test unified sign column with both compiler errors and SVN markers active simultaneously
  - _Requirements: 9.1, 9.2, 9.3, 9.5, 9.8, 17.1, 17.2_

- [x] 29. Write Lua integration tests — Telescope end-to-end
  - Write `tests/lua/integration/telescope_integration_spec.lua`: with mock query returning known function list from `sample_codebase/customer_main.4gl`, invoke `GeneroFileFunctions`, assert picker entries match mock data; invoke `GeneroDiagnostics` after populating quickfix with mock compiler output, assert picker entries match quickfix; test item selection navigates cursor to correct line in `sample_codebase/simple_functions.4gl`
  - _Requirements: 6.1, 6.4, 6.5, 6.6_

- [x] 30. Write Lua integration tests — debug streaming
  - Write `tests/lua/integration/debug_stream_spec.lua`: invoke `GeneroDebugStreamToggle`, assert a new window/buffer is opened; write lines to the debug log file, assert they appear in the debug buffer; invoke `GeneroDebugStreamClear`, assert buffer is empty; invoke `GeneroDebugStreamSelect` with a mock file path, assert buffer switches to new file; test error when log file does not exist
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6_

- [x] 31. Write Lua integration tests — nvim-cmp end-to-end
  - Write `tests/lua/integration/nvim_cmp_integration_spec.lua`: register the cmp source, trigger completion in a buffer containing `sample_codebase/simple_functions.4gl` content, assert completion items include `add_numbers`, `get_user_name`, `display_message` from mock query output; test completion with partial text typed; test completion does not crash when mock returns error
  - _Requirements: 5.1, 5.5, 5.7_

- [x] 32. Write Lua integration tests — feature interactions
  - Write `tests/lua/integration/feature_interaction_spec.lua`: open `sample_codebase/customer_main.4gl`, enable autocompile and hints, trigger `BufWritePost`, assert both quickfix and hints update; test navigation still works when quickfix list is populated with errors; test `GeneroCacheStats` displays non-empty output after a navigation query; test snippets expand correctly when hints are enabled
  - _Requirements: 17.3, 17.6, 17.7, 12.8_

- [ ] 33. ~~Write CI/CD pipeline configuration~~
  - ~~Write `.github/workflows/tests.yml`~~; ~~Add `neovim-tests` job~~; ~~Add `coverage` job~~; ~~Add dependency caching~~
  - _Deprioritised: CI/CD adds overhead not needed at this stage. Tests are run manually. Can be added in a future iteration._

- [ ] 34. ~~Write coverage reporting scripts~~
  - ~~Write `tests/scripts/generate_coverage.sh`~~; ~~Write `tests/scripts/generate_lua_coverage.sh`~~; ~~Write `tests/scripts/check_coverage.sh`~~; ~~Write `tests/scripts/tap_to_junit.py`~~
  - _Deprioritised: coverage tooling is tied to CI. Manual test runs provide sufficient feedback at this stage._

- [x] 35. Write test documentation
  - Write `tests/README.md`: explain prerequisites (Neovim 0.9+, vader.vim, plenary.nvim); document how to run the full suite (`./tests/run_tests.sh`), Lua-only (`./tests/run_lua_tests.sh`), VimScript layer only (`./tests/run_vim_tests.sh`), and a single file (`--file <path>`); document mock environment variables and how to use them when writing new tests; document the `sample_codebase/` fixture mapping (reference `tests/fixtures/README.md`); document the six correctness properties and which test files implement them
  - _Requirements: 21.1, 21.2, 21.3, 21.7_

- [ ] 36. Final checkpoint — full suite green
  - Run `./tests/run_tests.sh` under Neovim and confirm all tests pass. Ask the user if questions arise.

---

## Notes

- Tasks marked with `*` are optional property tests — valuable but can be skipped for a faster MVP. Prioritise them over other optional work.
- Struck-through tasks (12, 15, 16, 17, 18.1/18.2, 33, 34) are deprioritised in favour of Neovim-focused Lua tests. The text is retained for future reference.
- **Fixture strategy**: `sample_codebase/` is the source of truth for `.4gl`/`.m3` test files. Do not create new sample source files — reference existing ones by path. Only compiler output and SVN diff fixtures are written fresh (tasks 3.2–3.9) since those are synthetic mock data, not source code.
- Mock env vars (`MOCK_FGLCOMP_OUTPUT`, `MOCK_SVN_OUTPUT`, etc.) are the primary mechanism for controlling test behaviour — always reset them in `after_each` / `After:` blocks via `TestTeardown()`.
- The six correctness properties map to specific tasks: Property 1 → 5.2, Property 2 → 6.2 and 25, Property 3 → 7.2, Property 4 → 7.3, Property 5 → 8.2, Property 6 → 5.4.
- Each property test must run a minimum of 100 iterations.
- VimScript layer tests (tasks 5–13) run under Neovim via vader.vim — they test the VimScript autoload functions that the Lua layer calls. They are not plain-Vim tests.
- The `tests/results/` directory should be gitignored.
