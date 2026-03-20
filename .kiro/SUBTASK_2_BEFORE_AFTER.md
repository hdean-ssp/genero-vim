# Subtask 2: Enhanced Signatures - Before & After Comparison

## Current State (Subtask 3 Complete)

### Completion Menu
```
myFunc                    | myFunc(p1:STR, p2:INT) -> BOOL
anotherFunc               | anotherFunc(p1:STR) -> STR
complexFunc               | complexFunc(p1:STR, p2:INT, p3:BOOL, p4:DEC) -> INT
```

### Info Section (on selection)
```
myFunc(p1:STR, p2:INT) -> BOOL | /path/to/file.4gl | Line 42
```

### Issues
- Parameter count not visible
- Full type names not shown
- No parameter details
- No function complexity indication
- No information about what functions it calls

---

## Enhanced State (Subtask 2 - Proposed)

### Completion Menu (Option A: Keep Compact)
```
myFunc                    | myFunc(2 params) -> BOOL
anotherFunc               | anotherFunc(1 param) -> STR
complexFunc               | complexFunc(4 params) -> INT
```

### Info Section (on selection)
```
myFunc(2 params) -> 1 return | /path/to/file.4gl:42-58

Parameters:
  param1: STRING
  param2: INTEGER

Returns:
  BOOLEAN

Calls: validate_input, log_message (2 functions)
```

### Benefits
✓ Parameter count visible in menu
✓ Full type names in info section
✓ Parameter details on selection
✓ Function complexity clear
✓ Function dependencies shown
✓ Line range shown (start-end)

---

## Detailed Example: Complex Function

### Current Display
```
Menu:
processOrder              | processOrder(o:REC, c:REC, i:ARR, d:DEC) -> BOOL

Info:
processOrder(o:REC, c:REC, i:ARR, d:DEC) -> BOOL | /src/orders.4gl | Line 125
```

### Enhanced Display
```
Menu:
processOrder              | processOrder(4 params) -> BOOL

Info:
processOrder(4 params) -> 1 return | /src/orders.4gl:125-180

Parameters:
  order: RECORD
  customer: RECORD
  items: DYNAMIC ARRAY
  discount: DECIMAL

Returns:
  BOOLEAN

Calls: validate_order, calculate_total, apply_discount, save_order (4 functions)
```

### Improvements
- Parameter count immediately visible (4 params)
- Full type names readable (RECORD, DYNAMIC ARRAY, DECIMAL)
- Parameter names clear (order, customer, items, discount)
- Function complexity obvious (4 parameters, 4 function calls)
- Dependencies visible (what it calls)
- Line range shown (125-180)

---

## Example: Simple Function

### Current Display
```
Menu:
getName                   | getName(id:INT) -> STR

Info:
getName(id:INT) -> STR | /src/utils.4gl | Line 42
```

### Enhanced Display
```
Menu:
getName                   | getName(1 param) -> STR

Info:
getName(1 param) -> 1 return | /src/utils.4gl:42-48

Parameters:
  id: INTEGER

Returns:
  STRING

Calls: (no function calls)
```

### Improvements
- Parameter count visible (1 param)
- Full type names (INTEGER, STRING)
- Simplicity obvious (1 param, no calls)
- Line range shown (42-48)

---

## Example: Multi-return Function

### Current Display
```
Menu:
getOrderDetails           | getOrderDetails(id:INT) -> REC, DEC, STR

Info:
getOrderDetails(id:INT) -> REC, DEC, STR | /src/orders.4gl | Line 200
```

### Enhanced Display
```
Menu:
getOrderDetails           | getOrderDetails(1 param) -> 3 returns

Info:
getOrderDetails(1 param) -> 3 returns | /src/orders.4gl:200-220

Parameters:
  id: INTEGER

Returns:
  order: RECORD
  total: DECIMAL
  status: STRING

Calls: fetch_order, calculate_total, get_status (3 functions)
```

### Improvements
- Parameter count visible (1 param)
- Return count visible (3 returns)
- Full type names (INTEGER, RECORD, DECIMAL, STRING)
- Return value names shown (order, total, status)
- Function complexity clear
- Dependencies visible

---

## Implementation Phases

### Phase 1: Enhanced Info Section (MVP)
- ✓ Parameter list with full type names
- ✓ Return types with names
- ✓ Parameter count in menu label
- ✓ Function calls from calls array
- ✓ Line range (start-end)

### Phase 2: Parameter Count in Menu (Enhancement)
- ✓ Show "N params" instead of full signature
- ✓ Show "N returns" for multi-return functions
- ✓ Reduces menu clutter

### Phase 3: Function Dependencies (Enhancement)
- ✓ Query find-function-dependents
- ✓ Show "Called by: N functions"
- ✓ Optional: Show list of calling functions

### Phase 4: Parameter Documentation (Future)
- Parse parameter descriptions from comments
- Show in parameter hints
- Requires comment parsing

---

## Performance Impact

| Operation | Current | Enhanced | Impact |
|-----------|---------|----------|--------|
| Menu display | <1ms | <1ms | None |
| Info formatting | <1ms | <2ms | +1ms |
| Parameter formatting | N/A | <1ms | +1ms |
| Dependency query | N/A | <1ms | +1ms (Phase 3) |
| **Total** | ~10-20ms | ~10-20ms | Negligible |

---

## User Experience Improvement

### Before
- User sees function name and abbreviated signature
- Must select to see parameter details
- No indication of complexity
- No information about dependencies

### After
- User sees function name and parameter count
- Parameter details visible on selection
- Complexity obvious from param/return counts
- Dependencies visible (what it calls)
- Full type names for clarity
- Line range for navigation

### Result
- Better informed decisions about which function to use
- Faster understanding of function complexity
- Clearer parameter requirements
- Better code navigation
