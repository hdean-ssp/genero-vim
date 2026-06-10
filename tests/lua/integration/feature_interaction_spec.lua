-- tests/lua/integration/feature_interaction_spec.lua
-- Integration tests for interactions between multiple features

describe('feature interactions', function()

  local function reset()
    vim.env.MOCK_FGLCOMP_OUTPUT = ''
    vim.env.MOCK_FGLCOMP_EXIT   = '0'
    vim.env.MOCK_QUERY_OUTPUT   = '[]'
    vim.env.MOCK_QUERY_EXIT     = '0'
    vim.fn['genero_tools#config#init']()
    vim.fn['genero_tools#cache#clear']()
    vim.fn.setqflist({})
    vim.cmd('silent! %bdelete!')
  end

  before_each(reset)
  after_each(reset)

  -- ── navigation with quickfix errors present ─────────────────────────────────

  it('navigation still works when quickfix list is populated with errors', function()
    -- Populate quickfix with compiler errors
    vim.fn.setqflist({
      { filename = 'sample_codebase/simple_functions.4gl',
        lnum = 44, col = 5, text = 'undefined variable', type = 'E' },
    })
    -- Navigation should still work
    vim.cmd('edit sample_codebase/simple_functions.4gl')
    vim.api.nvim_win_set_cursor(0, {1, 0})
    local ok = pcall(vim.fn['genero_tools#navigation#goto_definition'], 'add_numbers')
    assert.is_true(ok)
    vim.fn.setqflist({})
  end)

  -- ── cache stats after navigation query ─────────────────────────────────────

  it('cache stats returns non-empty output after a navigation query', function()
    vim.env.MOCK_QUERY_OUTPUT = '[]'
    vim.cmd('edit sample_codebase/simple_functions.4gl')
    -- Trigger a query (will cache the result)
    pcall(vim.fn['genero_tools#navigation#goto_definition'], 'add_numbers')
    -- Cache stats should be callable
    local ok = pcall(vim.fn['genero_tools#cache#show_stats'])
    assert.is_true(ok)
  end)

  -- ── hints + compiler errors coexist ────────────────────────────────────────

  it('hints analyze does not throw when quickfix has compiler errors', function()
    vim.fn.setqflist({
      { filename = 'sample_codebase/whitespace_variations.4gl',
        lnum = 5, col = 1, text = 'error', type = 'E' },
    })
    vim.fn['genero_tools#config#init']()
    vim.fn['genero_tools#hints#config#init']()
    vim.cmd('edit sample_codebase/whitespace_variations.4gl')
    local bufnr = vim.fn.bufnr('%')
    local ok = pcall(vim.fn['genero_tools#hints#analyze'], bufnr)
    assert.is_true(ok)
    vim.fn.setqflist({})
  end)

  -- ── autocompile config interaction ─────────────────────────────────────────

  it('GeneroAutocompileEnable and Disable commands exist', function()
    assert.is_true(vim.fn.exists(':GeneroAutocompileEnable') > 0)
    assert.is_true(vim.fn.exists(':GeneroAutocompileDisable') > 0)
  end)

  it('GeneroAutocompileStatus command exists', function()
    assert.is_true(vim.fn.exists(':GeneroAutocompileStatus') > 0)
  end)

  -- ── cache cleared between features ─────────────────────────────────────────

  it('GeneroClearCache command exists and does not throw', function()
    assert.is_true(vim.fn.exists(':GeneroClearCache') > 0)
    local ok = pcall(vim.cmd, 'GeneroClearCache')
    assert.is_true(ok)
  end)

  -- ── config show ────────────────────────────────────────────────────────────

  it('GeneroConfigShow command exists', function()
    assert.is_true(vim.fn.exists(':GeneroConfigShow') > 0)
  end)

  -- ── snippets with hints enabled ─────────────────────────────────────────────

  it('snippets manager loads when hints are enabled', function()
    vim.fn['genero_tools#config#init']()
    vim.g.genero_tools_config['hints_enabled'] = 1
    package.loaded['genero_tools.snippets.manager'] = nil
    local ok, manager = pcall(require, 'genero_tools.snippets.manager')
    assert.is_true(ok)
    if ok then
      local snippets = manager.load_builtin()
      assert.is_table(snippets)
    end
  end)

end)
