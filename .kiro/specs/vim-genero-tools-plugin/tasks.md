# Implementation Plan: Vim Genero-Tools Plugin

## Overview

This implementation plan breaks down the vim genero-tools plugin into discrete coding tasks organized into logical phases. The plugin integrates with the genero-tools CLI to provide code navigation and lookup capabilities for Genero codebases. Implementation follows a bottom-up approach: core utilities first, then command execution, caching, display modes, and finally user-facing commands and keybindings.

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

- [x] 11. Implement user-facing commands
  - [x] 11.1 Create GeneroLookup command
    - Accept optional function_name argument
    - Use word under cursor if no argument provided
    - Call genero_tools#lookup_function() with current codebase path
    - Display result using configured display mode
    - _Requirements: 1.1, 1.4_
  
  - [x] 11.2 Create GeneroListModuleFiles command
    - Accept optional module_name argument
    - Use current file's module if no argument provided
    - Call genero_tools#list_module_files() with current codebase path
    - Display result using configured display mode
    - _Requirements: 2.1, 2.4_
  
  - [x] 11.3 Create GeneroListFunctions command
    - Accept optional file_path argument
    - Use current file if no argument provided
    - Call genero_tools#list_functions_in_file() with current codebase path
    - Display result using configured display mode
    - _Requirements: 3.1, 3.4_
  
  - [x] 11.4 Create GeneroFunctionSignature command
    - Accept optional function_name argument
    - Use word under cursor if no argument provided
    - Call genero_tools#get_function_signature() with current codebase path
    - Display result using configured display mode
    - _Requirements: 4.1, 4.4_
  
  - [x] 11.5 Create GeneroFileMetadata command
    - Accept optional file_path argument
    - Use current file if no argument provided
    - Call genero_tools#get_file_metadata() with current codebase path
    - Display result using configured display mode
    - _Requirements: 5.1, 5.4_

- [x] 12. Implement keybindings
  - [x] 12.1 Create keybinding registration function
    - Implement genero_tools#keybindings#register() to set up default keybindings
    - Map <leader>gl to GeneroLookup with word under cursor
    - Map <leader>gf to GeneroListFunctions with current file
    - Map <leader>gs to GeneroFunctionSignature with word under cursor
    - Map <leader>gm to GeneroFileMetadata with current file
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_
  
  - [x] 12.2 Integrate keybinding registration into plugin initialization
    - Call genero_tools#keybindings#register() if keybindings_enabled is true
    - Skip registration if keybindings_enabled is false
    - _Requirements: 12.1, 12.6_

- [x] 13. Implement codebase path detection
  - [x] 13.1 Create codebase path detection function
    - Implement genero_tools#get_codebase_path() to detect project root
    - Search for genero project markers (genero.conf, .genero, etc.)
    - Fall back to current working directory
    - _Requirements: 1.5, 2.5, 3.5, 4.5, 5.5, 15.6_
  
  - [ ]* 13.2 Write property test for codebase path inclusion
    - **Property 15: Codebase Path Is Included in Commands**
    - **Validates: Requirements 1.5, 2.5, 3.5, 4.5, 5.5**

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

- [ ] 15. Implement compiler integration
  - [ ] 15.1 Create compiler configuration system
    - Add compiler_enabled, compiler_command, compiler_source_dir to config
    - Add compiler_show_warnings, compiler_show_errors, compiler_highlight_unused, compiler_sign_column options
    - Implement genero_tools#compiler#init() to load compiler configuration
    - _Requirements: 18.1, 18.2, 18.3_
  
  - [ ] 15.2 Implement compiler command execution
    - Create genero_tools#compiler#execute() to run compiler command
    - Parse compiler output (errors, warnings, unused variables)
    - Support configurable source directory
    - Return structured result with error/warning/info entries
    - _Requirements: 18.4, 18.5, 18.6_
  
  - [ ] 15.3 Implement error/warning parsing
    - Create genero_tools#compiler#parse_output() to extract errors and warnings
    - Support multiple compiler output formats
    - Extract file path, line number, column, message, severity
    - Detect unused variable warnings
    - _Requirements: 18.7, 18.8, 18.9_
  
  - [ ] 15.4 Implement sign column indicators
    - Create genero_tools#compiler#signs#place() to add signs to sign column
    - Use different signs for errors (✕), warnings (⚠), and info (ℹ)
    - Update signs when compilation results change
    - Clear signs when errors are cleared
    - _Requirements: 18.10, 18.11_
  
  - [ ] 15.5 Implement syntax error highlighting
    - Create genero_tools#compiler#highlight#apply() to highlight errors
    - Use vim highlight groups for errors and warnings
    - Support line-level and column-level highlighting
    - Clear highlights when errors are cleared
    - _Requirements: 18.12, 18.13_
  
  - [ ] 15.6 Implement unused variable highlighting
    - Create genero_tools#compiler#highlight#unused_vars() to highlight unused variables
    - Parse compiler output for unused variable warnings
    - Apply distinct highlighting for unused variables
    - Support toggling unused variable highlighting
    - _Requirements: 18.14, 18.15_
  
  - [ ] 15.7 Implement compiler commands
    - Create GeneroCompile command to compile file or project
    - Create GeneroClearErrors command to clear error markers
    - Create GeneroNextError command to jump to next error
    - Create GeneroPrevError command to jump to previous error
    - _Requirements: 18.16, 18.17, 18.18, 18.19_
  
  - [ ] 15.8 Implement quickfix integration
    - Populate quickfix list with compiler errors/warnings
    - Support filtering by severity (errors only, warnings only, all)
    - Integrate with vim's quickfix navigation
    - _Requirements: 18.20, 18.21_
  
  - [ ]* 15.9 Write property tests for compiler integration
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
  - Verify all compiler commands are registered
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 17. Integration testing
  - [ ] 16.1 Create integration test suite
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
  
  - [ ]* 16.2 Write integration tests for command workflows
    - Test lookup command with various inputs
    - Test list commands with various inputs
    - Test metadata retrieval
    - Test error scenarios
    - Test large result set handling
    - Test compiler command with various source directories
    - _Requirements: 1.1, 2.1, 3.1, 4.1, 5.1, 18.4_
  
  - [ ]* 16.3 Write performance tests for large codebases
    - Test command execution time with large codebases
    - Test cache performance with many entries
    - Test pagination performance with large result sets
    - Verify timeout handling under load
    - Test compiler performance with large source directories
    - _Requirements: 15.2, 15.9, 6.1.1, 18.5_

- [ ] 18. Final checkpoint - Ensure all tests pass
  - Verify all property-based tests pass
  - Verify all unit tests pass
  - Verify all integration tests pass
  - Ensure plugin loads without errors
  - Ensure all commands are registered and callable
  - Ensure all keybindings work correctly
  - Ensure all display modes work as expected
  - Ensure compiler integration works correctly
  - Ensure all tests pass, ask the user if questions arise.

## Notes

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
