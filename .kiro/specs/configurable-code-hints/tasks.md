# Implementation Plan: Configurable Code Hints

## Overview

This implementation plan breaks down the Configurable Code Hints feature into discrete, manageable coding tasks organized into six phases. Each task builds incrementally on previous work, with property-based tests validating correctness properties throughout. The implementation follows the modular architecture defined in the design document, with clear separation between hint detection, configuration, display, and caching systems.

## Phase 1: Core Infrastructure

### Foundation for the Hint System

- [x] 1.1 Create hint engine core module
  - Create `autoload/genero_tools/hints.vim` with main orchestration functions
  - Implement `genero_tools#hints#init()` to initialize the hint system
  - Implement `genero_tools#hints#analyze(bufnr)` to analyze a buffer
  - Implement `genero_tools#hints#get_hints(bufnr)` to retrieve cached hints
  - Implement `genero_tools#hints#clear(bufnr)` to clear hints for a buffer
  - Set up detector registration system with `genero_tools#hints#register_detector()`
  - _Requirements: 1.1, 1.2, 20.1, 20.2_

- [x] 1.2 Create configuration system module
  - Create `autoload/genero_tools/hints/config.vim` for configuration management
  - Implement `genero_tools#hints#config#get_for_file(file_path)` to load effective config
  - Implement `genero_tools#hints#config#validate(config)` to validate settings
  - Implement `genero_tools#hints#config#load_per_file()` to load .genero-hints
  - Support configuration hierarchy: per-file > project-wide > defaults
  - _Requirements: 6.1, 6.5, 15.1, 16.1_

- [x]* 1.3 Write property tests for hint engine initialization
  - **Property 1: Hint Engine Initialization** - Engine initializes with defaults and user config
  - **Property 9: Configuration Loading** - Config is read from g:genero_tools_config
  - **Property 10: Configuration Validation** - Invalid config falls back to defaults
  - _Requirements: 1.1, 1.3, 1.4_

- [ ] 1.4 Create cache system module
  - Create `autoload/genero_tools/hints/cache.vim` for caching hint results
  - Implement `genero_tools#hints#cache#get(bufnr)` to retrieve cached hints
  - Implement `genero_tools#hints#cache#set(bufnr, hints)` to store hints
  - Implement `genero_tools#hints#cache#invalidate(bufnr)` to clear cache for file
  - Implement `genero_tools#hints#cache#clear()` to clear all cache
  - Use file hash and config hash as cache key components
  - _Requirements: 17.1, 17.2, 17.3, 17.4_

- [ ]* 1.5 Write property tests for cache system
  - **Property 55: Cache Storage** - Hints are cached with timestamp
  - **Property 56: Cache Hit** - Unchanged files use cached hints
  - **Property 57: Cache Invalidation** - File modification invalidates cache
  - **Property 58: Cache Eviction** - LRU eviction when cache exceeds limits
  - _Requirements: 17.1, 17.2, 17.3, 17.4_

- [x] 1.6 Create display system module
  - Create `autoload/genero_tools/hints/display.vim` for rendering hints
  - Implement `genero_tools#hints#display#show(bufnr, hints)` to display hints
  - Implement `genero_tools#hints#display#show_details(hint)` to show hint details
  - Implement `genero_tools#hints#display#refresh()` to update display
  - Define hint signs: GeneroHintInfo, GeneroHintWarning, GeneroHintStyle
  - Define highlight groups for each severity level
  - _Requirements: 7.1, 7.4, 8.5, 9.1, 9.2_

- [ ]* 1.7 Write property tests for display system
  - **Property 19: Display Mode Selection** - Display mode determines rendering method
  - **Property 20: Hint Positioning** - Hints display at correct line and column
  - **Property 23: Severity Assignment** - Severity level is assigned and respected
  - **Property 24: Severity Visual Distinction** - Visual indicators match severity
  - _Requirements: 7.1, 7.4, 8.1, 8.5_

- [ ] 1.8 Set up autocommands and initialization
  - Modify `plugin/genero_tools.vim` to initialize hint system on startup
  - Set up autocommands for BufRead, BufWrite, TextChanged, TextChangedI
  - Implement debouncing for real-time analysis with hints_delay
  - Register hint commands with existing command system
  - _Requirements: 1.1, 11.1, 11.2_

