# Format Integration Documentation

## Overview

This document describes how the vim-genero-tools plugin integrates the three output formats from genero-tools for optimized display in different contexts.

## Format Types

### 1. Concise Format (`--format=vim`)

**Purpose:** Single-line function signatures for quick reference  
**Use Cases:** Status bar, quick info popups, code hints

**Output Example:**
```
calculate(amount: DECIMAL, rate: DECIMAL) -> DECIMAL
```

**Plugin Features Using Concise Format:**
- Function signature display (`GeneroFunctionSignature` command)
- Code hints (inline function information)
- Status bar display (current function signature)

**Implementation:**
```vim
" Get function signature in concise format
let result = genero_tools#get_function_concise('function_name')
" result.data contains: "function_name(params) -> return_type"
```

### 2. Hover Format (`--format=vim-hover`)

**Purpose:** Detailed information for hover tooltips  
**Use Cases:** Hover information, search results

**Output Example:**
```
calculate(amount: DECIMAL, rate: DECIMAL) -> DECIMAL
File: src/math.4gl:42
Complexity: 5, LOC: 23
```

**Plugin Features Using Hover Format:**
- Hover information display (when hovering over function names)
- Search results display (detailed function information)

**Implementation:**
```vim
" Get function hover information
let result = genero_tools#get_function_hover('function_name')
" result.data contains three-line format:
" Line 1: function_name(params) -> return_type
" Line 2: File: path/to/file.4gl:line_number
" Line 3: Complexity: N, LOC: M
```

### 3. Completion Format (`--format=vim-completion`)

**Purpose:** Tab-separated format for Vim/Neovim completion  
**Use Cases:** Autocomplete suggestions

**Output Example:**
```
get_account	function(id: INTEGER) -> RECORD	src/queries.4gl:128 | Complexity: 3, LOC: 15
get_balance	function(account_id: INTEGER) -> DECIMAL	src/queries.4gl:156 | Complexity: 2, LOC: 8
```

**Format Breakdown:**
- Column 1 (word): Function name (the completion word)
- Column 2 (menu): Function signature (displayed in completion menu)
- Column 3 (info): File location and metrics (displayed in info window)

**Plugin Features Using Completion Format:**
- Autocomplete suggestions (when typing function names)

**Implementation:**
```vim
" Get completions with format flag
let result = genero_tools#format#execute_with_format('search-functions', [prefix], 'vim-completion')
" Parse tab-separated output
for line in split(result.data, "\n")
  let parts = split(line, "\t")
  let word = parts[0]
  let menu = parts[1]
  let info = parts[2]
endfor
```

## Format Flag Integration

### Helper Functions

The `autoload/genero_tools/format.vim` module provides helper functions for format flag integration:

#### `genero_tools#format#add_flag(args, format)`

Adds a format flag to query arguments.

**Parameters:**
- `args` (list): Query arguments
- `format` (string): Format name (e.g., 'vim', 'vim-hover', 'vim-completion')

**Returns:** Modified arguments list with format flag appended

**Example:**
```vim
let args = ['function_name']
let args_with_format = genero_tools#format#add_flag(args, 'vim-hover')
" Result: ['function_name', '--format=vim-hover']
```

#### `genero_tools#format#execute_with_format(command, args, format)`

Executes a query command with format flag.

**Parameters:**
- `command` (string): Query command (e.g., 'find-function', 'search-functions')
- `args` (list): Query arguments
- `format` (string): Format name

**Returns:** Result dictionary with success flag and data

**Example:**
```vim
let result = genero_tools#format#execute_with_format('find-function', ['my_func'], 'vim-hover')
if result.success
  echo result.data
endif
```

#### Format Getter Functions

```vim
" Get hover format
let format = genero_tools#format#get_hover_format()
" Returns: 'vim-hover'

" Get concise format
let format = genero_tools#format#get_concise_format()
" Returns: 'vim'

" Get completion format
let format = genero_tools#format#get_completion_format()
" Returns: 'vim-completion'
```

## Plugin Features

### 1. Hover Information Display

**Command:** (Implicit - triggered by hover keybinding or LSP)  
**Format Used:** `--format=vim-hover`  
**Display Mode:** Floating window or preview window

**How It Works:**
1. User hovers over a function name
2. Plugin queries genero-tools with `--format=vim-hover`
3. Output is split into three lines
4. Lines are displayed in floating window

**Example Output:**
```
calculate(amount: DECIMAL, rate: DECIMAL) -> DECIMAL
File: src/math.4gl:42
Complexity: 5, LOC: 23
```

### 2. Autocomplete Suggestions

**Trigger:** Ctrl+X Ctrl+O (omnifunc) or automatic on pause  
**Format Used:** `--format=vim-completion`  
**Display Mode:** Completion menu with preview

**How It Works:**
1. User types function name prefix
2. Plugin queries genero-tools with `--format=vim-completion`
3. Output is parsed (split on tabs)
4. Completions are added to completion menu
5. Menu shows function name, signature, and file location

**Example Completion Item:**
```
Word: get_account
Menu: function(id: INTEGER) -> RECORD
Info: src/queries.4gl:128 | Complexity: 3, LOC: 15
```

