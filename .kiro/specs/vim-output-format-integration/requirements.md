# Requirements Document: Vim Output Format Integration

## Introduction

This document specifies requirements for implementing refined output format flags from genero-tools into the vim-genero-tools plugin. The feature enables the plugin to use three optimized output formats (concise, hover, and completion) to provide better editor integration with improved performance and user experience.

The vim-genero-tools plugin currently displays function information using a generic format. This feature will integrate the three specialized output formats from genero-tools to optimize each plugin feature for its specific use case.

## Glossary

- **Vim_Plugin**: The vim-genero-tools plugin that provides code intelligence features in Vim/Neovim
- **Genero_Tools**: The genero-tools query system that provides function metadata
- **Output_Format**: A structured representation of query results optimized for specific use cases
- **Concise_Format**: Single-line function signatures (`--format=vim`) for tooltips and status bar
- **Hover_Format**: Multi-line format with file location and metrics (`--format=vim-hover`) for hover tooltips
- **Completion_Format**: Tab-separated format (`--format=vim-completion`) for autocomplete suggestions
- **Plugin_Feature**: A specific capability of the vim-genero-tools plugin (hover, autocomplete, hints, etc.)
- **Query_Command**: A shell command that retrieves metadata from genero-tools (e.g., `bash query.sh find-function`)
- **Function_Signature**: The complete declaration of a function including name, parameters, and return types
- **Hover_Information**: Detailed function information displayed when hovering over a function name
- **Autocomplete_Suggestion**: A function name suggestion in the editor's autocomplete menu
- **Code_Hint**: Inline information displayed while editing code
- **Status_Bar**: The editor's status line that displays current context information
- **Quickfix_List**: Vim's list of search results or errors that can be navigated
- **Format_Flag**: A command-line option that specifies the output format (e.g., `--format=vim`)
- **Filter_Flag**: A command-line option that customizes output (e.g., `--filter=functions-only`)
- **Performance_Target**: The maximum acceptable execution time for a query (<100ms)
- **Backward_Compatibility**: The ability to maintain existing functionality while adding new features

## Requirements

### Requirement 1: Hover Information Display with Hover Format

**User Story:** As a Vim user, I want to see detailed function information when hovering over function names, so that I can understand function signatures, file locations, and complexity metrics without leaving the editor.

#### Acceptance Criteria

1. WHEN the user hovers over a function name in the editor, THE Vim_Plugin SHALL query genero-tools using `--format=vim-hover`
2. THE Vim_Plugin SHALL parse the hover format output containing signature, file location, and complexity metrics
3. THE Vim_Plugin SHALL display the parsed information in a hover tooltip or floating window
4. THE hover tooltip SHALL show the function signature on the first line
5. THE hover tooltip SHALL show the file location (path and line number) on the second line
6. THE hover tooltip SHALL show complexity metrics (cyclomatic complexity and line count) on the third line
7. WHEN file location is unavailable, THE hover tooltip SHALL display "File: unknown"
8. WHEN complexity metrics are unavailable, THE hover tooltip SHALL display "Complexity: unknown, LOC: unknown"
9. WHEN the hover format query completes, THE Query_Command execution time SHALL be less than 100ms
10. THE hover information display SHALL be backward compatible with existing hover functionality

### Requirement 2: Autocomplete Suggestions with Completion Format

**User Story:** As a Vim user, I want autocomplete suggestions to show function signatures and metadata, so that I can quickly understand what each function does while typing.

#### Acceptance Criteria

1. WHEN the user triggers autocomplete in the editor, THE Vim_Plugin SHALL query genero-tools using `--format=vim-completion`
2. THE Vim_Plugin SHALL parse the tab-separated completion format output
3. THE Vim_Plugin SHALL extract the function name (column 1) as the completion word
4. THE Vim_Plugin SHALL extract the function signature (column 2) as the completion menu text
5. THE Vim_Plugin SHALL extract the file location and metrics (column 3) as the completion info
6. THE Vim_Plugin SHALL display the function name in the autocomplete menu
7. THE Vim_Plugin SHALL display the function signature next to each completion suggestion
8. WHEN the user selects a completion suggestion, THE Vim_Plugin SHALL insert the function name
9. WHEN the completion format query completes, THE Query_Command execution time SHALL be less than 100ms
10. THE autocomplete display SHALL be backward compatible with existing autocomplete functionality

### Requirement 3: Code Hints Display with Concise Format

**User Story:** As a Vim user, I want to see function signatures in code hints, so that I can quickly reference function parameters while editing.

#### Acceptance Criteria

