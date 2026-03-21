# Subtask 2: Enhanced Function Signatures - Summary

## What is Subtask 2?

Enhance autocomplete to display detailed parameter information and hints, making it easier for developers to understand function signatures at a glance.

## Current Limitations

1. **No Parameter Count**: Users can't see how many parameters a function takes
2. **Abbreviated Types**: Parameter types are abbreviated (STR, INT) in menu
3. **No Parameter Details**: Full parameter list only visible on selection
4. **No Complexity Indicator**: Can't assess function complexity quickly
5. **No Dependencies**: Don't know what functions it calls

## What We Can Improve

### 1. Parameter Count Display
- Show "N params" in menu label
- Example: `myFunc(2 params) -> BOOL`
- Quick visual indication of complexity

### 2. Enhanced Info Section
- Show full parameter list with full type names
- Example: `param1: STRING, param2: INTEGER`
- Show return types with names
- Show function calls (from calls array)

### 3. Function Complexity
- Show parameter count and return count
- Example: `myFunc(2 params) -> 1 return`
- Helps assess function complexity

### 4. Function Dependencies
- Show what functions it calls
- Example: `Calls: validate_input, log_message (2 functions)`
- Helps understand function relationships

## Data Available

query.sh provides:
- Parameter names and types
- Return types
- Function calls (what it calls)
- Line range (start-end)

We can use all of this to enhance the display.

## Three Implementation Approaches

### Option A: Enhanced Info Only (Simple)
- Expand info section with parameter details
- Keep menu compact
- Show on selection
- **Best for**: Minimal changes, compatibility

### Option B: Multi-line Menu (Complex)
- Show parameters in menu
- Multiple lines per entry
- **Best for**: Maximum visibility
- **Risk**: May break compatibility

### Option C: Hybrid (Recommended)
- Keep menu compact with parameter count
- Expand info section with full details
- **Best for**: Balance of visibility and simplicity

## Proposed MVP (Phase 1)

**What**: Enhanced info section with parameter details
**How**: Format parameters, show full types, add complexity info
**Where**: Info section (shown on selection)
**Performance**: No impact (~10-20ms total)

**Example**:
```
Menu:
myFunc                    | myFunc(2 params) -> BOOL

Info (on selection):
myFunc(2 params) -> 1 return | /path/to/file.4gl:42-58

Parameters:
  param1: STRING
  param2: INTEGER

Returns:
  BOOLEAN

Calls: validate_input, log_message (2 functions)
```

## Implementation Phases

### Phase 1: Enhanced Info Section (MVP)
- Parameter list with full type names
- Return types with names
- Parameter count in menu label
- Function calls from calls array
- Line range (start-end)
- **Effort**: 2-3 hours
- **Impact**: Significant UX improvement

### Phase 2: Parameter Count in Menu (Enhancement)
- Show "N params" instead of full signature
- Reduces menu clutter
- **Effort**: 1 hour
- **Impact**: Cleaner menu display

### Phase 3: Function Dependencies (Enhancement)
- Query find-function-dependents
- Show "Called by: N functions"
- **Effort**: 1-2 hours
- **Impact**: Better understanding of code relationships

### Phase 4: Parameter Documentation (Future)
- Parse parameter descriptions from comments
- Show in parameter hints
- **Effort**: 3-4 hours
- **Impact**: Complete documentation

## Key Questions

1. **Scope**: Start with Phase 1 only, or include Phase 2?
2. **Dependencies**: Query function dependents (Phase 3)?
3. **Type Names**: Show full (STRING) or keep abbreviated (STR)?
4. **Format**: Prefer parameter list or inline format?
5. **Complexity**: Show param count in menu label?

## Recommendation

Implement **Phase 1 (MVP)** with **Hybrid approach**:
- ✓ Enhanced info section with parameter details
- ✓ Parameter count in menu label
- ✓ Full type names in parameter list
- ✓ Function calls from calls array
- ✓ Line range (start-end)
- ✗ Defer function dependents query to Phase 3
- ✗ Defer parameter documentation to Phase 4

**Why**:
- Significant UX improvement
- No performance impact
- Uses data already available
- Manageable implementation
- Can defer enhancements to later phases

## Files to Modify

1. `autoload/genero_tools/signature.vim`
   - Add parameter formatting functions
   - Add complexity calculation functions
   - Add type name mapping

2. `autoload/genero_tools/complete.vim`
   - Use enhanced info in completions
   - Format parameter count in menu label
   - Format parameter list in info section

3. `autoload/genero_tools/config.vim`
   - Add configuration options (optional)

## Status

✓ Analysis complete
✓ Discussion points identified
✓ Before/after examples created
✓ Implementation phases defined
✓ Ready for implementation decision

## Next Steps

1. Confirm scope and approach
2. Implement Phase 1 (MVP)
3. Test with various function signatures
4. Gather feedback
5. Plan Phase 2-4 enhancements
