# Requirements Document: Vim Genero-Tools Plugin

## Introduction

The Vim Genero-Tools Plugin enables developers to navigate and explore large-scale Genero codebases (thousands of files, 6M+ LOC) directly from the vim editor. By integrating with the genero-tools CLI, the plugin provides quick access to function definitions, module contents, and file metadata without leaving the editor. The plugin is optimized for performance with intelligent caching, asynchronous command execution, result pagination, and timeout handling to ensure responsive interaction even with massive codebases. The plugin supports multiple display modes, intelligent caching, and works seamlessly with both vim and neovim.

## Glossary

- **genero-tools**: Command-line tool that provides code analysis and lookup capabilities for Genero codebases
- **Function Definition**: Information about a function including its name, file location, line number, and signature
- **Module**: A collection of related Genero source files (e.g., mymodule.m3)
- **Codebase Path**: The root directory of a Genero project
- **Cache TTL**: Time-to-live in seconds; the duration a cached result remains valid
- **Display Mode**: The method used to present results to the user (quickfix, popup, split, or echo)
- **Quickfix List**: Vim's built-in list of locations that can be navigated
- **Popup Window**: A floating window overlay (neovim feature)
- **Split Window**: A new vim window created by splitting the current window
- **Configuration**: User-defined settings that control plugin behavior

## Requirements

### Requirement 1: Function Lookup

**User Story:** As a developer, I want to quickly find function definitions in my Genero codebase, so that I can navigate to function implementations without manual searching.

#### Acceptance Criteria

1. WHEN a user executes the GeneroLookup command with a function name, THE Plugin SHALL query genero-tools and return the function definition
2. WHEN a function is found, THE Plugin SHALL return the function name, file path, line number, and signature
3. WHEN a function is not found, THE Plugin SHALL return an error message indicating the function was not found
4. WHEN a user provides no function name, THE Plugin SHALL use the word under the cursor as the function name
5. WHEN a lookup is performed, THE Plugin SHALL respect the configured codebase path

### Requirement 2: Module File Listing

**User Story:** As a developer, I want to see all files in a Genero module, so that I can understand the module structure and navigate between related files.

#### Acceptance Criteria

1. WHEN a user executes the GeneroListModuleFiles command with a module name, THE Plugin SHALL query genero-tools and return all file paths in the module
2. WHEN files are found, THE Plugin SHALL return a list of file paths organized by the module
3. WHEN a module is not found, THE Plugin SHALL return an error message indicating the module was not found
4. WHEN a user provides no module name, THE Plugin SHALL use the current file's module as the target module
5. WHEN listing files, THE Plugin SHALL respect the configured codebase path

### Requirement 3: Function Listing in File

**User Story:** As a developer, I want to see all functions defined in a specific file, so that I can quickly navigate between functions in that file.

#### Acceptance Criteria

1. WHEN a user executes the GeneroListFunctions command with a file path, THE Plugin SHALL query genero-tools and return all functions in that file
2. WHEN functions are found, THE Plugin SHALL return each function's name, line number, and signature
3. WHEN no functions are found, THE Plugin SHALL return an empty list
4. WHEN a user provides no file path, THE Plugin SHALL use the current file as the target
5. WHEN listing functions, THE Plugin SHALL respect the configured codebase path

### Requirement 4: Function Signature Retrieval

**User Story:** As a developer, I want to quickly view a function's signature, so that I can understand its parameters and return type without navigating to the definition.

#### Acceptance Criteria

1. WHEN a user executes the GeneroFunctionSignature command with a function name, THE Plugin SHALL query genero-tools and return the function signature
2. WHEN a signature is found, THE Plugin SHALL return the complete function signature as a string
3. WHEN a function is not found, THE Plugin SHALL return an error message
4. WHEN a user provides no function name, THE Plugin SHALL use the word under the cursor as the function name
5. WHEN retrieving a signature, THE Plugin SHALL respect the configured codebase path

### Requirement 5: File Metadata Retrieval

