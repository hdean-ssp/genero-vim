# Lua Layer Architecture Overview

## Visual Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    vim-genero-tools Plugin                      │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              VimScript Layer (Primary)                   │  │
│  │                                                          │  │
│  │  plugin/genero_tools.vim                                │  │
│  │  ├─ Initialize configuration                            │  │
│  │  ├─ Initialize Lua layer (if available)                 │  │
│  │  ├─ Register commands                                   │  │
│  │  └─ Register keybindings                                │  │
│  │                                                          │  │
│  │  autoload/genero_tools.vim                              │  │
│  │  ├─ lookup_function()                                   │  │
│  │  ├─ list_module_files()                                 │  │
│  │  ├─ list_functions_in_file()                            │  │
│  │  ├─ get_function_signature()                            │  │
│  │  └─ get_file_metadata()                                 │  │
│  │                                                          │  │
│  │  autoload/genero_tools/config.vim                       │  │
│  │  ├─ init()                                              │  │
│  │  ├─ get()                                               │  │
│  │  └─ show()                                              │  │
│  │                                                          │  │
│  │  autoload/genero_tools/cache.vim                        │  │
│  │  ├─ get()                                               │  │
│  │  ├─ set()                                               │  │
│  │  └─ clear()                                             │  │
│  │                                                          │  │
│  │  autoload/genero_tools/command.vim                      │  │
│  │  └─ execute_shell()                                     │  │
│  │                                                          │  │
│  │  autoload/genero_tools/complete.vim                     │  │
│  │  ├─ omnifunc()                                          │  │
│  │  ├─ get_completions()                                   │  │
│  │  └─ enable/disable()                                    │  │
│  │                                                          │  │
│  │  autoload/genero_tools/compiler.vim                     │  │
│  │  ├─ compile()                                           │  │
│  │  ├─ parse_errors()                                      │  │
│  │  └─ show_errors()                                       │  │
│  │                                                          │  │
│  │  autoload/genero_tools/display.vim                      │  │
│  │  ├─ quickfix()                                          │  │
│  │  ├─ echo()                                              │  │
│  │  └─ result()                                            │  │
│  │                                                          │  │
│  │  autoload/genero_tools/keybindings.vim                  │  │
│  │  └─ register()                                          │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         Lua Bridge (VimScript ↔ Lua Interface)          │  │
│  │                                                          │  │
│  │  autoload/genero_tools/lua_bridge.vim                   │  │
│  │  ├─ available()                                         │  │
│  │  ├─ call()                                              │  │
│  │  ├─ call_safe()                                         │  │
│  │  ├─ execute_async()                                     │  │
│  │  ├─ show_floating_window()                              │  │
│  │  ├─ explain_error()                                     │  │
│  │  ├─ generate_code()                                     │  │
│  │  └─ init()                                              │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         Lua Layer (Enhancement - Neovim Only)           │  │
│  │                                                          │  │
│  │  lua/genero_tools/init.lua                              │  │
│  │  ├─ setup()                                             │  │
│  │  ├─ is_available()                                      │  │
│  │  ├─ setup_autocommands()                                │  │
│  │  ├─ version()                                           │  │
│  │  └─ health_check()                                      │  │
│  │                                                          │  │
│  │  lua/genero_tools/async.lua                             │  │
│  │  ├─ execute_async()                                     │  │
│  │  ├─ call_ai_api()                                       │  │
│  │  ├─ execute_parallel()                                  │  │
│  │  ├─ debounce()                                          │  │
│  │  └─ throttle()                                          │  │
│  │                                                          │  │
│  │  lua/genero_tools/ui.lua                                │  │
│  │  ├─ show_floating_window()                              │  │
│  │  ├─ show_popup_menu()                                   │  │
│  │  ├─ show_split()                                        │  │
│  │  ├─ notify()                                            │  │
│  │  ├─ show_progress()                                     │  │
│  │  └─ highlight_pattern()                                 │  │
│  │                                                          │  │
│  │  lua/genero_tools/ai.lua                                │  │
│  │  ├─ explain_error()                                     │  │
│  │  ├─ generate_code()                                     │  │
│  │  ├─ suggest_refactoring()                               │  │
│  │  ├─ call_api()                                          │  │
│  │  ├─ call_openai()                                       │  │
│  │  ├─ call_claude()                                       │  │
│  │  ├─ call_local()                                        │  │
│  │  ├─ cache_response()                                    │  │
│  │  └─ get_cached_response()                               │  │
│  │                                                          │  │
│  │  lua/genero_tools/lsp.lua                               │  │
│  │  ├─ setup_lsp_client()                                  │  │
│  │  ├─ get_hover_info()                                    │  │
│  │  ├─ get_definition()                                    │  │
│  │  ├─ get_references()                                    │  │
│  │  ├─ rename_symbol()                                     │  │
│  │  ├─ format_document()                                   │  │
│  │  └─ format_range()                                      │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Shared Data Model                           │  │
│  │                                                          │  │
│  │  g:genero_tools_config (VimScript Dict)                 │  │
│  │  ├─ lua_enabled                                         │  │
│  │  ├─ async_enabled                                       │  │
│  │  ├─ ui_mode                                             │  │
│  │  ├─ lsp_enabled                                         │  │
│  │  ├─ ai_enabled                                          │  │
│  │  ├─ ai_provider                                         │  │
│  │  ├─ ai_api_key                                          │  │
│  │  └─ ... (other config options)                          │  │
│  │                                                          │  │
│  │  Cache Layer (Shared)                                   │  │
│  │  ├─ VimScript: genero_tools#cache#*()                   │  │
│  │  └─ Lua: vim.fn['genero_tools#cache#*']()               │  │
│  │                                                          │  │
│  │  Command Execution (Shared)                             │  │
│  │  ├─ VimScript: genero_tools#command#execute_shell()     │  │
│  │  └─ Lua: vim.fn['genero_tools#command#execute_shell']() │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