- [ ]* 1.9 Write unit tests for core infrastructure
  - Test hint engine initialization with various configurations
  - Test cache operations with multiple buffers
  - Test display system with different display modes
  - Test autocommand triggering and debouncing
  - _Requirements: 1.1, 1.2, 1.3_

- [ ] 1.10 Checkpoint - Verify core infrastructure
  - Ensure all core modules load without errors
  - Verify hint engine initializes on plugin startup
  - Verify configuration system loads defaults correctly
  - Verify cache system stores and retrieves hints
  - Ask the user if questions arise.

## Phase 2: Detection Modules

### Implement Hint Detection Checks

- [ ] 2.1 Implement whitespace & formatting detector
  - Create `autoload/genero_tools/hints/whitespace.vim`
  - Implement `genero_tools#hints#whitespace#detect(bufnr, config)` function
  - Detect trailing whitespace at end of lines
  - Detect mixed tabs and spaces in indentation
  - Detect inconsistent indentation levels
  - Detect multiple consecutive blank lines
  - Return list of hints with line, column, message, category, check, severity
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [ ]* 2.2 Write property test for whitespace detector
  - **Property 4: Whitespace Detection** - All whitespace issues detected correctly
  - **Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5**

- [ ] 2.3 Implement keyword & naming detector
  - Create `autoload/genero_tools/hints/keyword.vim`
  - Implement `genero_tools#hints#keyword#detect(bufnr, config)` function
  - Detect lowercase Genero keywords (IF, WHILE, FUNCTION, etc.)
  - Detect lowercase built-in functions (LENGTH, SUBSTR, etc.)
  - Detect inconsistent keyword casing within file
  - Detect variable naming convention violations
  - Support camelCase and snake_case naming conventions
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [ ]* 2.4 Write property test for keyword detector
  - **Property 5: Keyword Detection** - Keyword and naming issues detected
  - **Property 6: Naming Convention Detection** - Naming violations detected
  - **Validates: Requirements 3.1, 3.2, 3.3, 3.4**

- [ ] 2.5 Implement code structure detector
  - Create `autoload/genero_tools/hints/structure.vim`
  - Implement `genero_tools#hints#structure#detect(bufnr, config)` function
  - Detect unclosed blocks (missing END IF, END WHILE, etc.)
  - Detect excessive nesting depth beyond max_nesting_depth threshold
  - Detect lines exceeding max_line_length threshold
  - Detect complex functions lacking comments
  - Parse block structure to track nesting levels
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [ ]* 2.6 Write property test for structure detector
  - **Property 7: Code Structure Detection** - Structure issues detected
  - **Validates: Requirements 4.1, 4.2, 4.3, 4.4**

- [ ] 2.7 Implement Genero-specific detector
  - Create `autoload/genero_tools/hints/genero.vim`
  - Implement `genero_tools#hints#genero#detect(bufnr, config)` function
  - Detect missing error handling in database operations
  - Detect usage of deprecated Genero functions
  - Maintain list of deprecated functions
  - _Requirements: 5.1, 5.2_

- [ ]* 2.8 Write property test for Genero-specific detector
  - **Property 8: Genero-Specific Detection** - Genero issues detected
  - **Validates: Requirements 5.1, 5.2**

- [ ] 2.9 Create detector registration system
  - Implement detector registration in hint engine
  - Allow detectors to be registered without modifying core code
  - Coordinate execution of all registered detectors
  - Merge results from all detectors
  - Handle detector failures gracefully
  - _Requirements: 20.2, 20.3_

- [ ]* 2.10 Write unit tests for all detectors
  - Test each detector with various code samples
  - Test edge cases: empty files, single-line files, large files
  - Test detector failure handling
  - Test result merging from multiple detectors
  - _Requirements: 2.1, 3.1, 4.1, 5.1_

- [ ] 2.11 Checkpoint - Verify all detectors work
  - Ensure all detectors load and register correctly
  - Verify each detector produces correct hints
  - Verify detector failures don't break system
  - Verify results merge correctly
  - Ask the user if questions arise.

## Phase 3: User Interface

### Navigation, Display, and Help

