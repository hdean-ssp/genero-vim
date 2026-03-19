# Implementation Plan: Vim Genero-Tools Plugin

## Overview

This implementation plan breaks down the vim genero-tools plugin into discrete coding tasks organized into logical phases. The plugin integrates with the genero-tools CLI to provide code navigation and lookup capabilities for Genero codebases. Implementation follows a bottom-up approach: core utilities first, then command execution, caching, display modes, and finally user-facing commands and keybindings.

## Task Organization

Tasks are organized by priority and logical dependencies:

1. **Foundation** (Tasks 1-5) - Core infrastructure
2. **Code Navigation** (Tasks 6-8) - Core lookup functionality
3. **User-Facing Commands** (Tasks 9-10) - Commands and keybindings
4. **Compiler Integration** (Tasks 11-15) - Compiler features and testing
5. **Validation & Testing** (Tasks 16-18) - Checkpoints and integration testing
6. **Future Enhancements** (Task 19) - SVN diff markers (future task)
7. **Enhancement Tasks** (Tasks 20-26) - UI/UX improvements and bug fixes (can be done in parallel or after core completion)

## Tasks

- [x] 1. Set up project structure and core configuration
  - Create plugin directory structure (plugin/, autoload/, autoload/genero_tools/, doc/)
  - Create main plugin entry point (plugin/genero_tools.vim)
  - Create autoload/genero_tools.vim with core module structure
  - Create autoload/genero_tools/config.vim for configuration management
  - Create autoload/genero_tools/command.vim for command execution
  - Create autoload/genero_tools/cache.vim for caching logic
  - Create autoload/genero_tools/display.vim for display modes
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 11.8_

- [x] 2. Implement configuration management system
  - [x] 2.1 Create configuration initialization function
    - Implement genero_tools#config#init() to load g:genero_tools_config with defaults
    - Set default values: genero_tools_path, cache_enabled, cache_ttl, cache_max_size, display_mode, keybindings_enabled, timeout (10000ms for large codebases), async_enabled, result_limit, pagination_size
    - _Requirements: 11.1, 11.3, 11.4, 11.5, 11.6, 11.7, 11.8, 11.9, 11.10, 11.11, 11.12_
  
  - [x] 2.2 Create configuration getter function
    - Implement genero_tools#config#get(key) to retrieve configuration values
    - Return default if key not set
    - _Requirements: 11.1_
  
  - [x] 2.3 Create GeneroConfigShow command
    - Implement command to display current configuration
    - Format output for readability
    - Include guidance for large codebase settings
    - _Requirements: 11.2_
  
  - [ ]* 2.4 Write property test for configuration consistency
    - **Property 13: Configuration Settings Are Applied**
    - **Validates: Requirement 11.1**

- [x] 3. Implement command execution engine
  - [x] 3.1 Create genero_tools#execute_command() function
    - Build command line from command name and arguments
    - Properly escape all arguments for shell execution
    - Execute genero-tools CLI with timeout support (10000ms default for large codebases)
    - Parse JSON output from genero-tools
    - Return result dictionary with success, data, error, timestamp keys
    - Implement progress feedback for long-running commands
    - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6, 15.7, 15.8, 15.9, 15.10, 16.1, 16.2, 16.3, 16.4, 16.5, 16.6_
  
  - [x] 3.2 Implement asynchronous command execution
    - Create genero_tools#execute_command_async() for non-blocking execution
    - Display progress indicator during execution
    - Handle command cancellation
    - Call callback with results when complete
    - _Requirements: 6.1.1, 6.1.2, 6.1.3, 6.1.4, 6.1.5_
  
  - [x] 3.3 Implement progress feedback system
    - Create genero_tools#progress#show() to display status
    - Update progress for long-running commands (>2 seconds)
    - Display elapsed time and estimated completion
    - _Requirements: 15.9_
  
  - [ ]* 3.4 Write property test for result structure consistency
    - **Property 1: Result Structure Consistency**
    - **Validates: Requirement 16.1**
  
  - [ ]* 3.5 Write property test for successful results
    - **Property 2: Successful Results Have Data**
    - **Validates: Requirements 16.2, 16.5**
  
  - [ ]* 3.6 Write property test for failed results
    - **Property 3: Failed Results Have Error Message**
    - **Validates: Requirements 16.3, 16.6**
  
  - [ ]* 3.7 Write property test for timeout behavior
    - **Property 11: Command Execution Respects Timeout**
    - **Validates: Requirement 15.2**
  
  - [ ]* 3.8 Write property test for argument escaping
    - **Property 12: Argument Escaping Preserves Semantics**
    - **Validates: Requirement 15.1**

- [x] 4. Implement caching system
  - [x] 4.1 Create cache data structure and initialization
    - Initialize g:genero_tools_cache as empty dictionary
    - Store cache entries with key, value, and timestamp
    - Implement LRU tracking for cache eviction
    - _Requirements: 6.1, 6.6, 6.7_
  
  - [x] 4.2 Implement genero_tools#cache_get() function
    - Check if cache is enabled in configuration
    - Retrieve cached result by key
    - Check if TTL has expired (current_time - stored_time > cache_ttl)
    - Return cached result if valid, empty dict if expired or not found
    - _Requirements: 6.2, 6.3_
  
  - [x] 4.3 Implement genero_tools#cache_set() function
    - Check if cache is enabled in configuration
    - Store value in cache with key and current timestamp
    - Check cache size against cache_max_size limit
    - Evict oldest entry (LRU) if limit exceeded
    - Return 0 on success, 1 on error
    - _Requirements: 6.1, 6.6_
  
  - [x] 4.4 Create GeneroClearCache command
    - Clear all cached results
    - Display confirmation message with cache statistics
    - _Requirements: 6.4_
  
  - [x] 4.5 Implement cache eviction function
    - Implement LRU eviction strategy
    - Track access times for all cache entries
    - Evict oldest entries when cache_max_size exceeded
    - _Requirements: 6.6, 6.7_
  
  - [ ]* 4.6 Write property test for cache hit/miss
    - **Property 8: Cache Returns Identical Results Within TTL**
    - **Validates: Requirement 6.2**
  
  - [ ]* 4.7 Write property test for cache expiration
    - **Property 9: Expired Cache Entries Are Not Returned**
    - **Validates: Requirement 6.3**
  
  - [ ]* 4.8 Write property test for LRU eviction
    - **Property 16: Cache Eviction Maintains Consistency**
    - **Validates: Requirement 6.6**

