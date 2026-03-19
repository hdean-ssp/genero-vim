# Design Document: Configurable Code Hints

## Overview

The Configurable Code Hints feature provides a non-fatal hint system for the Vim Genero-Tools plugin that detects code quality issues, style violations, and potential problems in Genero code. Unlike compiler errors which block compilation, hints are warnings that help maintain code quality and consistency. The system is fully configurable, allowing developers to enable/disable specific hint checks, adjust thresholds, and customize display options.

### Key Characteristics

- **Non-fatal**: Hints do not prevent compilation or disrupt editing
- **Configurable**: Each hint check can be enabled/disabled with adjustable thresholds
- **Real-time**: Hints are detected as users type (with configurable delay)
- **Integrated**: Seamlessly integrates with existing sign column, display, and configuration systems
- **Performant**: Uses caching and debouncing to maintain editor responsiveness
- **Compatible**: Works with both Vim and Neovim with graceful fallbacks

### Architecture Principles

1. **Separation of Concerns**: Hint detection, configuration, display, and caching are separate modules
2. **Extensibility**: New hint checks can be added without modifying core code
3. **Consistency**: Follows existing plugin patterns for configuration, display, and error handling
4. **Performance**: Caching, debouncing, and background analysis prevent editor slowdown
5. **User Control**: All features are configurable with sensible defaults

---

## Architecture

### High-Level System Components

```
┌─────────────────────────────────────────────────────────────────┐
│                    Hint System Architecture                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              User Configuration Layer                     │   │
│  │  (g:genero_tools_config + .genero-hints file)            │   │
│  └──────────────────────────────────────────────────────────┘   │
│                            ▲                                      │
│                            │                                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │         Configuration System (config.vim)                │   │
│  │  - Load defaults                                          │   │
│  │  - Validate settings                                      │   │
│  │  - Merge per-file config                                 │   │
│  └──────────────────────────────────────────────────────────┘   │
│                            ▲                                      │
│                            │                                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │           Hint Engine (hints.vim)                        │   │
│  │  - Orchestrates analysis                                 │   │
│  │  - Manages hint lifecycle                                │   │
│  │  - Coordinates with detection modules                    │   │
│  └──────────────────────────────────────────────────────────┘   │
│           ▲                    ▲                    ▲             │
│           │                    │                    │             │
│  ┌────────┴──────┐  ┌──────────┴──────┐  ┌────────┴──────┐     │
│  │ Whitespace    │  │ Keyword &       │  │ Code          │     │
│  │ Formatting    │  │ Naming          │  │ Structure     │     │
│  │ Detector      │  │ Detector        │  │ Detector      │     │
│  │ (hints/ws.vim)│  │ (hints/kw.vim)  │  │ (hints/cs.vim)│     │
│  └───────────────┘  └─────────────────┘  └───────────────┘     │
│                                                                   │
│  ┌────────────────────────────────────────────────────────┐     │
│  │ Genero-Specific Detector (hints/genero.vim)            │     │
│  │ - Unused variables                                      │     │
│  │ - Missing error handling                                │     │
│  │ - Deprecated functions                                  │     │
│  │ - Missing type declarations                             │     │
│  └────────────────────────────────────────────────────────┘     │
│                            ▲                                      │
│                            │                                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │         Cache System (hints/cache.vim)                   │   │
│  │  - Store hint results                                    │   │
│  │  - Invalidate on file changes                            │   │
│  │  - LRU eviction                                          │   │
│  └──────────────────────────────────────────────────────────┘   │
│                            ▲                                      │
│                            │                                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │         Display System (hints/display.vim)               │   │
│  │  - Render signs in sign column                           │   │
│  │  - Render virtual text (Neovim)                          │   │
│  │  - Show hint details                                     │   │
│  │  - Highlight groups                                      │   │
│  └──────────────────────────────────────────────────────────┘   │
│                            ▲                                      │
│                            │                                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │         Navigation System (hints/nav.vim)                │   │
│  │  - Jump to next/prev hint                                │   │
│  │  - List all hints                                        │   │
│  │  - Show hint details                                     │   │
│  └──────────────────────────────────────────────────────────┘   │
│                            ▲                                      │
│                            │                                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │         Auto-fix System (hints/autofix.vim)              │   │
│  │  - Generate fix suggestions                              │   │
│  │  - Apply fixes to code                                   │   │
│  │  - Re-analyze after fix                                  │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
File Change Event
       │
       ▼
Debounce Timer (hints_delay)
       │
       ▼
Check Cache (hints_cache_enabled)
       │
       ├─ Cache Hit ──────────────────┐
       │                              │
       └─ Cache Miss                  │
              │                       │
              ▼                       │
         Run Detectors                │
         (all enabled checks)         │
              │                       │
              ▼                       │
         Store in Cache               │
              │                       │
              └──────────────────────┬┘
                                     │
                                     ▼
                            Merge with Config
                            (severity, display)
                                     │
                                     ▼
                            Display System
                            (signs/virtual text)
                                     │
                                     ▼
                            User sees hints
```

---

## Core Components

### 1. Hint Engine (`autoload/genero_tools/hints.vim`)

The central orchestrator that manages the hint system lifecycle.

**Responsibilities:**
- Initialize hint system on plugin startup
- Register files for hint analysis
- Coordinate hint detection across all modules
- Manage hint lifecycle (create, update, delete)
- Trigger analysis on file changes
- Coordinate with cache system

**Key Functions:**

