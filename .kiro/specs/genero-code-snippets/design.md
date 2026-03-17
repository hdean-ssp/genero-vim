# Design Document: Genero Code Snippets

## Overview

The Genero Code Snippets feature provides intelligent code snippet expansion for the genero-tools plugin, enabling developers to quickly insert common Genero language patterns. The system is designed with a Neovim-first approach, intentionally breaking Vim feature parity to provide enhanced value for Neovim users through async operations and smart parameter population.

The architecture consists of:
- **Snippet Library**: A collection of Genero pattern templates stored in Lua/JSON format
- **Snippet Engine**: Lua-based expansion engine for Neovim with VimScript fallback for Vim
- **Function Signature Integration**: Async querying of genero-tools API to populate function parameters
- **Placeholder Navigation**: Tab-based navigation through snippet fields with visual highlighting
- **Customization System**: User-accessible snippet files with hot-reload capability
- **Discovery Interface**: Commands to list and explore available snippets

## Architecture

### High-Level System Design

```
┌─────────────────────────────────────────────────────────────────┐
│                    Genero Code Snippets                         │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Snippet Trigger Layer                       │  │
│  │  ├─ Abbreviation triggers (e.g., "fn" → function)       │  │
│  │  ├─ Keybinding triggers (e.g., <C-s>)                   │  │
│  │  └─ Command triggers (e.g., :GeneroSnippet)             │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           ↓                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         Snippet Engine (Lua for Neovim)                 │  │
│  │  ├─ Snippet expansion                                   │  │
│  │  ├─ Placeholder navigation                              │  │
│  │  ├─ Variable substitution                               │  │
│  │  └─ Async parameter population                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           ↓                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         Snippet Library Manager                         │  │
│  │  ├─ Built-in snippets (Lua files)                       │  │
│  │  ├─ Custom snippets (user-defined)                      │  │
│  │  ├─ Snippet merging (custom overrides built-in)         │  │
│  │  └─ Hot-reload on file changes                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           ↓                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │      Function Signature Integration                     │  │
│  │  ├─ Async API queries (genero-tools)                    │  │
│  │  ├─ Parameter population                                │  │
│  │  ├─ Return type handling                                │  │
│  │  └─ Fallback to generic placeholders                    │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           ↓                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         UI & Display Layer                              │  │
│  │  ├─ Placeholder highlighting                            │  │
│  │  ├─ Selection menus (multiple snippets)                 │  │
│  │  ├─ Help/documentation display                          │  │
│  │  └─ Floating windows (Neovim) / Quickfix (Vim)          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Integration with Existing genero-tools

The snippet system integrates with genero-tools through:

1. **Lua Bridge**: Uses existing `lua_bridge.vim` to call Lua functions from VimScript
2. **Async Layer**: Leverages `lua/genero_tools/async.lua` for non-blocking API queries
3. **UI Layer**: Uses `lua/genero_tools/ui.lua` for floating windows and menus
4. **Command Execution**: Calls `genero_tools#command#execute_shell()` to query function signatures
5. **Caching**: Integrates with `genero_tools#cache#*()` for function signature caching
6. **Configuration**: Stores snippet settings in `g:genero_tools_config`

## Snippet Library Structure

### Directory Organization

```
lua/genero_tools/snippets/
├── init.lua                          # Snippet engine initialization
├── library.lua                        # Built-in snippet definitions
├── manager.lua                        # Snippet loading and merging
├── engine.lua                         # Expansion and navigation logic
├── patterns/
│   ├── function.lua                  # Function definition snippets
│   ├── control_flow.lua              # if/else, for, while, case
│   ├── error_handling.lua            # try/catch snippets
│   ├── data_structures.lua           # record, array snippets
│   └── common.lua                    # Other common patterns
└── templates/
    ├── builtin/                      # Built-in snippet templates
    │   ├── function.lua
    │   ├── if_else.lua
    │   ├── for_loop.lua
    │   ├── while_loop.lua
    │   ├── case_statement.lua
    │   ├── try_catch.lua
    │   ├── record.lua
    │   └── array.lua
    └── custom/                       # User custom snippets (optional)
        └── (user-defined files)
```

### Snippet Definition Format

Snippets are defined as Lua tables with the following structure:

```lua
{
  trigger = "fn",                    -- Abbreviation or keybinding
  name = "Function Definition",       -- Display name
  description = "Define a function", -- Help text
  pattern = "function",               -- Pattern category
  body = [[
    FUNCTION ${1:function_name}(${2:parameters}) RETURNS ${3:return_type}
      ${4:-- function body}
    END FUNCTION
  ]],
  placeholders = {
    { id = 1, label = "function_name", type = "identifier" },
    { id = 2, label = "parameters", type = "parameter_list" },
    { id = 3, label = "return_type", type = "type" },
    { id = 4, label = "body", type = "code" },
  },
  smart_expansion = true,            -- Enable async parameter population
  context = "global",                -- Where snippet can be used
  priority = 100,                    -- Higher priority = preferred
}
```

### Placeholder Syntax

Placeholders follow LuaSnip conventions:

- `${1:default}` - Numbered placeholder with default text
- `${1|option1,option2|}` - Choice placeholder
- `$VARIABLE` - Variable substitution (date, filename, etc.)
- `${1:${2:nested}}` - Nested placeholders

## Neovim Lua Implementation

### Snippet Integration Layer

Rather than building a custom snippet engine, we integrate with **LuaSnip** (primary) or other existing snippet engines. Our Lua layer focuses on:

1. **Snippet Library Management** - Loading and organizing Genero-specific snippets
2. **Smart Parameter Population** - Async querying of function signatures to populate snippet parameters
3. **Snippet Discovery** - Commands to list and explore available snippets

**File**: `lua/genero_tools/snippets/init.lua`

```lua
local Snippets = {}

-- Initialize snippet system
function Snippets.setup()
  -- Load built-in Genero snippets into LuaSnip
  -- Set up custom snippet directory
  -- Register snippet commands
  -- Set up keybindings
end

-- Load Genero snippets into LuaSnip
function Snippets.load_genero_snippets()
  -- Load built-in snippets from templates/
  -- Load custom snippets from user directory
  -- Register with LuaSnip
end

-- Populate function parameters in snippet
function Snippets.populate_function_params(snippet_context)
  -- Extract function name from context
  -- Query genero-tools API asynchronously
  -- Update snippet with parameter names/types
  -- Return updated snippet context
end

return Snippets
```

### Snippet Library Manager

**File**: `lua/genero_tools/snippets/manager.lua`

```lua
local Manager = {}

-- Load built-in Genero snippets
function Manager.load_builtin()
  -- Load all snippets from templates/builtin/
  -- Convert to LuaSnip format
  -- Return snippet table
end

-- Load custom snippets
function Manager.load_custom()
  -- Load snippets from user config directory
  -- Convert to LuaSnip format
  -- Return custom snippet table
end

-- Register snippets with LuaSnip
function Manager.register_with_luasnip(snippets)
  -- Add snippets to LuaSnip registry
  -- Make available for expansion
end

-- Watch for snippet file changes
function Manager.watch_files()
  -- Monitor custom snippet files
  -- Reload on changes
end

-- Get snippet by trigger
function Manager.get_snippet(trigger)
  -- Look up snippet by trigger key
  -- Return snippet definition
end

-- List all snippets
function Manager.list_snippets()
  -- Return all available snippets
end

return Manager
```

### Async Parameter Population

**File**: `lua/genero_tools/snippets/async_params.lua`

```lua
local AsyncParams = {}

-- Query function signature asynchronously
function AsyncParams.query_signature(function_name, callback)
  -- Use genero_tools.async to query API
  -- Call callback with signature data
  -- Handle errors gracefully
end

-- Populate snippet parameters from signature
function AsyncParams.populate_from_signature(snippet, signature)
  -- Extract parameter names and types
  -- Update LuaSnip placeholder defaults
  -- Mark optional parameters
  -- Return updated snippet context
end

-- Handle signature not found
function AsyncParams.fallback_parameters(snippet)
  -- Use generic parameter placeholders
  -- Return snippet with generic params
end

return AsyncParams
```

## Function Signature Integration

### Query Flow

```
User expands function call snippet
    ↓
Engine detects smart_expansion = true
    ↓
Extract function name from context
    ↓
AsyncParams.query_signature(function_name)
    ↓
genero_tools.async.execute_async('get-function-signature', [name])
    ↓
genero-tools CLI returns signature data
    ↓
AsyncParams.populate_from_signature(snippet, signature)
    ↓
Update placeholder defaults with parameter names/types
    ↓
Display updated snippet to user
```

### Parameter Population Logic

1. **Query genero-tools API** for function signature
2. **Extract parameters** from signature (name, type, optional flag)
3. **Update placeholders** with parameter information
4. **Mark optional parameters** with special syntax
5. **Handle return type** by adding return value placeholder
6. **Fallback to generic** if signature not found

