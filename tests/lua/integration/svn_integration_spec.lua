-- tests/lua/integration/svn_integration_spec.lua
-- End-to-end SVN integration: diff parsing, sign placement, unified signs

describe('SVN integration', function()

  local function reset()
    vim.env.MOCK_SVN_OUTPUT = ''
    vim.env.MOCK_SVN_EXIT   = '0'
    vim.fn['genero_tools#config#init']()
    vim.cmd('silent! %bdelete!')
  end

  before_each(reset)
  after_each(reset)

  -- ── parser via fixture files ────────────────────────────────────────────────

  it('parse_diff added_lines fixture returns 3 added lines', function()
    local diff = table.concat(vim.fn.readfile('tests/fixtures/svn_diff/added_lines.diff'), '\n')
    local result = vim.fn['genero_tools#svn#parser#parse_diff'](diff)
    assert.equals(3, #result.added)
    -- Check known line numbers from fixture comments
    local function contains(t, v)
      for _, x in ipairs(t) do if x == v then return true end end
      return false
    end
    assert.is_true(contains(result.added, 49))
    assert.is_true(contains(result.added, 52))
    assert.is_true(contains(result.added, 55))
    assert.equals(0, #result.deleted)
  end)

  it('parse_diff deleted_lines fixture returns 2 deleted lines', function()
    local diff = table.concat(vim.fn.readfile('tests/fixtures/svn_diff/deleted_lines.diff'), '\n')
    local result = vim.fn['genero_tools#svn#parser#parse_diff'](diff)
    assert.equals(2, #result.deleted)
    assert.equals(0, #result.added)
  end)

  it('parse_diff modified_lines fixture detects modification', function()
    local diff = table.concat(vim.fn.readfile('tests/fixtures/svn_diff/modified_lines.diff'), '\n')
    local result = vim.fn['genero_tools#svn#parser#parse_diff'](diff)
    -- A modification is a delete+add pair; appears in modified or deleted
    assert.is_true(#result.modified > 0 or #result.deleted > 0)
  end)

  it('parse_diff mixed_changes fixture has both added and deleted', function()
    local diff = table.concat(vim.fn.readfile('tests/fixtures/svn_diff/mixed_changes.diff'), '\n')
    local result = vim.fn['genero_tools#svn#parser#parse_diff'](diff)
    assert.is_true(#result.added > 0)
    assert.is_true(#result.deleted > 0)
  end)

  -- ── result structure ────────────────────────────────────────────────────────

  it('parse_diff always returns dict with added/deleted/modified keys', function()
    local result = vim.fn['genero_tools#svn#parser#parse_diff']('')
    assert.is_not_nil(result.added)
    assert.is_not_nil(result.deleted)
    assert.is_not_nil(result.modified)
  end)

  -- ── SVN module functions exist ──────────────────────────────────────────────

  it('svn module functions are callable', function()
    assert.is_true(vim.fn.exists('*genero_tools#svn#parse_diff') > 0)
    assert.is_true(vim.fn.exists('*genero_tools#svn#parser#parse_diff') > 0)
  end)

  -- ── unified signs ───────────────────────────────────────────────────────────

  it('GeneroUnifiedSignsToggle command exists', function()
    assert.is_true(vim.fn.exists(':GeneroUnifiedSignsToggle') > 0)
  end)

  it('GeneroUnifiedSignsEnable command exists', function()
    assert.is_true(vim.fn.exists(':GeneroUnifiedSignsEnable') > 0)
  end)

end)