- [x] 5. Implement display modes
  - [x] 5.1 Create genero_tools#display_result() dispatcher function
    - Accept result dictionary and display_mode parameter
    - Route to appropriate display function based on mode
    - Handle errors by displaying error message
    - Check result size and enable pagination if needed
    - _Requirements: 7.1, 8.1, 9.1, 10.1, 10.3_
  
  - [x] 5.2 Implement quickfix display mode with pagination
    - Create genero_tools#display#quickfix() function
    - Populate quickfix list with results (paginated if needed)
    - Open quickfix window
    - Format results for quickfix display
    - Implement pagination navigation commands
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7_
  
  - [x] 5.3 Implement popup display mode (neovim)
    - Create genero_tools#display#popup() function
    - Detect if running in neovim
    - Create floating popup window with results
    - Fall back to echo mode if vim (not neovim)
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_
  
  - [x] 5.4 Implement split display mode with pagination
    - Create genero_tools#display#split() function
    - Create new split window
    - Populate split with formatted results (paginated if needed)
    - Implement pagination navigation commands
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_
  
  - [x] 5.5 Implement echo display mode
    - Create genero_tools#display#echo() function
    - Format results for command line display
    - Handle long output with truncation/pagination
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_
  
  - [x] 5.6 Implement pagination system
    - Create genero_tools#pagination#paginate() to split large result sets
    - Implement navigation commands for next/previous pages
    - Track current page and total pages
    - _Requirements: 7.3, 7.7, 9.5_
  
  - [ ]* 5.7 Write property test for buffer preservation
    - **Property 10: Display Operations Do Not Modify Buffer**
    - **Validates: Requirements 7.5, 8.4, 9.3, 10.4**

- [x] 6. Implement core lookup functions
  - [x] 6.1 Implement genero_tools#lookup_function()
    - Accept function_name and codebase_path parameters
    - Check cache for existing result
    - Execute genero-tools lookup command if not cached
    - Cache result if successful
    - Return result dictionary with function definition info
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 6.1, 6.2, 6.3_
  
  - [ ]* 6.2 Write property test for function lookup completeness
    - **Property 4: Function Lookup Returns Complete Information**
    - **Validates: Requirement 1.2**

- [x] 7. Implement module and file listing functions
  - [x] 7.1 Implement genero_tools#list_module_files()
    - Accept module_name and codebase_path parameters
    - Check cache for existing result
    - Execute genero-tools list-files command if not cached
    - Cache result if successful
    - Return result dictionary with list of file paths
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 6.1, 6.2, 6.3_
  
  - [ ]* 7.2 Write property test for module file listing
    - **Property 6: Module File List Returns Paths**
    - **Validates: Requirement 2.2**
  
  - [x] 7.3 Implement genero_tools#list_functions_in_file()
    - Accept file_path and codebase_path parameters
    - Check cache for existing result
    - Execute genero-tools list-functions command if not cached
    - Cache result if successful
    - Return result dictionary with list of functions (name, line, signature)
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 6.1, 6.2, 6.3_
  
  - [ ]* 7.4 Write property test for function list fields
    - **Property 5: Function List Contains Required Fields**
    - **Validates: Requirement 3.2**

- [x] 8. Implement metadata retrieval functions
  - [x] 8.1 Implement genero_tools#get_function_signature()
    - Accept function_name and codebase_path parameters
    - Check cache for existing result
    - Execute genero-tools signature command if not cached
    - Cache result if successful
    - Return result dictionary with function signature
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 6.1, 6.2, 6.3_
  
  - [x] 8.2 Implement genero_tools#get_file_metadata()
    - Accept file_path and codebase_path parameters
    - Check cache for existing result
    - Execute genero-tools metadata command if not cached
    - Cache result if successful
    - Return result dictionary with author, ticket_codes, created_date, modified_date
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 6.1, 6.2, 6.3_
  
  - [ ]* 8.3 Write property test for file metadata fields
    - **Property 7: File Metadata Contains All Fields**
    - **Validates: Requirement 5.2**

- [x] 9. Implement error handling
  - [x] 9.1 Create error message formatting functions
    - Create genero_tools#error#format_not_found() for missing resources
    - Create genero_tools#error#format_invalid_path() for invalid paths
    - Create genero_tools#error#format_timeout() for timeout errors with guidance
    - Create genero_tools#error#format_parse_error() for JSON parse errors
    - Create genero_tools#error#format_permission_denied() for access errors
    - Create genero_tools#error#format_result_too_large() for large result sets
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5, 13.6, 13.7, 15.10_
  
  - [x] 9.2 Integrate error handling into command execution
    - Update genero_tools#execute_command() to catch and format errors
    - Ensure all error paths return proper error messages
    - Provide guidance for large codebase scenarios
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5, 13.6, 13.7, 15.10_
  
  - [x] 9.3 Implement cache memory pressure handling
    - Detect when cache is consuming excessive memory
    - Automatically clear expired entries
    - Trigger LRU eviction if needed
    - _Requirements: 6.7_

- [x] 10. Implement vim/neovim compatibility layer
  - [x] 10.1 Create compatibility detection functions
    - Implement genero_tools#compat#is_neovim() to detect neovim
    - Implement genero_tools#compat#is_vim() to detect vim
    - _Requirements: 14.1_
  
  - [x] 10.2 Create display mode fallback logic
    - Update display functions to fall back to supported modes
    - Popup mode falls back to echo in vim
    - All modes supported in neovim
    - _Requirements: 14.2, 14.3, 14.4_
  
  - [x] 10.3 Verify command execution compatibility
    - Ensure genero_tools#execute_command() works identically in both editors
    - Test system() function behavior in both editors
    - _Requirements: 14.5_
  
  - [ ]* 10.4 Write property test for vim/neovim compatibility
    - **Property 14: Vim and Neovim Compatibility**
    - **Validates: Requirements 14.1, 14.5**

- [x] 11. Implement codebase path detection
  - [x] 11.1 Create codebase path detection function
    - Implement genero_tools#get_codebase_path() to detect project root
    - Search for genero project markers (genero.conf, .genero, etc.)
    - Fall back to current working directory
    - _Requirements: 1.5, 2.5, 3.5, 4.5, 5.5, 15.6_
  
  - [ ]* 11.2 Write property test for codebase path inclusion
    - **Property 15: Codebase Path Is Included in Commands**
    - **Validates: Requirements 1.5, 2.5, 3.5, 4.5, 5.5**

- [x] 12. Implement user-facing commands
  - [x] 12.1 Create GeneroLookup command
    - Accept optional function_name argument
    - Use word under cursor if no argument provided
    - Call genero_tools#lookup_function() with current codebase path
    - Display result using configured display mode
    - _Requirements: 1.1, 1.4_
  
  - [x] 12.2 Create GeneroListModuleFiles command
    - Accept optional module_name argument
    - Use current file's module if no argument provided
    - Call genero_tools#list_module_files() with current codebase path
    - Display result using configured display mode
    - _Requirements: 2.1, 2.4_
  
  - [x] 12.3 Create GeneroListFunctions command
    - Accept optional file_path argument
    - Use current file if no argument provided
    - Call genero_tools#list_functions_in_file() with current codebase path
    - Display result using configured display mode
    - _Requirements: 3.1, 3.4_
  
  - [x] 12.4 Create GeneroFunctionSignature command
    - Accept optional function_name argument
    - Use word under cursor if no argument provided
    - Call genero_tools#get_function_signature() with current codebase path
    - Display result using configured display mode
    - _Requirements: 4.1, 4.4_
  
  - [x] 12.5 Create GeneroFileMetadata command
    - Accept optional file_path argument
    - Use current file if no argument provided
    - Call genero_tools#get_file_metadata() with current codebase path
    - Display result using configured display mode
    - _Requirements: 5.1, 5.4_

