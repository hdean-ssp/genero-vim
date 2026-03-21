# Display Architecture: Current vs Proposed

## Current Architecture (Fragmented)

```
┌─────────────────────────────────────────────────────────────────┐
│                    User Configuration                            │
│  display_mode, compiler_*, hints_*, debug_stream_*, etc.        │
└─────────────────────────────────────────────────────────────────┘
                              │
                ┌─────────────┼─────────────┐
                │             │             │
                ▼             ▼             ▼
        ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
        │   Compiler   │ │    Hints     │ │  Signatures  │
        │  (Quickfix   │ │   (Signs +   │ │  (Omnifunc   │
        │   + Signs)   │ │ Virtual Text)│ │    Menu)     │
        └──────────────┘ └──────────────┘ └──────────────┘
                │             │             │
        ┌───────┴─────────────┴─────────────┴───────┐
        │                                           │
        ▼                                           ▼
    ┌─────────────────────┐          ┌──────────────────────┐
    │ Direct Implementation│          │ Main Display Module  │
    │  - Quickfix API     │          │  - Dispatcher        │
    │  - Sign API         │          │  - Format functions  │
    │  - Direct echo      │          │  - Display modes     │
    │  - Custom UI        │          │  - Validation        │
    └─────────────────────┘          └──────────────────────┘
        │                                    │
        ▼                                    ▼
    ┌─────────────────────┐          ┌──────────────────────┐
    │   Inconsistent      │          │   Consistent         │
    │   Behavior          │          │   Behavior           │
    │   No Config Respect │          │   Respects Config    │
    │   Hard to Maintain  │          │   Easy to Extend     │
    └─────────────────────┘          └──────────────────────┘
```

### Issues with Current Architecture
- ✗ Features bypass main display module
- ✗ Inconsistent configuration usage
- ✗ Hardcoded display methods
- ✗ Difficult to maintain
- ✗ Difficult to extend
- ✗ Inconsistent user experience

---

## Proposed Architecture (Unified)

```
┌─────────────────────────────────────────────────────────────────┐
│                    User Configuration                            │
│  display_mode (global)                                          │
│  compiler_display_mode, hints_display_mode, etc. (overrides)   │
│  Feature-specific options (compiler_show_*, hints_display, etc.)│
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────────┐
                    │  Config Module       │
                    │  - Initialization    │
                    │  - Validation        │
                    │  - Mode Resolution   │
                    └──────────────────────┘
                              │
                              ▼
                    ┌──────────────────────┐
                    │  Display Module      │
                    │  - result()          │
                    │  - notify()          │
                    │  - error()           │
                    │  - details()         │
                    │  - get_mode()        │
                    │  - Dispatcher        │
                    │  - Format functions  │
                    │  - Display modes     │
                    │  - Validation        │
                    └──────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
    ┌──────────┐         ┌──────────┐         ┌──────────┐
    │ Compiler │         │  Hints   │         │Signatures│
    │ Feature  │         │ Feature  │         │ Feature  │
    │          │         │          │         │          │
    │ Uses:    │         │ Uses:    │         │ Uses:    │
    │ display# │         │ display# │         │ display# │
    │ result() │         │ result() │         │ result() │
    │ notify() │         │ notify() │         │ details()│
    │ error()  │         │ error()  │         │ error()  │
    └──────────┘         └──────────┘         └──────────┘
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              │
                              ▼
                    ┌──────────────────────┐
                    │  Display Modes       │
                    │  - Quickfix          │
                    │  - Popup             │
                    │  - Inline            │
                    │  - Split             │
                    │  - Echo              │
                    └──────────────────────┘
                              │
                              ▼
                    ┌──────────────────────┐
                    │   Consistent         │
                    │   Behavior           │
                    │   Config Respected   │
                    │   Easy to Maintain   │
                    │   Easy to Extend     │
                    └──────────────────────┘
```

### Benefits of Proposed Architecture
- ✓ All features use main display module
- ✓ Consistent configuration usage
- ✓ Flexible display methods
- ✓ Easy to maintain
- ✓ Easy to extend
- ✓ Consistent user experience

---

## Feature Integration Comparison

### Compiler Feature

