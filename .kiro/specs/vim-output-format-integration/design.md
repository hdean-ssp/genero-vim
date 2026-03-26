# Design Document: Vim Output Format Integration

## Overview

This document provides the technical design for implementing refined output format flags from genero-tools into the vim-genero-tools plugin. The design specifies the architecture, implementation approach, and correctness properties for each plugin feature.

## Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Vim/Neovim Editor                        │
├─────────────────────────────────────────────────────────────┤
│                   vim-genero-tools Plugin                   │
├──────────────────────────────────────────────────────────────┤
│  Feature Layer                                               │
│  ├─ Hover Display (vim-hover format)                        │
│  ├─ Autocomplete (vim-completion format)                    │
│  ├─ Code Hints (vim format)                                 │
│  ├─ Status Bar (vim format)                                 │
│  └─ Search Results (vim-hover format)                       │
├──────────────────────────────────────────────────────────────┤
│  Format Integration Layer                                    │
│  ├─ Format Flag Manager (--format option)                   │
│  ├─ Output Parser (concise, hover, completion)              │
│  ├─ Error Handler (validation, fallback)                    │
│  └─ Performance Optimizer (caching, async)                  │
├──────────────────────────────────────────────────────────────┤
│  Query Layer                                                 │
│  ├─ Query Builder (construct query with flags)              │
│  ├─ Query Executor (run genero-tools query)                 │
│  └─ Result Cache (cache query results)                      │
├──────────────────────────────────────────────────────────────┤
│                    genero-tools Query System                 │
│  ├─ find-function --format=vim|vim-hover|vim-completion    │
│  ├─ search-functions --format=vim|vim-hover|vim-completion │
│  └─ Other query commands with format support                │
└─────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

**Feature Layer:**
- Handles user interactions (hover, autocomplete, hints, etc.)
- Determines which format to use for each feature
- Displays results to the user

**Format Integration Layer:**
- Manages format flags and options
- Parses output in each format
- Handles errors and edge cases
- Optimizes performance

**Query Layer:**
- Constructs query commands with format flags
- Executes queries against genero-tools
- Caches results for performance

## Format Integration Design

### 1. Concise Format (`--format=vim`)

**Purpose:** Single-line function signatures for quick reference

**Format Pattern:**
```
function_name(param1: TYPE1, param2: TYPE2, ...) -> RETURN_TYPE
```

**Display Implementation:**
- Status bar: Display signature directly
- Code hints: Echo signature directly
- Inline: Show signature in popup

**Processing:** Trim whitespace, display as-is

**Performance:** <5ms for display

### 2. Hover Format (`--format=vim-hover`)

**Purpose:** Detailed function information for hover tooltips

**Format Pattern:**
```
function_name(param1: TYPE1, param2: TYPE2, ...) -> RETURN_TYPE
File: path/to/file.4gl:line_number
Complexity: N, LOC: M
```

**Display Implementation:**
- Hover tooltip: Split lines and display in floating window
- Search results: Split lines and display in quickfix list
- Preview window: Split lines and display in preview window

**Processing:** Split on newlines, display lines directly

**Performance:** <5ms for display

### 3. Completion Format (`--format=vim-completion`)

**Purpose:** Tab-separated format for autocomplete integration

**Format Pattern:**
```
word<TAB>menu<TAB>info
```

**Display Implementation:**
- Autocomplete menu: Split tabs and pass to Vim's completion API
- Info window: Tab-separated columns displayed by Vim

**Processing:** Split on newlines, split each line on tabs, pass to completion API

**Performance:** <5ms for display

## Feature Implementation Details

### Feature 1: Hover Information Display

**Implementation Steps:**
1. User hovers over function name
2. Plugin detects hover event
3. Plugin queries genero-tools with `--format=vim-hover`
4. Plugin parses three-line hover format
5. Plugin displays information in floating window

**Code Structure:**
```vim
" autoload/genero_tools/hover.vim
function! genero_tools#hover#show_info(func_name)
  " Query with hover format
  let cmd = s:build_query_command(a:func_name, 'vim-hover')
  let output = system(cmd)
  
  if v:shell_error != 0
    call s:handle_error(output)
    return
  endif
  
  " Parse hover format
  let info = s:parse_hover_format(output)
  
  " Display in floating window
  call s:display_hover_window(info)
endfunction
```

