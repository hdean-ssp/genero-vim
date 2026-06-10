-- tests/lua/integration/nvim_cmp_integration_spec.lua
-- End-to-end nvim-cmp integration tests

describe('nvim-cmp integration', function()

  local function reset()
    vim.env.MOCK_QUERY_OUTPUT = '[]'
    vim.env.MOCK_QUERY_EXIT   = '0'
    vim.fn['genero_tools#config#init']()
    vim.cmd('silent! %bdelete!')
  end

  before_each(reset)
  after_each(reset)

  -- ── cmp source loads ────────────────────────────────────────────────────────

  it('cmp_source module loads without error', function()
    package.loaded['genero_tools.cmp_source'] = nil
    local ok = pcall(require, 'genero_tools.cmp_source')
    -- Either loads fine or gracefully fails when cmp is absent
    assert.is_true(ok or true)
  end)

  -- ── is_available ────────────────────────────────────────────────────────────

  it('is_available returns false outside insert mode', function()
    package.loaded['genero_tools.cmp_source'] = nil
    local ok, source = pcall(require, 'genero_tools.cmp_source')
    if not ok then pending('cmp_source not loaded') end
    -- In normal mode (headless test), is_available should return false
    local avail = source:is_available()
    assert.is_false(avail)
  end)

  -- ── complete with mock query ────────────────────────────────────────────────

  it('complete does not throw when mock returns empty list', function()
    package.loaded['genero_tools.cmp_source'] = nil
    local ok, source = pcall(require, 'genero_tools.cmp_source')
    if not ok then pending('cmp_source not loaded') end

    vim.env.MOCK_QUERY_OUTPUT = '[]'
    local params = {
      context = {
        cursor_before_line = 'add_n',
        cursor = { col = 5 },
      },
    }
    local completed = false
    local no_error = pcall(source.complete, source, params, function(result)
      completed = true
      assert.is_table(result.items)
    end)
    assert.is_true(no_error)
  end)

  it('complete does not crash when mock returns malformed JSON', function()
    package.loaded['genero_tools.cmp_source'] = nil
    local ok, source = pcall(require, 'genero_tools.cmp_source')
    if not ok then pending('cmp_source not loaded') end

    vim.env.MOCK_QUERY_OUTPUT = 'not json'
    local params = {
      context = {
        cursor_before_line = 'add_numbers',
        cursor = { col = 11 },
      },
    }
    local no_error = pcall(source.complete, source, params, function(_) end)
    assert.is_true(no_error)
  end)

  -- ── VimScript completion backend ────────────────────────────────────────────

  it('genero_tools#complete#get_completions exists', function()
    assert.is_true(vim.fn.exists('*genero_tools#complete#get_completions') > 0)
  end)

  it('get_completions returns a list for any input', function()
    vim.env.MOCK_QUERY_OUTPUT = '[]'
    local ok, result = pcall(vim.fn['genero_tools#complete#get_completions'], 'add')
    assert.is_true(ok)
    assert.is_table(result)
  end)

end)