**Current:**
```vim
" Compiler directly uses quickfix and signs
call genero_tools#compiler#quickfix#populate(result)
call genero_tools#compiler#signs#place(errors, warnings)
call genero_tools#compiler#highlight#apply(errors, warnings)
echom 'Compilation complete'  " Direct echo
```

**Proposed:**
```vim
" Compiler uses display module
let display_mode = genero_tools#display#get_mode('compiler')
call genero_tools#display#result(result, display_mode)
call genero_tools#display#notify('Compilation complete', 3000)

" Signs and highlighting still used for navigation
if display_mode == 'quickfix' || display_mode == 'split'
  call genero_tools#compiler#signs#place(errors, warnings)
  call genero_tools#compiler#highlight#apply(errors, warnings)
endif
```

### Hints Feature

**Current:**
```vim
" Hints use custom display logic
let display_mode = genero_tools#hints#config#get('hints_display')
if display_mode == 'signs' || display_mode == 'both'
  call genero_tools#hints#display#show_signs(bufnr, hints)
endif
if display_mode == 'virtual_text' || display_mode == 'both'
  call genero_tools#hints#display#show_virtual_text(bufnr, hints)
endif
```

**Proposed:**
```vim
" Hints use display module
let display_mode = genero_tools#display#get_mode('hints')
call genero_tools#display#result(hints, display_mode)

" Signs and virtual text still used for in-editor display
let hints_display = genero_tools#hints#config#get('hints_display')
if hints_display == 'signs' || hints_display == 'both'
  call genero_tools#hints#display#show_signs(bufnr, hints)
endif
if hints_display == 'virtual_text' || hints_display == 'both'
  call genero_tools#hints#display#show_virtual_text(bufnr, hints)
endif
```

### Progress Feature

**Current:**
```vim
" Progress uses direct echo
echom 'Compiling...'
echom 'Compilation complete (5s elapsed)'
```

**Proposed:**
```vim
" Progress uses display module
let display_mode = genero_tools#display#get_mode('progress')
call genero_tools#display#notify('Compiling...', 0)
call genero_tools#display#notify('Compilation complete (5s elapsed)', 3000)
```

---

## Configuration Comparison

### Current Configuration
```vim
let g:genero_tools_config = {
  \ 'display_mode': 'quickfix',
  \ 'compiler_show_errors': 1,
  \ 'compiler_show_warnings': 1,
  \ 'compiler_sign_column': 1,
  \ 'hints_display': 'signs',
  \ 'hints_highlight_columns': 1,
  \ 'debug_stream_width': 0,
  \ 'debug_stream_max_lines': 1000,
  \ }
```

**Issues:**
- ✗ `display_mode` only used by main module
- ✗ Compiler doesn't respect `display_mode`
- ✗ Hints use separate `hints_display` config
- ✗ No display config for signatures, progress, errors
- ✗ Inconsistent naming conventions

### Proposed Configuration
```vim
let g:genero_tools_config = {
  \ 'display_mode': 'quickfix',
  \ 
  \ 'compiler_display_mode': '',  " inherit from global
  \ 'compiler_show_errors': 1,
  \ 'compiler_show_warnings': 1,
  \ 'compiler_show_signs': 1,
  \ 'compiler_show_highlights': 1,
  \ 
  \ 'hints_display_mode': '',     " inherit from global
  \ 'hints_display': 'signs',     " signs, virtual_text, both
  \ 'hints_highlight_columns': 1,
  \ 
  \ 'signatures_display_mode': '',
  \ 'signatures_show_details': 1,
  \ 
  \ 'progress_display_mode': '',
  \ 'progress_show_elapsed': 1,
  \ 
  \ 'debug_display_mode': 'split',
  \ 'debug_stream_width': 0,
  \ 'debug_stream_max_lines': 1000,
  \ 
  \ 'error_display_mode': '',
  \ 'error_show_details': 1,
  \ 
  \ 'notify_enabled': 1,
  \ 'notify_duration': 3000,
  \ }
```

**Benefits:**
- ✓ Consistent naming conventions
- ✓ All features have display mode config
- ✓ Feature-specific overrides available
- ✓ Clear inheritance from global config
- ✓ Easy to understand and maintain

