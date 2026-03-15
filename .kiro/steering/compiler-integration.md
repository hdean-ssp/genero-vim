---
inclusion: manual
---

# Compiler Integration Steering Guide

## Overview

This guide documents the fglcomp compiler output format and version-specific parsing strategies for the vim-genero-tools-plugin compiler integration feature.

## fglcomp Output Format

### Command
```bash
fglcomp -M -W all <filename>
```

- `-M`: Write error messages to standard output instead of creating .err file
- `-W all`: Display all warning messages

### Output Format (fglcomp 3.10+)

```
filename:start_line:start_col:end_line:end_col:severity:(-error_code) message
```

**Components:**
- `filename`: Source file path (relative or absolute)
- `start_line`: Starting line number (1-indexed)
- `start_col`: Starting column number (1-indexed)
- `end_line`: Ending line number (1-indexed)
- `end_col`: Ending column number (1-indexed)
- `severity`: One of: `error`, `warning`, `info`
- `error_code`: Numeric error code in parentheses (e.g., `-6631`)
- `message`: Human-readable error/warning message

### Real Examples

**Type Error:**
```
tc1.4gl:3:5:3:18:error:(-6631) incompatible types, found: CHAR, required: base.StringBuffer.
```

**Method Call Error:**
```
tc3.4gl:9:26:9:30:error:(-6631) incompatible types, found: CHAR, required: om.DomNode.
```

**Unqualified Import Warning:**
```
tc4.4gl:4:14:4:18:warning:(-8452) Unqualified imported symbol.
```

## Version-Specific Parsing

### Compiler Version Detection

The plugin supports three modes:

1. **auto** (default) - Automatically detect compiler version by running `fglcomp -V`
2. **Explicit version** - User specifies version (e.g., '3.10', '3.20')
3. **Fallback** - If detection fails, use most recent known format

### Version Parsers

#### fglcomp 3.10+ Parser

**Format:** `filename:start_line:start_col:end_line:end_col:severity:(-code) message`

**Regex Pattern:**
```vim
let pattern = '^\([^:]*\):\(\d\+\):\(\d\+\):\(\d\+\):\(\d\+\):\(error\|warning\|info\):((-\d\+)) \(.*\)$'
```

**Parsing Logic:**
1. Split line by colons (first 6 fields)
2. Extract filename, line numbers, columns, severity
3. Extract error code and message from remainder
4. Detect unused variable warnings by checking message content

**Unused Variable Detection:**
- Look for keywords: "unused", "not used", "never used"
- Common patterns: "variable 'X' is not used"

#### Future Version Support

When fglcomp output format changes:

1. Create new parser function: `genero_tools#compiler#parse_v330()`
2. Add version detection logic
3. Update dispatcher to route to correct parser
4. Maintain backward compatibility with older versions

## Implementation Strategy

### Phase 1: Framework (No Output Examples Needed)
- Configuration system with version support
- Command execution framework
- Sign column placement logic
- Quickfix integration framework
- Compiler commands (compile, clear, navigate)

### Phase 2: Parsing (With Mock Output)
- Implement version-specific parsers
- Test with mock output examples
- Validate regex patterns
- Handle edge cases

### Phase 3: Refinement (With Real Output)
- Test with actual fglcomp output
- Adjust parsing for edge cases
- Optimize performance
- Add support for new compiler versions

## Mock Output Examples

For testing without real compiler output, use these examples:

```
test.4gl:5:10:5:20:error:(-6631) incompatible types, found: CHAR, required: STRING.
test.4gl:12:3:12:15:warning:(-8452) Unqualified imported symbol.
test.4gl:25:1:25:30:error:(-6632) undefined variable 'myVar'.
test.4gl:30:5:30:18:warning:(-8453) variable 'unused_var' is not used.
```

## Configuration Examples

### Auto-Detect Version
```vim
let g:genero_tools_config.compiler_version = 'auto'
```

### Explicit Version
```vim
let g:genero_tools_config.compiler_version = '3.10'
```

### Custom Compiler Command
```vim
let g:genero_tools_config.compiler_command = '/opt/genero/bin/fglcomp'
```

## Error Code Reference

Common fglcomp error codes:

- `-6631`: Incompatible types
- `-6632`: Undefined variable
- `-8452`: Unqualified imported symbol
- `-8453`: Unused variable
- `-1260`: Type conversion error (runtime)

## Extensibility

The parsing system is designed to be extensible:

1. **Add new version parser:**
   ```vim
   function! genero_tools#compiler#parse_v330(output)
     " New parsing logic for fglcomp 3.30+
   endfunction
   ```

2. **Update dispatcher:**
   ```vim
   if version >= '3.30'
     return genero_tools#compiler#parse_v330(output)
   elseif version >= '3.20'
     return genero_tools#compiler#parse_v320(output)
   else
     return genero_tools#compiler#parse_v310(output)
   endif
   ```

3. **Maintain backward compatibility:**
   - Always support at least 2 previous versions
   - Provide clear error messages for unsupported versions
   - Allow users to specify version explicitly if auto-detection fails

## Testing Strategy

### Unit Tests
- Test each version parser with mock output
- Verify regex patterns match expected format
- Test edge cases (empty output, malformed lines, etc.)

### Integration Tests
- Test with actual fglcomp output (when available)
- Test version detection
- Test fallback behavior
- Test with different compiler versions

### Property Tests
- **Property 18:** Compiler output parsing preserves semantics
- **Property 19:** Error markers are placed correctly
- **Property 20:** Unused variable detection is accurate
