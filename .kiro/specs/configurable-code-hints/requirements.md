# Requirements Document: Configurable Code Hints

## Introduction

The Configurable Code Hints feature adds a non-fatal hint system to the Vim Genero-Tools plugin that detects code quality issues, style violations, and potential problems in Genero code. Unlike compiler errors which block compilation, hints are warnings that help maintain code quality and consistency across large codebases. The system is fully configurable, allowing developers to enable/disable specific hint checks, adjust thresholds, and customize display options. Hints integrate seamlessly with the existing sign column system and distinguish themselves visually from compiler errors. The feature supports both Vim and Neovim with real-time detection as users type.

## Glossary

- **Hint**: A non-fatal warning about code quality, style, or potential issues that does not prevent compilation
- **Hint Category**: A logical grouping of related hint checks (e.g., Whitespace & Formatting, Keyword & Naming)
- **Hint Check**: An individual rule that detects a specific code issue (e.g., trailing whitespace, lowercase keywords)
- **Severity Level**: The classification of a hint's importance (info, warning, style)
- **Virtual Text**: Inline text displayed at the end of a line in Neovim (requires Neovim 0.3.2+)
- **Sign Column**: The narrow column on the left side of the editor that displays visual indicators
- **Sign**: A visual indicator in the sign column (e.g., ✕ for errors, ⚠ for warnings, ◆ for hints)
- **Threshold**: A configurable numeric limit for hint checks (e.g., max line length, max nesting depth)
- **Configuration Scope**: The level at which hints are configured (project-wide or per-file)
- **Hint Engine**: The core system that analyzes code and generates hints
- **Real-time Detection**: Hint analysis performed as the user types or saves the file
- **Auto-fix**: An optional suggestion to automatically correct a detected hint issue
- **Genero Code**: Source code written in the Genero language (.4gl, .m3, .m4, .per files)

## Requirements

### Requirement 1: Hint System Initialization

**User Story:** As a plugin developer, I want the hint system to initialize properly on plugin startup, so that hints are available for all Genero files.

#### Acceptance Criteria

1. WHEN the plugin loads, THE Hint_Engine SHALL initialize with default configuration
2. WHEN a Genero file is opened, THE Hint_Engine SHALL register the file for hint analysis
3. WHEN the plugin initializes, THE Hint_Engine SHALL load user configuration from g:genero_tools_config
4. IF user configuration is missing, THE Hint_Engine SHALL use sensible defaults for all hint checks
5. WHEN the plugin initializes, THE Hint_Engine SHALL verify that required dependencies are available

### Requirement 2: Whitespace & Formatting Hints

**User Story:** As a developer, I want to detect whitespace and formatting issues in my code, so that I can maintain consistent code style.

#### Acceptance Criteria

1. WHEN code is analyzed, THE Hint_Engine SHALL detect trailing whitespace at the end of lines
2. WHEN code is analyzed, THE Hint_Engine SHALL detect mixed tabs and spaces in indentation
3. WHEN code is analyzed, THE Hint_Engine SHALL detect inconsistent indentation levels within a file
4. WHEN code is analyzed, THE Hint_Engine SHALL detect multiple consecutive blank lines (more than 2)
5. WHEN a whitespace hint is detected, THE Hint_Engine SHALL report the line number and column position
6. WHERE the trailing_whitespace check is enabled, THE Hint_Engine SHALL flag lines with trailing spaces or tabs
7. WHERE the mixed_indentation check is enabled, THE Hint_Engine SHALL flag lines mixing tabs and spaces
8. WHERE the indentation_consistency check is enabled, THE Hint_Engine SHALL flag lines with inconsistent indentation
9. WHERE the multiple_blank_lines check is enabled, THE Hint_Engine SHALL flag sections with excessive blank lines

### Requirement 3: Keyword & Naming Convention Hints

**User Story:** As a developer, I want to detect keyword and naming convention violations, so that my code follows Genero style guidelines.

#### Acceptance Criteria