1. WHEN the user requests code hints (e.g., via a key mapping), THE Vim_Plugin SHALL query genero-tools using `--format=vim`
2. THE Vim_Plugin SHALL parse the concise format output containing function signature
3. THE Vim_Plugin SHALL display the function signature in an inline hint or status message
4. THE concise format output SHALL be a single line containing function name, parameters, and return type
5. THE code hint display SHALL be compact and non-intrusive
6. WHEN the concise format query completes, THE Query_Command execution time SHALL be less than 100ms
7. THE code hint display SHALL be backward compatible with existing hint functionality
8. THE code hint display SHALL support multiple functions in search results

### Requirement 4: Function Signature Display in Status Bar with Concise Format

**User Story:** As a Vim user, I want to see the current function signature in the status bar, so that I can quickly reference the function I'm working in.

#### Acceptance Criteria

1. WHEN the user positions the cursor in a function, THE Vim_Plugin SHALL query genero-tools using `--format=vim`
2. THE Vim_Plugin SHALL parse the concise format output containing the function signature
3. THE Vim_Plugin SHALL display the function signature in the editor's status bar
4. THE status bar display SHALL show the complete function signature including parameters and return type
5. THE status bar display SHALL update when the user moves to a different function
6. WHEN the concise format query completes, THE Query_Command execution time SHALL be less than 100ms
7. THE status bar display SHALL be backward compatible with existing status bar functionality
8. THE status bar display SHALL handle functions with no parameters and no return types

### Requirement 5: Search Results Display with Hover Format

**User Story:** As a Vim user, I want search results to show detailed function information, so that I can quickly understand each search result without opening the file.

#### Acceptance Criteria

1. WHEN the user searches for functions, THE Vim_Plugin SHALL query genero-tools using `--format=vim-hover`
2. THE Vim_Plugin SHALL parse the hover format output for each search result
3. THE Vim_Plugin SHALL display search results in the quickfix list or search results window
4. EACH search result SHALL show the function signature
5. EACH search result SHALL show the file location (path and line number)
6. EACH search result SHALL show complexity metrics (cyclomatic complexity and line count)
7. WHEN the user selects a search result, THE Vim_Plugin SHALL navigate to the function definition
8. WHEN the hover format query completes, THE Query_Command execution time SHALL be less than 100ms
9. THE search results display SHALL be backward compatible with existing search functionality
10. THE search results display SHALL support multiple functions in results

### Requirement 6: Format Flag Implementation in Plugin

**User Story:** As a plugin developer, I want the plugin to use format flags when querying genero-tools, so that I can get optimized output for each use case.

#### Acceptance Criteria

1. WHEN the Vim_Plugin queries genero-tools, THE Plugin SHALL append the appropriate `--format` flag to the query command
2. FOR hover information display, THE Plugin SHALL use `--format=vim-hover`
3. FOR autocomplete suggestions, THE Plugin SHALL use `--format=vim-completion`
4. FOR code hints and status bar, THE Plugin SHALL use `--format=vim`
5. FOR search results display, THE Plugin SHALL use `--format=vim-hover`
6. THE format flag implementation SHALL be consistent across all plugin features
7. THE format flag implementation SHALL not break existing query commands
8. THE format flag implementation SHALL be documented in the plugin code

### Requirement 7: Minimal Output Processing for Display

**User Story:** As a plugin developer, I want to display formatted output directly from genero-tools with minimal processing, so that the plugin can efficiently show function information without unnecessary parsing.

#### Acceptance Criteria

1. WHEN the Vim_Plugin receives concise format output, THE Plugin SHALL display it directly as a single-line signature
2. WHEN the Vim_Plugin receives hover format output, THE Plugin SHALL split lines and display directly in floating window/preview
3. WHEN the Vim_Plugin receives completion format output, THE Plugin SHALL split tabs and pass to Vim's completion API
4. THE output processing SHALL be minimal—only splitting lines/tabs as needed for display
5. THE output processing SHALL handle empty results gracefully
6. THE output processing SHALL preserve all formatting from genero-tools
7. THE output processing SHALL be fast and efficient
8. THE output processing SHALL be testable and maintainable

### Requirement 8: Performance Optimization for Plugin Features

**User Story:** As a Vim user, I want plugin features to respond quickly, so that I can work efficiently without waiting for queries to complete.

#### Acceptance Criteria

1. WHEN a hover query is executed, THE Query_Command execution time SHALL be less than 100ms
2. WHEN an autocomplete query is executed, THE Query_Command execution time SHALL be less than 100ms
3. WHEN a code hint query is executed, THE Query_Command execution time SHALL be less than 100ms
4. WHEN a status bar query is executed, THE Query_Command execution time SHALL be less than 100ms
5. WHEN a search query is executed, THE Query_Command execution time SHALL be less than 100ms
6. THE Plugin SHALL use concise format for faster queries when detailed information is not needed
7. THE Plugin SHALL cache query results to avoid repeated queries for the same function
8. THE Plugin SHALL not block the editor while queries are executing

