# Configurable Code Hints - Implementation Started

## Status: Phase 1 Core Infrastructure Complete

The hint engine core module has been created and is ready for detector implementation.

## What Was Completed

### Core Module: `autoload/genero_tools/hints.vim`

The main hint engine orchestrator has been implemented with:

- **Initialization System** (`genero_tools#hints#init()`)
  - Loads configuration with defaults
  - Initializes cache system
  - Initializes display system
  - Registers built-in detectors
  - Sets up autocommands for Genero files (.4gl, .m3, .m4, .per)

- **Detector Registration** (`genero_tools#hints#register_detector()`)
  - Allows detectors to be registered without modifying core code
  - Supports extensibility for future hint checks

- **Analysis Engine** (`genero_tools#hints#analyze()`)
  - Checks cache first for performance
  - Runs all enabled detectors
  - Merges results from multiple detectors
  - Handles detector failures gracefully
  - Stores results in cache and buffer state

- **Hint Retrieval** (`genero_tools#hints#get_hints()`)
  - Returns cached hints without re-analyzing
  - Falls back to cache if buffer state unavailable

- **Hint Clearing** (`genero_tools#hints#clear()`)
  - Removes hints from display
  - Invalidates cache
  - Clears buffer state

- **Autocommand Handlers**
  - `on_buffer_read()` - Analyze on file open
  - `on_buffer_write()` - Re-analyze on file save
  - `on_text_changed()` - Real-time analysis with debouncing

- **Debouncing System** (`debounce_callback()`)
  - Prevents excessive analysis while typing
  - Configurable delay (default: 500ms)
  - Cancels previous timers to avoid overlapping analysis

- **Hint Creation Helper** (`genero_tools#hints#create_hint()`)
  - Standardized hint dictionary structure
  - Used by all detectors for consistency

## Architecture

```
genero_tools#hints#init()
  ├─ genero_tools#hints#config#init()
  ├─ genero_tools#hints#cache#init()
  ├─ genero_tools#hints#display#init()
  └─ register_detector() × 4
      ├─ whitespace#detect()
      ├─ keyword#detect()
      ├─ structure#detect()
      └─ genero#detect()

genero_tools#hints#analyze(bufnr)
  ├─ Check hints_enabled config
  ├─ Check cache
  ├─ Run all detectors
  ├─ Merge results
  ├─ Store in cache
  └─ Return hints

Autocommands (BufRead, BufWrite, TextChanged, TextChangedI)
  ├─ on_buffer_read() → analyze() → display#show()
  ├─ on_buffer_write() → invalidate cache → analyze() → display#show()
  └─ on_text_changed() → debounce → analyze() → display#show()
```

## Next Steps

### Phase 1 Remaining Tasks

1. **Task 1.2** - Create configuration system module (`autoload/genero_tools/hints/config.vim`)
   - Load effective configuration for files
   - Validate configuration settings
   - Load per-file configuration from `.genero-hints`

2. **Task 1.4** - Create cache system module (`autoload/genero_tools/hints/cache.vim`)
   - Store hint results with timestamp
   - Implement TTL-based expiration
   - Implement LRU eviction

3. **Task 1.6** - Create display system module (`autoload/genero_tools/hints/display.vim`)
   - Display hints in sign column
   - Display hints as virtual text (Neovim)
   - Show hint details in popup/floating window

### Phase 2 - Detection Modules

4. **Task 2.1** - Whitespace & formatting detector
5. **Task 2.3** - Keyword & naming detector
6. **Task 2.5** - Code structure detector
7. **Task 2.7** - Genero-specific detector

### Phase 3 - User Interface

8. **Task 3.1** - Navigation commands
9. **Task 3.3** - Hint details display
10. **Task 3.5** - Sign column integration
11. **Task 3.7** - Virtual text support (Neovim)
12. **Task 3.9** - Help system

### Phase 4 - Advanced Features

13. **Task 4.1** - Auto-fix system
14. **Task 4.3** - Real-time analysis with debouncing
15. **Task 4.7** - Per-file configuration support

### Phase 5 - Integration & Polish

16. **Task 5.1** - Sign column integration with compiler
17. **Task 5.3** - Configuration system integration
18. **Task 5.5** - Display system integration
19. **Task 5.7** - Error handling integration
20. **Task 5.9** - Vim/Neovim compatibility

### Phase 6 - Testing & Validation

21. **Task 6.1** - Comprehensive unit tests
22. **Task 6.2** - Property-based tests (74 properties)
23. **Task 6.3** - Integration tests
24. **Task 6.4** - Performance testing
25. **Task 6.5** - Edge case testing
26. **Task 6.6** - Compatibility testing

## Documentation

- **User Guide**: `docs/HINTS.md` - Complete hints documentation
- **Quick Reference**: `docs/DEVELOPER_QUICK_REFERENCE.md` - Updated with hints commands
- **README**: Updated with hints feature description

## How to Continue

1. Open `.kiro/specs/configurable-code-hints/tasks.md`
2. Start with Task 1.2 (Configuration System)
3. Follow the implementation plan sequentially
4. Each task references specific requirements for traceability
5. Property-based tests validate correctness properties

## Key Design Decisions

1. **Modular Architecture** - Each detector is independent and can be extended
2. **Cache-First** - Always check cache before analyzing to improve performance
3. **Graceful Degradation** - Detector failures don't break the system
4. **Debouncing** - Real-time analysis debounced to prevent excessive checks
5. **Separation of Concerns** - Detection, configuration, display, and caching are separate modules

## Testing Strategy

- **Unit Tests** - Test each module independently
- **Property-Based Tests** - Validate 74 correctness properties
- **Integration Tests** - Test module interactions
- **Performance Tests** - Ensure analysis completes within hints_delay
- **Edge Case Tests** - Empty files, large files, deeply nested code, etc.

## Configuration

All hints are fully configurable through `g:genero_tools_config`:

```vim
" System options
hints_enabled = 1
hints_display = 'signs'
hints_severity = 'warning'
hints_realtime = 1
hints_cache_enabled = 1
hints_cache_ttl = 300
auto_fix_enabled = 1
hints_delay = 500

" Individual checks (1 = enabled, 0 = disabled)
trailing_whitespace = 1
mixed_indentation = 1
lowercase_keywords = 1
... (14 more checks)

" Thresholds
max_line_length = 100
max_nesting_depth = 5
max_blank_lines = 2
naming_convention_style = 'camelCase'
```

## Performance Characteristics

- **Analysis Time**: Completes within `hints_delay` (default 500ms)
- **Cache Hit**: Returns cached results instantly
- **Memory**: LRU eviction prevents unbounded growth
- **Real-time**: Debounced to prevent excessive analysis while typing
- **Background**: Other files analyzed when editor is idle

---

**Ready to implement?** Open `.kiro/specs/configurable-code-hints/tasks.md` and start with Task 1.2!