- [ ] 3.1 Implement navigation commands
  - Create `autoload/genero_tools/hints/nav.vim`
  - Implement `genero_tools#hints#nav#next()` to jump to next hint
  - Implement `genero_tools#hints#nav#prev()` to jump to previous hint
  - Implement `genero_tools#hints#nav#list()` to list all hints
  - Implement `genero_tools#hints#nav#details()` to show hint details
  - Support wrap-around navigation
  - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_

- [ ]* 3.2 Write property tests for navigation
  - **Property 34: Next Hint Navigation** - Next command jumps correctly
  - **Property 35: Previous Hint Navigation** - Previous command jumps correctly
  - **Property 36: List Hints** - List command shows all hints
  - **Property 37: Hint Selection** - Selection jumps to hint
  - **Property 38: Navigation Wrap-Around** - Wrap-around works correctly
  - **Validates: Requirements 12.1, 12.2, 12.3, 12.4, 12.5**

- [ ] 3.3 Implement hint details display
  - Enhance display system to show detailed hint information
  - Show hint message, severity, category, line number
  - Show auto-fix suggestion if available
  - Show explanation of why hint was triggered
  - Use floating window (Neovim) or popup (Vim) for details
  - _Requirements: 13.2, 13.3, 13.4, 13.5_

- [ ]* 3.4 Write property tests for hint details
  - **Property 40: Hint Details Display** - Details shown correctly
  - **Property 41: Auto-Fix Suggestion Display** - Suggestions included
  - **Property 42: Hint Explanation** - Explanation provided
  - **Validates: Requirements 13.2, 13.3, 13.4, 13.5**

- [ ] 3.5 Implement sign column integration
  - Integrate with existing sign column system
  - Place hint signs alongside compiler error signs
  - Handle multiple signs on same line
  - Support unified sign column with compiler, SVN, and hint signs
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.6_

- [ ]* 3.6 Write property tests for sign column
  - **Property 25: Sign Column Integration** - Hints display in sign column
  - **Property 26: Multiple Signs on Same Line** - Multiple signs coexist
  - **Property 27: Unified Sign Column** - Unified column works
  - **Property 28: Sign Removal** - Signs removed when disabled
  - **Validates: Requirements 9.1, 9.2, 9.3, 9.4, 9.6**

- [ ] 3.7 Implement virtual text support (Neovim)
  - Add virtual text rendering for Neovim 0.3.2+
  - Display hint message at end of line
  - Use extmarks for virtual text placement
  - Fall back to signs in Vim
  - _Requirements: 7.2, 7.5, 18.2_

- [ ]* 3.8 Write property tests for virtual text
  - **Property 21: Display Fallback** - Virtual text falls back to signs in Vim
  - **Property 62: Neovim Features** - Neovim features used when available
  - **Validates: Requirements 7.2, 7.5, 18.2**

- [ ] 3.9 Create help system
  - Implement :GeneroHintHelp command
  - Implement :GeneroHintHelp [hint_name] for specific hints
  - Display hint documentation with examples
  - Link to relevant documentation from hint details
  - _Requirements: 22.1, 22.2, 22.3, 22.4_

- [ ]* 3.10 Write unit tests for UI components
  - Test navigation commands with various hint distributions
  - Test details display with different hint types
  - Test sign column integration
  - Test virtual text rendering (Neovim)
  - Test help system
  - _Requirements: 12.1, 13.2, 9.1, 7.2_

- [ ] 3.11 Checkpoint - Verify UI works
  - Ensure all navigation commands work correctly
  - Verify hint details display properly
  - Verify signs display in sign column
  - Verify virtual text displays in Neovim
  - Verify help system works
  - Ask the user if questions arise.

## Phase 4: Advanced Features

### Auto-fix, Real-time Analysis, and Configuration

- [ ] 4.1 Implement auto-fix system
  - Create `autoload/genero_tools/hints/autofix.vim`
  - Implement `genero_tools#hints#autofix#apply()` to apply fix at cursor
  - Implement `genero_tools#hints#autofix#suggest(hint)` to generate suggestion
  - Support auto-fixes: remove trailing whitespace, fix indentation, uppercase keywords
  - Re-analyze affected lines after applying fix
  - Update hint display after fix
  - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5, 14.6_