### VimScript Command Flow (Works in Vim & Neovim)

```
User Command
    ↓
plugin/genero_tools.vim (Command Registration)
    ↓
autoload/genero_tools.vim (Core API)
    ↓
autoload/genero_tools/command.vim (Execute Shell)
    ↓
genero-tools CLI (query.sh)
    ↓
Result
    ↓
autoload/genero_tools/display.vim (Display Result)
    ↓
User sees result (quickfix, echo, split, etc.)
```

### Lua Enhancement Flow (Neovim Only)

```
User Command
    ↓
plugin/genero_tools.vim (Command Registration)
    ↓
autoload/genero_tools/lua_bridge.vim (Check if Lua available)
    ↓
lua/genero_tools/*.lua (Lua Implementation)
    ↓
Async/UI/AI/LSP Features
    ↓
Result
    ↓
User sees enhanced result (floating window, async, etc.)
```

### Fallback Flow (Lua Unavailable)

```
User Command
    ↓
autoload/genero_tools/lua_bridge.vim (Lua unavailable)
    ↓
Fallback to VimScript
    ↓
autoload/genero_tools.vim (Core API)
    ↓
Result (same as VimScript flow)
```

## Integration Points

### 1. Configuration Access

```
VimScript                          Lua
    ↓                              ↓
g:genero_tools_config ←────────────→ vim.g.genero_tools_config
    ↓                              ↓
genero_tools#config#get()          vim.g.genero_tools_config[key]
```

### 2. Command Execution

```
Lua                                VimScript
    ↓                              ↓
vim.fn['genero_tools#command#execute_shell']()
    ↓
genero-tools CLI
    ↓
Result
```

### 3. Caching

```
VimScript                          Lua
    ↓                              ↓
genero_tools#cache#get/set() ←────→ vim.fn['genero_tools#cache#get/set']()
    ↓                              ↓
Shared Cache Dictionary
```

## Feature Availability

### Vim 8.0+
- ✅ Function lookup
- ✅ Module exploration
- ✅ File metadata
- ✅ Autocomplete
- ✅ Compiler integration
- ✅ Caching
- ✅ Configuration

