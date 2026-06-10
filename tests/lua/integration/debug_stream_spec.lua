-- tests/lua/integration/debug_stream_spec.lua
-- Integration tests for debug streaming (Neovim only)

if not vim.fn.has('nvim') then
  return
end

describe('debug streaming', function()

  local tmpfile

  local function reset()
    -- Stop any active stream
    pcall(vim.fn['genero_tools#debug_stream#stop'])
    vim.cmd('silent! %bdelete!')
    if tmpfile and vim.fn.filereadable(tmpfile) == 1 then
      vim.fn.delete(tmpfile)
    end
    tmpfile = nil
  end

  before_each(reset)
  after_each(reset)

  -- ── commands exist ──────────────────────────────────────────────────────────

  it('GeneroDebugStreamToggle command exists', function()
    assert.is_true(vim.fn.exists(':GeneroDebugStreamToggle') > 0)
  end)

  it('GeneroDebugStreamOpen command exists', function()
    assert.is_true(vim.fn.exists(':GeneroDebugStreamOpen') > 0)
  end)

  it('GeneroDebugStreamClose command exists', function()
    assert.is_true(vim.fn.exists(':GeneroDebugStreamClose') > 0)
  end)

  it('GeneroDebugStreamClear command exists', function()
    assert.is_true(vim.fn.exists(':GeneroDebugStreamClear') > 0)
  end)

  it('GeneroDebugStreamSelect command exists', function()
    assert.is_true(vim.fn.exists(':GeneroDebugStreamSelect') > 0)
  end)

  -- ── status function ─────────────────────────────────────────────────────────

  it('debug_stream#status returns a dict', function()
    local status = vim.fn['genero_tools#debug_stream#status']()
    assert.is_table(status)
    assert.is_not_nil(status.enabled)
  end)

  it('debug_stream#status.enabled is 0 when not streaming', function()
    local status = vim.fn['genero_tools#debug_stream#status']()
    assert.equals(0, status.enabled)
  end)

  -- ── start with valid file ───────────────────────────────────────────────────

  it('start opens a window for a readable file', function()
    tmpfile = vim.fn.tempname() .. '.log'
    vim.fn.writefile({'line 1', 'line 2'}, tmpfile)

    local ok = pcall(vim.fn['genero_tools#debug_stream#start'], tmpfile)
    assert.is_true(ok)

    local status = vim.fn['genero_tools#debug_stream#status']()
    assert.equals(1, status.enabled)

    -- Clean up
    vim.fn['genero_tools#debug_stream#stop']()
  end)

  -- ── stop ────────────────────────────────────────────────────────────────────

  it('stop disables streaming', function()
    tmpfile = vim.fn.tempname() .. '.log'
    vim.fn.writefile({'hello'}, tmpfile)

    pcall(vim.fn['genero_tools#debug_stream#start'], tmpfile)
    vim.fn['genero_tools#debug_stream#stop']()

    local status = vim.fn['genero_tools#debug_stream#status']()
    assert.equals(0, status.enabled)
  end)

  -- ── clear ───────────────────────────────────────────────────────────────────

  it('clear does not throw when not streaming', function()
    local ok = pcall(vim.fn['genero_tools#debug_stream#clear'])
    assert.is_true(ok)
  end)

  -- ── error when file does not exist ─────────────────────────────────────────

  it('start with nonexistent file does not crash', function()
    local ok = pcall(vim.fn['genero_tools#debug_stream#start'], '/nonexistent/path/debug.log')
    assert.is_true(ok)
    -- Should not have started streaming
    local status = vim.fn['genero_tools#debug_stream#status']()
    assert.equals(0, status.enabled)
  end)

end)