**User Story:** As a developer, I want to view metadata about a file, so that I can understand authorship, related tickets, and modification history.

#### Acceptance Criteria

1. WHEN a user executes the GeneroFileMetadata command with a file path, THE Plugin SHALL query genero-tools and return file metadata
2. WHEN metadata is found, THE Plugin SHALL return the author, ticket codes, creation date, and modification date
3. WHEN a file is not found, THE Plugin SHALL return an error message
4. WHEN a user provides no file path, THE Plugin SHALL use the current file as the target
5. WHEN retrieving metadata, THE Plugin SHALL respect the configured codebase path

### Requirement 6: Result Caching

**User Story:** As a developer working in a large codebase, I want results to be cached with intelligent eviction, so that repeated lookups are fast and the plugin doesn't consume excessive memory.

#### Acceptance Criteria

1. WHEN caching is enabled in configuration, THE Plugin SHALL store command results with a timestamp
2. WHEN a cached result is requested and the TTL has not expired, THE Plugin SHALL return the cached result instead of querying genero-tools
3. WHEN a cached result's TTL has expired, THE Plugin SHALL fetch fresh data from genero-tools
4. WHEN a user executes the GeneroClearCache command, THE Plugin SHALL clear all cached results
5. WHEN caching is disabled in configuration, THE Plugin SHALL not store or retrieve cached results
6. WHEN cache size exceeds cache_max_size, THE Plugin SHALL evict oldest entries using LRU strategy
7. WHEN cache memory pressure is detected, THE Plugin SHALL automatically clear expired entries

### Requirement 6.1: Asynchronous Command Execution

**User Story:** As a developer, I want long-running queries to execute asynchronously, so that the editor remains responsive while genero-tools processes large codebases.

#### Acceptance Criteria

1. WHEN async_enabled is true in configuration, THE Plugin SHALL execute genero-tools commands asynchronously
2. WHEN a command is executing asynchronously, THE Plugin SHALL display a status indicator
3. WHEN an asynchronous command completes, THE Plugin SHALL display results using the configured display mode
4. WHEN a user cancels an asynchronous command, THE Plugin SHALL terminate the process gracefully
5. WHEN async_enabled is false, THE Plugin SHALL execute commands synchronously with timeout protection

### Requirement 7: Quickfix Display Mode

**User Story:** As a developer, I want to view lookup results in vim's quickfix list with pagination support, so that I can navigate to results using vim's standard quickfix navigation even when there are thousands of results.

#### Acceptance Criteria

1. WHEN a user configures display_mode as 'quickfix', THE Plugin SHALL populate the quickfix list with results
2. WHEN results are displayed in quickfix mode, THE Plugin SHALL open the quickfix window
3. WHEN result count exceeds result_limit, THE Plugin SHALL paginate results with pagination_size entries per page
4. WHEN multiple results are returned, THE Plugin SHALL add all results to the quickfix list (or first page if paginated)
5. WHEN an error occurs, THE Plugin SHALL display the error message in the quickfix list
6. WHEN the quickfix list is populated, THE Plugin SHALL not modify the current buffer content
7. WHEN pagination is active, THE Plugin SHALL provide navigation commands to load next/previous pages

### Requirement 8: Popup Display Mode

**User Story:** As a developer using neovim, I want to view results in a floating popup window, so that I can see results without disrupting my current view.

#### Acceptance Criteria

1. WHEN a user configures display_mode as 'popup' and is using neovim, THE Plugin SHALL create a floating popup window
2. WHEN results are displayed in popup mode, THE Plugin SHALL format results for readability in the popup
3. WHEN a user is using vim (not neovim), THE Plugin SHALL fall back to echo mode
4. WHEN the popup is displayed, THE Plugin SHALL not modify the current buffer content
5. WHEN the popup is closed, THE Plugin SHALL restore the previous editor state

### Requirement 9: Split Display Mode

**User Story:** As a developer, I want to view results in a split window, so that I can see results alongside my current code.