```vim
" Initialize hint engine with configuration
function! genero_tools#hints#init() abort
  " Load configuration
  " Initialize all detector modules
  " Set up autocommands for file changes
  " Initialize cache system
endfunction

" Analyze file and return all hints
function! genero_tools#hints#analyze(bufnr) abort
  " Check cache first
  " Run all enabled detectors
  " Merge results
  " Store in cache
  " Return hint list
endfunction

" Analyze specific line range (for real-time detection)
function! genero_tools#hints#analyze_range(bufnr, start_line, end_line) abort
  " Analyze only affected lines
  " Update cache for affected lines
  " Return hints for range
endfunction

" Get all hints for current buffer
function! genero_tools#hints#get_hints(bufnr) abort
  " Return cached or analyzed hints
endfunction

" Clear hints for buffer
function! genero_tools#hints#clear(bufnr) abort
  " Remove all hint signs
  " Clear cache
  " Clear virtual text
endfunction
```

### 2. Configuration System (`autoload/genero_tools/hints/config.vim`)

Manages hint configuration from multiple sources with proper merging and validation.

**Configuration Sources (in priority order):**
1. Per-file configuration (`.genero-hints` in project root)
2. Project-wide configuration (`g:genero_tools_config`)
3. Built-in defaults

**Configuration Structure:**

```vim
" Global hint configuration
let g:genero_tools_config.hints_enabled = 1
let g:genero_tools_config.hints_display = 'signs'  " 'signs', 'virtual_text', 'both'
let g:genero_tools_config.hints_severity = 'warning'  " 'info', 'warning', 'style'
let g:genero_tools_config.hints_realtime = 1
let g:genero_tools_config.hints_cache_enabled = 1
let g:genero_tools_config.hints_cache_ttl = 300
let g:genero_tools_config.auto_fix_enabled = 1
let g:genero_tools_config.hints_delay = 500

" Individual hint checks
let g:genero_tools_config.trailing_whitespace = 1
let g:genero_tools_config.mixed_indentation = 1
let g:genero_tools_config.indentation_consistency = 1
let g:genero_tools_config.multiple_blank_lines = 1
let g:genero_tools_config.lowercase_keywords = 1
let g:genero_tools_config.lowercase_functions = 1
let g:genero_tools_config.keyword_consistency = 1
let g:genero_tools_config.naming_convention = 0
let g:genero_tools_config.unclosed_blocks = 1
let g:genero_tools_config.nesting_depth = 1
let g:genero_tools_config.line_length = 1
let g:genero_tools_config.missing_comments = 0
let g:genero_tools_config.unused_variables = 0
let g:genero_tools_config.missing_error_handling = 0
let g:genero_tools_config.deprecated_functions = 1
let g:genero_tools_config.missing_type_declarations = 0

" Threshold options
let g:genero_tools_config.max_line_length = 100
let g:genero_tools_config.max_nesting_depth = 5
let g:genero_tools_config.max_blank_lines = 2
let g:genero_tools_config.naming_convention_style = 'camelCase'  " 'camelCase', 'snake_case'
```

**Key Functions:**

```vim
" Get effective configuration for a file
function! genero_tools#hints#config#get_for_file(file_path) abort
  " Load project-wide config
  " Load per-file config if exists
  " Merge with priority
  " Return effective config
endfunction

" Validate configuration
function! genero_tools#hints#config#validate(config) abort
  " Check all keys are valid
  " Check value types
  " Check threshold ranges
  " Return validation result
endfunction

" Load per-file configuration from .genero-hints
function! genero_tools#hints#config#load_per_file() abort
  " Find .genero-hints in project root
  " Parse JSON/YAML configuration
  " Return per-file config
endfunction
```

### 3. Display System (`autoload/genero_tools/hints/display.vim`)

Renders hints in the editor using signs and/or virtual text.

**Display Methods:**
- **Signs**: Visual indicators in the sign column (all editors)
- **Virtual Text**: Inline text at end of line (Neovim 0.3.2+)
- **Both**: Combine signs and virtual text

**Sign Definitions:**

```vim
" Hint signs (distinct from compiler errors)
sign define GeneroHintInfo text=◆ texthl=GeneroHintInfo
sign define GeneroHintWarning text=◆ texthl=GeneroHintWarning
sign define GeneroHintStyle text=◆ texthl=GeneroHintStyle

" Highlight groups
highlight GeneroHintInfo ctermfg=Blue guifg=Blue
highlight GeneroHintWarning ctermfg=Yellow guifg=Yellow
highlight GeneroHintStyle ctermfg=Cyan guifg=Cyan
```

**Key Functions:**

```vim
" Display hints for buffer
function! genero_tools#hints#display#show(bufnr, hints) abort
  " Clear existing hint signs
  " For each hint:
  "   - Place sign in sign column
  "   - Add virtual text if enabled (Neovim)
  "   - Store hint metadata for details
endfunction

" Show hint details in popup/tooltip
function! genero_tools#hints#display#show_details(hint) abort
  " Format hint information
  " Show in floating window (Neovim) or popup (Vim)
  " Include: message, severity, category, line, auto-fix suggestion
endfunction

" Update display after configuration change
function! genero_tools#hints#display#refresh() abort
  " Re-display all hints with new settings
endfunction
```

### 4. Detection Modules

#### 4.1 Whitespace & Formatting Detector (`autoload/genero_tools/hints/whitespace.vim`)

Detects whitespace and formatting issues.

**Checks:**
- Trailing whitespace at end of lines
- Mixed tabs and spaces in indentation
- Inconsistent indentation levels
- Multiple consecutive blank lines