### Requirement 9: Error Handling for Format Integration

**User Story:** As a Vim user, I want the plugin to handle errors gracefully, so that I can continue working even if a query fails.

#### Acceptance Criteria

1. WHEN a query fails, THE Plugin SHALL display a user-friendly error message
2. WHEN a format is not recognized, THE Plugin SHALL fall back to default behavior
3. WHEN output parsing fails, THE Plugin SHALL display a diagnostic message
4. WHEN the database is not found, THE Plugin SHALL suggest creating the database
5. WHEN no results are found, THE Plugin SHALL display "No results found" instead of an error
6. THE error handling SHALL not crash the plugin or editor
7. THE error handling SHALL allow the user to continue working
8. THE error messages SHALL be helpful and actionable

### Requirement 10: Backward Compatibility with Existing Plugin Features

**User Story:** As a plugin user, I want existing plugin features to continue working, so that I don't need to update my configuration or scripts.

#### Acceptance Criteria

1. WHEN the plugin is updated with format flag support, THE existing hover functionality SHALL continue to work
2. WHEN the plugin is updated with format flag support, THE existing autocomplete functionality SHALL continue to work
3. WHEN the plugin is updated with format flag support, THE existing code hints SHALL continue to work
4. WHEN the plugin is updated with format flag support, THE existing status bar display SHALL continue to work
5. WHEN the plugin is updated with format flag support, THE existing search functionality SHALL continue to work
6. ALL existing plugin configuration options SHALL continue to work
7. ALL existing plugin key mappings SHALL continue to work
8. THE plugin update SHALL not require changes to user configuration files
9. THE plugin update SHALL not break existing scripts or integrations
10. THE plugin update SHALL be fully backward compatible with previous versions

### Requirement 11: Documentation of Format Integration

**User Story:** As a plugin developer, I want clear documentation of format integration, so that I can understand how the plugin uses each format and how to extend it.

#### Acceptance Criteria

1. THE documentation SHALL explain which format each plugin feature uses and why
2. THE documentation SHALL show how each format is parsed and displayed
3. THE documentation SHALL include code examples for each format
4. THE documentation SHALL document the performance expectations for each use case
5. THE documentation SHALL document error handling for each scenario
6. THE documentation SHALL include troubleshooting tips for common issues
7. THE documentation SHALL be written in Markdown and included in the plugin docs
8. THE documentation SHALL be clear and accessible to plugin developers

### Requirement 12: Testing of Format Integration

**User Story:** As a developer, I want comprehensive tests for format integration, so that I can verify correctness and prevent regressions.

#### Acceptance Criteria

1. WHEN concise format tests are executed, THE tests SHALL verify correct parsing of single-line signatures
2. WHEN hover format tests are executed, THE tests SHALL verify correct parsing of three-line format
3. WHEN completion format tests are executed, THE tests SHALL verify correct parsing of tab-separated columns
4. WHEN format flag tests are executed, THE tests SHALL verify correct flag usage for each feature
5. WHEN error handling tests are executed, THE tests SHALL verify graceful error handling
6. WHEN backward compatibility tests are executed, THE tests SHALL verify existing functionality is unchanged
7. WHEN performance tests are executed, THE tests SHALL verify query execution time is <100ms
8. THE test suite SHALL achieve >90% code coverage for format integration logic
9. THE tests SHALL be automated and run on every code change
10. THE tests SHALL include both unit tests and integration tests

## Acceptance Criteria Analysis

### Testability Assessment

**Requirement 1 (Hover Display):** Testable as property
- Property: Hover format output SHALL be parsed and displayed correctly
- Example: Three-line format with signature, file, metrics
- Edge case: Missing metadata, unknown values

**Requirement 2 (Autocomplete):** Testable as property
- Property: Completion format output SHALL be parsed into completion items
- Example: Tab-separated columns with word, menu, info
- Edge case: Missing columns, special characters

**Requirement 3 (Code Hints):** Testable as property
- Property: Concise format output SHALL be parsed as single-line signature
- Example: `function_name(params) -> return_type`
- Edge case: No parameters, no return type

**Requirement 4 (Status Bar):** Testable as property
- Property: Concise format output SHALL be displayed in status bar
- Example: Function signature updates when cursor moves
- Edge case: Long signatures, special characters

**Requirement 5 (Search Results):** Testable as property
- Property: Hover format output SHALL be displayed in search results
- Example: Multiple results with signature, file, metrics
- Edge case: No results, missing metadata