- [x] 13. Implement keybindings
  - [x] 13.1 Create keybinding registration function
    - Implement genero_tools#keybindings#register() to set up default keybindings
    - Map <leader>gl to GeneroLookup with word under cursor
    - Map <leader>gf to GeneroListFunctions with current file
    - Map <leader>gs to GeneroFunctionSignature with word under cursor
    - Map <leader>gm to GeneroFileMetadata with current file
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_
  
  - [x] 13.2 Integrate keybinding registration into plugin initialization
    - Call genero_tools#keybindings#register() if keybindings_enabled is true
    - Skip registration if keybindings_enabled is false
    - _Requirements: 12.1, 12.6_

- [x] 14. Implement large codebase optimization guidance
  - [x] 14.1 Add result limit guidance messages
    - When result count reaches result_limit (1000), display message suggesting narrower search
    - Include examples of more specific search patterns
    - _Requirements: 17.1_
  
  - [x] 14.2 Add timeout recovery suggestions
    - When command times out, suggest using more specific search terms
    - Suggest filtering by module or file
    - Recommend increasing timeout for very large codebases
    - _Requirements: 17.2_
  
  - [x] 14.3 Add cache efficiency messaging
    - Display cache statistics in GeneroConfigShow
    - Show hit/miss ratio and memory usage
    - Suggest optimal cache_ttl and cache_max_size for large codebases
    - _Requirements: 17.5_
  
  - [x] 14.4 Add progress and performance feedback
    - Display elapsed time for commands taking >2 seconds
    - Show estimated completion time if available
    - Recommend async_enabled for large codebases
    - _Requirements: 17.4, 17.7_

- [x] 15. Implement compiler integration
  - [x] 15.1 Create compiler configuration system
    - Add compiler_enabled, compiler_command, compiler_source_dir to config
    - Add compiler_version config option (e.g., '3.10', '3.20', 'auto')
    - Add compiler_show_warnings, compiler_show_errors, compiler_highlight_unused, compiler_sign_column options
    - Implement genero_tools#compiler#init() to load compiler configuration
    - Implement genero_tools#compiler#detect_version() to auto-detect compiler version
    - Support version-specific parsing strategies
    - _Requirements: 18.1, 18.2, 18.3, 18.22_
  
  - [x] 15.2 Implement compiler command execution
    - Create genero_tools#compiler#execute() to run compiler command
    - Parse compiler output (errors, warnings, unused variables)
    - Support configurable source directory
    - Return structured result with error/warning/info entries
    - Route parsing to version-specific parser based on compiler_version
    - _Requirements: 18.4, 18.5, 18.6, 18.22_
  
  - [x] 15.3 Implement error/warning parsing
    - Create genero_tools#compiler#parse_output() dispatcher function
    - Implement version-specific parsers:
      - genero_tools#compiler#parse_v310() for fglcomp 3.10+ format
      - genero_tools#compiler#parse_v320() for fglcomp 3.20+ format (if different)
      - Support extensibility for future versions
    - Extract file path, line number, column, message, severity
    - Detect unused variable warnings
    - Handle format: filename:start_line:start_col:end_line:end_col:severity:(-code) message
    - _Requirements: 18.7, 18.8, 18.9, 18.22, 18.23_
  
  - [x] 15.4 Implement sign column indicators
    - Create genero_tools#compiler#signs#place() to add signs to sign column
    - Use different signs for errors (✕), warnings (⚠), and info (ℹ)
    - Update signs when compilation results change
    - Clear signs when errors are cleared
    - _Requirements: 18.10, 18.11_
  
  - [x] 15.5 Implement syntax error highlighting
    - Create genero_tools#compiler#highlight#apply() to highlight errors
    - Use vim highlight groups for errors and warnings
    - Support line-level and column-level highlighting
    - Clear highlights when errors are cleared
    - _Requirements: 18.12, 18.13_
  
  - [x] 15.6 Implement unused variable highlighting
    - Create genero_tools#compiler#highlight#unused_vars() to highlight unused variables
    - Parse compiler output for unused variable warnings
    - Apply distinct highlighting for unused variables
    - Support toggling unused variable highlighting
    - _Requirements: 18.14, 18.15_
  
  - [x] 15.7 Implement compiler commands
    - Create GeneroCompile command to compile file or project
    - Create GeneroClearErrors command to clear error markers
    - Create GeneroNextError command to jump to next error
    - Create GeneroPrevError command to jump to previous error
    - _Requirements: 18.16, 18.17, 18.18, 18.19_
  
  - [x] 15.8 Implement quickfix integration
    - Populate quickfix list with compiler errors/warnings
    - Support filtering by severity (errors only, warnings only, all)
    - Integrate with vim's quickfix navigation
    - _Requirements: 18.20, 18.21_
  
  - [x] 15.9 Implement autocompile on save
    - Create genero_tools#compiler#autocompile#enable() to enable autocompile
    - Create genero_tools#compiler#autocompile#disable() to disable autocompile
    - Create genero_tools#compiler#autocompile#status() to show status
    - Compile on BufWritePost with configurable delay
    - Update signs and highlighting on successful compilation
    - _Requirements: 18.24, 18.25, 18.26_
  
  - [ ]* 15.10 Write property tests for compiler integration
    - **Property 18: Compiler Output Parsing Preserves Semantics**
    - **Property 19: Error Markers Are Placed Correctly**
    - **Property 20: Unused Variable Detection Is Accurate**
    - **Validates: Requirements 18.7, 18.10, 18.14**

- [ ] 16. Checkpoint - Ensure compiler integration works
  - Verify compiler command execution works
  - Verify error/warning parsing is accurate
  - Verify sign column indicators display correctly
  - Verify syntax error highlighting works
  - Verify unused variable highlighting works
  - Verify quickfix integration works
  - Verify autocompile on save works
  - Verify all compiler commands are registered
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 17. Integration testing
  - [x] 17.1 Create integration test suite
    - Test end-to-end workflows for each command
    - Test with actual genero-tools CLI (if available)
    - Test vim command execution and display
    - Test with both vim and neovim
    - Test keybinding functionality
    - Test pagination with large result sets (1000+ results)
    - Test asynchronous command execution
    - Test cache behavior under sustained usage
    - Test timeout handling with slow genero-tools responses
    - Test compiler integration with actual compiler output
    - _Requirements: 1.1, 2.1, 3.1, 4.1, 5.1, 7.1, 8.1, 9.1, 10.1, 11.1, 12.1, 14.1, 6.1.1, 6.1.2, 18.1_
  
  - [ ]* 17.2 Write integration tests for command workflows
    - Test lookup command with various inputs
    - Test list commands with various inputs
    - Test metadata retrieval
    - Test error scenarios
    - Test large result set handling
    - Test compiler command with various source directories
    - _Requirements: 1.1, 2.1, 3.1, 4.1, 5.1, 18.4_
  
  - [ ]* 17.3 Write performance tests for large codebases
    - Test command execution time with large codebases
    - Test cache performance with many entries
    - Test pagination performance with large result sets
    - Verify timeout handling under load
    - Test compiler performance with large source directories
    - _Requirements: 15.2, 15.9, 6.1.1, 18.5_

