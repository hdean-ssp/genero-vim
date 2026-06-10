# Test Suite — genero-tools Vim Plugin

## Prerequisites

- **Neovim 0.9+** (required for all tests)
- **plenary.nvim** — Lua test framework
- **vader.vim** — VimScript test framework

### Installing test dependencies

```bash
# plenary.nvim
git clone --depth=1 https://github.com/nvim-lua/plenary.nvim \
  ~/.local/share/nvim/site/pack/test/start/plenary.nvim

# vader.vim
git clone --depth=1 https://github.com/junegunn/vader.vim \
  ~/.local/share/nvim/site/pack/test/start/vader.vim
```

Override the install path at runtime with environment variables:

```bash
PLENARY_PATH=/path/to/plenary.nvim ./tests/run_tests.sh
VADER_PATH=/path/to/vader.vim      ./tests/run_vim_tests.sh
```

---

## Running the tests

### Full suite (Lua + VimScript)

```bash
./tests/run_tests.sh
```

### Lua / plenary tests only

```bash
./tests/run_lua_tests.sh
```

### VimScript / vader tests only

```bash
./tests/run_vim_tests.sh
```

### Single file

```bash
./tests/run_tests.sh --file tests/vader/unit/compiler_parser.vader
./tests/run_tests.sh --file tests/lua/unit/async_spec.lua
```

---

## Mock environment variables

All external processes are replaced by shell scripts in `tests/mocks/`. Set
these variables before running tests (or inside `Before:` / `before_each`
blocks) to control mock behaviour:

| Variable | Default | Controls |
|---|---|---|
| `MOCK_FGLCOMP_OUTPUT` | `""` | stdout of `fglcomp` |
| `MOCK_FGLCOMP_EXIT` | `0` | exit code of `fglcomp` |
| `MOCK_FGLFORM_OUTPUT` | `""` | stdout of `fglform` |
| `MOCK_FGLFORM_EXIT` | `0` | exit code of `fglform` |
| `MOCK_SVN_OUTPUT` | `""` | stdout of `svn` |
| `MOCK_SVN_EXIT` | `0` | exit code of `svn` |
| `MOCK_QUERY_OUTPUT` | `[]` | stdout of `query.sh` |
| `MOCK_QUERY_EXIT` | `0` | exit code of `query.sh` |

**Always reset mock variables in teardown** — use `TestTeardown()` (VimScript)
or reset in `after_each` (Lua).

---

## `sample_codebase/` fixture mapping

Tests open source files directly from `sample_codebase/` rather than creating
copies. See [`tests/fixtures/README.md`](fixtures/README.md) for the full
mapping. Key files:

| File | Primary use |
|---|---|
| `simple_functions.4gl` | Navigation, autocomplete, compiler error fixtures |
| `customer_main.4gl` | Module-scoped navigation, hints, lualine breadcrumb |
| `edge_cases.4gl` | Parser edge cases |
| `whitespace_variations.4gl` | Hints — mixed indentation |
| `multiline_params.4gl` | Autocomplete signatures, snippet smart expansion |
| `customer.m3` / `reporting.m3` | Module file tests |

Synthetic fixtures (compiler output, SVN diffs) live under
`tests/fixtures/compiler_output/` and `tests/fixtures/svn_diff/`.

---

## Six correctness properties

The test suite validates six universal invariants using property-based tests
(100 iterations each):

| # | Property | Test file |
|---|---|---|
| 1 | Compiler parser round-trip | `vader/property/compiler_parser_props.vader`, `lua/property/parser_props_spec.lua` |
| 2 | SVN diff parser correctness | `vader/property/svn_parser_props.vader`, `lua/property/parser_props_spec.lua` |
| 3 | Cache set-get round-trip | `vader/property/cache_props.vader` |
| 4 | Cache size invariant | `vader/property/cache_props.vader` |
| 5 | Config validation always produces valid state | `vader/property/config_validation_props.vader` |
| 6 | Compiler file-type routing | `vader/property/compiler_parser_props.vader` |

---

## Directory structure

```
tests/
├── run_tests.sh          # Full suite runner
├── run_lua_tests.sh      # Lua/plenary runner
├── run_vim_tests.sh      # VimScript/vader runner
├── vimrc                 # Minimal Neovim config for vader
├── init.lua              # Minimal Neovim config for plenary
│
├── mocks/                # Mock executables (fglcomp, fglform, svn, query.sh)
├── fixtures/
│   ├── README.md         # sample_codebase/ fixture mapping
│   ├── compiler_output/  # Synthetic fglcomp output files
│   └── svn_diff/         # Synthetic SVN unified diff files
│
├── helpers/              # Shared VimScript helpers
│   ├── setup.vim         # TestSetup() / TestTeardown()
│   ├── assertions.vim    # AssertEqual, AssertContains, etc.
│   ├── mock_config.vim   # MockConfigSet / MockConfigReset
│   └── generators.vim    # TestGenCompilerError, TestGenSvnDiff
│
├── vader/
│   ├── unit/             # VimScript unit tests
│   └── property/         # VimScript property tests
│
├── lua/
│   ├── unit/             # Lua unit tests
│   ├── integration/      # Lua integration tests
│   └── property/         # Lua property tests
│
└── compat/               # Version compatibility tests
    └── neovim_compat.vader
```

---

## Writing new tests

### VimScript (vader)

```vim
Before:
  source tests/helpers/setup.vim
  source tests/helpers/assertions.vim
  call TestSetup()

After:
  call TestTeardown()

Execute (my test description):
  let $MOCK_QUERY_OUTPUT = '[{"name":"foo"}]'
  " ... test body ...
  call AssertEqual('expected', actual, 'description')
```

### Lua (plenary)

```lua
describe('my feature', function()
  before_each(function()
    vim.env.MOCK_QUERY_OUTPUT = '[]'
    vim.fn['genero_tools#config#init']()
  end)

  after_each(function()
    vim.cmd('silent! %bdelete!')
  end)

  it('does something', function()
    local result = require('genero_tools.async').parse_output({}, {}, 0)
    assert.is_true(result.success)
  end)
end)
```

### Test isolation rules

- Always call `TestSetup()` / `TestTeardown()` in vader `Before:`/`After:` blocks.
- Always reset mock env vars in `after_each` Lua blocks.
- Never depend on test execution order — each test must be self-contained.
- Use `sample_codebase/` files by path; do not create new `.4gl` source files.