### Caching Strategy

- Cache function signatures using `genero_tools#cache#*()` 
- TTL: 1 hour (configurable)
- Cache key: `snippet-signature:{function_name}`
- Invalidate on demand via `:GeneroClearCache`

## Trigger Mechanism

### Trigger Types

LuaSnip handles trigger expansion natively. Our integration:

1. **Abbreviation Triggers** (e.g., "fn" → function)
   - Defined in snippet metadata
   - LuaSnip detects and expands automatically
   - Works in insert mode

2. **Keybinding Triggers** (e.g., `<C-s>`)
   - User presses keybinding
   - Show snippet selection menu
   - User selects snippet
   - LuaSnip expands

3. **Command Triggers** (e.g., `:GeneroSnippet function`)
   - User runs command
   - Programmatically trigger LuaSnip expansion
   - Useful for discovery

### Trigger Configuration

Triggers are configured in `g:genero_tools_config`:

```lua
vim.g.genero_tools_config = {
  snippets_enabled = true,
  snippet_engine = 'luasnip',           -- Primary engine
  snippet_triggers = {
    abbreviations = true,               -- Enable abbreviation triggers
    keybindings = true,                 -- Enable keybinding triggers
    custom_triggers = {                 -- Custom trigger mappings
      fn = "function",
      ife = "if_else",
      -- ...
    }
  },
  snippet_keybinding = "<C-s>",         -- Keybinding for snippet menu
}
```

### Conflict Resolution

- User can customize or disable triggers via config
- Snippet triggers don't override existing keybindings
- If conflict detected, warn user and suggest alternative

## Placeholder Navigation

### Navigation Flow

LuaSnip handles placeholder navigation natively:

1. **Snippet Expanded**: LuaSnip positions cursor at first placeholder
2. **Tab Pressed**: LuaSnip moves to next placeholder
3. **Shift+Tab Pressed**: LuaSnip moves to previous placeholder
4. **Placeholder Highlighted**: LuaSnip provides visual feedback
5. **Placeholder Exited**: Continue editing or expand another snippet

### Navigation Keybindings

LuaSnip default keybindings:

```lua
-- In snippet context
<Tab>       -- Next placeholder (LuaSnip default)
<S-Tab>     -- Previous placeholder (LuaSnip default)
<C-c>       -- Exit snippet mode (LuaSnip default)
<Esc>       -- Exit snippet mode (LuaSnip default)
```

Our integration respects LuaSnip's navigation defaults.

## Customization System

### User Snippet Directory

Snippets can be customized by creating files in:

```
~/.config/nvim/genero-snippets/  (Neovim)
~/.vim/genero-snippets/          (Vim)
```

### Custom Snippet Format

Users create Lua files with snippet definitions:

```lua
-- ~/.config/nvim/genero-snippets/custom.lua
return {
  {
    trigger = "mysnip",
    name = "My Custom Snippet",
    body = [[
      -- Custom snippet body
    ]],
    placeholders = { ... },
  },
  -- More snippets...
}
```

### Snippet Merging

- Built-in snippets loaded first
- Custom snippets loaded second
- Custom snippets with same trigger override built-in
- Merged library available to engine

### Hot-Reload

- File watcher monitors custom snippet directory
- On file change, reload snippets
- No plugin restart required
- User notified of reload

## Integration Points

### With GeneroLookup

When user looks up a function via `:GeneroLookup`, offer option to:
- Expand function call snippet with looked-up function
- Populate parameters from function signature

### With Autocomplete

When autocomplete suggests a function, offer option to:
- Expand function call snippet with suggested function
- Populate parameters from function signature

### With Existing Keybindings

- Snippet triggers don't override existing keybindings
- User can customize or disable snippet triggers
- Snippet mode exits cleanly without affecting other features

## Error Handling

### Snippet Expansion Errors

1. **Invalid Placeholder Syntax**: Log error, display generic snippet
2. **Function Signature Not Found**: Use generic parameter placeholders
3. **Async Query Timeout**: Fall back to generic parameters
4. **Snippet File Parse Error**: Log error, skip invalid snippet

### User Guidance

- Provide clear error messages
- Suggest corrective actions
- Link to documentation
- Offer fallback options

## Testing Strategy

### Unit Testing

**Snippet Library Tests**:
- Verify all built-in snippets exist with correct structure
- Verify placeholder syntax is valid
- Verify snippet merging works correctly
- Verify custom snippets override built-in