- [ ]* 4.2 Write property tests for auto-fix
  - **Property 43: Auto-Fix Generation** - Fixes generated for applicable hints
  - **Property 44: Auto-Fix Application** - Fixes applied correctly
  - **Property 45: Auto-Fix Re-Analysis** - Re-analysis after fix
  - **Property 46: Auto-Fix Enable** - Fixes provided when enabled
  - **Property 47: Auto-Fix Disable** - Fixes not provided when disabled
  - **Property 48: Auto-Fix Display Update** - Display updated after fix
  - **Validates: Requirements 14.1, 14.2, 14.3, 14.4, 14.5, 14.6**

- [ ] 4.3 Implement real-time analysis with debouncing
  - Set up debounced analysis on TextChanged and TextChangedI events
  - Use hints_delay configuration for debounce timing
  - Perform full analysis on BufWrite event
  - Analyze only affected line range for real-time
  - Update cache after analysis
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

- [ ]* 4.4 Write property tests for real-time analysis
  - **Property 30: Real-Time Analysis** - Analysis triggered with debounce
  - **Property 31: Save Analysis** - Full analysis on save
  - **Property 32: Real-Time Disable** - Only save analysis when disabled
  - **Property 33: Analysis Progress** - Progress indicator shown
  - **Validates: Requirements 11.1, 11.2, 11.3, 11.4, 11.5**

- [ ] 4.5 Implement background analysis
  - Analyze current file with priority
  - Analyze other open files when editor is idle
  - Reduce analysis frequency when system resources are low
  - _Requirements: 24.2, 24.3, 24.4_

- [ ]* 4.6 Write property tests for background analysis
  - **Property 71: File Prioritization** - Current file prioritized
  - **Property 72: Background Analysis** - Other files analyzed when idle
  - **Property 73: Resource Management** - Frequency reduced on low resources
  - **Validates: Requirements 24.2, 24.3, 24.4**

- [ ] 4.7 Implement per-file configuration support
  - Load .genero-hints file from project root
  - Parse JSON configuration with pattern-based rules
  - Apply per-file rules to matching files
  - Merge per-file config with project-wide config
  - Reload configuration on file save
  - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5_

- [ ]* 4.8 Write property tests for per-file configuration
  - **Property 13: Per-File Configuration Loading** - .genero-hints loaded
  - **Property 14: Configuration Merging** - Rules merged correctly
  - **Property 15: Configuration Fallback** - Invalid config falls back
  - **Property 16: Configuration Reload** - Config reloaded on save
  - **Validates: Requirements 15.1, 15.2, 15.3, 15.4, 15.5**

- [ ] 4.9 Implement configuration validation and reload
  - Validate all configuration options on load
  - Check option types and value ranges
  - Warn user about invalid configuration
  - Reload configuration when settings change
  - Apply changes to all open files
  - _Requirements: 6.5, 16.4, 16.5_

- [ ]* 4.10 Write property tests for configuration
  - **Property 11: Individual Check Control** - Disabled checks don't generate hints
  - **Property 12: Threshold Respect** - Thresholds used correctly
  - **Property 17: Configuration Application** - Changes applied to all files
  - **Property 18: New File Configuration** - New files get current config
  - **Validates: Requirements 6.2, 6.3, 6.4, 16.4, 16.5**

- [ ]* 4.11 Write unit tests for advanced features
  - Test auto-fix for each fix type
  - Test real-time analysis debouncing
  - Test background analysis prioritization
  - Test per-file configuration loading and merging
  - Test configuration validation
  - _Requirements: 14.1, 11.1, 24.2, 15.1, 6.5_

- [ ] 4.12 Checkpoint - Verify advanced features
  - Ensure auto-fix system works correctly
  - Verify real-time analysis with debouncing
  - Verify background analysis prioritizes current file
  - Verify per-file configuration loads and merges
  - Verify configuration validation works
  - Ask the user if questions arise.

## Phase 5: Integration & Polish

### Integration with Existing Systems

- [ ] 5.1 Integrate with existing sign column system
  - Ensure hints work with existing compiler error signs
  - Ensure hints work with existing SVN diff signs
  - Support unified sign column with all sign types
  - Handle sign column space allocation
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 23.1_

- [ ]* 5.2 Write property tests for sign column integration
  - **Property 65: Sign Column Coexistence** - Hints work with existing signs
  - **Validates: Requirements 23.1**