### Neovim 0.4+ (Without Lua)
- ✅ All Vim features
- ❌ Async operations
- ❌ Floating windows
- ❌ LSP integration
- ❌ AI features

### Neovim 0.5+ (With Lua Enabled)
- ✅ All Vim features
- ✅ Async operations
- ✅ Floating windows
- ✅ LSP integration
- ✅ AI features

## Configuration Hierarchy

```
Default Config (in code)
    ↓
User Config (g:genero_tools_config)
    ↓
Lua Layer Config (if enabled)
    ↓
Feature-Specific Config
```

## Error Handling Strategy

```
VimScript Call
    ↓
Try Lua Implementation
    ↓
Success? → Return Lua Result
    ↓
Failure? → Log Error
    ↓
Fallback to VimScript
    ↓
Return VimScript Result
```

## Performance Optimization

### Caching Strategy
```
Request
    ↓
Check Cache (VimScript or Lua)
    ↓
Cache Hit? → Return Cached Result
    ↓
Cache Miss? → Execute Command
    ↓
Store in Cache
    ↓
Return Result
```

### Async Strategy (Lua Only)
```
Request
    ↓
Start Background Job
    ↓
Return Immediately (Non-blocking)
    ↓
Job Completes
    ↓
Call Callback with Result
    ↓
Display Result
```

## Deployment Strategy

### Phase 1: Foundation (Current)
- VimScript core functionality
- Lua bridge layer
- Lua module structure

### Phase 2: Async & UI
- Lua async operations
- Floating window UI
- Non-blocking execution

### Phase 3: LSP Integration
- Lua LSP client
- Hover information
- Goto definition

### Phase 4: AI IDE Features
- Error explanation
- Code generation
- Refactoring suggestions

## Testing Matrix

```
                    Vim 8.0+    Neovim 0.4+    Neovim 0.5+ (Lua)
Core Features       ✅          ✅             ✅
Async Operations    ❌          ❌             ✅
Floating Windows    ❌          ❌             ✅
LSP Integration     ❌          ❌             ✅
AI Features         ❌          ❌             ✅
```

## File Organization

```
vim-genero-tools/
├── plugin/
│   └── genero_tools.vim                    # Entry point
├── autoload/
│   ├── genero_tools.vim                    # Core API
│   └── genero_tools/
│       ├── lua_bridge.vim                  # NEW: Lua bridge
│       ├── config.vim
│       ├── cache.vim
│       ├── command.vim
│       ├── display.vim
│       ├── complete.vim
│       ├── compiler.vim
│       ├── keybindings.vim
│       └── ... (other modules)
├── lua/                                    # NEW: Lua layer
│   └── genero_tools/
│       ├── init.lua                        # NEW: Initialization
│       ├── async.lua                       # NEW: Async operations
│       ├── ui.lua                          # NEW: UI components
│       ├── ai.lua                          # NEW: AI features
│       └── lsp.lua                         # NEW: LSP integration
├── docs/
│   ├── NEOVIM_LUA_LAYER.md                # NEW: Architecture
│   ├── NEOVIM_LUA_FEATURES.md             # NEW: User guide
│   ├── LUA_QUICK_REFERENCE.md             # NEW: Quick ref
│   └── ... (other docs)
├── .kiro/steering/
│   └── lua-layer-architecture.md          # NEW: Developer guide
└── ... (other files)
```

## Summary

This architecture provides:

1. **Clear Separation** - VimScript for interface, Lua for implementation
2. **Graceful Degradation** - Works without Lua, enhanced with Lua
3. **Backward Compatibility** - Vim users unaffected
4. **Future-Proof** - Easy to add new Lua features
5. **Performance** - Async operations, caching, optimization
6. **Maintainability** - Clear patterns and guidelines
7. **Extensibility** - Plugin API for third-party extensions

The plugin serves both Vim users (with full functionality) and Neovim users (with optional enhancements), positioning it well for the future while respecting the present.