**Engine Tests**:
- Verify snippet expansion inserts correct text
- Verify cursor positioned at first placeholder
- Verify placeholder navigation works
- Verify variable substitution works

**Parameter Population Tests**:
- Verify function signature queries work
- Verify parameters populated correctly
- Verify fallback to generic parameters
- Verify optional parameters marked correctly

**Trigger Tests**:
- Verify abbreviation triggers work
- Verify keybinding triggers work
- Verify command triggers work
- Verify trigger conflicts handled

### Property-Based Testing

Property tests verify universal properties across all inputs using randomization.

### Integration Tests

- Verify snippets work with genero-tools API
- Verify snippets work with existing keybindings
- Verify snippets work with autocomplete
- Verify snippets work with GeneroLookup

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Snippet Expansion Positions Cursor at First Placeholder

*For any* snippet with placeholders, when expanded, the cursor should be positioned at the first placeholder for immediate editing.

**Validates: Requirements 1.9**

### Property 2: Tab Navigation Moves Through Placeholders in Sequence

*For any* snippet with multiple placeholders, pressing Tab should move the cursor to the next placeholder in sequence.

**Validates: Requirements 1.10**

### Property 3: Function Signature Query Populates Parameters

*For any* function call snippet in Neovim with a valid function name, expanding the snippet should query the genero-tools API and populate parameter placeholders with parameter names and types.

**Validates: Requirements 2.1, 2.2**

### Property 4: Return Type Placeholder Included for Functions with Return Types

*For any* function signature with a return type, the expanded snippet should include a placeholder for the return value assignment.

**Validates: Requirements 2.3**

### Property 5: Fallback to Generic Parameters When Signature Not Found

*For any* function call snippet where the function signature cannot be found, the snippet should fall back to generic parameter placeholders.

**Validates: Requirements 2.4**

### Property 6: Optional Parameters Marked in Snippet

*For any* function signature with optional parameters, the expanded snippet should mark optional parameters as such.

**Validates: Requirements 2.5**

### Property 7: Placeholder Navigation Works in Neovim

*For any* snippet expanded in Neovim, placeholder navigation and substitution should work correctly.

**Validates: Requirements 3.2**

### Property 8: Async Queries Don't Block Editor

*For any* async function signature query, the editor should remain responsive and not block during the query.

**Validates: Requirements 3.3**

### Property 9: Selection Menu Presented for Multiple Snippets

*For any* pattern with multiple available snippets, a selection menu should be presented to the user.

**Validates: Requirements 3.4**

### Property 10: Variable Substitution Works in Snippets

*For any* snippet with variables (e.g., $DATE, $FILENAME), the variables should be substituted correctly when the snippet is expanded.

**Validates: Requirements 3.5**

### Property 11: Current Placeholder Highlighted While Active

*For any* active snippet, the current placeholder should be highlighted for visual clarity.

**Validates: Requirements 3.6**

### Property 12: Trigger Keys Activate Snippet Expansion

*For any* configured trigger key, pressing the key should expand the corresponding snippet at the cursor position.

**Validates: Requirements 4.1, 4.2**

### Property 13: User-Defined Trigger Mappings Respected

*For any* user-defined trigger mapping, the snippet engine should respect the custom mapping.

**Validates: Requirements 4.3**

### Property 14: Snippet Abbreviations Expand on Demand

*For any* snippet abbreviation (e.g., "fn"), typing the abbreviation should expand the snippet on demand.

**Validates: Requirements 4.5**

### Property 15: Snippet File Changes Reloaded Without Restart

*For any* modification to a snippet file, the snippet engine should reload the changes without requiring a plugin restart.

**Validates: Requirements 5.2**

### Property 16: Custom Snippets Merged with Built-in Snippets

*For any* custom snippet defined, the snippet engine should merge it with built-in snippets and make it available.

**Validates: Requirements 5.3**

### Property 17: Custom Snippets Take Precedence Over Built-in

*For any* custom snippet with the same trigger as a built-in snippet, the custom snippet should take precedence.

**Validates: Requirements 5.4**

### Property 18: List Command Shows All Available Snippets

*For any* list command execution, all available snippets should be listed with their triggers and descriptions.

**Validates: Requirements 6.1**

### Property 19: Help Command Displays Snippet Documentation

*For any* help command execution, snippet documentation should be displayed including trigger keys and placeholder descriptions.

**Validates: Requirements 6.2**

### Property 20: Help Accessible via Command or Floating Window

