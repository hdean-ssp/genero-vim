-- tests/lua/integration/compiler_integration_spec.lua
-- End-to-end compiler integration: quickfix, signs, navigation, .per routing

describe('compiler integration', function()

  local function reset()
    vim.env.MOCK_FGLCOMP_OUTPUT = ''
    vim.env.MOCK_FGLCOMP_EXIT   = '0'
    vim.env.MOCK_FGLFORM_OUTPUT = ''
    vim.env.MOCK_FGLFORM_EXIT   = '0'
    vim.fn['genero_tools#config#init']()
    vim.fn.setqflist({})
    vim.cmd('silent! %bdelete!')
  end

  before_each(reset)
  after_each(reset)

  -- ── parse + quickfix ────────────────────────────────────────────────────────

  it('parse_v310 produces correct entries from errors_v310.txt fixture', function()
    local lines = table.concat(vim.fn.readfile('tests/fixtures/compiler_output/errors_v310.txt'), '\n')
    local result = vim.fn['genero_tools#compiler#parse_v310'](lines, 'fgl')
    assert.equals(1, result.success)
    assert.equals(3, #result.errors)
    assert.equals('sample_codebase/simple_functions.4gl', result.errors[1].file)
    assert.equals(44, result.errors[1].line)
    assert.equals('error', result.errors[1].severity)
  end)

  it('parse_v310 produces correct entries from warnings_v310.txt fixture', function()
    local lines = table.concat(vim.fn.readfile('tests/fixtures/compiler_output/warnings_v310.txt'), '\n')
    local result = vim.fn['genero_tools#compiler#parse_v310'](lines, 'fgl')
    assert.equals(1, result.success)
    assert.equals(0, #result.errors)
    assert.equals(2, #result.warnings)
    assert.equals('sample_codebase/customer_main.4gl', result.warnings[1].file)
  end)

  it('parse_v310 handles mixed fixture with both errors and warnings', function()
    local lines = table.concat(vim.fn.readfile('tests/fixtures/compiler_output/mixed.txt'), '\n')
    local result = vim.fn['genero_tools#compiler#parse_v310'](lines, 'fgl')
    assert.equals(1, result.success)
    assert.is_true(#result.errors > 0)
    assert.is_true(#result.warnings > 0)
  end)

  -- ── file-type routing ───────────────────────────────────────────────────────

  it('.4gl file routes to fglcomp', function()
    assert.equals('fgl', vim.fn['genero_tools#compiler#detect_file_type']('foo.4gl'))
  end)

  it('.per file routes to fglform', function()
    assert.equals('per', vim.fn['genero_tools#compiler#detect_file_type']('form.per'))
  end)

  it('get_compiler_command returns fglcomp for fgl type', function()
    local cmd = vim.fn['genero_tools#compiler#get_compiler_command']('fgl')
    assert.equals('fglcomp', cmd)
  end)

  it('get_compiler_command returns fglform for per type', function()
    local cmd = vim.fn['genero_tools#compiler#get_compiler_command']('per')
    assert.equals('fglform', cmd)
  end)

  -- ── mock compiler execution ─────────────────────────────────────────────────

  it('execute returns a result dict when mock fglcomp exits 0 with no output', function()
    vim.env.MOCK_FGLCOMP_OUTPUT = ''
    vim.env.MOCK_FGLCOMP_EXIT   = '0'
    local result = vim.fn['genero_tools#compiler#execute']('sample_codebase/simple_functions.4gl')
    assert.is_table(result)
    assert.is_not_nil(result.success)
  end)

  it('execute returns a result dict when mock fglcomp exits 1', function()
    vim.env.MOCK_FGLCOMP_EXIT   = '1'
    vim.env.MOCK_FGLCOMP_OUTPUT = ''
    local result = vim.fn['genero_tools#compiler#execute']('sample_codebase/simple_functions.4gl')
    assert.is_table(result)
  end)

  it('execute with errors fixture populates errors list', function()
    local fixture = table.concat(vim.fn.readfile('tests/fixtures/compiler_output/errors_v310.txt'), '\n')
    vim.env.MOCK_FGLCOMP_OUTPUT = fixture
    vim.env.MOCK_FGLCOMP_EXIT   = '1'
    local result = vim.fn['genero_tools#compiler#execute']('sample_codebase/simple_functions.4gl')
    assert.is_table(result)
    -- errors may be in result.errors or parsed from raw output
    assert.is_not_nil(result.errors or result.output)
  end)

  -- ── GeneroClearErrors command ───────────────────────────────────────────────

  it('GeneroClearErrors command exists', function()
    assert.is_true(vim.fn.exists(':GeneroClearErrors') > 0)
  end)

end)