- [x] 18. Final checkpoint - Ensure all tests pass
  - Verify all property-based tests pass
  - Verify all unit tests pass
  - Verify all integration tests pass
  - Ensure plugin loads without errors
  - Ensure all commands are registered and callable
  - Ensure all keybindings work correctly
  - Ensure all display modes work as expected
  - Ensure compiler integration works correctly
  - Ensure all tests pass, ask the user if questions arise.

- [x] 19. SVN Diff Markers Feature (Future Task)
  - **See:** `.kiro/specs/vim-genero-tools-plugin/svn-diff-markers.md`
  - Detect SVN working copies
  - Retrieve and parse SVN diff output
  - Display diff markers in sign column (added/modified/deleted)
  - Implement caching for performance
  - Create commands: `:GeneroSVNRefresh`, `:GeneroSVNToggle`, `:GeneroSVNStatus`
  - Integrate with existing compiler signs (no conflicts)
  - Support configuration options for customization
  - Handle errors gracefully (SVN not installed, auth failures, etc.)
  - _Requirements: 19.1, 19.2, 19.3, 19.4, 19.5, 19.6, 19.7, 19.8_

- [ ] 20. Add .per File Compilation Support
  - **Priority:** HIGH
  - **Objective:** Add support for Genero .per (form) files with automatic detection and compilation using `fglform` compiler
  - **Current State:** Plugin only supports .4gl/.m3/.m4 files with fglcomp compiler
  - **Target State:** .per files compile with fglform, errors display in sign column and quickfix, autocompile works
  - **See:** `.kiro/specs/vim-genero-tools-plugin/TASK_PER_FILE_SUPPORT.md` for full specification
  - **Implementation Plan:**
    - Phase 1: File detection (ftdetect/per.vim, ftplugin/per.vim)
    - Phase 2: Compiler detection (auto-select fglform for .per files)
    - Phase 3: Output parsing (handle fglform output format)
    - Phase 4: Integration (autocompile, signs, quickfix)
    - Phase 5: Testing & documentation
  - **Files to Create:**
    - `ftdetect/per.vim` - File type detection for .per files
    - `ftplugin/per.vim` - Filetype plugin for .per files
    - `autoload/genero_tools/compiler/per.vim` - Per-specific compiler logic
    - `autoload/genero_tools/compiler/per_parser.vim` - Per output parser
    - `test/test_per_compilation.vim` - Test cases for .per compilation
  - **Files to Modify:**
    - `autoload/genero_tools/compiler.vim` - Add file type detection
    - `autoload/genero_tools/compiler/execute.vim` - Select compiler based on file type
    - `autoload/genero_tools/config.vim` - Add fglform configuration options
    - `plugin/genero_tools.vim` - Register per filetype commands if needed
    - `README.md` - Document .per file support
  - **Configuration Options:**
    - `compiler_form_command`: fglform command path (default: 'fglform')
    - `compiler_form_args`: fglform compiler flags (default: ['-M', '-W', 'all'])
  - **Success Criteria:**
    - ✓ .per files are recognized and highlighted
    - ✓ `:GeneroCompile` works on .per files
    - ✓ Errors from `fglform` appear in sign column
    - ✓ Errors from `fglform` appear in quickfix list
    - ✓ Autocompile works for .per files
    - ✓ Mixed projects with .4gl and .per files work correctly
    - ✓ Configuration options are documented
    - ✓ Tests pass for all scenarios

## Enhancement Tasks (E1-E3)

**IMPORTANT: Enhancement tasks (21-27) can be implemented in parallel with core tasks OR after core completion. They are NOT blocking for the core plugin functionality.**

These tasks improve UI/UX, fix bugs, and add integrations discovered after core implementation. The recommended approach is:

**Option A (Parallel Development):** Implement enhancement tasks alongside core tasks for faster overall completion
- Pros: Faster time-to-feature, can address issues as they're discovered
- Cons: More context switching, requires careful coordination

**Option B (Sequential Development):** Complete core tasks (1-18) first, then enhancement tasks (21-27)
- Pros: Clear separation of concerns, easier to validate core functionality
- Cons: Longer time to address UI/UX issues

**Current Status:** Task 22 (E1.2) has been completed as a quick-win improvement. Tasks 16-18 (core validation) can proceed in parallel.

---- [x] 21. E1.1: Modernize Default Configuration
  - **Priority:** MEDIUM
  - **Status:** COMPLETE
  - **Objective:** Update default configuration to use modern, clean aesthetic with floating windows
  - **Files:** autoload/genero_tools/config.vim, autoload/genero_tools/display.vim, lua/genero_tools/ui.lua
  - **Implementation Steps:**
    - [x] Review current config defaults in autoload/genero_tools/config.vim
    - [x] Update autoload/genero_tools/display.vim to support floating windows
    - [x] Implement floating window UI with rounded borders, padding, title bar, and scrollable content
    - [x] Leverage existing lua/genero_tools/ui.lua floating window support
    - [x] Add config options for floating window customization:
      - [x] `floating_window_border`: 'rounded', 'solid', 'shadow', etc. (default: 'rounded')
      - [x] `floating_window_width`: fixed width (default: 80)
      - [x] `floating_window_height`: fixed height (default: 20)
      - [x] `floating_window_position`: 'center', 'top', 'bottom', 'cursor' (default: 'center')
      - [x] `floating_window_title`: custom title (default: 'Genero-Tools')
      - [x] `popup_auto_close_delay`: milliseconds (default: 5000)
    - [x] Update display.vim to use config values instead of hardcoded values
    - [x] Enhance lua/genero_tools/ui.lua to support all config options
  - **Testing:** Verify floating windows display correctly with various result sizes and customization options
  - **Completion:** See test/TASK_21_COMPLETE.md for implementation details
  - **Notes:** All customization options now fully implemented and integrated

- [x] 22. E1.2: Reduce Startup Noise
  - **Priority:** HIGH
  - **Objective:** Eliminate duplicate autocompile notifications and implement silent loading
  - **Current Issue:** Plugin echoes three times about autocompile on file load
  - **Files:** autoload/genero_tools/compiler/autocompile.vim, plugin/genero_tools.vim
  - **Implementation Steps:**
    - Review autoload/genero_tools/compiler/autocompile.vim for duplicate notifications
    - Identify and consolidate all autocompile notification calls
    - Update plugin/genero_tools.vim to consolidate initialization messages
    - Add configuration option: `startup_messages` ('silent', 'normal', 'verbose', default: 'silent')
    - Implement silent mode by default with optional verbose mode for debugging
    - Collect all startup events and display single consolidated message or use silent mode
  - **Testing:** Verify plugin loads silently without duplicate messages