*For any* snippet with documentation, the documentation should be accessible via a help command or floating window.

**Validates: Requirements 6.4**

### Property 21: Guidance Provided When Snippet Engine Not Installed

*For any* case where a snippet engine is not installed, the plugin should provide guidance on installing a compatible engine.

**Validates: Requirements 7.1**

### Property 22: Neovim-Specific Features Disabled in Vim

*For any* Vim environment (not Neovim), Neovim-specific snippet features (smart expansion, async population) should be disabled.

**Validates: Requirements 7.2**

### Property 23: Basic Snippet Expansion Works in Vim

*For any* Vim environment with a compatible snippet engine, basic snippet expansion should work.

**Validates: Requirements 7.3**

### Property 24: Manual Snippet Insertion Available When Engine Unavailable

*For any* case where a snippet engine is unavailable, users should be able to manually insert snippet templates as text blocks.

**Validates: Requirements 7.4**

### Property 25: Generated Code is Syntactically Valid

*For any* snippet expansion, the generated code should be syntactically valid Genero code.

**Validates: Requirements 8.1**

### Property 26: Placeholder Syntax Follows Snippet Engine Conventions

*For any* snippet, the placeholder syntax should follow the snippet engine's conventions (e.g., `${1:name}` for LuaSnip).

**Validates: Requirements 8.2**

### Property 27: Expanded Code Compiles Without Syntax Errors

*For any* snippet expansion, the expanded code should compile without syntax errors.

**Validates: Requirements 8.3**

### Property 28: Error Logged and Guidance Provided for Invalid Code

*For any* snippet that generates invalid code, an error should be logged and corrective guidance provided.

**Validates: Requirements 8.4**

### Property 29: Parameter Types Match Function Definition

*For any* function signature used to populate parameters, the parameter types should match the function definition.

**Validates: Requirements 8.5**

### Property 30: Existing Keybindings Not Disrupted

*For any* snippet expansion, existing keybindings should not be disrupted or overridden.

**Validates: Requirements 9.3**

### Property 31: User Can Choose Between Snippets and Autocomplete

*For any* case where both snippets and autocomplete apply, the user should be able to choose which feature to use.

**Validates: Requirements 9.4**

## Documentation

### User Documentation

- **Snippet Reference**: List of all available snippets with examples
- **Configuration Guide**: How to enable/disable snippets and configure engines
- **Custom Snippets Guide**: How to create and customize snippets
- **Troubleshooting**: Common issues and solutions
- **Vim vs Neovim**: Feature comparison and differences

### Developer Documentation

- **Snippet Format**: Specification for snippet definition format
- **Engine API**: API for snippet engine functions
- **Integration Guide**: How to integrate snippets with other features
- **Testing Guide**: How to test snippets

## Configuration

Snippet configuration is stored in `g:genero_tools_config`:

```lua
vim.g.genero_tools_config = {
  snippets_enabled = true,
  snippet_engine = 'luasnip',           -- or 'vim-snipmate', 'vim-vsnip'
  snippet_triggers = {
    abbreviations = true,
    keybindings = true,
    custom_triggers = {
      fn = 'function',
      ife = 'if_else',
      -- ...
    }
  },
  snippet_keybinding = '<C-s>',
  snippet_custom_dir = '~/.config/nvim/genero-snippets',
  snippet_smart_expansion = true,       -- Enable async parameter population
  snippet_highlight_placeholder = true, -- Highlight current placeholder
  snippet_cache_signatures = true,      -- Cache function signatures
}
```

## Constraints and Assumptions

### Constraints

1. **Neovim-First**: Intentionally breaks Vim feature parity for Neovim enhancements
2. **LuaSnip Dependency**: Designed to work with LuaSnip as primary engine
3. **Async Operations**: Function signature queries are asynchronous
4. **genero-tools API**: Relies on existing genero-tools API for function signatures

### Assumptions

1. **Neovim 0.5+**: Lua layer requires Neovim 0.5 or later
2. **LuaSnip Installed**: User has installed LuaSnip (or compatible engine)
3. **genero-tools Available**: genero-tools CLI is available and configured
4. **Function Signatures Available**: Function signatures are available via genero-tools API

## Future Enhancements

1. **AI-Powered Snippets**: Generate snippets based on context using AI
2. **Snippet Marketplace**: Share and discover community snippets
3. **Context-Aware Snippets**: Suggest snippets based on code context
4. **Snippet Composition**: Combine multiple snippets into complex patterns
5. **LSP Integration**: Use LSP for better parameter population
