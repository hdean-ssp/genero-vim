# Genero-Tools Lua API Reference

**Status:** Complete Lua API Documentation  
**Target:** Neovim 0.4+  
**Last Updated:** March 19, 2026

---

## Overview

The genero-tools plugin provides a comprehensive Lua API for Neovim users. This reference documents all 60+ Lua functions across 7 modules, enabling advanced customization and integration.

**Note:** Lua features require Neovim 0.4+. Vim users should use VimScript APIs instead.

---

## Table of Contents

1. [Core Module](#core-module-luagenero_toolsinit)
2. [Async Module](#async-module-luagenero_toolsasync)
3. [UI Module](#ui-module-luagenero_toolsui)
4. [Lualine Integration](#lualine-integration-luagenero_toolslualine)
5. [Snippets Module](#snippets-module-luagenero_toolssnippets)
6. [Snippet Manager](#snippet-manager-luagenero_toolssnippetsmanager)
7. [Async Parameters](#async-parameters-luagenero_toolssnippetsasync_params)
8. [Snippet Integration](#snippet-integration-luagenero_toolssnippetsintegration)

---

## Core Module (`lua/genero_tools/init.lua`)

The core module provides initialization and health checking for the Lua layer.

### `M.is_available()`

Check if Lua layer is available (Neovim only).

**Returns:** `boolean` - True if running on Neovim, false otherwise

**Example:**
```lua
if require('genero_tools').is_available() then
  print("Lua layer available")
end
```

---

### `M.setup(config)`

Initialize the Lua layer with configuration.

**Parameters:**
- `config` (table, optional) - Configuration table (uses `vim.g.genero_tools_config` if not provided)

**Returns:** `nil`

**Example:**
```lua
require('genero_tools').setup({
  async_enabled = true,
  ui_mode = 'floating',
})
```

---

### `M.setup_autocommands()`

Set up autocommands for Lua features (called automatically by `setup()`).

**Returns:** `nil`

**Details:**
- Creates `GeneroToolsLua` autocommand group
- Sets up VimEnter event for initialization
- Enables Lua features based on configuration

---

### `M.version()`

Get the Lua layer version.

**Returns:** `string` - Version number (e.g., "1.0.0")

**Example:**
```lua
local version = require('genero_tools').version()
print("Genero-Tools Lua version: " .. version)
```

---

### `M.health_check()`

Perform health check for Lua layer.

**Returns:** `table` - Health status with keys:
- `available` (boolean) - Lua layer available
- `version` (string) - Module version
- `async_enabled` (boolean) - Async operations enabled
- `ui_enabled` (boolean) - UI module enabled
- `snippets_enabled` (boolean) - Snippets enabled
- `lua_enabled` (boolean) - Lua layer enabled in configuration

**Example:**
```lua
local health = require('genero_tools').health_check()
if health.available then
  print("Lua layer healthy")
end
```

---

## Async Module (`lua/genero_tools/async.lua`)

Provides non-blocking command execution for Neovim using job control.

### `M.init()`

Initialize async module.

**Returns:** `nil`

---

### `M.execute_async(command, args, callback)`

Execute a genero-tools command asynchronously.

**Parameters:**
- `command` (string) - Command name (e.g., 'find-function')
- `args` (table) - Command arguments as list
- `callback` (string or function) - VimScript function name or Lua function to call with results

**Returns:** `number` - Job ID

**Example:**
```lua
local async = require('genero_tools.async')

async.execute_async('find-function', {'myFunction'}, function(result)
  if result.success then
    print("Found: " .. vim.inspect(result.data))
  else
    print("Error: " .. result.error)
  end
end)
```

---

### `M.parse_output(output, error_output, exit_code)`

Parse command output into result structure.

**Parameters:**
- `output` (table) - Lines of stdout
- `error_output` (table) - Lines of stderr
- `exit_code` (number) - Command exit code

**Returns:** `table` - Result with keys:
- `success` (boolean) - Command succeeded
- `data` (table) - Parsed JSON data
- `error` (string) - Error message if failed
- `timestamp` (number) - Unix timestamp

---

### `M.execute_parallel(commands, callback)`

Execute multiple commands in parallel.

**Parameters:**
- `commands` (table) - List of command tables with `command` and `args` keys
- `callback` (function) - Called with results table when all complete

**Returns:** `table` - Job IDs for each command

**Example:**
```lua
local async = require('genero_tools.async')

async.execute_parallel({
  { command = 'find-function', args = {'func1'} },
  { command = 'find-function', args = {'func2'} },
}, function(results)
  for i, result in ipairs(results) do
    print("Result " .. i .. ": " .. (result.success and "OK" or "FAILED"))
  end
end)
```

---

### `M.debounce(func, delay)`

Debounce function execution (delay before calling).

**Parameters:**
- `func` (function) - Function to debounce
- `delay` (number) - Delay in milliseconds

**Returns:** `function` - Debounced function

**Example:**
```lua
local async = require('genero_tools.async')

local debounced_search = async.debounce(function(query)
  print("Searching for: " .. query)
end, 500)

-- Call multiple times, only executes once after 500ms of inactivity
debounced_search("test")
debounced_search("test2")
debounced_search("test3")  -- Only this one executes
```

---

### `M.throttle(func, interval)`

Throttle function execution (max once per interval).

**Parameters:**
- `func` (function) - Function to throttle
- `interval` (number) - Minimum interval in milliseconds

**Returns:** `function` - Throttled function

**Example:**
```lua
local async = require('genero_tools.async')

local throttled_scroll = async.throttle(function()
  print("Scroll event")
end, 100)

-- Called on every scroll, but executes max once per 100ms
```

---

## UI Module (`lua/genero_tools/ui.lua`)

Provides modern UI components for Neovim (floating windows, popups, etc.).

### `M.init()`

Initialize UI module.

**Returns:** `nil`

---

### `M.show_floating_window(content, options)`

Display content in a floating window.

**Parameters:**
- `content` (string or table) - Content to display (string or list of strings)
- `options` (table, optional) - Display options:
  - `title` (string) - Window title
  - `width` (number) - Window width in columns
  - `height` (number) - Window height in lines
  - `border` (string) - Border style: 'rounded', 'solid', 'shadow', 'none'
  - `position` (string) - Position: 'center', 'top', 'bottom', 'left', 'right', 'cursor'

**Returns:** `table` - Window info with keys:
- `buf` (number) - Buffer handle
- `win` (number) - Window handle
- `width` (number) - Actual width
- `height` (number) - Actual height

**Example:**
```lua
local ui = require('genero_tools.ui')

ui.show_floating_window({
  "Line 1",
  "Line 2",
  "Line 3",
}, {
  title = "My Window",
  width = 60,
  height = 10,
  border = "rounded",
  position = "center",
})
```

---

### `M.setup_floating_window_keys(buf, win)`

Set up keybindings for floating window.

**Parameters:**
- `buf` (number) - Buffer handle
- `win` (number) - Window handle

**Returns:** `nil`

**Details:**
- Maps `q` and `Esc` to close window
- Maps `j/k` for scrolling
- Maps `gg` to go to start
- Maps `G` to go to end

---

### `M.show_popup_menu(items, callback)`

Display a popup menu for selection.

**Parameters:**
- `items` (table) - List of menu items (strings or tables with `text` and `value`)
- `callback` (function) - Called with selected item when user selects

**Returns:** `number` - Window handle

**Example:**
```lua
local ui = require('genero_tools.ui')

ui.show_popup_menu({
  { text = "Option 1", value = "opt1" },
  { text = "Option 2", value = "opt2" },
  { text = "Option 3", value = "opt3" },
}, function(selected)
  print("Selected: " .. selected.value)
end)
```

---

### `M.notify(message, level)`

Display a notification.

**Parameters:**
- `message` (string) - Notification message
- `level` (number or string) - Log level:
  - `vim.log.levels.DEBUG` or "debug"
  - `vim.log.levels.INFO` or "info"
  - `vim.log.levels.WARN` or "warn"
  - `vim.log.levels.ERROR` or "error"

**Returns:** `nil`

**Example:**
```lua
local ui = require('genero_tools.ui')

ui.notify("Operation completed successfully", vim.log.levels.INFO)
ui.notify("Warning: Large result set", vim.log.levels.WARN)
```

---

### `M.show_progress(message, percentage)`

Display a progress indicator.

**Parameters:**
- `message` (string) - Progress message
- `percentage` (number) - Progress percentage (0-100)

**Returns:** `number` - Progress window handle

**Example:**
```lua
local ui = require('genero_tools.ui')

ui.show_progress("Compiling...", 50)
```

---

### `M.show_split(content, options)`

Create a split window with content.

**Parameters:**
- `content` (string or table) - Content to display
- `options` (table, optional) - Split options:
  - `direction` (string) - 'horizontal' or 'vertical'
  - `size` (number) - Split size in lines/columns
  - `title` (string) - Buffer title

**Returns:** `table` - Split info with `buf` and `win` handles

---

### `M.highlight_pattern(buf, pattern, hl_group)`

Highlight text matching pattern in buffer.

**Parameters:**
- `buf` (number) - Buffer handle
- `pattern` (string) - Regex pattern to match
- `hl_group` (string) - Highlight group name

**Returns:** `nil`

**Example:**
```lua
local ui = require('genero_tools.ui')

ui.highlight_pattern(buf, "error", "ErrorMsg")
```

---

## Lualine Integration (`lua/genero_tools/lualine.lua`)

Integrates genero-tools diagnostics into lualine statusline.

### `M.diagnostics()`

Format diagnostic counts for lualine display.

**Returns:** `string` - Formatted diagnostic string with color codes

**Details:**
- Shows error count with dark red background
- Shows warning count with dark yellow background
- Returns empty string if no diagnostics

**Example:**
```lua
-- In lualine config
require('lualine').setup({
  sections = {
    lualine_c = { require('genero_tools.lualine').diagnostics },
  },
})
```

---

### `M.setup_highlights()`

Set up highlight groups for lualine display.

**Returns:** `nil`

**Details:**
- Creates `GeneroLualineError` highlight (dark red background)
- Creates `GeneroLualineWarning` highlight (dark yellow background)

---

### `M.setup()`

Initialize lualine integration.

**Returns:** `nil`

**Example:**
```lua
require('genero_tools.lualine').setup()
```

---

## Snippets Module (`lua/genero_tools/snippets/init.lua`)

Provides intelligent code snippet expansion for Genero patterns.

### `M.setup()`

Initialize snippet system (Neovim only).

**Returns:** `nil`

**Details:**
- Checks for LuaSnip availability
- Loads built-in snippets
- Loads custom snippets from user directory
- Registers with LuaSnip
- Sets up file watcher for hot-reload

**Example:**
```lua
require('genero_tools.snippets').setup()
```

---

### `M.merge_snippets(builtin, custom)`

Merge built-in and custom snippets.

**Parameters:**
- `builtin` (table) - Built-in snippets
- `custom` (table) - Custom snippets (takes precedence)

**Returns:** `table` - Merged snippets

---

### `M.get_snippet(trigger)`

Get snippet by trigger name.

**Parameters:**
- `trigger` (string) - Snippet trigger

**Returns:** `table or nil` - Snippet definition or nil if not found

---

### `M.list_snippets()`

List all available snippets.

**Returns:** `table` - Map of trigger -> snippet definition

---

### `M.expand_snippet(trigger)`

Expand snippet by trigger.

**Parameters:**
- `trigger` (string) - Snippet trigger

**Returns:** `boolean` - True if expanded, false if not found

---

### `M.populate_function_params(function_name, callback)`

Populate function parameters asynchronously.

**Parameters:**
- `function_name` (string) - Function name to look up
- `callback` (function) - Called with populated snippet

**Returns:** `nil`

**Example:**
```lua
local snippets = require('genero_tools.snippets')

snippets.populate_function_params('myFunction', function(snippet)
  print("Populated snippet: " .. vim.inspect(snippet))
end)
```

---

### `M.is_luasnip_available()`

Check if LuaSnip is available.

**Returns:** `boolean` - True if LuaSnip loaded

---

### `M.version()`

Get snippets module version.

**Returns:** `string` - Version number

---

### `M.health_check()`

Perform health check for snippets module.

**Returns:** `table` - Health status with keys:
- `version` (string) - Module version
- `luasnip_available` (boolean) - LuaSnip available
- `builtin_count` (number) - Built-in snippet count
- `custom_count` (number) - Custom snippet count

---

### `M.list_snippets_display()`

Get formatted snippet list for display.

**Returns:** `table` - List of formatted snippet strings

---

### `M.show_help(trigger)`

Display help for specific snippet.

**Parameters:**
- `trigger` (string) - Snippet trigger

**Returns:** `nil`

---

### `M.expand_by_name(trigger)`

Expand snippet by name/trigger.

**Parameters:**
- `trigger` (string) - Snippet trigger

**Returns:** `boolean` - True if expanded

---

## Snippet Manager (`lua/genero_tools/snippets/manager.lua`)

Manages snippet loading, registration, and caching.

### `M.load_builtin()`

Load built-in Genero snippets.

**Returns:** `table` - Map of trigger -> snippet definition

---

### `M.load_custom()`

Load custom snippets from user directory.

**Returns:** `table` - Map of trigger -> snippet definition

**Details:**
- Loads from `~/.config/nvim/genero-snippets/` by default
- Configurable via `snippet_custom_dir` option

---

### `M.load_snippets_from_directory(dir)`

Load snippets from specific directory.

**Parameters:**
- `dir` (string) - Directory path

**Returns:** `table` - Map of trigger -> snippet definition

---

### `M.register_with_luasnip(snippets)`

Register snippets with LuaSnip.

**Parameters:**
- `snippets` (table) - Snippets to register

**Returns:** `nil`

---

### `M.convert_to_luasnip_format(snippet)`

Convert snippet to LuaSnip format.

**Parameters:**
- `snippet` (table) - Snippet definition

**Returns:** `table` - LuaSnip-formatted snippet

---

### `M.watch_files()`

Watch snippet files for changes and hot-reload.

**Returns:** `nil`

---

### `M.get_snippet(trigger)`

Get snippet by trigger.

**Parameters:**
- `trigger` (string) - Snippet trigger

**Returns:** `table or nil` - Snippet definition

---

### `M.list_snippets()`

List all available snippets.

**Returns:** `table` - Map of trigger -> snippet definition

---

### `M.get_snippet_count()`

Get total snippet count.

**Returns:** `number` - Total snippets loaded

---

### `M.clear_caches()`

Clear all snippet caches.

**Returns:** `nil`

---

### `M.reload_all()`

Reload all snippets from disk.

**Returns:** `nil`

---

## Async Parameters (`lua/genero_tools/snippets/async_params.lua`)

Handles asynchronous function parameter population for snippets.

### `M.init()`

Initialize async parameters module.

**Returns:** `nil`

---

### `M.query_signature(function_name, callback)`

Query function signature asynchronously.

**Parameters:**
- `function_name` (string) - Function name to look up
- `callback` (function) - Called with signature data

**Returns:** `nil`

**Example:**
```lua
local async_params = require('genero_tools.snippets.async_params')

async_params.query_signature('myFunction', function(signature)
  if signature then
    print("Parameters: " .. vim.inspect(signature.parameters))
  end
end)
```

---

### `M.parse_signature_data(data)`

Parse signature data from API response.

**Parameters:**
- `data` (table) - Raw signature data

**Returns:** `table` - Parsed signature with keys:
- `name` (string) - Function name
- `parameters` (table) - Parameter list
- `return_type` (string) - Return type

---

### `M.populate_from_signature(snippet, signature)`

Populate snippet from function signature.

**Parameters:**
- `snippet` (table) - Snippet template
- `signature` (table) - Function signature

**Returns:** `table` - Populated snippet

---

### `M.fallback_parameters(snippet, num_params)`

Create fallback parameters when signature unavailable.

**Parameters:**
- `snippet` (table) - Snippet template
- `num_params` (number) - Number of parameters to create

**Returns:** `table` - Snippet with fallback parameters

---

### `M.format_parameters(parameters)`

Format parameter list as string.

**Parameters:**
- `parameters` (table) - Parameter list

**Returns:** `string` - Formatted parameter string

---

### `M.create_parameter_placeholders(parameters, start_index)`

Create LuaSnip placeholders for parameters.

**Parameters:**
- `parameters` (table) - Parameter list
- `start_index` (number) - Starting placeholder index

**Returns:** `table` - List of placeholder strings

---

### `M.create_return_placeholder(return_type, placeholder_index)`

Create placeholder for return value.

**Parameters:**
- `return_type` (string) - Return type
- `placeholder_index` (number) - Placeholder index

**Returns:** `string` - Return placeholder

---

### `M.is_optional(param_name, optional_params)`

Check if parameter is optional.

**Parameters:**
- `param_name` (string) - Parameter name
- `optional_params` (table) - List of optional parameter names

**Returns:** `boolean` - True if optional

---

### `M.build_function_call_snippet(function_name, signature)`

Build complete function call snippet.

**Parameters:**
- `function_name` (string) - Function name
- `signature` (table) - Function signature

**Returns:** `string` - Complete snippet body

---

### `M.merge_into_snippet(snippet, param_context)`

Merge parameters into snippet template.

**Parameters:**
- `snippet` (table) - Snippet template
- `param_context` (table) - Parameter context

**Returns:** `table` - Merged snippet

---

## Snippet Integration (`lua/genero_tools/snippets/integration.lua`)

Integrates snippets with other genero-tools features.

### `M.offer_snippet_after_lookup(function_name)`

Offer snippet after function lookup.

**Parameters:**
- `function_name` (string) - Function name

**Returns:** `nil`

**Details:**
- Called after `:GeneroLookup` command
- Offers to expand function call snippet
- Uses async parameter population

---

### `M.expand_function_call_snippet(function_name)`

Expand function call snippet.

**Parameters:**
- `function_name` (string) - Function name

**Returns:** `boolean` - True if expanded

---

### `M.build_generic_function_call_snippet(function_name)`

Build generic function call snippet (fallback).

**Parameters:**
- `function_name` (string) - Function name

**Returns:** `string` - Generic snippet body

---

### `M.insert_snippet_at_cursor(snippet_body)`

Insert snippet at cursor position.

**Parameters:**
- `snippet_body` (string) - Snippet body to insert

**Returns:** `nil`

---

### `M.offer_snippet_in_autocomplete(function_name)`

Offer snippet in autocomplete menu.

**Parameters:**
- `function_name` (string) - Function name

**Returns:** `nil`

**Details:**
- Adds snippet option to autocomplete menu
- Allows user to select snippet expansion

---

### `M.get_snippet_config()`

Get snippet configuration.

**Returns:** `table` - Configuration with keys:
- `enabled` (boolean) - Snippets enabled
- `engine` (string) - Snippet engine
- `smart_expansion` (boolean) - Smart expansion enabled
- `custom_dir` (string) - Custom snippet directory

---

### `M.snippets_available()`

Check if snippets are available.

**Returns:** `boolean` - True if snippets available

---

## Configuration Integration

All Lua modules can access configuration via:

```lua
-- Get configuration value
local value = vim.fn['genero_tools#config#get']('config_key')

-- Or access directly
local config = vim.g.genero_tools_config
local value = config.config_key
```

### Lua Layer Configuration

The `lua_enabled` configuration option controls whether Lua features are available:

```lua
-- Check if Lua layer is enabled
if vim.g.genero_tools_config.lua_enabled then
  require('genero_tools').setup()
end
```

**Default Behavior:**
- Automatically set to `true` on Neovim
- Automatically set to `false` on Vim
- Can be manually overridden in configuration

**Example:**
```lua
-- Force disable Lua layer (not recommended)
vim.g.genero_tools_config.lua_enabled = false

-- Or in init.lua before plugin loads
vim.g.genero_tools_config = {
  lua_enabled = false,  -- Disable Lua features
  -- ... other config
}
```

---

## Error Handling

All Lua functions use pcall for safe error handling:

```lua
local ok, result = pcall(function()
  return require('genero_tools').setup()
end)

if not ok then
  vim.notify("Error: " .. result, vim.log.levels.ERROR)
end
```

---

## Performance Considerations

1. **Async Operations:** Use `M.execute_async()` for long-running commands
2. **Debouncing:** Use `M.debounce()` for high-frequency events (e.g., text changes)
3. **Caching:** Snippets are cached automatically; use `M.clear_caches()` to refresh
4. **Parallel Execution:** Use `M.execute_parallel()` for multiple independent operations

---

## Examples

### Complete Setup Example

```lua
-- init.lua
require('genero_tools').setup({
  async_enabled = true,
  ui_mode = 'floating',
})

-- Initialize snippets
require('genero_tools.snippets').setup()

-- Set up lualine integration
require('genero_tools.lualine').setup()
```

### Custom Async Command

```lua
local async = require('genero_tools.async')

async.execute_async('find-function', {'myFunc'}, function(result)
  if result.success then
    local ui = require('genero_tools.ui')
    ui.show_floating_window(
      vim.inspect(result.data),
      { title = "Function Details" }
    )
  end
end)
```

### Debounced Search

```lua
local async = require('genero_tools.async')

local search = async.debounce(function(query)
  vim.fn['genero_tools#lookup_function'](query)
end, 500)

-- Use in autocmd
vim.api.nvim_create_autocmd('TextChangedI', {
  callback = function()
    search(vim.fn.expand('<cword>'))
  end,
})
```

---

## Troubleshooting

**Lua layer not available:**
```lua
if not require('genero_tools').is_available() then
  print("Neovim required for Lua features")
end
```

**LuaSnip not found:**
```lua
if not require('genero_tools.snippets').is_luasnip_available() then
  vim.notify("Install LuaSnip for snippet features")
end
```

**Async operations not working:**
```lua
if not vim.fn['genero_tools#config#get']('async_enabled') then
  print("Async operations disabled in config")
end
```

---

## See Also

- [README.md](../README.md) - Main plugin documentation
- [NEOVIM_SETUP.md](NEOVIM_SETUP.md) - Neovim setup guide
- [SNIPPETS.md](SNIPPETS.md) - Snippet system documentation
- [ERROR_HANDLING.md](ERROR_HANDLING.md) - Error handling guide