#### Acceptance Criteria

1. WHEN a user configures display_mode as 'split', THE Plugin SHALL create a new split window
2. WHEN results are displayed in split mode, THE Plugin SHALL populate the split window with formatted results
3. WHEN the split window is created, THE Plugin SHALL not modify the current buffer content
4. WHEN a user closes the split window, THE Plugin SHALL restore the previous editor state
5. WHEN multiple results are returned, THE Plugin SHALL display all results in the split window

### Requirement 10: Echo Display Mode

**User Story:** As a developer, I want to view results in the command line, so that I can see results without opening additional windows.

#### Acceptance Criteria

1. WHEN a user configures display_mode as 'echo', THE Plugin SHALL display results in the vim command line
2. WHEN results are displayed in echo mode, THE Plugin SHALL format results for readability
3. WHEN an error occurs, THE Plugin SHALL display the error message in the command line
4. WHEN results are echoed, THE Plugin SHALL not modify the current buffer content
5. WHEN results are long, THE Plugin SHALL truncate or paginate the output appropriately

### Requirement 11: Configuration Management

**User Story:** As a developer, I want to configure the plugin behavior for large codebases, so that I can customize it to match my workflow, environment, and codebase scale.

#### Acceptance Criteria

1. WHEN the plugin loads, THE Plugin SHALL read configuration from g:genero_tools_config
2. WHEN a user executes the GeneroConfigShow command, THE Plugin SHALL display the current configuration
3. WHEN a user sets genero_tools_path in configuration, THE Plugin SHALL use that path to locate genero-tools
4. WHEN a user sets cache_enabled in configuration, THE Plugin SHALL enable or disable caching accordingly
5. WHEN a user sets cache_ttl in configuration, THE Plugin SHALL use that value for cache expiration
6. WHEN a user sets cache_max_size in configuration, THE Plugin SHALL enforce that limit with LRU eviction
7. WHEN a user sets display_mode in configuration, THE Plugin SHALL use that mode for displaying results
8. WHEN a user sets timeout in configuration, THE Plugin SHALL enforce that timeout for command execution (recommended 10000ms for large codebases)
9. WHEN a user sets keybindings_enabled in configuration, THE Plugin SHALL register or skip keybindings accordingly
10. WHEN a user sets async_enabled in configuration, THE Plugin SHALL execute commands asynchronously or synchronously
11. WHEN a user sets result_limit in configuration, THE Plugin SHALL limit result sets and enable pagination
12. WHEN a user sets pagination_size in configuration, THE Plugin SHALL use that value for paginated result display

### Requirement 12: Keybinding Support

**User Story:** As a developer, I want to use keybindings to trigger plugin commands, so that I can quickly access functionality without typing commands.

#### Acceptance Criteria

1. WHEN keybindings_enabled is true in configuration, THE Plugin SHALL register default keybindings
2. WHEN a user presses the lookup keybinding, THE Plugin SHALL execute the GeneroLookup command with the word under the cursor
3. WHEN a user presses the list functions keybinding, THE Plugin SHALL execute the GeneroListFunctions command with the current file
4. WHEN a user presses the signature keybinding, THE Plugin SHALL execute the GeneroFunctionSignature command with the word under the cursor
5. WHEN a user presses the metadata keybinding, THE Plugin SHALL execute the GeneroFileMetadata command with the current file
6. WHEN keybindings_enabled is false in configuration, THE Plugin SHALL not register keybindings

### Requirement 13: Error Handling

**User Story:** As a developer, I want clear error messages when something goes wrong, so that I can understand what happened and how to fix it.

#### Acceptance Criteria

1. WHEN genero-tools is not found, THE Plugin SHALL return an error message with installation instructions
2. WHEN the codebase path is invalid, THE Plugin SHALL return an error message indicating the path does not exist
3. WHEN a command times out, THE Plugin SHALL return an error message with the timeout value
4. WHEN genero-tools returns invalid JSON, THE Plugin SHALL return an error message indicating a parse error
5. WHEN a function or file is not found, THE Plugin SHALL return an error message with search details
6. WHEN permission is denied, THE Plugin SHALL return an error message indicating an access issue
7. WHEN an error occurs, THE Plugin SHALL display the error message using the configured display mode

