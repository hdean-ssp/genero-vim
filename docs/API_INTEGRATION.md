# Genero-Tools API Integration

The plugin uses `query.sh` shell command interface to query genero-tools database. All commands return JSON output.

## Supported Commands

### Function Queries

#### find-function
Find function by exact name: `query.sh find-function <name>`

```vim
:GeneroLookup myFunction
```

#### list-file-functions
List all functions in a file: `query.sh list-file-functions <path>`

```vim
:GeneroListFunctions ./src/utils.4gl
```

#### search-functions
Search functions by pattern: `query.sh search-functions <pattern>`

```vim
:GeneroLookup get_*
```

### Module Queries

#### find-functions-in-module
Find all functions in a module: `query.sh find-functions-in-module <name>`

```vim
:GeneroListModuleFiles core
```

### File Metadata Queries

#### file-references
Get all code references for a file: `query.sh file-references <path>`

```vim
:GeneroFileMetadata ./src/utils.4gl
```

#### file-authors
Get all authors who modified a file: `query.sh file-authors <path>`

## Configuration

```vim
let g:genero_tools_config = {
  \ 'genero_tools_path': 'query.sh',
  \ 'cache_enabled': v:true,
  \ 'cache_ttl': 3600,
  \ 'cache_max_size': 100,
  \ 'display_mode': 'quickfix',
  \ 'keybindings_enabled': v:true,
  \ 'timeout': 10000,
  \ 'async_enabled': v:true,
  \ 'result_limit': 1000,
  \ 'pagination_size': 50
  \ }
```

## Command Mapping

| Vim Command | Query.sh Command | Purpose |
|-------------|------------------|---------|
| `:GeneroLookup func` | `find-function func` | Find function definition |
| `:GeneroListFunctions file` | `list-file-functions file` | List functions in file |
| `:GeneroListModuleFiles mod` | `find-functions-in-module mod` | List functions in module |
| `:GeneroFunctionSignature func` | `find-function func` | Get function signature |
| `:GeneroFileMetadata file` | `file-references file` | Get file metadata |

## Setup

### Prerequisites

1. genero-tools installed and query.sh in PATH
2. Workspace metadata generated:
   ```bash
   bash generate_signatures.sh /path/to/codebase
   bash generate_modules.sh /path/to/codebase
   ```
3. Databases created:
   ```bash
   query.sh create-dbs
   ```

## Performance

- Function lookup: <1ms
- Pattern search: <10ms
- Module queries: <1ms
- Caching: Reduces redundant queries significantly

## Troubleshooting

**query.sh not found:**
```vim
let g:genero_tools_config.genero_tools_path = '/path/to/query.sh'
```

**Database not found:**
```bash
query.sh create-dbs
```

**Slow queries:**
```vim
let g:genero_tools_config.cache_enabled = v:true
let g:genero_tools_config.timeout = 15000
```

**Results not updating:**
```vim
:GeneroClearCache
query.sh create-dbs
```

## References

- genero-tools API: `/genero-tools-api/api/`
- Shell commands: `shell-commands.json`
- Database schema: `database-schema.json`