### 3. Function Signature Display

**Command:** `:GeneroFunctionSignature [function_name]`  
**Format Used:** `--format=vim`  
**Display Mode:** Echo or configured display mode

**How It Works:**
1. User runs command with function name
2. Plugin queries genero-tools with `--format=vim`
3. Single-line signature is displayed

**Example Output:**
```
calculate(amount: DECIMAL, rate: DECIMAL) -> DECIMAL
```

### 4. Search Results Display

**Format Used:** `--format=vim-hover`  
**Display Mode:** Quickfix list

**How It Works:**
1. User searches for functions
2. Plugin queries genero-tools with `--format=vim-hover`
3. Results are split into groups of three lines
4. Each group is added to quickfix list
5. User can navigate results with quickfix commands

**Example Quickfix Entry:**
```
calculate(amount: DECIMAL, rate: DECIMAL) -> DECIMAL
File: src/math.4gl:42
Complexity: 5, LOC: 23
```

## Output Parsing

### Concise Format Parsing

```vim
" Input: "function_name(params) -> return_type"
" Output: Single line, use directly
echo trim(output)
```

### Hover Format Parsing

```vim
" Input: Three lines separated by newlines
let lines = split(output, "\n")
" lines[0] = signature
" lines[1] = file location
" lines[2] = complexity metrics
```

### Completion Format Parsing

```vim
" Input: Tab-separated lines
for line in split(output, "\n")
  let parts = split(line, "\t")
  let word = parts[0]      " Function name
  let menu = parts[1]      " Function signature
  let info = parts[2]      " File location and metrics
endfor
```

## Error Handling

### Query Errors

If a query fails, the plugin displays an error message and falls back to default behavior:

```vim
if !result.success
  call genero_tools#error#error('Feature', 'Query failed: ' . result.error)
  return
endif
```

### Empty Results

If no results are found, the plugin displays a helpful message:

```vim
if empty(result.data)
  call genero_tools#error#warn('Feature', 'No results found')
  return
endif
```

### Format Errors

If output parsing fails, the plugin displays a diagnostic message:

```vim
try
  let parts = split(line, "\t")
  if len(parts) < 3
    call genero_tools#error#debug('Feature', 'Invalid format: ' . line)
  endif
catch
  call genero_tools#error#debug('Feature', 'Parse error: ' . v:exception)
endtry
```

## Performance Characteristics

### Query Execution Time

| Format | Typical Time | Large Codebase |
|--------|--------------|----------------|
| Concise | <10ms | <50ms |
| Hover | <15ms | <75ms |
| Completion | <20ms | <100ms |

All formats meet the <100ms performance target.

### Caching

The plugin caches query results to avoid repeated queries:

```vim
let cache_key = 'find-function-hover:' . function_name
let cached = genero_tools#cache#get(cache_key)
if !empty(cached)
  return cached
endif
```

## Backward Compatibility

The format flag integration maintains full backward compatibility:

- Existing commands continue to work
- Existing keybindings continue to work
- Existing configuration options continue to work
- No breaking changes to plugin API

## Troubleshooting

### Format Flags Not Working

**Problem:** Queries don't include format flags  
**Solution:** Verify genero-tools version supports format flags

```bash
bash query.sh find-function "test" --format=vim
```

### Output Not Displaying Correctly

**Problem:** Formatted output not displayed as expected  
**Solution:** Check display mode configuration

```vim
let display_mode = genero_tools#config#get('display_mode')
echo 'Current display mode: ' . display_mode
```

### Performance Issues

**Problem:** Queries are slow  
**Solution:** Use concise format for quick queries, enable caching

```vim
" Use concise format for faster queries
let result = genero_tools#get_function_concise('function_name')

" Check cache statistics
call genero_tools#cache#stats()
```

## Examples

### Example 1: Display Function Signature

```vim
" Get and display function signature
let result = genero_tools#get_function_concise('calculate')
if result.success
  echo result.data
endif
```

### Example 2: Get Hover Information

```vim
" Get hover information for function
let result = genero_tools#get_function_hover('calculate')
if result.success
  let lines = split(result.data, "\n")
  echo 'Signature: ' . lines[0]
  echo 'Location: ' . lines[1]
  echo 'Metrics: ' . lines[2]
endif
```

### Example 3: Parse Completion Results

```vim
" Get completions and parse format
let result = genero_tools#format#execute_with_format('search-functions', ['get_*'], 'vim-completion')
if result.success
  for line in split(result.data, "\n")
    let parts = split(line, "\t")
    echo 'Function: ' . parts[0]
    echo 'Signature: ' . parts[1]
    echo 'Info: ' . parts[2]
  endfor
endif
```

## Related Documentation

- [VIM_OUTPUT_FORMATS.md](../update/VIM_OUTPUT_FORMATS.md) - Format specifications
- [FORMAT_EXAMPLES.md](../update/FORMAT_EXAMPLES.md) - Concrete examples
- [VIM_PLUGIN_INTEGRATION_GUIDE.md](../update/VIM_PLUGIN_INTEGRATION_GUIDE.md) - Integration patterns

---

**Status:** Documentation Complete  
**Created:** 2026-03-26  
**Version:** 1.0