- [ ] 5.3 Integrate with existing configuration system
  - Add hint configuration options to g:genero_tools_config
  - Support configuration through .vimrc
  - Support configuration through :GeneroConfigShow
  - Ensure configuration changes apply to all files
  - _Requirements: 6.1, 16.1, 16.2, 16.4, 23.2_

- [ ]* 5.4 Write property tests for configuration integration
  - **Property 66: Config System Integration** - Hints work with config system
  - **Validates: Requirements 23.2**

- [ ] 5.5 Integrate with existing display system
  - Use existing display modes (signs, virtual text, both)
  - Use existing highlight groups where applicable
  - Support existing display configuration options
  - _Requirements: 7.1, 7.2, 7.3, 23.3_

- [ ]* 5.6 Write property tests for display integration
  - **Property 67: Display Mode Integration** - Hints work with display modes
  - **Validates: Requirements 23.3**

- [ ] 5.7 Integrate with existing error handling
  - Use existing error logging system
  - Use existing error handling patterns
  - Ensure errors don't interrupt editing
  - Log errors to debug stream
  - _Requirements: 21.1, 21.2, 21.4, 21.5, 23.4_

- [ ]* 5.8 Write property tests for error handling integration
  - **Property 52: Error Logging** - Errors logged and operation continues
  - **Property 53: Exception Handling** - Exceptions caught and skipped
  - **Property 54: Display Fallback** - Display failures fall back
  - **Property 68: Error Handling Integration** - Hints work with error system
  - **Validates: Requirements 21.1, 21.2, 21.4, 21.5, 23.4**

- [ ] 5.9 Implement Vim/Neovim compatibility layer
  - Detect editor capabilities (has('nvim'), has('popupwin'), etc.)
  - Use Neovim-specific features when available
  - Fall back to Vim-compatible methods
  - Test on both Vim 8.0+ and Neovim 0.3.2+
  - _Requirements: 18.1, 18.2, 18.3, 18.4, 18.5_

- [ ]* 5.10 Write property tests for compatibility
  - **Property 61: Vim Compatibility** - Vim uses compatible methods
  - **Property 62: Neovim Features** - Neovim uses specific features
  - **Property 63: Graceful Degradation** - Unavailable features degrade
  - **Validates: Requirements 18.1, 18.2, 18.3, 18.4, 18.5**

- [ ] 5.11 Add comprehensive documentation
  - Create user guide for hint system
  - Document all configuration options
  - Document all commands
  - Create examples for common use cases
  - Document auto-fix capabilities
  - _Requirements: 22.1, 22.2, 22.3, 22.4_

- [ ]* 5.12 Write unit tests for integration
  - Test hint system with compiler errors
  - Test hint system with SVN diff markers
  - Test hint system with existing configuration
  - Test hint system with existing display modes
  - Test hint system with existing error handling
  - _Requirements: 23.1, 23.2, 23.3, 23.4, 23.5_

- [ ] 5.13 Checkpoint - Verify integration
  - Ensure hints work with compiler errors
  - Ensure hints work with SVN diff markers
  - Ensure hints work with existing configuration
  - Ensure hints work with existing display modes
  - Ensure hints work with existing error handling
  - Ask the user if questions arise.

## Phase 6: Testing & Validation

### Comprehensive Testing and Quality Assurance

- [ ] 6.1 Create comprehensive unit tests
  - Test all public API functions
  - Test configuration loading and validation
  - Test each detector with various code samples
  - Test display system with different modes
  - Test navigation commands
  - Test auto-fix system
  - Test cache operations
  - Test error handling
  - _Requirements: 1.1, 2.1, 3.1, 4.1, 5.1, 6.1, 7.1, 8.1_

