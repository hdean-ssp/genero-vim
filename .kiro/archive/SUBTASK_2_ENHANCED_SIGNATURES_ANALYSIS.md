# Subtask 2: Enhanced Function Signatures in Autocomplete - Analysis & Design

## Overview
Enhance autocomplete to display detailed parameter information and hints, not just function names and basic signatures.

## Current State

### What We Have
- Function signatures already formatted (from subtask 3)
- Parameter information available in query.sh output
- Abbreviated types (STRING→STR, INTEGER→INT)
- Truncated signatures for menu display

### What's Missing
- Parameter hints on selection
- Required vs optional parameter indication
- Parameter descriptions/documentation
- Multi-line parameter display
- Type information in completion menu

## Available Data from query.sh

### Function Object Structure
```json
{
  "name": "string",
  "file": "string",
  "line_start": "integer",
  "line_end": "integer",
  "signature": "string (human readable)",
  "parameters": [
    {"name": "string", "type": "string"}
  ],
  "returns": [
    {"name": "string", "type": "string"}
  ],
  "calls": [
    {"name": "string", "line": "integer"}
  ]
}
```

### Key Observations
1. **Parameters**: Array of {name, type} objects
2. **Returns**: Array of {name, type} objects
3. **Calls**: Shows function dependencies
4. **Signature**: Human-readable string (may include full details)
5. **No metadata**: No "required/optional" flag in data structure

## Enhancement Opportunities

### 1. Parameter Count Display
**Current**: `myFunc(param1:STR, param2:INT) -> BOOL`
**Enhanced**: `myFunc(2 params) -> BOOL` or `myFunc(p1:STR, p2:INT) -> BOOL`

**Benefit**: Quick visual indication of function complexity
**Implementation**: Count parameters array length

### 2. Parameter Hints on Selection
**Current**: Info shows signature + file + line
**Enhanced**: Info shows full parameter details

**Example**:
```
Function: myFunc
Signature: myFunc(param1: STRING, param2: INTEGER) -> BOOLEAN
Parameters:
  - param1: STRING
  - param2: INTEGER
Returns:
  - BOOLEAN
Called by: 5 functions
Calls: 3 functions
Location: /path/to/file.4gl:42-58
```

**Implementation**: Format parameter array into readable list

### 3. Parameter Type Indicators
**Current**: Abbreviated types in signature
**Enhanced**: Full type names in parameter hints

**Example**:
```
Parameters:
  - param1: STRING (text data)
  - param2: INTEGER (numeric value)
  - param3: BOOLEAN (true/false)
```

**Implementation**: Map abbreviated types back to full names

### 4. Function Complexity Indicator
**Current**: No indication of complexity
**Enhanced**: Show parameter count and return count

**Example**:
```
myFunc(2 params) -> 1 return
```

**Benefit**: Quick assessment of function complexity
**Implementation**: Count arrays

### 5. Function Dependencies
**Current**: Not shown
**Enhanced**: Show what functions it calls and what calls it

**Example**:
```
Calls: validate_input, log_message, process_data (3 functions)
Called by: 5 functions
```

**Implementation**: Use calls array and find-function-dependents

## Implementation Approaches

### Option A: Enhanced Info Section (Simple)
- Keep menu display as-is
- Expand info section with parameter details
- Show on selection/hover
- No changes to completion menu behavior

**Pros**: Simple, non-intrusive, works with all editors
**Cons**: Info only shown on selection, not visible by default

### Option B: Multi-line Menu Display (Complex)
- Show parameters on multiple lines in menu
- Requires custom completion formatting
- May not work with all editors
- Better visibility but more complex

**Pros**: Parameters visible in menu
**Cons**: Complex, editor-dependent, may break compatibility

### Option C: Hybrid (Recommended)
- Keep menu compact (current implementation)
- Enhance info section with full details
- Add parameter count to menu label
- Show full details on selection

**Pros**: Best of both worlds, compatible, informative
**Cons**: Requires more formatting code

## Proposed Implementation

### Phase 1: Enhanced Info Section (MVP)
1. Format parameters into readable list
2. Show parameter types (full names)
3. Show return types
4. Show function complexity (param count, return count)
5. Show location (file and line range)

**Example Info Display**:
```
myFunc(2 params) -> 1 return | /path/to/file.4gl:42-58

Parameters:
  param1: STRING
  param2: INTEGER

Returns:
  BOOLEAN

Calls: 3 functions
Called by: 5 functions
```

### Phase 2: Parameter Count in Menu (Enhancement)
1. Add parameter count to menu label
2. Example: `myFunc(2 params)` instead of just signature

**Benefit**: Quick visual indication without expanding menu

### Phase 3: Function Dependencies (Enhancement)
1. Query function dependents (what calls this function)
2. Show count in info section
3. Optional: Show list of calling functions

**Challenge**: Requires additional query (find-function-dependents)
**Performance**: <1ms per query

### Phase 4: Parameter Documentation (Future)
1. Parse parameter descriptions from comments
2. Show in parameter hints
3. Requires comment parsing (not in current query.sh output)

## Data Processing Pipeline

### Current (Subtask 3)
```
query.sh output → signature.vim → formatted signature
```

### Enhanced (Subtask 2)
```
query.sh output → signature.vim → formatted signature
                → parameter formatter → parameter list
                → complexity calculator → param/return counts
                → dependency query → call information
```

## Configuration Options

```vim
" Enhanced signature display
let g:genero_tools_config.autocomplete_show_param_count = 1
let g:genero_tools_config.autocomplete_show_param_hints = 1
let g:genero_tools_config.autocomplete_show_dependencies = 1
let g:genero_tools_config.autocomplete_show_full_types = 1
```

## Performance Considerations

### Current Performance
- Menu display: <1ms
- Info display: <1ms
- Total: ~10-20ms

### Enhanced Performance (Phase 1)
- Parameter formatting: <1ms
- Complexity calculation: <1ms
- Info display: <1ms
- Total: ~10-20ms (no change)

### Enhanced Performance (Phase 3)
- Additional query (find-function-dependents): <1ms
- Total: ~10-20ms (minimal impact)

## Challenges & Solutions

### Challenge 1: Required vs Optional Parameters
**Problem**: query.sh doesn't indicate if parameters are required
**Solution**: 
- Assume all parameters are required (conservative)
- Could parse function signature for optional indicators
- Document as limitation

### Challenge 2: Parameter Descriptions
**Problem**: query.sh doesn't include parameter documentation
**Solution**:
- Parse from source code comments (future enhancement)
- Show only type information for now
- Document as future improvement

### Challenge 3: Large Parameter Lists
**Problem**: Functions with 10+ parameters
**Solution**:
- Truncate parameter list with ellipsis
- Show full list in info section
- Configurable truncation limit

### Challenge 4: Return Type Names
**Problem**: Some functions return multiple values
**Solution**:
- Show all return types
- Format as comma-separated list
- Indicate if multiple returns

## Next Steps

1. Implement Phase 1 (enhanced info section)
2. Test with various function signatures
3. Implement Phase 2 (parameter count in menu)
4. Implement Phase 3 (function dependencies)
5. Add configuration options
6. Document usage and limitations

## Files to Modify

- `autoload/genero_tools/signature.vim` - Add parameter formatting functions
- `autoload/genero_tools/complete.vim` - Use enhanced info in completions
- `autoload/genero_tools/config.vim` - Add configuration options

## Status

Analysis complete. Ready for implementation discussion.