**Correctness Properties:**
- Property: Hover format output SHALL be parsed into three components (signature, file, metrics)
- Property: Parsed components SHALL match expected values
- Property: Floating window SHALL display all three components
- Edge case: Missing metadata SHALL display "unknown"

### Feature 2: Autocomplete Suggestions

**Implementation Steps:**
1. User triggers autocomplete
2. Plugin queries genero-tools with `--format=vim-completion`
3. Plugin parses tab-separated completion format
4. Plugin displays completions in autocomplete menu

**Code Structure:**
```vim
" autoload/genero_tools/complete.vim
function! genero_tools#complete#get_completions(prefix)
  " Query with completion format
  let cmd = s:build_query_command(a:prefix . '*', 'vim-completion')
  let output = system(cmd)
  
  if v:shell_error != 0
    return []
  endif
  
  " Parse completion format
  let completions = s:parse_completion_format(output)
  
  return completions
endfunction
```

**Correctness Properties:**
- Property: Completion format output SHALL be parsed into completion items
- Property: Each completion item SHALL have word, menu, and info
- Property: Completion menu SHALL display word and menu text
- Edge case: Missing columns SHALL be handled gracefully

### Feature 3: Code Hints Display

**Implementation Steps:**
1. User requests code hints
2. Plugin queries genero-tools with `--format=vim`
3. Plugin parses single-line concise format
4. Plugin displays signature in hint

**Code Structure:**
```vim
" autoload/genero_tools/hints.vim
function! genero_tools#hints#show_signature(func_name)
  " Query with concise format
  let cmd = s:build_query_command(a:func_name, 'vim')
  let output = system(cmd)
  
  if v:shell_error != 0
    return
  endif
  
  " Parse concise format
  let info = s:parse_concise_format(output)
  
  " Display in hint
  call s:display_hint(info.signature)
endfunction
```

**Correctness Properties:**
- Property: Concise format output SHALL be single line
- Property: Signature SHALL contain function name, parameters, and return type
- Property: Hint display SHALL show complete signature
- Edge case: No parameters or return type SHALL be handled

### Feature 4: Function Signature in Status Bar

**Implementation Steps:**
1. User moves cursor to function
2. Plugin detects cursor position
3. Plugin queries genero-tools with `--format=vim`
4. Plugin parses concise format
5. Plugin updates status bar

**Code Structure:**
```vim
" autoload/genero_tools/statusline.vim
function! genero_tools#statusline#get_signature()
  " Get current function name
  let func_name = s:get_current_function()
  
  if empty(func_name)
    return ''
  endif
  
  " Query with concise format
  let cmd = s:build_query_command(func_name, 'vim')
  let output = system(cmd)
  
  if v:shell_error != 0
    return ''
  endif
  
  " Parse concise format
  let info = s:parse_concise_format(output)
  
  return info.signature
endfunction
```

**Correctness Properties:**
- Property: Status bar SHALL display current function signature
- Property: Signature SHALL update when cursor moves to different function
- Property: Signature SHALL be complete and accurate
- Edge case: No function at cursor SHALL display empty

### Feature 5: Search Results Display

**Implementation Steps:**
1. User searches for functions
2. Plugin queries genero-tools with `--format=vim-hover`
3. Plugin parses hover format for each result
4. Plugin displays results in quickfix list

**Code Structure:**
```vim
" autoload/genero_tools/search.vim
function! genero_tools#search#find_functions(pattern)
  " Query with hover format
  let cmd = s:build_query_command(a:pattern, 'vim-hover')
  let output = system(cmd)
  
  if v:shell_error != 0
    call s:handle_error(output)
    return
  endif
  
  " Parse hover format for each result
  let results = s:parse_hover_results(output)
  
  " Display in quickfix list
  call setqflist(results)
  copen
endfunction
```

**Correctness Properties:**
- Property: Search results SHALL display hover format information
- Property: Each result SHALL show signature, file, and metrics
- Property: Quickfix list SHALL be navigable
- Edge case: No results SHALL display empty list

## Query Command Building