- [ ] 6.2 Create property-based tests for all 74 correctness properties
  - Property 1: Hint Engine Initialization
  - Property 2: File Registration
  - Property 3: Dependency Verification
  - Property 4: Whitespace Detection
  - Property 5: Keyword Detection
  - Property 6: Naming Convention Detection
  - Property 7: Code Structure Detection
  - Property 8: Genero-Specific Detection
  - Property 9: Configuration Loading
  - Property 10: Configuration Validation
  - Property 11: Individual Check Control
  - Property 12: Threshold Respect
  - Property 13: Per-File Configuration Loading
  - Property 14: Configuration Merging
  - Property 15: Configuration Fallback
  - Property 16: Configuration Reload
  - Property 17: Configuration Application
  - Property 18: New File Configuration
  - Property 19: Display Mode Selection
  - Property 20: Hint Positioning
  - Property 21: Display Fallback
  - Property 22: Display Update
  - Property 23: Severity Assignment
  - Property 24: Severity Visual Distinction
  - Property 25: Sign Column Integration
  - Property 26: Multiple Signs on Same Line
  - Property 27: Unified Sign Column
  - Property 28: Sign Removal
  - Property 29: Error vs Hint Visual Distinction
  - Property 30: Real-Time Analysis
  - Property 31: Save Analysis
  - Property 32: Real-Time Disable
  - Property 33: Analysis Progress
  - Property 34: Next Hint Navigation
  - Property 35: Previous Hint Navigation
  - Property 36: List Hints
  - Property 37: Hint Selection
  - Property 38: Navigation Wrap-Around
  - Property 39: Navigation Highlight
  - Property 40: Hint Details Display
  - Property 41: Auto-Fix Suggestion Display
  - Property 42: Hint Explanation
  - Property 43: Auto-Fix Generation
  - Property 44: Auto-Fix Application
  - Property 45: Auto-Fix Re-Analysis
  - Property 46: Auto-Fix Enable
  - Property 47: Auto-Fix Disable
  - Property 48: Auto-Fix Display Update
  - Property 49: Extensibility
  - Property 50: Efficient Processing
  - Property 51: Async Support
  - Property 52: Error Logging
  - Property 53: Exception Handling
  - Property 54: Display Fallback
  - Property 55: Cache Storage
  - Property 56: Cache Hit
  - Property 57: Cache Invalidation
  - Property 58: Cache Eviction
  - Property 59: Cache Clearing
  - Property 60: Cache Disable
  - Property 61: Vim Compatibility
  - Property 62: Neovim Features
  - Property 63: Graceful Degradation
  - Property 64: Configuration Options Support
  - Property 65: Sign Column Coexistence
  - Property 66: Config System Integration
  - Property 67: Display Mode Integration
  - Property 68: Error Handling Integration
  - Property 69: Error and Hint Coexistence
  - Property 70: Analysis Performance
  - Property 71: File Prioritization
  - Property 72: Background Analysis
  - Property 73: Resource Management
  - Property 74: Debouncing
  - _Requirements: All requirements validated through properties_

- [ ] 6.3 Create integration tests
  - Test hint system with compiler errors
  - Test hint system with SVN diff markers
  - Test hint system with existing configuration
  - Test hint system with existing display modes
  - Test hint system with existing error handling
  - Test multiple files with different configurations
  - Test configuration changes affecting all files
  - _Requirements: 23.1, 23.2, 23.3, 23.4, 23.5_

- [ ] 6.4 Performance testing and optimization
  - Measure analysis time for various file sizes
  - Verify analysis completes within hints_delay
  - Verify cache improves performance
  - Verify debouncing reduces analysis frequency
  - Optimize slow detectors
  - _Requirements: 24.1, 24.2, 24.3, 24.4, 24.5_

- [ ] 6.5 Edge case testing
  - Test with empty files
  - Test with very large files (10k+ lines)
  - Test with files containing only whitespace
  - Test with deeply nested code (10+ levels)
  - Test with invalid UTF-8 characters
  - Test with mixed line endings
  - Test with very long lines (1000+ characters)
  - _Requirements: All requirements_

- [ ] 6.6 Compatibility testing
  - Test on Vim 8.0+
  - Test on Neovim 0.3.2+
  - Test with different terminal emulators
  - Test with different color schemes
  - Test with different font sizes
  - _Requirements: 18.1, 18.2, 18.3, 18.4, 18.5_

- [ ] 6.7 Final checkpoint - All tests pass
  - Ensure all unit tests pass
  - Ensure all property-based tests pass (minimum 100 iterations each)
  - Ensure all integration tests pass
  - Ensure performance meets requirements
  - Ensure edge cases handled correctly
  - Ensure compatibility verified
  - Ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Property-based tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- Integration tests verify interaction with existing systems
- All code should follow existing plugin patterns and conventions
- All public functions should have documentation comments
- All error conditions should be handled gracefully