**Key Functions:**

```vim
" Detect all whitespace issues in buffer
function! genero_tools#hints#whitespace#detect(bufnr, config) abort
  " Get buffer lines
  " For each line:
  "   - Check trailing whitespace
  "   - Check mixed indentation
  "   - Check indentation consistency
  "   - Check blank line sequences
  " Return list of hints
endfunction
```

#### 4.2 Keyword & Naming Detector (`autoload/genero_tools/hints/keyword.vim`)

Detects keyword and naming convention violations.

**Checks:**
- Lowercase Genero keywords (IF, WHILE, FUNCTION, etc.)
- Lowercase built-in functions (LENGTH, SUBSTR, etc.)
- Inconsistent keyword casing within file
- Variable naming convention violations

**Key Functions:**

```vim
" Detect keyword and naming issues
function! genero_tools#hints#keyword#detect(bufnr, config) abort
  " Parse buffer for keywords and identifiers
  " Check keyword casing
  " Check function name casing
  " Check variable naming conventions
  " Return list of hints
endfunction
```

#### 4.3 Code Structure Detector (`autoload/genero_tools/hints/structure.vim`)

Detects structural code issues.

**Checks:**
- Unclosed blocks (missing END IF, END WHILE, etc.)
- Excessive nesting depth
- Lines exceeding maximum length
- Complex functions lacking comments

**Key Functions:**

```vim
" Detect code structure issues
function! genero_tools#hints#structure#detect(bufnr, config) abort
  " Parse block structure
  " Check nesting depth
  " Check line lengths
  " Check for comments in complex sections
  " Return list of hints
endfunction
```

#### 4.4 Genero-Specific Detector (`autoload/genero_tools/hints/genero.vim`)

Detects Genero-specific code quality issues.

**Checks:**
- Missing error handling in database operations
- Usage of deprecated Genero functions

**Key Functions:**

```vim
" Detect Genero-specific issues
function! genero_tools#hints#genero#detect(bufnr, config) abort
  " Check for error handling patterns
  " Check for deprecated functions
  " Return list of hints
endfunction
```

### 5. Cache System (`autoload/genero_tools/hints/cache.vim`)

Caches hint analysis results to improve performance.

**Cache Key Structure:**
```
hints:{bufnr}:{file_hash}:{config_hash}
```

**Cache Entry Structure:**
```vim
{
  'hints': [...],           " List of hints
  'timestamp': 1234567890,  " When cached
  'file_hash': 'abc123',    " File content hash
  'config_hash': 'def456'   " Config hash
}
```

**Key Functions:**

```vim
" Get cached hints for buffer
function! genero_tools#hints#cache#get(bufnr) abort
  " Check if cache exists and is valid
  " Return cached hints or empty list
endfunction

" Store hints in cache
function! genero_tools#hints#cache#set(bufnr, hints) abort
  " Store hints with timestamp
  " Manage cache size
endfunction

" Invalidate cache for buffer
function! genero_tools#hints#cache#invalidate(bufnr) abort
  " Remove cached hints
endfunction

" Clear all hint cache
function! genero_tools#hints#cache#clear() abort
  " Remove all cached hints
endfunction
```

### 6. Navigation System (`autoload/genero_tools/hints/nav.vim`)

Provides commands to navigate between hints.

**Key Functions:**

```vim
" Jump to next hint in buffer
function! genero_tools#hints#nav#next() abort
  " Find next hint after cursor
  " Jump to hint location
  " Show hint details
endfunction

" Jump to previous hint in buffer
function! genero_tools#hints#nav#prev() abort
  " Find previous hint before cursor
  " Jump to hint location
  " Show hint details
endfunction

" List all hints in buffer
function! genero_tools#hints#nav#list() abort
  " Get all hints
  " Display in quickfix or floating window
  " Allow selection and jump
endfunction

" Show details for hint at cursor
function! genero_tools#hints#nav#details() abort
  " Find hint at cursor
  " Show detailed information
endfunction
```

### 7. Auto-fix System (`autoload/genero_tools/hints/autofix.vim`)

Provides automatic fixes for detected hints.

**Supported Auto-fixes:**
- Remove trailing whitespace
- Fix mixed indentation
- Fix inconsistent indentation
- Remove extra blank lines
- Uppercase keywords
- Uppercase function names

**Key Functions:**

```vim
" Apply auto-fix for hint at cursor
function! genero_tools#hints#autofix#apply() abort
  " Find hint at cursor
  " Generate fix
  " Apply to buffer
  " Re-analyze affected lines
endfunction

" Generate fix suggestion for hint
function! genero_tools#hints#autofix#suggest(hint) abort
  " Based on hint type, generate fix
  " Return fix suggestion
endfunction
```

---

## Hint Data Structure

Each hint is represented as a dictionary:

```vim
{
  'line': 42,                    " Line number (1-indexed)
  'column': 10,                  " Column number (1-indexed)
  'message': 'Trailing whitespace detected',
  'category': 'whitespace',      " whitespace, keyword, structure, genero
  'check': 'trailing_whitespace', " Specific check name
  'severity': 'warning',         " info, warning, style
  'auto_fix': {                  " Optional auto-fix suggestion
    'type': 'remove_trailing_ws',
    'description': 'Remove trailing whitespace'
  }
}
```

---

## File Structure

### New Files to Create

