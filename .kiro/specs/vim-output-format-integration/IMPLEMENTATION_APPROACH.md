# Implementation Approach: Vim Output Format Integration

## Overview

This document clarifies the simplified implementation approach for integrating genero-tools output format flags into the vim-genero-tools plugin.

## Key Principle

**genero-tools is doing the formatting for us.** We don't need to parse the output into structured data and reconstruct it. We simply:

1. Add the `--format=` flag to our query commands
2. Take the output and display it directly to the user
3. Do minimal processing (split lines/tabs) only as needed for display

## Implementation Strategy

### Phase 1: Add Format Flags (0.5 days)

For each plugin feature, update the query command to include the appropriate format flag:

**Hover Display:**
```vim
let cmd = 'bash query.sh find-function "' . func_name . '" --format=vim-hover'
let output = system(cmd)
" Output is already formatted: 3 lines (signature, file, metrics)
```

**Autocomplete:**
```vim
let cmd = 'bash query.sh search-functions "' . prefix . '*" --format=vim-completion'
let output = system(cmd)
" Output is already formatted: tab-separated (word, menu, info)
```

**Code Hints:**
```vim
let cmd = 'bash query.sh find-function "' . func_name . '" --format=vim'
let output = system(cmd)
" Output is already formatted: single-line signature
```

**Status Bar:**
```vim
let cmd = 'bash query.sh find-function "' . func_name . '" --format=vim'
let output = system(cmd)
" Output is already formatted: single-line signature
```

**Search Results:**
```vim
let cmd = 'bash query.sh search-functions "' . pattern . '" --format=vim-hover'
let output = system(cmd)
" Output is already formatted: 3 lines per result
```

### Phase 2: Update Display Logic (0.5 days)

For each feature, update the display code to handle the new format:

**Hover Display:**
```vim
" Split lines and display in floating window
let lines = split(output, "\n")
" lines[0] = signature
" lines[1] = file location
" lines[2] = complexity metrics
call display_hover_window(lines)
```

**Autocomplete:**
```vim
" Split lines, then split each line on tabs
let completions = []
for line in split(output, "\n")
  let parts = split(line, "\t")
  call add(completions, {
    \ 'word': parts[0],
    \ 'menu': parts[1],
    \ 'info': parts[2]
  \ })
endfor
return completions
```

**Code Hints:**
```vim
" Display signature directly (trim whitespace)
echo trim(output)
```

**Status Bar:**
```vim
" Display signature directly (trim whitespace)
return trim(output)
```

**Search Results:**
```vim
" Split lines and display in quickfix
let lines = split(output, "\n")
" Group every 3 lines as one result
for i in range(0, len(lines)-1, 3)
  " lines[i] = signature
  " lines[i+1] = file location
  " lines[i+2] = complexity metrics
endfor
```

### Phase 3: Error Handling (0.25 days)

Add basic error handling:

```vim
if v:shell_error != 0
  " Handle query error
  echohl ErrorMsg
  echo 'Query failed: ' . output
  echohl None
  return
endif

if empty(output)
  " Handle no results
  echo 'No results found'
  return
endif
```

### Phase 4: Testing & Documentation (0.75 days)

- Write integration tests to verify format flags are used
- Write integration tests to verify display logic works
- Write backward compatibility tests
- Document the approach

## What We DON'T Need

- ❌ Complex parsing logic to extract components
- ❌ Structured data representations
- ❌ Format validation (genero-tools handles this)
- ❌ Reconstruction of formatted output
- ❌ Separate parser modules for each format

## What We DO Need

- ✅ Add `--format=` flag to query commands
- ✅ Split lines/tabs for display (minimal processing)
- ✅ Display output directly to user
- ✅ Basic error handling
- ✅ Tests to verify format flags work
- ✅ Documentation

## Effort Reduction

**Original estimate:** 3.5 days  
**Simplified estimate:** 2 days

**Reduction:** 43% less work by eliminating unnecessary parsing complexity

## Files to Modify

1. `autoload/genero_tools/hover.vim` - Add format flag, split lines for display
2. `autoload/genero_tools/complete.vim` - Add format flag, split tabs for completion
3. `autoload/genero_tools/hints.vim` - Add format flag, display directly
4. `autoload/genero_tools/statusline.vim` - Add format flag, display directly
5. `autoload/genero_tools/search.vim` - Add format flag, split lines for quickfix

## Testing Approach

- Verify format flags are included in queries
- Verify output is displayed correctly
- Verify backward compatibility
- No need for complex parsing tests

## Documentation

- Document which format each feature uses
- Show simple code examples
- Include troubleshooting tips

---

**Status:** Approach Finalized - Ready for Implementation  
**Created:** 2026-03-25  
**Version:** 1.0