1. WHEN code is analyzed, THE Hint_Engine SHALL detect lowercase Genero keywords (e.g., `if`, `while`, `function`)
2. WHEN code is analyzed, THE Hint_Engine SHALL detect lowercase built-in function names (e.g., `length()`, `substr()`)
3. WHEN code is analyzed, THE Hint_Engine SHALL detect inconsistent keyword casing within a file
4. WHEN code is analyzed, THE Hint_Engine SHALL detect variable naming convention violations
5. WHERE the lowercase_keywords check is enabled, THE Hint_Engine SHALL flag keywords not in uppercase
6. WHERE the lowercase_functions check is enabled, THE Hint_Engine SHALL flag built-in functions not in uppercase
7. WHERE the keyword_consistency check is enabled, THE Hint_Engine SHALL flag inconsistent keyword casing
8. WHERE the naming_convention check is enabled, THE Hint_Engine SHALL flag variables not following configured convention

### Requirement 4: Code Structure Hints

**User Story:** As a developer, I want to detect structural code issues, so that I can improve code organization and readability.

#### Acceptance Criteria

1. WHEN code is analyzed, THE Hint_Engine SHALL detect unclosed blocks (missing END IF, END WHILE, etc.)
2. WHEN code is analyzed, THE Hint_Engine SHALL detect excessive nesting depth beyond configured threshold
3. WHEN code is analyzed, THE Hint_Engine SHALL detect lines exceeding configured maximum length
4. WHEN code is analyzed, THE Hint_Engine SHALL detect complex functions lacking comments
5. WHERE the unclosed_blocks check is enabled, THE Hint_Engine SHALL flag blocks without proper closing statements
6. WHERE the nesting_depth check is enabled, THE Hint_Engine SHALL flag code exceeding max_nesting_depth threshold
7. WHERE the line_length check is enabled, THE Hint_Engine SHALL flag lines exceeding max_line_length threshold
8. WHERE the missing_comments check is enabled, THE Hint_Engine SHALL flag complex sections without documentation

### Requirement 5: Genero-Specific Hints

**User Story:** As a Genero developer, I want to detect Genero-specific code quality issues, so that I can follow best practices for the language.

#### Acceptance Criteria

1. WHEN code is analyzed, THE Hint_Engine SHALL detect missing error handling in database operations
2. WHEN code is analyzed, THE Hint_Engine SHALL detect usage of deprecated Genero functions
3. WHERE the missing_error_handling check is enabled, THE Hint_Engine SHALL flag database operations without error checks
4. WHERE the deprecated_functions check is enabled, THE Hint_Engine SHALL flag usage of deprecated functions

### Requirement 6: Hint Configuration System

**User Story:** As a developer, I want to configure which hints are enabled and their thresholds, so that hints match my project's coding standards.

#### Acceptance Criteria

1. WHEN the plugin initializes, THE Configuration_System SHALL read hint settings from g:genero_tools_config
2. WHEN a user sets hints_enabled to 0, THE Hint_Engine SHALL disable all hint checking
3. WHEN a user configures individual hint checks, THE Hint_Engine SHALL respect enable/disable settings
4. WHEN a user sets a threshold value, THE Hint_Engine SHALL use that value for hint detection
5. WHEN configuration is invalid, THE Configuration_System SHALL use sensible defaults and warn the user
6. WHEN a user executes :GeneroConfigShow, THE Configuration_System SHALL display all hint settings
7. WHERE per-file configuration is supported, THE Hint_Engine SHALL check for .genero-hints file in project root

### Requirement 7: Hint Display Options

**User Story:** As a developer, I want to choose how hints are displayed, so that I can use the display method that works best for my workflow.

#### Acceptance Criteria

1. WHEN hints_display is set to 'signs', THE Hint_Engine SHALL display hints only in the sign column
2. WHEN hints_display is set to 'virtual_text', THE Hint_Engine SHALL display hints as inline text (Neovim only)
3. WHEN hints_display is set to 'both', THE Hint_Engine SHALL display hints in both sign column and virtual text
4. WHEN a hint is detected, THE Display_System SHALL show the hint at the correct line and column
5. WHEN hints_display is set to 'virtual_text' in Vim, THE Display_System SHALL fall back to 'signs'
6. WHEN a user changes hints_display setting, THE Display_System SHALL update all displayed hints immediately

### Requirement 8: Hint Severity Levels

**User Story:** As a developer, I want hints to have different severity levels, so that I can prioritize which issues to address first.

#### Acceptance Criteria