---

## Display Mode Support Matrix

### Current State
```
Feature          | Quickfix | Popup | Inline | Split | Echo
─────────────────┼──────────┼───────┼────────┼───────┼─────
Compiler         |    ✓     |   ✗   |   ✗    |   ✗   |  ✗
Hints            |    ✗     |   ✗   |   ✗    |   ✗   |  ✗
Signatures       |    ✗     |   ✗   |   ✗    |   ✗   |  ✗
Progress         |    ✗     |   ✗   |   ✗    |   ✗   |  ✓
Debug Stream     |    ✗     |   ✗   |   ✗    |   ✓   |  ✗
Errors           |    ✗     |   ✗   |   ✗    |   ✗   |  ✓
```

### Proposed State
```
Feature          | Quickfix | Popup | Inline | Split | Echo
─────────────────┼──────────┼───────┼────────┼───────┼─────
Compiler         |    ✓     |   ✓   |   ✓    |   ✓   |  ✓
Hints            |    ✓     |   ✓   |   ✓    |   ✓   |  ✓
Signatures       |    ✓     |   ✓   |   ✓    |   ✓   |  ✓
Progress         |    ✓     |   ✓   |   ✓    |   ✓   |  ✓
Debug Stream     |    ✓     |   ✓   |   ✓    |   ✓   |  ✓
Errors           |    ✓     |   ✓   |   ✓    |   ✓   |  ✓
```

---

## Code Complexity Comparison

### Current Approach
```
Total Display Functions: ~30
- Main display module: 10 functions
- Compiler display: 8 functions
- Hints display: 7 functions
- Progress display: 2 functions
- Debug stream display: 3 functions

Duplication: High
- Multiple implementations of similar logic
- Inconsistent error handling
- Inconsistent formatting

Maintainability: Low
- Changes to display logic require updates in multiple places
- Difficult to add new display modes
- Difficult to ensure consistency
```

### Proposed Approach
```
Total Display Functions: ~20
- Main display module: 15 functions (extended)
- Compiler display: 3 functions (simplified)
- Hints display: 3 functions (simplified)
- Progress display: 1 function (simplified)
- Debug stream display: 1 function (simplified)

Duplication: Low
- Single implementation of display logic
- Consistent error handling
- Consistent formatting

Maintainability: High
- Changes to display logic in one place
- Easy to add new display modes
- Easy to ensure consistency
```

---

## Migration Path

### Phase 1: Foundation (No Breaking Changes)
- Extend display module with new functions
- Add feature-specific display mode configs
- Add mode resolution helper
- All existing code continues to work

### Phase 2: Compiler Integration
- Update compiler to use display module
- Maintain backward compatibility
- Existing configs still work

### Phase 3: Hints Integration
- Update hints to use display module
- Maintain backward compatibility
- Existing configs still work

### Phase 4: Other Features
- Update signatures, progress, debug stream
- Maintain backward compatibility
- Existing configs still work

### Phase 5: Cleanup (Optional)
- Remove deprecated functions
- Consolidate configuration
- Update documentation

---

## Backward Compatibility

### Guaranteed
- ✓ Default behavior unchanged (quickfix mode)
- ✓ Existing configuration still works
- ✓ Existing functions still available
- ✓ No breaking changes to public API

### Deprecation Path
- Old functions marked as deprecated
- Warnings logged when old functions used
- Gradual migration period (2-3 releases)
- Full removal in major version

---

## Summary

| Aspect | Current | Proposed |
|--------|---------|----------|
| **Consistency** | Fragmented | Unified |
| **Configuration** | Inconsistent | Consistent |
| **Maintainability** | Low | High |
| **Extensibility** | Difficult | Easy |
| **Code Duplication** | High | Low |
| **User Experience** | Inconsistent | Consistent |
| **Backward Compatibility** | N/A | Maintained |
| **Implementation Effort** | N/A | 6-9 days |

---

## Recommendation

**Proceed with unified architecture implementation.**

The proposed architecture provides significant improvements in consistency, maintainability, and extensibility while maintaining full backward compatibility. The implementation effort is reasonable and can be done incrementally.
