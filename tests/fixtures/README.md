# Test Fixtures

This directory contains fixture data used by the test suite. Fixture files are
divided into two categories:

- **`sample_codebase/` references** — existing `.4gl` and `.m3` source files in
  the repo root that tests open directly. No copies are made; tests reference
  them by path relative to the repo root.
- **Synthetic fixtures** — compiler output and SVN diff files written fresh
  under `tests/fixtures/` because they are mock data, not real source code.

---

## `sample_codebase/` fixture mapping

Each file below is mapped to its primary test purpose. A file may be used by
more than one test area.

### `sample_codebase/simple_functions.4gl`

**Primary use:** Navigation and autocomplete unit tests.

Contains four straightforward functions with basic parameter and return types:

| Function | Signature |
|---|---|
| `add_numbers` | `(a INTEGER, b INTEGER) → INTEGER` |
| `get_user_name` | `(user_id INTEGER) → STRING` |
| `no_params_no_return` | `()` |
| `display_message` | `(msg STRING)` |

Used by:
- `tests/vader/unit/navigation.vader` — goto-definition and cursor-movement assertions
- `tests/lua/unit/telescope_spec.lua` — picker entry list (`add_numbers`, `get_user_name`, `no_params_no_return`, `display_message`)
- `tests/lua/unit/cmp_source_spec.lua` — partial-match completion filtering
- `tests/lua/integration/compiler_integration_spec.lua` — quickfix and sign column assertions (errors reference line numbers in this file)
- `tests/lua/integration/nvim_cmp_integration_spec.lua` — end-to-end completion
- `tests/lua/integration/telescope_integration_spec.lua` — item selection navigates to correct line
- `tests/fixtures/compiler_output/errors_v310.txt` — error lines reference line numbers in this file

---

### `sample_codebase/customer_main.4gl`

**Primary use:** Module-scoped navigation tests, multiple functions, record types.

Contains a rich set of functions covering:
- Module entry point (`customer_main`)
- Search with dynamic array of record (`customer_search_by_name`)
- CRUD operations (`customer_add_new`, `customer_delete`, `customer_edit`)
- Extensive record-type variations: `RECORD LIKE table.*`, inline records,
  dynamic arrays of records, nested field types, mixed `DEFINE` blocks

Also contains `#TMPHD` debug markers and lowercase constructs used by hints tests.

Used by:
- `tests/vader/unit/navigation.vader` — module-scoped lookup for `customer_search_by_name`
- `tests/vader/unit/hints.vader` — `#TMPHD` markers and lowercase keyword detection
- `tests/lua/unit/telescope_spec.lua` — `module_functions` picker
- `tests/lua/unit/lualine_spec.lua` — breadcrumb component (cursor inside `customer_search_by_name`)
- `tests/lua/integration/feature_interaction_spec.lua` — autocompile + hints interaction
- `tests/lua/integration/telescope_integration_spec.lua` — mock query returns functions from this file
- `tests/fixtures/compiler_output/warnings_v310.txt` — warning lines reference line numbers in this file

---

### `sample_codebase/edge_cases.4gl`

**Primary use:** Parser edge-case tests — long parameter lists, nested calls, control flow.

Contains functions that stress the parser:

| Function | Edge case |
|---|---|
| `function_with_long_params` | Five parameters with complex types (`VARCHAR`, `DECIMAL`, `DATETIME`, `MONEY`, `BYTE`) |
| `inline_return` | Minimal body, immediate return |
| `function_with_comments` | Inline comments after statements and after `RETURN` |
| `mixed_case_FUNCTION` | Mixed-case keyword and identifier names |
| `complex_call_patterns` | Multiple return values, chained assignments |
| `control_flow_calls` | `CALL` inside `IF`, `CASE`, and `WHILE` blocks |
| `nested_function_calls` | Nested call expressions, calls in conditional expressions |

Used by:
- `tests/vader/unit/compiler_parser.vader` — malformed and edge-case input parsing
- `tests/vader/property/compiler_parser_props.vader` — property tests that exercise unusual but valid syntax

---

### `sample_codebase/whitespace_variations.4gl`

**Primary use:** Hints tests — mixed whitespace and tab indentation.

Contains four functions with deliberately varied whitespace:

| Function | Whitespace pattern |
|---|---|
| `spaced_function` | Space-indented, blank lines between sections |
| `compact_function` | No blank lines, compact style |
| `tabbed_function` | Tab-indented, tab before `RETURN` value |
| `mixed_whitespace` | Mix of spaces and tabs within the same function |