- [x] 23. E2.1: Add Line/Text Error Highlighting
  - **Priority:** MEDIUM
  - **Status:** COMPLETE
  - **Objective:** Enhance error visualization by adding line and text highlighting in addition to signs
  - **Current State:** Only signs placed in sign column, no line highlighting
  - **Files:** autoload/genero_tools/compiler/highlight.vim
  - **Implementation Steps:**
    - [x] Review current highlight.vim implementation
    - [x] Add line-level highlighting for error lines (background color)
    - [x] Add text-level highlighting for specific error locations (column ranges)
    - [x] Support different highlight groups for errors vs warnings
    - [x] Implement clearing of highlights when errors are resolved
    - [x] Ensure highlights don't interfere with syntax highlighting
  - **Testing:** Verify error lines and text are highlighted correctly with various error types

- [x] 24. E2.2: Fix Sign Column Popping In/Out
  - **Priority:** MEDIUM
  - **Status:** COMPLETE
  - **Objective:** Prevent sign column from toggling visibility when errors appear/disappear
  - **Current Issue:** Sign column visibility toggles on/off with error presence, causing visual jitter
  - **Files:** autoload/genero_tools/compiler/signs.vim
  - **Implementation Steps:**
    - [x] Review autoload/genero_tools/compiler/signs.vim sign placement logic
    - [x] Implement persistent sign column by setting `signcolumn=yes` in buffer
    - [x] Ensure sign column remains visible even when no errors present
    - [x] Add configuration option: `compiler_sign_column_always_visible` (default: true)
    - [x] Test with various error scenarios to ensure column stability
  - **Testing:** Verify sign column remains stable when errors appear/disappear

- [x] 25. E2.3: Fix Statusline "no previous error" Bug
  - **Priority:** HIGH
  - **Status:** COMPLETE
  - **Objective:** Fix statusline displaying "no previous error" without user action
  - **Current Issue:** Statusline shows "no previous error" message unexpectedly
  - **Files:** autoload/genero_tools/compiler/quickfix.vim
  - **Implementation Steps:**
    - [x] Review autoload/genero_tools/compiler/quickfix.vim quickfix navigation logic
    - [x] Identify where "no previous error" message is triggered
    - [x] Ensure message only appears when user explicitly navigates (GeneroPrevError command)
    - [x] Verify quickfix list initialization doesn't trigger navigation messages
    - [x] Add guard conditions to prevent spurious error messages
  - **Testing:** Verify statusline remains clean until user navigates errors

- [x] 26. E3.1: Add which-key Integration
  - **Priority:** LOW
  - **Status:** COMPLETE
  - **Objective:** Integrate keybindings with which-key plugin for better keybinding discovery
  - **Files:** autoload/genero_tools/keybindings.vim, new: autoload/genero_tools/which_key.vim
  - **Implementation Steps:**
    - [x] Create new autoload/genero_tools/which_key.vim module
    - [x] Detect if which-key plugin is installed
    - [x] Register all genero-tools keybindings with which-key
    - [x] Organize keybindings into logical groups:
      - Lookup: GeneroLookup, GeneroFunctionSignature
      - Navigation: GeneroListFunctions, GeneroListModuleFiles, GeneroFileMetadata
      - Compiler: GeneroCompile, GeneroNextError, GeneroPrevError, GeneroClearErrors
      - Cache: GeneroClearCache
    - [x] Add descriptions for each keybinding
    - [x] Support custom keybinding prefixes
  - **Testing:** Verify which-key displays all genero-tools keybindings correctly

- [x] 27. E3.2: Document which-key Integration
  - **Priority:** LOW
  - **Status:** COMPLETE
  - **Objective:** Create documentation for which-key integration
  - **Files:** new: docs/KEYBINDINGS.md
  - **Implementation Steps:**
    - [x] Create docs/KEYBINDINGS.md with comprehensive keybinding documentation
    - [x] Document all default keybindings and their purposes
    - [x] Provide examples of customizing keybindings
    - [x] Explain which-key integration and how to use it
    - [x] Include troubleshooting section for keybinding issues
    - [x] Add examples of common keybinding customizations
  - **Testing:** Verify documentation is clear and complete

- [ ] 28. Debug File Streaming Feature
  - **Priority:** HIGH
  - **Objective:** Stream debug output from files in a 1/3 width split window for live debugging
  - **Current Issue:** Compiler has no proper debug, so developers output info to specific files in a debug directory
  - **Target State:** Users can open a split window that streams live changes from debug files while coding
  - **Files to Create:**
    - new: `autoload/genero_tools/debug_stream.vim` - Debug file streaming module
    - new: `autoload/genero_tools/debug_stream/` - Debug streaming submodule directory
    - new: `autoload/genero_tools/debug_stream/watcher.vim` - File watcher for changes
    - new: `autoload/genero_tools/debug_stream/ui.vim` - UI for debug window
  - **Implementation Steps:**
    1. Create configuration options:
       - `debug_stream_enabled`: true/false (default: false)
       - `debug_stream_directory`: path to debug directory (default: './debug')
       - `debug_stream_width`: percentage or fixed (default: 33% for 1/3 width)
       - `debug_stream_auto_scroll`: true/false (default: true)
       - `debug_stream_max_lines`: max lines to display (default: 1000)
       - `debug_stream_refresh_interval`: ms between checks (default: 500)
    
    2. Implement file watcher:
       - Create `genero_tools#debug_stream#watcher#start()` to begin watching directory
       - Implement file change detection using file modification time
       - Track currently selected debug file
       - Detect new files added to debug directory
       - Detect file deletions
    
    3. Implement file selector:
       - Create `genero_tools#debug_stream#select_file()` to show file picker
       - Display list of files in debug directory
       - Allow user to select which file to stream
       - Support filtering by file pattern
       - Remember last selected file
    
    4. Implement streaming display:
       - Create `genero_tools#debug_stream#ui#open()` to create split window
       - Set split to 1/3 width (configurable)
       - Display file name and status in window title
       - Show file content with auto-scroll to end
       - Implement line number display
       - Support syntax highlighting for debug output
    
    5. Implement content updates:
       - Create `genero_tools#debug_stream#update()` to refresh file content
       - Read file changes since last update
       - Append new lines to display buffer
       - Maintain max line limit (configurable)
       - Auto-scroll to end if enabled
       - Handle file deletions gracefully
    
    6. Implement keybindings and commands:
       - Create `:GeneroDebugStreamOpen` command to open debug stream
       - Create `:GeneroDebugStreamClose` command to close debug stream
       - Create `:GeneroDebugStreamSelect` command to select different file
       - Create `:GeneroDebugStreamClear` command to clear display
       - Create `:GeneroDebugStreamToggle` command to toggle on/off
       - Create `:GeneroDebugStreamStatus` command to show status
       - Add default keybinding (e.g., `<leader>gd` to toggle)
    
    7. Implement auto-refresh:
       - Use timer to periodically check for file changes
       - Update display when changes detected
       - Handle timer cleanup on window close
       - Support pause/resume functionality
    
    8. Implement error handling:
       - Handle missing debug directory gracefully
       - Handle file permission errors
       - Handle file encoding issues
       - Display appropriate error messages
       - Provide recovery options
  
  - **Testing:** 
    - Verify debug window opens with correct width
    - Verify file selection works
    - Verify content streams and updates in real-time
    - Verify auto-scroll works correctly
    - Verify max line limit is enforced
    - Verify window closes cleanly
    - Test with various file sizes and update frequencies
    - Test error scenarios (missing directory, permission denied, etc.)
  
  - **Related Code:**
    - `autoload/genero_tools/display.vim` - Display functions
    - `autoload/genero_tools/config.vim` - Configuration
    - `lua/genero_tools/ui.lua` - Lua UI layer (can be leveraged for advanced UI)

