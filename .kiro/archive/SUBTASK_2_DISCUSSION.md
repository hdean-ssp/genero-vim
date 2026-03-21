# Subtask 2: Enhanced Function Signatures - Discussion Points

## Current State
- Signatures already formatted with abbreviated types
- Parameter information available from query.sh
- Info section shows signature + file + line

## What We Can Enhance

### 1. Parameter Details
**Current Info**:
```
myFunc(param1:STR, param2:INT) -> BOOL | /path/to/file.4gl | Line 42
```

**Enhanced Info**:
```
myFunc(2 params) -> 1 return | /path/to/file.4gl:42-58

Parameters:
  param1: STRING
  param2: INTEGER

Returns:
  BOOLEAN
```

### 2. Function Complexity
**Current**: No indication
**Enhanced**: Show parameter count and return count
- Example: `myFunc(2 params) -> 1 return`
- Quick visual assessment of complexity

### 3. Function Dependencies
**Current**: Not shown
**Enhanced**: Show what functions it calls and what calls it
- Example: `Calls: 3 functions | Called by: 5 functions`
- Requires additional query (find-function-dependents)

## Three Implementation Approaches

### Option A: Enhanced Info Section (Simple)
- Expand info display with parameter details
- Show on selection/hover
- No menu changes
- **Pros**: Simple, non-intrusive
- **Cons**: Info only on selection

### Option B: Multi-line Menu (Complex)
- Show parameters in menu itself
- Multiple lines per entry
- **Pros**: Parameters visible by default
- **Cons**: Complex, may break compatibility

### Option C: Hybrid (Recommended)
- Keep menu compact
- Enhance info section with full details
- Add parameter count to menu label
- **Pros**: Best of both, compatible, informative
- **Cons**: More formatting code

## Data Available from query.sh

Each function object includes:
```json
{
  "name": "myFunc",
  "parameters": [
    {"name": "param1", "type": "STRING"},
    {"name": "param2", "type": "INTEGER"}
  ],
  "returns": [
    {"name": "result", "type": "BOOLEAN"}
  ],
  "calls": [
    {"name": "validate_input", "line": 45},
    {"name": "log_message", "line": 48}
  ]
}
```

## Proposed MVP (Phase 1)

**Scope**: Enhanced info section with parameter details
**Approach**: Hybrid (keep menu compact, expand info)
**Display**: Parameter list + return types + complexity + location

**Implementation**:
1. Format parameters into readable list
2. Show full type names (STRING, INTEGER, BOOLEAN)
3. Show parameter count and return count
4. Show function location (file and line range)
5. Show what functions it calls (from calls array)

**Example Output**:
```
myFunc(2 params) -> 1 return | /path/to/file.4gl:42-58

Parameters:
  param1: STRING
  param2: INTEGER

Returns:
  BOOLEAN

Calls: validate_input, log_message (2 functions)
```

## Performance Impact

**Current**: ~10-20ms total
**Enhanced (Phase 1)**: ~10-20ms (no change - all data already available)
**Enhanced (Phase 3 with dependencies)**: ~10-20ms (additional query <1ms)

## Limitations & Workarounds

### Limitation 1: No Required/Optional Indicator
- query.sh doesn't provide this information
- Workaround: Assume all parameters required
- Future: Parse function signature for optional indicators

### Limitation 2: No Parameter Documentation
- query.sh doesn't include parameter descriptions
- Workaround: Show only type information
- Future: Parse from source code comments

### Limitation 3: No Parameter Order Hints
- Can't determine if parameters are positional or named
- Workaround: Show in order from query.sh
- Future: Parse function signature

## Questions for You

1. **Scope**: Start with Phase 1 (enhanced info) or include Phase 2 (param count in menu)?
2. **Dependencies**: Should we query function dependents (what calls this function)?
3. **Display Format**: Prefer parameter list or inline format?
4. **Type Names**: Show full names (STRING) or keep abbreviated (STR)?
5. **Complexity**: Show parameter count in menu label?

## Recommendation

Implement **Phase 1 (MVP)** with **Hybrid approach**:
- Keep menu display compact (current implementation)
- Enhance info section with full parameter details
- Show parameter count in menu label (e.g., `myFunc(2 params)`)
- Show function calls from calls array
- Defer function dependents query to Phase 3
- Use full type names in parameter list (more readable)

This provides significant value without major complexity or performance impact.