1. WHEN a hint is generated, THE Hint_Engine SHALL assign a severity level (info, warning, or style)
2. WHEN hints_severity is set to 'info', THE Hint_Engine SHALL treat all hints as informational
3. WHEN hints_severity is set to 'warning', THE Hint_Engine SHALL treat all hints as warnings
4. WHEN hints_severity is set to 'style', THE Hint_Engine SHALL treat all hints as style suggestions
5. WHEN a hint is displayed, THE Display_System SHALL use a visual indicator matching the severity level
6. WHEN a user views hint details, THE Hint_Engine SHALL display the severity level

### Requirement 9: Sign Column Integration

**User Story:** As a developer, I want hints to integrate with the existing sign column system, so that I can see all code issues in one place.

#### Acceptance Criteria

1. WHEN hints are enabled, THE Sign_Column_System SHALL reserve space for hint signs
2. WHEN a hint is detected, THE Sign_Column_System SHALL display a hint sign (◆ or similar)
3. WHEN both compiler errors and hints exist on the same line, THE Sign_Column_System SHALL display both signs
4. WHEN the unified sign column is enabled, THE Sign_Column_System SHALL combine compiler, SVN, and hint signs
5. WHEN a user clicks on a hint sign, THE Sign_Column_System SHALL display hint details
6. WHEN hints are disabled, THE Sign_Column_System SHALL remove hint signs from the display

### Requirement 10: Visual Distinction from Compiler Errors

**User Story:** As a developer, I want hints to look different from compiler errors, so that I can quickly distinguish between fatal and non-fatal issues.

#### Acceptance Criteria

1. WHEN a compiler error is displayed, THE Display_System SHALL use error highlighting (red background)
2. WHEN a hint is displayed, THE Display_System SHALL use hint highlighting (different color than errors)
3. WHEN a hint sign is displayed, THE Display_System SHALL use a different sign character than error signs
4. WHEN both errors and hints exist, THE Display_System SHALL ensure both are visually distinct
5. WHEN a user hovers over a hint sign, THE Display_System SHALL show hint details in a tooltip or popup

### Requirement 11: Real-time Hint Detection

**User Story:** As a developer, I want hints to be detected in real-time as I type, so that I get immediate feedback on code quality.

#### Acceptance Criteria

1. WHEN a user types in a Genero file, THE Hint_Engine SHALL analyze the file after a configurable delay
2. WHEN the file is saved, THE Hint_Engine SHALL perform a full analysis and update all hints
3. WHEN hints_realtime is enabled, THE Hint_Engine SHALL detect hints as the user types
4. WHEN hints_realtime is disabled, THE Hint_Engine SHALL only detect hints on file save
5. WHEN a user modifies a line, THE Hint_Engine SHALL re-analyze that line and surrounding context
6. WHEN analysis is in progress, THE Display_System SHALL show a progress indicator

### Requirement 12: Hint Navigation

**User Story:** As a developer, I want to quickly navigate between hints in a file, so that I can efficiently review and fix code quality issues.

#### Acceptance Criteria

1. WHEN a user executes :GeneroNextHint, THE Navigation_System SHALL jump to the next hint in the file
2. WHEN a user executes :GeneroPrevHint, THE Navigation_System SHALL jump to the previous hint in the file
3. WHEN a user executes :GeneroListHints, THE Navigation_System SHALL display all hints in the current file
4. WHEN a user selects a hint from the list, THE Navigation_System SHALL jump to that hint's location
5. WHEN no more hints exist in a direction, THE Navigation_System SHALL wrap around or display a message
6. WHEN a user navigates to a hint, THE Display_System SHALL highlight the hint and show details

### Requirement 13: Hint Details and Information

**User Story:** As a developer, I want to see detailed information about each hint, so that I understand what the issue is and how to fix it.

#### Acceptance Criteria

1. WHEN a user hovers over a hint sign, THE Display_System SHALL show a tooltip with hint details
2. WHEN a user executes :GeneroHintDetails, THE Display_System SHALL show detailed information about the hint at cursor
3. WHEN hint details are displayed, THE Display_System SHALL include: hint message, severity, category, and line number
4. WHEN a hint has an auto-fix suggestion, THE Display_System SHALL include the suggestion in the details
5. WHEN a user views hint details, THE Display_System SHALL explain why the hint was triggered

### Requirement 14: Auto-fix Suggestions

**User Story:** As a developer, I want auto-fix suggestions for common hint issues, so that I can quickly correct problems.

#### Acceptance Criteria