```
autoload/genero_tools/hints.vim                    # Main hint engine
autoload/genero_tools/hints/config.vim             # Configuration management
autoload/genero_tools/hints/display.vim            # Display system
autoload/genero_tools/hints/cache.vim              # Caching system
autoload/genero_tools/hints/nav.vim                # Navigation commands
autoload/genero_tools/hints/autofix.vim            # Auto-fix system
autoload/genero_tools/hints/whitespace.vim         # Whitespace detector
autoload/genero_tools/hints/keyword.vim            # Keyword detector
autoload/genero_tools/hints/structure.vim          # Structure detector
autoload/genero_tools/hints/genero.vim             # Genero-specific detector
```

### Files to Modify

```
autoload/genero_tools/config.vim                   # Add hint configuration options
autoload/genero_tools/commands.vim                 # Add hint commands
plugin/genero_tools.vim                            # Initialize hint system
```

### Test Files

```
tests/unit/test_hints.vim                          # Unit tests for hint engine
tests/unit/test_hints_config.vim                   # Configuration tests
tests/unit/test_hints_display.vim                  # Display system tests
tests/unit/test_hints_cache.vim                    # Cache system tests
tests/unit/test_hints_detectors.vim                # Detector tests
tests/properties/test_hints_properties.vim         # Property-based tests
tests/integration/test_hints_integration.vim       # Integration tests
```

---

## Configuration Schema

### Global Configuration

All hint configuration is stored in `g:genero_tools_config`:

```vim
" System-level options
hints_enabled: 1                    " Enable/disable all hints
hints_display: 'signs'              " 'signs', 'virtual_text', 'both'
hints_severity: 'warning'           " 'info', 'warning', 'style'
hints_realtime: 1                   " Enable real-time detection
hints_cache_enabled: 1              " Enable caching
hints_cache_ttl: 300                " Cache TTL in seconds
auto_fix_enabled: 1                 " Enable auto-fix suggestions
hints_delay: 500                    " Delay before analyzing (ms)

" Individual hint checks (1 = enabled, 0 = disabled)
trailing_whitespace: 1
mixed_indentation: 1
indentation_consistency: 1
multiple_blank_lines: 1
lowercase_keywords: 1
lowercase_functions: 1
keyword_consistency: 1
naming_convention: 0
unclosed_blocks: 1
nesting_depth: 1
line_length: 1
missing_comments: 0
missing_error_handling: 0
deprecated_functions: 1

" Threshold options
max_line_length: 100
max_nesting_depth: 5
max_blank_lines: 2
naming_convention_style: 'camelCase'
```

### Per-File Configuration

Optional `.genero-hints` file in project root (JSON format):

```json
{
  "rules": [
    {
      "pattern": "**/*.4gl",
      "config": {
        "max_line_length": 120,
        "lowercase_keywords": 0,
        "naming_convention": 1
      }
    },
    {
      "pattern": "legacy/**/*.4gl",
      "config": {
        "hints_enabled": 0
      }
    }
  ]
}
```

---

## Display Integration

### Sign Column Integration

Hints use distinct signs from compiler errors:

```vim
" Compiler errors (existing)
sign define GeneroCompilerError text=✕ texthl=ErrorMsg

" Hints (new)
sign define GeneroHintInfo text=◆ texthl=GeneroHintInfo
sign define GeneroHintWarning text=◆ texthl=GeneroHintWarning
sign define GeneroHintStyle text=◆ texthl=GeneroHintStyle
```

### Virtual Text (Neovim)

Virtual text is displayed at end of line with hint message:

```
42 | FUNCTION myFunc()              ◆ Lowercase keyword detected
```

### Highlight Groups

```vim
highlight GeneroHintInfo ctermfg=Blue guifg=#0087FF
highlight GeneroHintWarning ctermfg=Yellow guifg=#FFFF00
highlight GeneroHintStyle ctermfg=Cyan guifg=#00FFFF
```

---

## Performance Considerations

### Caching Strategy

1. **Cache Key**: `hints:{bufnr}:{file_hash}:{config_hash}`
2. **TTL**: Configurable (default 300 seconds)
3. **Invalidation**: On file modification, configuration change
4. **LRU Eviction**: When cache exceeds size limit

### Analysis Debouncing

- Real-time analysis is debounced with configurable delay (default 500ms)
- Prevents excessive analysis while user is typing
- Full analysis on file save

### Background Analysis

- Current file is prioritized
- Other open files analyzed in background when editor is idle
- Can be disabled for performance

### Memory Management

- Cache size limits prevent unbounded growth
- LRU eviction removes oldest entries
- Per-file cache entries are independent

---

## Vim/Neovim Compatibility

### Feature Detection

```vim
" Check for Neovim
if has('nvim')
  " Use Neovim-specific features
  " - Virtual text (nvim_buf_set_extmark)
  " - Floating windows (nvim_open_win)
else
  " Use Vim-compatible features
  " - Signs only
  " - Popup windows (if available)
endif
```

### Fallback Strategies

| Feature | Neovim | Vim | Fallback |
|---------|--------|-----|----------|
| Virtual Text | ✓ | ✗ | Signs only |
| Floating Window | ✓ | ✓ (8.1+) | Popup/Echo |
| Extmarks | ✓ | ✗ | Signs |
| Namespace | ✓ | ✗ | Global state |

---

## Error Handling

### Exception Handling

All detector modules wrap analysis in try-catch:

```vim
try
  let hints = genero_tools#hints#whitespace#detect(bufnr, config)
catch
  " Log error
  " Continue with other detectors
  " Return empty hint list for this detector
endtry
```

### Graceful Degradation

- If a detector fails, other detectors continue
- If display fails, try alternative display method
- If cache fails, re-analyze
- If configuration is invalid, use defaults