**Requirement 6 (Format Flags):** Testable as property
- Property: Correct format flag SHALL be used for each feature
- Example: `--format=vim-hover` for hover, `--format=vim` for hints
- Edge case: Invalid format, missing flag

**Requirement 7 (Output Parsing):** Testable as property
- Property: Each format SHALL be parsed correctly
- Example: Concise, hover, completion formats
- Edge case: Malformed output, missing fields

**Requirement 8 (Performance):** Testable as property
- Property: Query execution time SHALL be <100ms
- Example: Measure execution time for each query
- Edge case: Large codebases, slow systems

**Requirement 9 (Error Handling):** Testable as property
- Property: Errors SHALL be handled gracefully
- Example: Invalid format, missing database
- Edge case: Unexpected errors, edge cases

**Requirement 10 (Backward Compatibility):** Testable as property
- Property: Existing functionality SHALL continue to work
- Example: Hover, autocomplete, hints work as before
- Edge case: Old configuration, deprecated features

**Requirement 11 (Documentation):** Testable as example
- Example: Documentation includes all format examples
- Edge case: Complex types, edge cases documented

**Requirement 12 (Testing):** Testable as property
- Property: Test suite SHALL achieve >90% coverage
- Example: All formats tested, all features tested
- Edge case: Error conditions, edge cases

## Common Acceptance Criteria Patterns

### Round Trip Properties

For each output format, verify that parsing and re-formatting produces equivalent results:
- Concise format: Parse signature → extract components → reconstruct signature
- Hover format: Parse three lines → extract fields → reconstruct format
- Completion format: Parse tab-separated → extract columns → reconstruct format

### Invariants

Properties that remain constant despite changes:
- Function name SHALL be preserved through parsing
- Parameter types SHALL be preserved through parsing
- Return types SHALL be preserved through parsing
- File location SHALL be preserved through parsing
- Complexity metrics SHALL be preserved through parsing

### Metamorphic Properties

Relationships that must hold between different formats:
- Concise format signature SHALL match first line of hover format
- Completion format word (column 1) SHALL match function name in concise format
- Completion format menu (column 2) SHALL match concise format signature

### Error Conditions

Generate bad inputs and ensure proper error handling:
- Invalid format flag → error message
- Malformed output → graceful fallback
- Missing database → helpful suggestion
- No results → empty result set (not error)

## Implementation Considerations

### Plugin Features to Update

1. **Hover Information Display** - Use `--format=vim-hover`
2. **Autocomplete Suggestions** - Use `--format=vim-completion`
3. **Code Hints Display** - Use `--format=vim`
4. **Function Signature in Status Bar** - Use `--format=vim`
5. **Search Results Display** - Use `--format=vim-hover`

### Output Parsing Strategy

- **Concise Format**: Split on newlines, extract single line
- **Hover Format**: Split on newlines, extract three lines (signature, file, metrics)
- **Completion Format**: Split on newlines, split each line on tabs, extract three columns

### Performance Optimization

- Use concise format for quick queries (hints, status bar)
- Use hover format for detailed information (hover, search results)
- Use completion format for autocomplete (native Vim format)
- Cache results to avoid repeated queries
- Use async queries to avoid blocking editor

### Error Handling Strategy

- Validate format flag before querying
- Validate output format before parsing
- Handle missing or unknown values gracefully
- Provide helpful error messages
- Fall back to default behavior on error

## Success Criteria

- ✅ Hover information displays with file location and metrics
- ✅ Autocomplete suggestions show function signatures
- ✅ Code hints display concise function signatures
- ✅ Status bar shows current function signature
- ✅ Search results display detailed function information
- ✅ Format flags are used correctly for each feature
- ✅ Output parsing is robust and handles edge cases
- ✅ Performance targets are met (<100ms)
- ✅ Error handling is graceful and helpful
- ✅ Backward compatibility is maintained
- ✅ Documentation is clear and complete
- ✅ Test coverage is >90%

## Related Documentation

- [VIM_OUTPUT_FORMATS.md](../../update/VIM_OUTPUT_FORMATS.md) - Format specifications
- [FORMAT_EXAMPLES.md](../../update/FORMAT_EXAMPLES.md) - Concrete examples
- [VIM_PLUGIN_INTEGRATION_GUIDE.md](../../update/VIM_PLUGIN_INTEGRATION_GUIDE.md) - Integration patterns
- [SPEC_SUMMARY.md](../../update/SPEC_SUMMARY.md) - Feature overview

---

**Status:** Requirements Complete - Ready for Design Phase  
**Created:** 2026-03-25  
**Version:** 1.0
