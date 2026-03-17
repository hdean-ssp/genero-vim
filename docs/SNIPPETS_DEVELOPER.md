# Genero Code Snippets - Developer Documentation

## Architecture

The snippet system is organized into several Lua modules:

### Core Modules

**`lua/genero_tools/snippets/init.lua`** - Main module
- `setup()` - Initialize snippet system
- `list_snippets()` - Get all snippets
- `get_snippet(trigger)` - Get snippet by trigger
- `expand_by_name(trigger)` - Expand snippet by trigger
- `health_check()` - Check module health

**`lua/genero_tools/snippets/manager.lua`** - Snippet management
- `load_builtin()` - Load built-in snippets
- `load_custom()` - Load custom snippets
- `register_with_luasnip(snippets)` - Register with LuaSnip
- `get_snippet(trigger)` - Get snippet by trigger
- `list_snippets()` - List all snippets

**`lua/genero_tools/snippets/async_params.lua`** - Parameter population
- `query_signature(function_name, callback)` - Query function signature
- `populate_from_signature(snippet, signature)` - Populate parameters
- `fallback_parameters(snippet, num_params)` - Generic parameters
- `create_return_placeholder(return_type, index)` - Return type placeholder

**`lua/genero_tools/snippets/integration.lua`** - Integration layer
- `offer_snippet_after_lookup(function_name)` - GeneroLookup integration
- `expand_function_call_snippet(function_name)` - Expand function call
- `offer_snippet_in_autocomplete(function_name)` - Autocomplete integration
- `get_snippet_config()` - Get configuration

## Snippet Format

Snippets are Lua tables with the following structure:

```lua
{
  trigger = "fn",
  name = "Function Definition",
  description = "Define a function with parameters",
  body = [[
FUNCTION ${1:function_name}(${2:parameters})
  ${3:-- function body}
END FUNCTION
  ]],
}
```

### Placeholder Syntax

Snippets use LuaSnip placeholder syntax:
- `${1:default_text}` - Placeholder 1 with default text
- `${2:param_name -- TYPE}` - Placeholder 2 with type info
- `${3:return_value}` - Placeholder 3

Placeholders are numbered sequentially for Tab navigation.

## Built-in Snippets

Built-in snippets are stored in `lua/genero_tools/snippets/templates/builtin/`:

- `function.lua` - Function definition snippets
- `if_else.lua` - Conditional snippets
- `for_loop.lua` - For loop snippets
- `while_loop.lua` - While loop snippets
- `case_statement.lua` - Case/when snippets
- `try_catch.lua` - Error handling snippets
- `record.lua` - Record definition snippets
- `array.lua` - Array declaration snippets

Each file returns an array of snippet tables.

## Integration Points

### With GeneroLookup

When a function is looked up, the integration module offers to expand a function call snippet:

```lua
require('genero_tools.snippets.integration').offer_snippet_after_lookup('function_name')
```

### With Autocomplete

Autocomplete can offer snippet expansion:

```lua
require('genero_tools.snippets.integration').offer_snippet_in_autocomplete('function_name')
```

### With Configuration

Snippet settings are stored in `g:genero_tools_config`:
- `snippets_enabled` - Enable/disable snippets
- `snippet_engine` - Engine to use (default: 'luasnip')
- `snippet_smart_expansion` - Enable async parameter population
- `snippet_custom_dir` - Custom snippet directory

## Testing

### Unit Tests

Test files are in `test/`:
- `test_async_params.lua` - Parameter population tests
- `test_snippet_manager.lua` - Manager tests
- `test_task_6_snippet_commands.lua` - Command tests
- `test_task_8_integration.lua` - Integration tests
- `test_task_10_checkpoint.lua` - Checkpoint tests

### Running Tests

```bash
# Run Lua tests
nvim -u NONE -c "lua require('test.test_async_params').run_all()"

# Run VimScript tests
nvim -u NONE -c "source test/test_snippet_commands.vim"
```

## Adding New Snippets

1. Create a new file in `lua/genero_tools/snippets/templates/builtin/`
2. Return an array of snippet tables
3. Each snippet must have: `trigger`, `name`, `description`, `body`
4. Use LuaSnip placeholder syntax in body
5. Snippets are automatically loaded on startup

Example:

```lua
-- lua/genero_tools/snippets/templates/builtin/my_pattern.lua
return {
  {
    trigger = "mysnip",
    name = "My Snippet",
    description = "My code pattern",
    body = [[
PATTERN ${1:placeholder1}
  ${2:placeholder2}
END PATTERN
    ]],
  },
}
```

## Configuration

Snippet configuration is in `autoload/genero_tools/config.vim`:

```vim
let defaults = {
  \ 'snippets_enabled': v:true,
  \ 'snippet_engine': 'luasnip',
  \ 'snippet_smart_expansion': v:true,
  \ 'snippet_custom_dir': expand('~/.config/nvim/genero-snippets'),
  \ }
```

## VimScript Bridge

The VimScript bridge in `autoload/genero_tools/snippets.vim` provides:

- `genero_tools#snippets#list()` - List snippets
- `genero_tools#snippets#help(trigger)` - Show help
- `genero_tools#snippets#expand(trigger)` - Expand snippet
- `genero_tools#snippets#available()` - Check availability

Commands are registered in `plugin/genero_tools.vim`:

```vim
command! GeneroSnippetList call genero_tools#snippets#list()
command! -nargs=? GeneroSnippetHelp call genero_tools#snippets#help(<q-args>)
command! -nargs=? GeneroSnippet call genero_tools#snippets#expand(<q-args>)
```

## Vim Compatibility

Snippets are Neovim-only. Vim compatibility is handled by:

1. Conditional command registration in `plugin/genero_tools.vim`
2. Vim detection in VimScript bridge functions
3. Graceful error messages for Vim users

## Performance Considerations

- Built-in snippets are loaded once at startup
- Snippets are cached in memory
- Function signatures are queried asynchronously
- No blocking operations in the editor

## Future Enhancements

- Custom snippet hot-reload (Task 5)
- Property-based testing (optional tasks)
- Additional snippet patterns
- Snippet customization UI
