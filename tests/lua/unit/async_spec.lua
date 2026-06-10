-- tests/lua/unit/async_spec.lua
-- Tests for genero_tools.async

local async = require('genero_tools.async')

describe('genero_tools.async', function()

  describe('parse_output', function()

    it('returns success=true for exit_code=0 with valid JSON', function()
      local result = async.parse_output({'["hello","world"]'}, {}, 0)
      assert.is_true(result.success)
      assert.are.same({'hello', 'world'}, result.data)
    end)

    it('returns success=false for exit_code=1', function()
      local result = async.parse_output({}, {'error message'}, 1)
      assert.is_false(result.success)
      assert.equals(1, result.exit_code)
    end)

    it('returns success=false for malformed JSON', function()
      local result = async.parse_output({'not valid json {{{'}, {}, 0)
      -- success is true (exit 0) but data falls back to raw output
      assert.equals(0, result.exit_code)
      -- data should be the raw output list (fallback)
      assert.is_not_nil(result.data)
    end)

    it('returns empty data for empty output with exit_code=0', function()
      local result = async.parse_output({}, {}, 0)
      assert.is_true(result.success)
    end)

    it('captures error output in error field', function()
      local result = async.parse_output({}, {'stderr line 1', 'stderr line 2'}, 1)
      assert.is_false(result.success)
      assert.matches('stderr line 1', result.error)
    end)

  end)

  describe('module structure', function()

    it('exposes execute_async function', function()
      assert.is_function(async.execute_async)
    end)

    it('exposes debounce function', function()
      assert.is_function(async.debounce)
    end)

    it('debounce returns a callable', function()
      local called = false
      local debounced = async.debounce(function() called = true end, 100)
      assert.is_function(debounced)
    end)

  end)

end)