### Requirement 14: Vim and Neovim Compatibility

**User Story:** As a developer using either vim or neovim, I want the plugin to work seamlessly in my editor, so that I can use the same plugin regardless of which editor I prefer.

#### Acceptance Criteria

1. WHEN the plugin loads, THE Plugin SHALL detect whether it is running in vim or neovim
2. WHEN running in vim, THE Plugin SHALL use vim-compatible display modes (quickfix, split, echo)
3. WHEN running in neovim, THE Plugin SHALL support all display modes including popup
4. WHEN a display mode is not supported in the current editor, THE Plugin SHALL fall back to a supported mode
5. WHEN a command is executed, THE Plugin SHALL work identically in both vim and neovim
6. WHEN the plugin is used, THE Plugin SHALL not use editor-specific features that break compatibility

### Requirement 15: Command Execution

**User Story:** As a developer working with large codebases, I want the plugin to reliably execute genero-tools commands with proper timeout handling and progress feedback, so that I can trust the results and understand when operations are taking time.

#### Acceptance Criteria

1. WHEN a command is executed, THE Plugin SHALL properly escape all arguments
2. WHEN a command is executed, THE Plugin SHALL respect the configured timeout setting (critical for large codebases)
3. WHEN a command completes successfully, THE Plugin SHALL parse the JSON output from genero-tools
4. WHEN a command fails, THE Plugin SHALL return a descriptive error message
5. WHEN a command times out, THE Plugin SHALL terminate execution and return a timeout error with guidance
6. WHEN a command is executed, THE Plugin SHALL include the codebase path in the command arguments
7. WHEN a command is executed, THE Plugin SHALL not modify any input parameters
8. WHEN async_enabled is true, THE Plugin SHALL execute commands asynchronously with progress feedback
9. WHEN a command takes longer than 2 seconds, THE Plugin SHALL display a progress indicator
10. WHEN a command returns a very large result set, THE Plugin SHALL suggest pagination or narrowing search criteria

### Requirement 16: Result Structure Consistency

**User Story:** As a developer, I want consistent result structures from all commands, so that I can reliably process results in my scripts.

#### Acceptance Criteria

1. WHEN any command completes, THE Plugin SHALL return a result dictionary with keys: success, data, error, timestamp
2. WHEN a command succeeds, THE Plugin SHALL set success to true and populate the data key
3. WHEN a command fails, THE Plugin SHALL set success to false and populate the error key
4. WHEN a command completes, THE Plugin SHALL set timestamp to the current time
5. WHEN a command fails, THE Plugin SHALL set the data key to an empty dictionary
6. WHEN a command succeeds, THE Plugin SHALL set the error key to an empty string

### Requirement 17: Large Codebase Query Optimization

**User Story:** As a developer working in a massive codebase (thousands of files, 6M+ LOC), I want guidance on optimizing queries, so that I can get results quickly without overwhelming the system.

#### Acceptance Criteria

1. WHEN a query returns the result_limit (1000 results), THE Plugin SHALL display a message suggesting the user narrow their search criteria
2. WHEN a command times out, THE Plugin SHALL suggest using more specific search terms or filtering by module
3. WHEN the cache is full, THE Plugin SHALL automatically evict oldest entries without user intervention
4. WHEN async_enabled is true, THE Plugin SHALL execute all commands asynchronously to keep the editor responsive
5. WHEN a user performs repeated lookups, THE Plugin SHALL benefit from caching to avoid redundant genero-tools queries
6. WHEN displaying large result sets, THE Plugin SHALL use pagination to avoid overwhelming the display
7. WHEN a command takes longer than 2 seconds, THE Plugin SHALL display elapsed time and progress feedback