1. WHEN a hint is detected, THE Hint_Engine SHALL generate an auto-fix suggestion if available
2. WHEN a user executes :GeneroHintAutofix, THE Auto_Fix_System SHALL apply the fix for the hint at cursor
3. WHEN an auto-fix is applied, THE Auto_Fix_System SHALL update the file and re-analyze the affected lines
4. WHERE auto_fix_enabled is set to 1, THE Auto_Fix_System SHALL provide auto-fix suggestions
5. WHERE auto_fix_enabled is set to 0, THE Auto_Fix_System SHALL not generate or apply fixes
6. WHEN an auto-fix is applied, THE Display_System SHALL update the hint display immediately

### Requirement 15: Per-File Configuration

**User Story:** As a developer, I want to configure hints on a per-file basis, so that I can have different rules for different parts of my codebase.

#### Acceptance Criteria

1. WHEN a .genero-hints file exists in the project root, THE Configuration_System SHALL read per-file rules
2. WHEN per-file configuration is found, THE Hint_Engine SHALL apply those rules to matching files
3. WHEN a file matches multiple configuration patterns, THE Configuration_System SHALL merge rules with project-wide settings
4. WHEN per-file configuration is invalid, THE Configuration_System SHALL fall back to project-wide settings
5. WHEN a user modifies .genero-hints, THE Configuration_System SHALL reload configuration on next file save

### Requirement 16: Project-Wide Configuration

**User Story:** As a project lead, I want to configure hints for the entire project, so that all developers follow the same code quality standards.

#### Acceptance Criteria

1. WHEN hints are configured in g:genero_tools_config, THE Configuration_System SHALL apply to all files in the project
2. WHEN a user sets hints in their .vimrc, THE Configuration_System SHALL use those settings as project defaults
3. WHEN a user executes :GeneroConfigShow, THE Configuration_System SHALL display all active hint configurations
4. WHEN configuration is changed, THE Configuration_System SHALL apply changes to all open files
5. WHEN a new file is opened, THE Configuration_System SHALL apply current project-wide configuration

### Requirement 17: Hint Caching and Performance

**User Story:** As a developer working in a large codebase, I want hint analysis to be cached and optimized, so that the editor remains responsive.

#### Acceptance Criteria

1. WHEN hints are analyzed, THE Hint_Engine SHALL cache results with a timestamp
2. WHEN a file is unchanged, THE Hint_Engine SHALL use cached hints instead of re-analyzing
3. WHEN a file is modified, THE Hint_Engine SHALL invalidate the cache for that file
4. WHEN cache size exceeds limits, THE Hint_Engine SHALL evict oldest entries
5. WHEN a user executes :GeneroClearHintCache, THE Hint_Engine SHALL clear all cached hints
6. WHEN hints_cache_enabled is set to 0, THE Hint_Engine SHALL not cache hint results

### Requirement 18: Vim and Neovim Compatibility

**User Story:** As a Vim user, I want hints to work in both Vim and Neovim, so that I can use the feature regardless of my editor choice.

#### Acceptance Criteria

1. WHEN the plugin runs in Vim, THE Hint_Engine SHALL use Vim-compatible display methods
2. WHEN the plugin runs in Neovim, THE Hint_Engine SHALL use Neovim-specific features when available
3. WHEN virtual_text display is requested in Vim, THE Display_System SHALL fall back to signs
4. WHEN the plugin detects Neovim, THE Display_System SHALL enable Neovim-specific features
5. WHEN a feature is unavailable in the current editor, THE Display_System SHALL gracefully degrade

### Requirement 19: Hint Configuration Options

**User Story:** As a developer, I want comprehensive configuration options for hints, so that I can customize the system to my needs.

#### Acceptance Criteria

1. WHEN the plugin initializes, THE Configuration_System SHALL support the following options:
   - hints_enabled: Enable/disable all hints (default: 1)
   - hints_display: Display method - 'signs', 'virtual_text', or 'both' (default: 'signs')
   - hints_severity: Severity level - 'info', 'warning', or 'style' (default: 'warning')
   - hints_realtime: Enable real-time detection (default: 1)
   - hints_cache_enabled: Enable hint caching (default: 1)
   - hints_cache_ttl: Cache time-to-live in seconds (default: 300)
   - auto_fix_enabled: Enable auto-fix suggestions (default: 1)
   - hints_delay: Delay before analyzing (ms) (default: 500)