Used by:
- `tests/vader/unit/hints.vader` — mixed-indentation hint detection
- `tests/lua/unit/ui_spec.lua` — virtual text hints on correct lines

---

### `sample_codebase/customer_db.4gl` and `sample_codebase/customer_validate.4gl`

**Primary use:** Integration tests — cross-file references between the DB layer and validation layer.

`customer_db.4gl` provides database operations (`customer_insert`, `customer_update`,
`customer_remove`, `customer_exists`, `customer_load`, `customer_load_by_name`,
`customer_count_by_name`) that are called from `customer_main.4gl`.

`customer_validate.4gl` provides validation functions (`validate_customer`,
`validate_name`, `validate_email`, `validate_phone`) also called from
`customer_main.4gl`. Contains a `#TMPHD` marker in `validate_phone`.

Together with `customer_main.4gl` these three files form a realistic multi-file
module that exercises cross-file function lookup and reference resolution.

Used by:
- `tests/vader/unit/navigation.vader` — cross-file goto-definition
- `tests/lua/integration/feature_interaction_spec.lua` — navigation with quickfix errors present

---

### `sample_codebase/multiline_params.4gl`

**Primary use:** Autocomplete signature tests — multi-line function parameter declarations.

Contains functions covering every multi-line parameter layout the parser must handle:

| Function | Layout |
|---|---|
| `single_line_params` | All params on one line (baseline) |
| `multiline_two_lines` | Params split across two lines |
| `multiline_each_line` | One param per line, closing `)` on its own line |
| `multiline_paren_on_same_line` | Opening `(` on same line as `FUNCTION`, params on next line |
| `no_params_multiline` | No params, multi-line body |
| `lib4_win_display_list` | Eleven params across three continuation lines (real-world style) |

Used by:
- `tests/lua/unit/cmp_source_spec.lua` — signature display for multi-line declarations
- `tests/lua/unit/snippets_spec.lua` — smart expansion populates parameters from these signatures
- `tests/vader/property/compiler_parser_props.vader` — parser round-trip over multi-line signatures

---

### `sample_codebase/customer.m3` and `sample_codebase/reporting.m3`

**Primary use:** Module file (`.m3` makefile) tests.

`customer.m3` defines the `customer` module, listing `customer_main.4gl`,
`customer_db.4gl`, `customer_validate.4gl`, and `customer_display.4gl` as its
`4GLS` sources. Used to test module-scoped navigation and the module picker.

`reporting.m3` defines a simpler single-program module (`report_main.4gl`).
Used to test module file parsing with a minimal makefile structure.

Used by:
- `tests/vader/unit/navigation.vader` — module-scoped lookup using `customer.m3`
- `tests/lua/unit/telescope_spec.lua` — `module_functions` picker with `customer.m3`

---

### `sample_codebase/modules/test.m3` and `sample_codebase/modules/multiline.m3`

**Primary use:** Module picker tests — `.m3` files in a subdirectory.

`modules/test.m3` is a large, realistic makefile with many library dependencies
spread across continuation lines. Tests that the module picker can parse and
display complex makefiles.

`modules/multiline.m3` is a compact makefile where every variable assignment
uses line continuations (`\`). Tests that the parser handles continuation lines
in all variable positions (`L4GLS`, `U4GLS`, `4GLS`).

Used by:
- `tests/lua/unit/telescope_spec.lua` — `module_files` picker lists sibling files
- `tests/vader/unit/navigation.vader` — module picker with subdirectory `.m3` files

---

## Synthetic fixture directories

### `tests/fixtures/compiler_output/`

Synthetic fglcomp output files used to drive compiler integration tests via
`MOCK_FGLCOMP_OUTPUT`. See task 3.2–3.5 for file contents.

| File | Contents |
|---|---|
| `errors_v310.txt` | Three fglcomp 3.10 full-format error lines referencing `simple_functions.4gl` |
| `warnings_v310.txt` | Two fglcomp 3.10 warning lines referencing `customer_main.4gl` |
| `errors_v320.txt` | Three fglcomp 3.20 format error lines |
| `mixed.txt` | Errors and warnings across multiple sample files |

### `tests/fixtures/svn_diff/`

Synthetic unified diff files used to drive SVN integration tests via
`MOCK_SVN_OUTPUT`. See task 3.6–3.9 for file contents.

| File | Contents |
|---|---|
| `added_lines.diff` | Three added lines at known line numbers in `simple_functions.4gl` |
| `deleted_lines.diff` | Two deleted lines at known line numbers |
| `modified_lines.diff` | One deleted + one added line (modification) |
| `mixed_changes.diff` | Combined adds, deletes, and modifications |
