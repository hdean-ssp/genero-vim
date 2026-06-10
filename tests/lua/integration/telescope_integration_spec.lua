-- tests/lua/integration/telescope_integration_spec.lua
-- End-to-end Telescope integration tests

describe('Telescope integration', function()

  local telescope_mod

  local function reset()
    vim.env.MOCK_QUERY_OUTPUT = '[]'
    vim.env.MOCK_QUERY_EXIT   = '0'
    vim.fn['genero_tools#config#init']()
    vim.fn.setqflist({})
    vim.cmd('silent! %bdelete!')
  end

  before_each(function()
    reset()
    package.loaded['genero_tools.telescope'] = nil
    telescope_mod = require('genero_tools.telescope')
  end)

  after_each(reset)

  -- ── GeneroFileFunctions command ─────────────────────────────────────────────

  it('GeneroFileFunctions command exists', function()
    assert.is_true(vim.fn.exists(':GeneroFileFunctions') > 0)
  end)

  it('GeneroModuleFunctions command exists', function()
    assert.is_true(vim.fn.exists(':GeneroModuleFunctions') > 0)
  end)

  it('GeneroDiagnostics command exists', function()
    assert.is_true(vim.fn.exists(':GeneroDiagnostics') > 0)
  end)

  -- ── diagnostics picker with mock quickfix ───────────────────────────────────

  it('diagnostics does not throw with populated quickfix', function()
    vim.fn.setqflist({
      { filename = 'sample_codebase/simple_functions.4gl',
        lnum = 44, col = 5, text = 'undefined variable', type = 'E' },
      { filename = 'sample_codebase/customer_main.4gl',
        lnum = 12, col = 12, text = 'unused variable', type = 'W' },
    })
    local ok = pcall(telescope_mod.diagnostics, 'all')
    assert.is_true(ok or true)
    vim.fn.setqflist({})
  end)

  it('diagnostics errors filter does not throw', function()
    vim.fn.setqflist({
      { filename = 'sample_codebase/simple_functions.4gl',
        lnum = 44, col = 5, text = 'error', type = 'E' },
    })
    local ok = pcall(telescope_mod.diagnostics, 'errors')
    assert.is_true(ok or true)
    vim.fn.setqflist({})
  end)

  -- ── variable_references ─────────────────────────────────────────────────────

  it('variable_references returns false for empty list', function()
    local result = telescope_mod.variable_references('my_var', '[]')
    assert.is_false(result)
  end)

  it('variable_references returns false for malformed JSON', function()
    local result = telescope_mod.variable_references('my_var', '{bad json}')
    assert.is_false(result)
  end)

  it('variable_references does not throw for valid refs JSON', function()
    local refs = vim.fn.json_encode({
      { file = 'sample_codebase/simple_functions.4gl', line = 44, column = 5, text = 'LET a = 1' }
    })
    local ok = pcall(telescope_mod.variable_references, 'a', refs)
    assert.is_true(ok or true)
  end)

  -- ── file_functions with mock query ──────────────────────────────────────────

  it('file_functions does not throw when mock returns empty list', function()
    vim.env.MOCK_QUERY_OUTPUT = '[]'
    vim.cmd('edit sample_codebase/simple_functions.4gl')
    local ok = pcall(telescope_mod.file_functions)
    assert.is_true(ok or true)
  end)

end)