2. WHEN the plugin initializes, THE Configuration_System SHALL support individual hint check options:
   - trailing_whitespace: Detect trailing spaces (default: 1)
   - mixed_indentation: Detect mixed tabs/spaces (default: 1)
   - indentation_consistency: Detect inconsistent indentation (default: 1)
   - multiple_blank_lines: Detect excessive blank lines (default: 1)
   - lowercase_keywords: Detect lowercase keywords (default: 1)
   - lowercase_functions: Detect lowercase functions (default: 1)
   - keyword_consistency: Detect inconsistent casing (default: 1)
   - naming_convention: Detect naming violations (default: 0)
   - unclosed_blocks: Detect unclosed blocks (default: 1)
   - nesting_depth: Detect excessive nesting (default: 1)
   - line_length: Detect long lines (default: 1)
   - missing_comments: Detect missing comments (default: 0)
   - missing_error_handling: Detect missing error handling (default: 0)
   - deprecated_functions: Detect deprecated functions (default: 1)

3. WHEN the plugin initializes, THE Configuration_System SHALL support threshold options:
   - max_line_length: Maximum line length (default: 100)
   - max_nesting_depth: Maximum nesting depth (default: 5)
   - max_blank_lines: Maximum consecutive blank lines (default: 2)
   - naming_convention_style: Variable naming style - 'camelCase' or 'snake_case' (default: 'camelCase')

### Requirement 20: Hint Engine Architecture

**User Story:** As a plugin developer, I want a well-architected hint engine, so that new hint checks can be easily added.

#### Acceptance Criteria

1. WHEN the Hint_Engine is designed, THE Architecture SHALL separate hint detection from display
2. WHEN a new hint check is added, THE Architecture SHALL allow registration without modifying core code
3. WHEN hints are analyzed, THE Architecture SHALL process all checks efficiently
4. WHEN the plugin runs, THE Architecture SHALL support both synchronous and asynchronous analysis
5. WHEN hints are displayed, THE Architecture SHALL use a consistent interface for all display methods

### Requirement 21: Error Handling and Robustness

**User Story:** As a developer, I want the hint system to handle errors gracefully, so that hint failures don't disrupt my editing.

#### Acceptance Criteria

1. WHEN hint analysis fails, THE Error_Handler SHALL log the error and continue operation
2. WHEN a hint check throws an exception, THE Error_Handler SHALL catch it and skip that check
3. WHEN configuration is invalid, THE Error_Handler SHALL use defaults and warn the user
4. WHEN a display method fails, THE Error_Handler SHALL fall back to an alternative method
5. WHEN the hint system encounters an error, THE Error_Handler SHALL not interrupt the user's editing

### Requirement 22: Documentation and Help

**User Story:** As a user, I want clear documentation about hints, so that I can understand and use the feature effectively.

#### Acceptance Criteria

1. WHEN a user executes :GeneroHintHelp, THE Help_System SHALL display hint documentation
2. WHEN a user executes :GeneroHintHelp [hint_name], THE Help_System SHALL display details about a specific hint
3. WHEN hint documentation is displayed, THE Help_System SHALL include examples and explanations
4. WHEN a user views hint details, THE Display_System SHALL include a link to relevant documentation

### Requirement 23: Integration with Existing Systems

**User Story:** As a plugin user, I want hints to integrate seamlessly with existing plugin features, so that I have a unified experience.

#### Acceptance Criteria

1. WHEN hints are enabled, THE Integration_System SHALL work with the existing sign column system
2. WHEN hints are enabled, THE Integration_System SHALL work with the existing configuration system
3. WHEN hints are enabled, THE Integration_System SHALL work with the existing display modes
4. WHEN hints are enabled, THE Integration_System SHALL work with the existing error handling system
5. WHEN both compiler errors and hints exist, THE Integration_System SHALL display both without conflicts

### Requirement 24: Performance Optimization

**User Story:** As a developer in a large codebase, I want hint analysis to be optimized for performance, so that the editor remains responsive.

#### Acceptance Criteria

1. WHEN a file is analyzed, THE Hint_Engine SHALL complete analysis within hints_delay milliseconds
2. WHEN multiple files are open, THE Hint_Engine SHALL prioritize the current file
3. WHEN the editor is idle, THE Hint_Engine SHALL perform background analysis on other files
4. WHEN system resources are low, THE Hint_Engine SHALL reduce analysis frequency
5. WHEN a user types rapidly, THE Hint_Engine SHALL debounce analysis requests