- [ ] 29. Keybinding Help Popup (Neovim Only)
  - **Priority:** MEDIUM
  - **Objective:** Display a configurable popup window showing available hotkeys and their descriptions
  - **Current Issue:** New users may not know what hotkeys are available or what they do
  - **Target State:** Popup window appears on buffer enter (configurable) showing all available keybindings with descriptions
  - **Neovim Only:** Uses floating windows and advanced UI features not available in Vim
  - **Files to Create:**
    - new: `autoload/genero_tools/help.vim` - Help system module
    - new: `autoload/genero_tools/help/` - Help submodule directory
    - new: `autoload/genero_tools/help/popup.vim` - Popup window management
    - new: `autoload/genero_tools/help/keybindings.vim` - Keybinding data and formatting
  - **Implementation Steps:**
    1. Create configuration options:
       - `help_popup_enabled`: true/false (default: true)
       - `help_popup_show_on_buffer_enter`: true/false (default: true)
       - `help_popup_show_on_startup`: true/false (default: false)
       - `help_popup_width`: percentage or fixed (default: 50%)
       - `help_popup_height`: percentage or fixed (default: 60%)
       - `help_popup_position`: 'center', 'top', 'bottom' (default: 'center')
       - `help_popup_border`: 'rounded', 'solid', 'shadow' (default: 'rounded')
       - `help_popup_auto_close_delay`: ms to auto-close (default: 0 = manual close)
       - `help_popup_show_categories`: true/false (default: true)
    
    2. Implement keybinding data structure:
       - Create `genero_tools#help#keybindings#get_all()` to return all keybindings
       - Organize keybindings by category:
         - Code Navigation: GeneroLookup, GeneroListFunctions, etc.
         - Compilation: GeneroCompile, GeneroNextError, etc.
         - Debug: GeneroDebugStreamOpen, GeneroDebugStreamSelect, etc.
         - Cache: GeneroClearCache
         - Configuration: GeneroConfigShow
       - Include descriptions for each keybinding
       - Support custom keybinding overrides
    
    3. Implement popup window creation:
       - Create `genero_tools#help#popup#open()` to create floating window
       - Use `nvim_open_win()` for Neovim floating window
       - Set window options (border, title, etc.)
       - Format keybinding data for display
       - Support scrolling for long content
    
    4. Implement keybinding formatting:
       - Create `genero_tools#help#keybindings#format()` to format for display
       - Show keybinding, command name, and description
       - Organize by category with headers
       - Use consistent formatting and alignment
       - Support syntax highlighting for readability
    
    5. Implement popup controls:
       - Create `genero_tools#help#popup#close()` to close popup
       - Implement keybindings within popup:
         - `q` or `Esc` to close
         - `j`/`k` or arrow keys to scroll
         - `g` to go to top
         - `G` to go to bottom
         - `/` to search within popup
       - Support mouse clicks to close
    
    6. Implement auto-show functionality:
       - Create `genero_tools#help#popup#show_on_buffer_enter()` for BufEnter event
       - Create `genero_tools#help#popup#show_on_startup()` for plugin initialization
       - Track if popup has been shown (don't spam user)
       - Support dismissal with "don't show again" option
    
    7. Implement commands and keybindings:
       - Create `:GeneroHelp` command to show help popup
       - Create `:GeneroHelpToggle` command to toggle popup
       - Create `:GeneroHelpClose` command to close popup
       - Add default keybinding (e.g., `<leader>gh` to show help)
    
    8. Implement search functionality:
       - Create `genero_tools#help#search#find()` to search keybindings
       - Support searching by keybinding, command name, or description
       - Highlight search results in popup
       - Support case-insensitive search
    
    9. Implement customization:
       - Allow users to customize keybinding descriptions
       - Support hiding specific categories
       - Support custom keybinding groups
       - Support exporting keybindings to file
  
  - **Testing:**
    - Verify popup opens with correct dimensions
    - Verify keybindings are displayed correctly
    - Verify popup closes on keybinding
    - Verify scrolling works
    - Verify search functionality works
    - Verify auto-show on buffer enter works
    - Verify auto-close delay works
    - Test with various window sizes
    - Test with many keybindings
    - Verify Neovim-only features work correctly
  
  - **Related Code:**
    - `autoload/genero_tools/keybindings.vim` - Keybinding setup
    - `lua/genero_tools/ui.lua` - Lua UI layer (can be leveraged)
    - `autoload/genero_tools/display.vim` - Display patterns
  
  - **Neovim Requirements:**
    - Requires Neovim 0.5+ for floating windows
    - Uses `nvim_open_win()` for window creation
    - Uses `nvim_buf_set_lines()` for content
    - Falls back gracefully if not in Neovim

- [ ] 30. E4.1: Lualine Integration for Error/Warning Counts
  - **Priority:** MEDIUM
  - **Objective:** Create custom lualine component for Neovim that displays error and warning counts with color-coded backgrounds
  - **Current State:** Error/warning counts only visible in quickfix list or sign column
  - **Target State:** Lualine statusline shows "E5 W3" with red and yellow backgrounds respectively
  - **Neovim Only:** Requires lualine plugin and Neovim-specific APIs
  - **Files to Create:**
    - new: `lua/genero_tools/lualine_component.lua` - Lualine component module
  - **Implementation Steps:**
    1. Create configuration options:
       - `lualine_enabled`: true/false (default: true)
       - `lualine_position`: 'left', 'right', 'center' (default: 'right')
       - `lualine_show_errors`: true/false (default: true)
       - `lualine_show_warnings`: true/false (default: true)
       - `lualine_show_info`: true/false (default: false)
       - `lualine_error_color`: hex color (default: '#ff0000')
       - `lualine_warning_color`: hex color (default: '#ffff00')
       - `lualine_info_color`: hex color (default: '#0000ff')
       - `lualine_format`: 'compact' (E5 W3), 'verbose' (Errors: 5, Warnings: 3) (default: 'compact')
    
    2. Implement error/warning counting:
       - Create `genero_tools#lualine#get_counts()` to count signs in current buffer
       - Parse sign column for GeneroError, GeneroWarning, GeneroInfo signs
       - Return counts as dictionary: {errors: N, warnings: N, info: N}
       - Cache counts to avoid repeated parsing
       - Update cache on compilation completion
    
    3. Implement lualine component:
       - Create `genero_tools#lualine#component()` function
       - Format counts based on `lualine_format` config
       - Return formatted string with color information
       - Handle case where no errors/warnings present
       - Support dynamic updates on buffer changes
    
    4. Implement color configuration:
       - Create highlight groups for lualine sections
       - Support customization via config
       - Use sensible defaults (red for errors, yellow for warnings, blue for info)
       - Integrate with lualine's color system
    
    5. Implement registration:
       - Create `genero_tools#lualine#register()` to register component with lualine
       - Detect if lualine is installed
       - Register component in appropriate section
       - Support custom section configuration
       - Handle registration failures gracefully
    
    6. Implement update mechanism:
       - Create autocommand to update counts on compilation
       - Update on BufEnter, BufWritePost (after autocompile)
       - Trigger lualine refresh after update
       - Handle buffer-specific counts
    
    7. Implement commands:
       - Create `:GeneroLualineToggle` command to toggle component
       - Create `:GeneroLualineStatus` command to show current counts
       - Create `:GeneroLualineRefresh` command to manually refresh
    
    8. Implement error handling:
       - Handle missing lualine plugin gracefully
       - Handle Vim (non-Neovim) gracefully
       - Handle invalid configuration options
       - Provide helpful error messages
  
  - **Testing:**
    - Verify component displays correctly in lualine
    - Verify counts update after compilation
    - Verify colors are applied correctly
    - Verify format options work (compact vs verbose)
    - Verify toggle command works
    - Verify graceful fallback if lualine not installed
    - Test with various error/warning counts
    - Test with no errors/warnings
    - Verify Neovim-only features work correctly
  
  - **Related Code:**
    - `autoload/genero_tools/compiler/signs.vim` - Sign placement
    - `autoload/genero_tools/compiler/autocompile.vim` - Compilation workflow
    - `lua/genero_tools/ui.lua` - Lua UI layer
    - `autoload/genero_tools/config.vim` - Configuration
  
  - **Neovim Requirements:**
    - Requires Neovim 0.5+ for Lua support
    - Requires lualine plugin (https://github.com/nvim-lualine/lualine.nvim)
    - Uses `nvim_buf_get_lines()` to read sign column
    - Uses lualine's component API for registration
    - Falls back gracefully if lualine not installed

- [ ] 31. E4.2: Table Definition Lookup on Hover
  - **Priority:** MEDIUM
  - **Objective:** Fetch and display table definitions when hovering over `LIKE table.*` or `LIKE table.column` patterns with a keybinding
  - **Current State:** No built-in way to quickly view table structure and column types
  - **Target State:** Users can press a keybinding while cursor is on a LIKE clause to see table columns and their types in a readable format
  - **Files to Create:**
    - new: `autoload/genero_tools/table_lookup.vim` - Table lookup module
    - new: `autoload/genero_tools/table_lookup/` - Table lookup submodule directory
    - new: `autoload/genero_tools/table_lookup/parser.vim` - LIKE clause parser
    - new: `autoload/genero_tools/table_lookup/display.vim` - Table definition display
  - **Implementation Steps:**
    1. Create configuration options:
       - `table_lookup_enabled`: true/false (default: true)
       - `table_lookup_keybinding`: keybinding (default: '<leader>gt')
       - `table_lookup_display_mode`: 'popup', 'split', 'quickfix', 'echo' (default: 'popup')
       - `table_lookup_show_constraints`: true/false (default: true)
       - `table_lookup_show_indexes`: true/false (default: true)
       - `table_lookup_cache_enabled`: true/false (default: true)
       - `table_lookup_cache_ttl`: seconds (default: 3600)
    
    2. Implement LIKE clause detection:
       - Create `genero_tools#table_lookup#detect_like_clause()` to find LIKE clause at cursor
       - Parse patterns: `LIKE table.*`, `LIKE table.column`, `LIKE schema.table.*`, `LIKE schema.table.column`
       - Extract table name and optional column name
       - Handle quoted identifiers (e.g., `LIKE "MyTable".*`)
       - Return table name, column name (if specified), and schema (if specified)
    
    3. Implement table definition fetching:
       - Create `genero_tools#table_lookup#fetch_table_definition()` to retrieve table structure
       - Use genero-tools CLI to fetch table metadata (columns, types, constraints, indexes)
       - Check cache first if enabled
       - Cache results with configurable TTL
       - Handle errors gracefully (table not found, permission denied, etc.)
       - Return structured data: {table_name, columns: [{name, type, nullable, default, constraints}], indexes, primary_key}
    
    4. Implement column filtering:
       - Create `genero_tools#table_lookup#filter_column()` to filter to specific column if requested
       - If user was on `LIKE table.column`, show only that column's details
       - If user was on `LIKE table.*`, show all columns
       - Highlight the requested column if filtering
    
    5. Implement readable display formatting:
       - Create `genero_tools#table_lookup#display#format_table()` to format table definition
       - Display table name and schema prominently
       - Show columns in a table format: Name | Type | Nullable | Default | Constraints
       - Use consistent spacing and alignment
       - Support syntax highlighting for readability
       - Include indexes and primary key information if enabled
       - Show constraints (UNIQUE, CHECK, FOREIGN KEY, etc.)
    
    6. Implement display modes:
       - Create `genero_tools#table_lookup#display#popup()` for floating window display (Neovim)
       - Create `genero_tools#table_lookup#display#split()` for split window display
       - Create `genero_tools#table_lookup#display#quickfix()` for quickfix list display
       - Create `genero_tools#table_lookup#display#echo()` for command line display
       - Route to appropriate display based on config
       - Fall back to echo if unsupported mode
    
    7. Implement keybinding:
       - Create `genero_tools#table_lookup#lookup()` main function
       - Detect LIKE clause at cursor position
       - Fetch table definition
       - Display in configured mode
       - Handle errors with user-friendly messages
       - Create `:GeneroTableLookup` command
       - Register keybinding from config (default: `<leader>gt`)
    
    8. Implement error handling:
       - Handle table not found (suggest similar table names)
       - Handle permission denied (suggest checking database access)
       - Handle invalid table name (show error message)
       - Handle cursor not on LIKE clause (show helpful message)
       - Handle genero-tools CLI errors gracefully
       - Provide recovery suggestions
    
    9. Implement caching:
       - Create `genero_tools#table_lookup#cache#get()` to retrieve cached table definition
       - Create `genero_tools#table_lookup#cache#set()` to store table definition
       - Implement TTL-based expiration
       - Create `:GeneroTableLookupClearCache` command to clear cache
       - Show cache statistics in status messages
    
    10. Implement integration with genero-tools:
        - Use existing genero-tools CLI commands to fetch table metadata
        - Leverage existing caching infrastructure if available
        - Integrate with existing error handling patterns
        - Use existing display functions where applicable
  
  - **Testing:**
    - Verify LIKE clause detection works for various patterns
    - Verify table definition fetching works correctly
    - Verify column filtering works when specified
    - Verify display formatting is readable and well-organized
    - Verify all display modes work correctly
    - Verify keybinding triggers lookup correctly
    - Verify caching works and respects TTL
    - Verify error handling for missing tables
    - Verify error handling for cursor not on LIKE clause
    - Test with various table structures (many columns, constraints, indexes)
    - Test with schema-qualified table names
    - Test with quoted identifiers
  
  - **Related Code:**
    - `autoload/genero_tools/display.vim` - Display patterns
    - `autoload/genero_tools/cache.vim` - Caching infrastructure
    - `autoload/genero_tools/command.vim` - Command execution
    - `autoload/genero_tools/keybindings.vim` - Keybinding setup
    - `lua/genero_tools/ui.lua` - Lua UI layer (for popup display)
  
  - **User Workflow:**
    1. User is editing a .4gl file with a LIKE clause: `DEFINE rec LIKE customers.*`
    2. User positions cursor on the LIKE clause
    3. User presses `<leader>gt` (or configured keybinding)
    4. Plugin detects `customers` table and fetches its definition
    5. Popup/split/quickfix displays table structure:
       ```
       Table: customers
       
       Column Name    | Type      | Nullable | Default | Constraints
       ─────────────────────────────────────────────────────────────
       id             | INTEGER   | NO       | -       | PRIMARY KEY
       name           | VARCHAR   | NO       | -       | -
       email          | VARCHAR   | YES      | NULL    | UNIQUE
       created_at     | DATETIME  | NO       | NOW()   | -
       ```
    6. User can close popup and continue editing with full knowledge of table structure

## Notes

- Tasks 1-15 represent core plugin functionality and compiler integration (COMPLETE)
- Tasks 16-18 represent validation and testing checkpoints (COMPLETE)
- Task 19 represents SVN diff markers feature (COMPLETE)
- Task 20 represents .per file support (HIGH priority, NOT STARTED)
- Tasks 21-27 represent enhancement tasks (E1-E3) for UI/UX improvements and bug fixes:
  - Task 21 (E1.1): MOSTLY COMPLETE - floating window support implemented, customization review needed
  - Task 22 (E1.2): COMPLETE - startup noise eliminated
  - Task 23 (E2.1): COMPLETE - line/text error highlighting implemented
  - Task 24 (E2.2): COMPLETE - sign column stability fixed
  - Task 25 (E2.3): COMPLETE - statusline bug fixed
  - Task 26 (E3.1): COMPLETE - which-key integration implemented
  - Task 27 (E3.2): COMPLETE - which-key documentation complete
- Task 28 represents Debug File Streaming feature (HIGH priority, NOT STARTED)
- Task 29 represents Keybinding Help Popup feature (MEDIUM priority, NOT STARTED)
- Task 30 represents Lualine Integration feature (MEDIUM priority, NOT STARTED)
- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Property tests validate universal correctness properties across all valid inputs
- Unit tests validate specific examples and edge cases
- Checkpoints ensure incremental validation of core functionality
- Implementation uses VimScript for all plugin code
- Plugin must support both vim and neovim with appropriate fallbacks
- All core functions must be implemented before user-facing commands
- **Large Codebase Considerations:**
  - Default timeout set to 10000ms (10 seconds) to handle large codebases
  - Pagination enabled by default with 50 results per page
  - Cache size limited to 100 entries with LRU eviction
  - Asynchronous execution recommended for large codebases
  - Progress feedback essential for commands taking >2 seconds
  - Result limiting prevents overwhelming vim with thousands of results
- **Compiler Integration Considerations:**
  - Compiler command is configurable and can be any build tool (fglc, make, etc.)
  - Source directory is configurable to support different project layouts
  - Sign column indicators provide visual feedback without disrupting editing
  - Unused variable highlighting helps identify dead code
  - Syntax error highlighting integrates with vim's native highlighting system
- **Enhancement Tasks (E1-E4) - Status Summary:**
  - E1: UI/UX improvements (modernize config, reduce startup noise) - MOSTLY COMPLETE
  - E2: Compiler integration bug fixes (error highlighting, sign column stability, statusline) - COMPLETE
  - E3: which-key integration for better keybinding discovery - COMPLETE
  - E4: Lualine integration for statusline error/warning counts - NOT STARTED
  - Enhancement tasks address issues discovered during core implementation
  - Recommended implementation order for remaining: Task 20 → Task 28 → Task 29 → Task 30
- **Debug File Streaming (Task 28):**
  - Provides live debugging capability for developers using file-based debug output
  - Streams changes from debug files in a 1/3 width split window
  - Supports file selection and auto-refresh
  - Complements compiler integration with practical debugging workflow
  - HIGH priority feature for improved developer experience
- **Keybinding Help Popup (Task 29):**
  - Provides obvious way to discover available hotkeys
  - Configurable popup window shows all keybindings with descriptions
  - Organized by category (Navigation, Compilation, Debug, etc.)
  - Neovim-only feature using floating windows
  - Auto-show on buffer enter (configurable)
  - Supports search and customization
  - MEDIUM priority feature for improved user onboarding
- **Lualine Integration (Task 30):**
  - Displays error and warning counts in statusline with color-coded backgrounds
  - Integrates with lualine plugin for Neovim
  - Shows "E5 W3" format with red and yellow backgrounds
  - Automatically updates after compilation
  - Neovim-only feature requiring lualine plugin
  - MEDIUM priority feature for improved error visibility

## Current Implementation Status

**COMPLETED (Tasks 1-19, 21-27):**
- Core plugin infrastructure and compiler integration
- SVN diff markers with unified sign column
- Error navigation and quickfix integration
- Tab key improvements and comment string fixes
- UI/UX enhancements (floating windows with full customization, startup noise reduction, error highlighting)
- which-key integration for keybinding discovery

**NOT STARTED (HIGH PRIORITY):**
- Task 20: .per file compilation support (HIGH priority)
- Task 28: Debug file streaming feature (HIGH priority)

**NOT STARTED (MEDIUM/LOW PRIORITY):**
- Task 29: Keybinding help popup (MEDIUM priority, Neovim-only)
- Task 30: Lualine integration (MEDIUM priority, Neovim-only)
- Task 31: Table Definition Lookup on Hover (MEDIUM priority)