**Format Flag Manager:**
```vim
function! s:build_query_command(query, format)
  " Build query command with format flag
  let cmd = 'bash query.sh find-function "' . a:query . '"'
  
  if !empty(a:format)
    let cmd .= ' --format=' . a:format
  endif
  
  return cmd
endfunction
```

**Format Selection Logic:**
```vim
function! s:get_format_for_feature(feature)
  let formats = {
    \ 'hover': 'vim-hover',
    \ 'autocomplete': 'vim-completion',
    \ 'hints': 'vim',
    \ 'statusbar': 'vim',
    \ 'search': 'vim-hover'
  \ }
  
  return get(formats, a:feature, 'vim')
endfunction
```

## Error Handling Strategy

**Error Detection:**
```vim
function! s:handle_query_error(output, error_code)
  if a:error_code == 0
    return 1  " Success
  endif
  
  if a:output =~ 'Invalid format'
    call s:show_error('Invalid format option')
  elseif a:output =~ 'Database not found'
    call s:show_error('Database not found. Run: bash generate_all.sh /path/to/code')
  elseif a:output =~ 'Function not found'
    call s:show_error('Function not found')
  else
    call s:show_error('Query failed: ' . a:output)
  endif
  
  return 0  " Failure
endfunction
```

**Fallback Strategy:**
```vim
function! s:query_with_fallback(query, format)
  " Try with specified format
  let cmd = s:build_query_command(a:query, a:format)
  let output = system(cmd)
  
  if v:shell_error == 0
    return output
  endif
  
  " Fall back to default format
  let cmd = s:build_query_command(a:query, '')
  let output = system(cmd)
  
  return output
endfunction
```

## Performance Optimization

**Result Caching:**
```vim
let s:query_cache = {}

function! s:get_cached_result(query, format)
  let key = a:query . ':' . a:format
  
  if has_key(s:query_cache, key)
    return s:query_cache[key]
  endif
  
  let cmd = s:build_query_command(a:query, a:format)
  let result = system(cmd)
  
  let s:query_cache[key] = result
  
  return result
endfunction
```

**Async Query Execution (Neovim):**
```lua
function M.query_async(query, format, callback)
  vim.fn.jobstart({'bash', 'query.sh', 'find-function', query, '--format=' .. format}, {
    on_stdout = function(_, data, _)
      callback(table.concat(data, '\n'))
    end,
    on_stderr = function(_, data, _)
      callback(nil, table.concat(data, '\n'))
    end
  })
end
```

## Backward Compatibility

**Compatibility Layer:**
```vim
function! s:query_with_compatibility(query)
  " Try new format-based query
  let cmd = s:build_query_command(a:query, 'vim')
  let output = system(cmd)
  
  if v:shell_error == 0
    return output
  endif
  
  " Fall back to old query method
  let cmd = 'bash query.sh find-function "' . a:query . '"'
  let output = system(cmd)
  
  return output
endfunction
```

**Feature Flags:**
```vim
let g:genero_tools_use_formats = get(g:, 'genero_tools_use_formats', 1)

function! s:should_use_formats()
  return g:genero_tools_use_formats
endfunction
```

## Correctness Properties

### Property 1: Format Flag Correctness

**Property:** For each plugin feature, the correct format flag SHALL be used

**Test Cases:**
- Hover feature uses `--format=vim-hover`
- Autocomplete feature uses `--format=vim-completion`
- Hints feature uses `--format=vim`
- Status bar feature uses `--format=vim`
- Search feature uses `--format=vim-hover`

**Verification:**
```vim
function! test_format_flags()
  assert_equal(s:get_format_for_feature('hover'), 'vim-hover')
  assert_equal(s:get_format_for_feature('autocomplete'), 'vim-completion')
  assert_equal(s:get_format_for_feature('hints'), 'vim')
  assert_equal(s:get_format_for_feature('statusbar'), 'vim')
  assert_equal(s:get_format_for_feature('search'), 'vim-hover')
endfunction
```

### Property 2: Output Parsing Correctness

**Property:** Each format SHALL be parsed correctly into its components

**Test Cases:**
- Concise format: Parse single-line signature
- Hover format: Parse three-line format with signature, file, metrics
- Completion format: Parse tab-separated columns