### User Feedback

- Errors logged to debug stream
- Warnings shown to user (configurable)
- Non-blocking: errors don't interrupt editing

---

## API Design

### Public Functions

```vim
" Initialize hint system
function! genero_tools#hints#init() abort

" Analyze buffer and return hints
function! genero_tools#hints#analyze(bufnr) abort

" Get cached hints
function! genero_tools#hints#get_hints(bufnr) abort

" Clear hints for buffer
function! genero_tools#hints#clear(bufnr) abort

" Navigation commands
function! genero_tools#hints#nav#next() abort
function! genero_tools#hints#nav#prev() abort
function! genero_tools#hints#nav#list() abort
function! genero_tools#hints#nav#details() abort

" Auto-fix
function! genero_tools#hints#autofix#apply() abort

" Configuration
function! genero_tools#hints#config#get_for_file(file_path) abort
function! genero_tools#hints#config#validate(config) abort
```

### Internal Helper Functions

```vim
" Detector registration
function! genero_tools#hints#register_detector(name, detector_func) abort

" Hint creation
function! genero_tools#hints#create_hint(line, col, message, category, check, severity) abort

" Cache management
function! genero_tools#hints#cache#get(bufnr) abort
function! genero_tools#hints#cache#set(bufnr, hints) abort
function! genero_tools#hints#cache#invalidate(bufnr) abort
```

### Integration Points

1. **Configuration System**: Uses existing `g:genero_tools_config`
2. **Display System**: Uses existing sign column and display modes
3. **Cache System**: Uses existing cache infrastructure
4. **Error Handling**: Uses existing error handling patterns
5. **Commands**: Registers new commands with existing command system

---

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

Before writing correctness properties, I need to analyze the acceptance criteria for testability. Let me use the prework tool to formalize this analysis.


### Acceptance Criteria Testing Prework

Based on analysis of the 24 requirements with 120+ acceptance criteria, the following testability assessment was performed:

**Summary:**
- Testable as properties: ~95 criteria
- Testable as examples: ~15 criteria  
- Not testable (architectural/UI): ~10 criteria

**Key Findings:**
- Most functional requirements are testable through property-based testing
- Configuration and behavior requirements map well to universal properties
- UI interactions (hover, click) are not automatically testable
- Architectural requirements about code organization are not functionally testable
- Performance requirements can be tested through timing measurements

### Property Reflection

After analyzing all testable criteria, the following redundancies were identified and consolidated:

**Consolidated Properties:**
1. Configuration loading (1.3, 6.1, 16.1) → Single property: "Configuration is loaded from all sources"
2. Default fallback (1.4, 6.5, 21.3) → Single property: "Invalid configuration falls back to defaults"
3. Display mode selection (7.1, 7.2, 7.3) → Single property: "Display mode determines hint rendering method"
4. Severity assignment (8.1, 8.2, 8.3, 8.4) → Single property: "Severity level is assigned and respected"
5. Sign column integration (9.1, 9.2, 9.3, 9.6) → Single property: "Hints integrate with sign column system"
6. Real-time analysis (11.1, 11.3, 11.4, 11.5) → Single property: "Analysis respects real-time and debounce settings"
7. Navigation (12.1, 12.2, 12.5) → Single property: "Navigation commands move between hints correctly"
8. Cache management (17.1, 17.2, 17.3, 17.4, 17.6) → Single property: "Cache stores and invalidates hints correctly"
9. Compatibility (18.1, 18.2, 18.3, 18.4, 18.5) → Single property: "System adapts to editor capabilities"
10. Error handling (21.1, 21.2, 21.4, 21.5) → Single property: "Errors are handled gracefully without interruption"

---

## Correctness Properties

### Property 1: Hint Engine Initialization

*For any* plugin initialization, the Hint Engine should initialize with default configuration, load user configuration from g:genero_tools_config, and use sensible defaults when configuration is missing.

**Validates: Requirements 1.1, 1.3, 1.4**

### Property 2: File Registration

*For any* Genero file opened in the editor, the file should be registered with the Hint Engine for analysis.

**Validates: Requirements 1.2**

### Property 3: Dependency Verification

*For any* plugin initialization, the Hint Engine should verify that required dependencies are available and report any missing dependencies.

**Validates: Requirements 1.5**

### Property 4: Whitespace Detection

*For any* code buffer containing trailing whitespace, mixed indentation, inconsistent indentation, or excessive blank lines, the Hint Engine should detect and report these issues with correct line and column positions.

**Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5**

### Property 5: Keyword Detection

*For any* code buffer containing lowercase keywords, lowercase built-in functions, or inconsistent keyword casing, the Hint Engine should detect and report these issues.

**Validates: Requirements 3.1, 3.2, 3.3**

### Property 6: Naming Convention Detection

*For any* code buffer with variable naming convention violations, the Hint Engine should detect and report these issues when the naming_convention check is enabled.

**Validates: Requirements 3.4**

### Property 7: Code Structure Detection

*For any* code buffer containing unclosed blocks, excessive nesting depth, long lines, or complex functions lacking comments, the Hint Engine should detect and report these issues.

**Validates: Requirements 4.1, 4.2, 4.3, 4.4**

### Property 8: Genero-Specific Detection

*For any* code buffer containing missing error handling or deprecated functions, the Hint Engine should detect and report these issues when the respective checks are enabled.

**Validates: Requirements 5.1, 5.2**

### Property 9: Configuration Loading

*For any* plugin initialization, the Configuration System should read hint settings from g:genero_tools_config, apply them to all files in the project, and use those settings as project defaults.

**Validates: Requirements 6.1, 16.1, 16.2**

### Property 10: Configuration Validation

*For any* invalid configuration provided to the system, the Configuration System should use sensible defaults and warn the user.

**Validates: Requirements 6.5, 21.3**

### Property 11: Individual Check Control

*For any* hint check that is disabled in configuration, the Hint Engine should not generate hints for that check.

**Validates: Requirements 6.2, 6.3**

### Property 12: Threshold Respect

*For any* threshold value set in configuration, the Hint Engine should use that value for hint detection (e.g., max_line_length, max_nesting_depth).

**Validates: Requirements 6.4**

### Property 13: Per-File Configuration Loading

*For any* .genero-hints file existing in the project root, the Configuration System should read per-file rules and apply them to matching files.

**Validates: Requirements 6.7, 15.1, 15.2**

### Property 14: Configuration Merging

*For any* file matching multiple configuration patterns, the Configuration System should merge rules with project-wide settings, with per-file settings taking precedence.

**Validates: Requirements 15.3**

### Property 15: Configuration Fallback

*For any* invalid per-file configuration, the Configuration System should fall back to project-wide settings.

**Validates: Requirements 15.4**

### Property 16: Configuration Reload

*For any* modification to .genero-hints file, the Configuration System should reload configuration on the next file save.

**Validates: Requirements 15.5**

### Property 17: Configuration Application

*For any* configuration change, the Configuration System should apply changes to all open files immediately.

**Validates: Requirements 16.4**

### Property 18: New File Configuration

*For any* new file opened in the editor, the Configuration System should apply current project-wide configuration to that file.

**Validates: Requirements 16.5**

### Property 19: Display Mode Selection

*For any* hints_display setting ('signs', 'virtual_text', or 'both'), the Display System should render hints using the specified method(s).

**Validates: Requirements 7.1, 7.2, 7.3**

### Property 20: Hint Positioning

*For any* hint detected in code, the Display System should show the hint at the correct line and column position.

**Validates: Requirements 7.4**

### Property 21: Display Fallback