**Verification:**
```vim
function! test_parsing()
  " Test concise format
  let concise = 'calculate(amount: DECIMAL, rate: DECIMAL) -> DECIMAL'
  let parsed = s:parse_concise_format(concise)
  assert_equal(parsed.name, 'calculate')
  assert_equal(parsed.signature, concise)
  
  " Test hover format
  let hover = "calculate(amount: DECIMAL, rate: DECIMAL) -> DECIMAL\nFile: src/math.4gl:42\nComplexity: 5, LOC: 23"
  let parsed = s:parse_hover_format(hover)
  assert_equal(parsed.file, 'src/math.4gl')
  assert_equal(parsed.line, 42)
  assert_equal(parsed.complexity, 5)
  assert_equal(parsed.loc, 23)
  
  " Test completion format
  let completion = "calculate\tfunction(amount: DECIMAL, rate: DECIMAL) -> DECIMAL\tsrc/math.4gl:42 | Complexity: 5, LOC: 23"
  let parsed = s:parse_completion_format(completion)
  assert_equal(len(parsed), 1)
  assert_equal(parsed[0].word, 'calculate')
endfunction
```

### Property 3: Error Handling Correctness

**Property:** Errors SHALL be handled gracefully with helpful messages

**Test Cases:**
- Invalid format: Display error message
- Missing database: Suggest database creation
- Malformed output: Fall back to default behavior
- No results: Display empty result set

**Verification:**
```vim
function! test_error_handling()
  " Test invalid format error
  let output = 'Error: Invalid format'
  call s:handle_query_error(output, 1)
  " Verify error message displayed
  
  " Test missing database error
  let output = 'Error: Database not found'
  call s:handle_query_error(output, 1)
  " Verify helpful suggestion displayed
endfunction
```

### Property 4: Performance Correctness

**Property:** Query execution time SHALL be less than 100ms

**Test Cases:**
- Concise format query: <10ms
- Hover format query: <15ms
- Completion format query: <20ms

**Verification:**
```vim
function! test_performance()
  let start = reltime()
  let output = s:query_with_cache('calculate', 'vim')
  let elapsed = reltimefloat(reltime(start)) * 1000
  assert(elapsed < 100, 'Query took ' . elapsed . 'ms')
endfunction
```

### Property 5: Backward Compatibility Correctness

**Property:** Existing plugin functionality SHALL continue to work

**Test Cases:**
- Hover display works without format flag
- Autocomplete works without format flag
- Hints display works without format flag
- Status bar works without format flag
- Search works without format flag

**Verification:**
```vim
function! test_backward_compatibility()
  " Test that old queries still work
  let output = system('bash query.sh find-function "calculate"')
  assert(!empty(output), 'Old query format still works')
endfunction
```

## Implementation Phases

### Phase 1: Core Format Integration (1 day)
- Implement format flag manager
- Implement output parsers for all three formats
- Implement error handling
- Implement query command builder

### Phase 2: Feature Integration (1 day)
- Integrate hover display with hover format
- Integrate autocomplete with completion format
- Integrate code hints with concise format
- Integrate status bar with concise format
- Integrate search results with hover format

### Phase 3: Performance & Optimization (0.5 days)
- Implement result caching
- Implement async query execution
- Optimize parsing logic
- Performance testing

### Phase 4: Testing & Documentation (1 day)
- Unit tests for all parsers
- Integration tests for all features
- Backward compatibility tests
- Performance tests
- Documentation

**Total Effort: 3.5 days**

## Testing Strategy

### Unit Tests
- Test each format parser independently
- Test format flag selection
- Test error handling
- Test edge cases (no params, no returns, etc.)

### Integration Tests
- Test each feature with real genero-tools output
- Test backward compatibility
- Test error scenarios
- Test performance

### Test Coverage Target
- >90% code coverage for format integration logic
- All format types tested
- All features tested
- All error conditions tested

## Documentation Deliverables

1. **Format Integration Guide** - How to use each format in the plugin
2. **Parser Reference** - Documentation of each parser
3. **Feature Integration Guide** - How each feature uses formats
4. **Troubleshooting Guide** - Common issues and solutions
5. **Code Examples** - Examples for each format and feature

---

**Status:** Design Complete - Ready for Implementation  
**Created:** 2026-03-25  
**Version:** 1.0