*For any* request for virtual_text display in Vim (which doesn't support it), the Display System should fall back to signs-only display.

**Validates: Requirements 7.5**

### Property 22: Display Update

*For any* change to hints_display setting, the Display System should update all displayed hints immediately to reflect the new display method.

**Validates: Requirements 7.6**

### Property 23: Severity Assignment

*For any* hint generated by the Hint Engine, the hint should be assigned a severity level (info, warning, or style) and that severity should be respected in display and configuration.

**Validates: Requirements 8.1, 8.2, 8.3, 8.4**

### Property 24: Severity Visual Distinction

*For any* hint displayed, the Display System should use a visual indicator (sign character, color, highlight group) matching the severity level.

**Validates: Requirements 8.5**

### Property 25: Sign Column Integration

*For any* enabled hints, the Sign Column System should reserve space for hint signs and display hint signs (◆ or similar) at the correct line.

**Validates: Requirements 9.1, 9.2**

### Property 26: Multiple Signs on Same Line

*For any* line containing both compiler errors and hints, the Sign Column System should display both signs without conflict.

**Validates: Requirements 9.3**

### Property 27: Unified Sign Column

*For any* unified sign column enabled, the Sign Column System should combine compiler, SVN, and hint signs appropriately.

**Validates: Requirements 9.4**

### Property 28: Sign Removal

*For any* disabled hints, the Sign Column System should remove hint signs from the display.

**Validates: Requirements 9.6**

### Property 29: Error vs Hint Visual Distinction

*For any* compiler error and hint displayed together, the Display System should ensure they are visually distinct through different sign characters, colors, or highlight groups.

**Validates: Requirements 10.1, 10.2, 10.3, 10.4**

### Property 30: Real-Time Analysis

*For any* user typing in a Genero file with hints_realtime enabled, the Hint Engine should analyze the file after the configured hints_delay and detect hints as the user types.

**Validates: Requirements 11.1, 11.3, 11.5**

### Property 31: Save Analysis

*For any* file save event, the Hint Engine should perform a full analysis and update all hints.

**Validates: Requirements 11.2**

### Property 32: Real-Time Disable

*For any* hints_realtime disabled, the Hint Engine should only detect hints on file save, not while typing.

**Validates: Requirements 11.4**

### Property 33: Analysis Progress

*For any* analysis in progress, the Display System should show a progress indicator to the user.

**Validates: Requirements 11.6**

### Property 34: Next Hint Navigation

*For any* execution of :GeneroNextHint command, the Navigation System should jump to the next hint in the file after the current cursor position.

**Validates: Requirements 12.1**

### Property 35: Previous Hint Navigation

*For any* execution of :GeneroPrevHint command, the Navigation System should jump to the previous hint in the file before the current cursor position.

**Validates: Requirements 12.2**

### Property 36: List Hints

*For any* execution of :GeneroListHints command, the Navigation System should display all hints in the current file in a list.

**Validates: Requirements 12.3**

### Property 37: Hint Selection

*For any* selection of a hint from the list, the Navigation System should jump to that hint's location.

**Validates: Requirements 12.4**

### Property 38: Navigation Wrap-Around

*For any* navigation past the last hint in a direction, the Navigation System should wrap around to the beginning or display a message.

**Validates: Requirements 12.5**

### Property 39: Navigation Highlight

*For any* navigation to a hint, the Display System should highlight the hint and show details.

**Validates: Requirements 12.6**

### Property 40: Hint Details Display

*For any* execution of :GeneroHintDetails command, the Display System should show detailed information about the hint at the cursor including message, severity, category, and line number.

**Validates: Requirements 13.2, 13.3**

### Property 41: Auto-Fix Suggestion Display

*For any* hint with an available auto-fix suggestion, the Display System should include the suggestion in the hint details.

**Validates: Requirements 13.4**

### Property 42: Hint Explanation

*For any* hint details displayed, the Display System should explain why the hint was triggered.

**Validates: Requirements 13.5**

### Property 43: Auto-Fix Generation

*For any* hint detected, the Hint Engine should generate an auto-fix suggestion if one is available for that hint type.

**Validates: Requirements 14.1**

### Property 44: Auto-Fix Application

*For any* execution of :GeneroHintAutofix command, the Auto-Fix System should apply the fix for the hint at the cursor and update the file.

**Validates: Requirements 14.2**

### Property 45: Auto-Fix Re-Analysis

*For any* auto-fix applied, the Auto-Fix System should re-analyze the affected lines and update the hint display.

**Validates: Requirements 14.3**

### Property 46: Auto-Fix Enable

*For any* auto_fix_enabled set to 1, the Auto-Fix System should provide auto-fix suggestions for applicable hints.

**Validates: Requirements 14.4**

### Property 47: Auto-Fix Disable

*For any* auto_fix_enabled set to 0, the Auto-Fix System should not generate or apply fixes.

**Validates: Requirements 14.5**

### Property 48: Auto-Fix Display Update

*For any* auto-fix applied, the Display System should update the hint display immediately to reflect the changes.

**Validates: Requirements 14.6**

### Property 49: Extensibility

*For any* new hint check registered with the Hint Engine, the check should be executed during analysis without requiring modifications to core code.

**Validates: Requirements 20.2**

### Property 50: Efficient Processing

*For any* hint analysis, the Hint Engine should process all enabled checks efficiently.

**Validates: Requirements 20.3**

### Property 51: Async Support

*For any* plugin execution, the Hint Engine should support both synchronous and asynchronous analysis modes.

**Validates: Requirements 20.4**

### Property 52: Error Logging

*For any* hint analysis failure, the Error Handler should log the error and continue operation without interrupting the user.

**Validates: Requirements 21.1, 21.5**

### Property 53: Exception Handling

*For any* hint check that throws an exception, the Error Handler should catch it and skip that check while continuing with other checks.

**Validates: Requirements 21.2**

### Property 54: Display Fallback

*For any* display method failure, the Error Handler should fall back to an alternative display method.

**Validates: Requirements 21.4**

### Property 55: Cache Storage

*For any* hint analysis, the Hint Engine should cache results with a timestamp when hints_cache_enabled is 1.

**Validates: Requirements 17.1**

### Property 56: Cache Hit

*For any* unchanged file, the Hint Engine should use cached hints instead of re-analyzing.

**Validates: Requirements 17.2**

### Property 57: Cache Invalidation

*For any* file modification, the Hint Engine should invalidate the cache for that file.

**Validates: Requirements 17.3**

### Property 58: Cache Eviction

*For any* cache size exceeding configured limits, the Hint Engine should evict oldest entries using LRU strategy.

**Validates: Requirements 17.4**

### Property 59: Cache Clearing

*For any* execution of :GeneroClearHintCache command, the Hint Engine should clear all cached hints.

**Validates: Requirements 17.5**

### Property 60: Cache Disable

*For any* hints_cache_enabled set to 0, the Hint Engine should not cache hint results.

**Validates: Requirements 17.6**

### Property 61: Vim Compatibility

*For any* plugin execution in Vim, the Hint Engine should use Vim-compatible display methods.

**Validates: Requirements 18.1**

### Property 62: Neovim Features

*For any* plugin execution in Neovim, the Hint Engine should use Neovim-specific features when available.

**Validates: Requirements 18.2**

### Property 63: Graceful Degradation

*For any* unavailable feature in the current editor, the Display System should gracefully degrade to an alternative method.

**Validates: Requirements 18.5**

### Property 64: Configuration Options Support

*For any* plugin initialization, the Configuration System should support all documented configuration options with appropriate defaults.

**Validates: Requirements 19.1, 19.2, 19.3**

### Property 65: Sign Column Coexistence

*For any* enabled hints, the Integration System should work seamlessly with the existing sign column system without conflicts.

**Validates: Requirements 23.1**

### Property 66: Config System Integration

*For any* enabled hints, the Integration System should work seamlessly with the existing configuration system.

**Validates: Requirements 23.2**

### Property 67: Display Mode Integration

*For any* enabled hints, the Integration System should work seamlessly with existing display modes.

**Validates: Requirements 23.3**

### Property 68: Error Handling Integration

*For any* enabled hints, the Integration System should work seamlessly with the existing error handling system.

**Validates: Requirements 23.4**

### Property 69: Error and Hint Coexistence

*For any* buffer containing both compiler errors and hints, the Integration System should display both without conflicts.

**Validates: Requirements 23.5**

### Property 70: Analysis Performance

*For any* file analysis, the Hint Engine should complete analysis within the configured hints_delay milliseconds.

**Validates: Requirements 24.1**

### Property 71: File Prioritization

*For any* multiple open files, the Hint Engine should prioritize analysis of the current file.

**Validates: Requirements 24.2**

### Property 72: Background Analysis

*For any* idle editor state, the Hint Engine should perform background analysis on other open files.

**Validates: Requirements 24.3**

### Property 73: Resource Management

*For any* low system resources, the Hint Engine should reduce analysis frequency to maintain responsiveness.

**Validates: Requirements 24.4**

### Property 74: Debouncing

*For any* rapid user typing, the Hint Engine should debounce analysis requests to avoid excessive analysis.

**Validates: Requirements 24.5**

---

## Error Handling

### Exception Handling Strategy

All hint detection modules wrap analysis in try-catch blocks:

```vim
try
  let hints = genero_tools#hints#whitespace#detect(bufnr, config)
catch /.*/ 
  " Log error
  call genero_tools#error#log('Whitespace detector failed: ' . v:exception)
  " Continue with other detectors
  let hints = []
endtry
```

### Graceful Degradation

1. **Display Failure**: Fall back from virtual_text → signs → echo
2. **Cache Failure**: Re-analyze instead of using cache
3. **Configuration Failure**: Use defaults
4. **Detector Failure**: Skip detector, continue with others
5. **File Access Failure**: Log error, skip file

### User Feedback

- Errors logged to debug stream (if enabled)
- Warnings shown to user (configurable)
- Non-blocking: errors don't interrupt editing

---

## Testing Strategy

### Dual Testing Approach

The hint system requires both unit tests and property-based tests for comprehensive coverage:

**Unit Tests** (specific examples and edge cases):
- Configuration loading with various input formats
- Individual detector behavior with specific code samples
- Display rendering with different configurations
- Navigation commands with various hint distributions
- Auto-fix application for each fix type
- Error handling with various failure scenarios

**Property-Based Tests** (universal properties across all inputs):
- For each of the 74 correctness properties above
- Minimum 100 iterations per property test
- Random input generation for code buffers, configurations, and file states
- Verification of property invariants across all generated inputs

### Property Test Configuration

Each property test should:
1. Reference the design document property number
2. Use tag format: `Feature: configurable-code-hints, Property {number}: {property_text}`
3. Run minimum 100 iterations
4. Generate random but valid inputs
5. Verify the property holds for all inputs

### Test File Organization

```
tests/unit/test_hints.vim                    # Core engine tests
tests/unit/test_hints_config.vim             # Configuration tests
tests/unit/test_hints_display.vim            # Display system tests
tests/unit/test_hints_cache.vim              # Cache system tests
tests/unit/test_hints_detectors.vim          # Individual detector tests
tests/unit/test_hints_nav.vim                # Navigation tests
tests/unit/test_hints_autofix.vim            # Auto-fix tests
tests/properties/test_hints_properties.vim   # Property-based tests
tests/integration/test_hints_integration.vim # Integration tests
```

### Coverage Goals

- Unit tests: 100% of public API functions
- Property tests: All 74 correctness properties
- Integration tests: Interaction with existing systems
- Edge cases: Empty files, large files, invalid configurations, missing dependencies

---

## Design Decisions and Rationales

### 1. Modular Architecture

**Decision**: Separate hint detection, configuration, display, and caching into independent modules.

**Rationale**: 
- Allows independent testing and development
- Makes it easy to add new detectors without modifying core code
- Enables reuse of components in other contexts
- Follows existing plugin patterns

### 2. Configuration Hierarchy

**Decision**: Support project-wide, per-file, and default configurations with clear precedence.

**Rationale**:
- Allows flexibility for different project needs
- Per-file configuration enables gradual adoption
- Clear precedence prevents confusion
- Follows common configuration patterns

### 3. Caching Strategy

**Decision**: Cache hints with file and configuration hashes, invalidate on changes.

**Rationale**:
- Improves performance for unchanged files
- Handles configuration changes correctly
- LRU eviction prevents unbounded memory growth
- Configurable TTL allows tuning for different workflows

### 4. Real-Time with Debouncing

**Decision**: Analyze on file changes with configurable delay, full analysis on save.

**Rationale**:
- Provides immediate feedback without excessive analysis
- Debouncing prevents slowdown during rapid typing
- Full analysis on save ensures accuracy
- Configurable delay allows tuning for different systems

### 5. Display Flexibility

**Decision**: Support signs, virtual text, or both with automatic fallback.

**Rationale**:
- Accommodates different user preferences
- Neovim users get enhanced experience with virtual text
- Vim users get reliable sign-based display
- Automatic fallback ensures feature works everywhere

### 6. Severity Levels

**Decision**: Assign severity (info, warning, style) to each hint with configurable override.

**Rationale**:
- Allows users to prioritize which hints to address
- Enables filtering by severity
- Supports different visual indicators per severity
- Configurable override allows project-wide policy

### 7. Error Handling

**Decision**: Catch exceptions in detectors, log errors, continue with other detectors.

**Rationale**:
- One detector failure doesn't break entire system
- Errors are logged for debugging
- User editing is never interrupted
- System remains responsive even with errors

---

## Future Enhancements

Potential improvements for future versions:

1. **Machine Learning**: Learn coding patterns and suggest hints based on project style
2. **Custom Detectors**: Allow users to write custom hint detectors in Lua
3. **Hint Suppression**: Allow suppressing hints for specific lines with comments
4. **Hint Statistics**: Track which hints are most common and suggest configuration changes
5. **Integration with LSP**: Use LSP diagnostics for some hint types
6. **Hint Grouping**: Group related hints and show summary
7. **Batch Operations**: Apply auto-fixes to multiple hints at once
8. **Hint History**: Track hint changes over time
9. **Team Configuration**: Share hint configuration across team via version control
10. **Performance Profiling**: Built-in profiling to identify slow detectors

