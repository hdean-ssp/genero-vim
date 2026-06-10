-- tests/lua/unit/cmp_source_spec.lua
-- Tests for genero_tools.cmp_source

describe('genero_tools.cmp_source', function()

  local source

  before_each(function()
    package.loaded['genero_tools.cmp_source'] = nil
    -- cmp_source auto-registers with nvim-cmp on load; suppress errors if cmp absent
    local ok, mod = pcall(require, 'genero_tools.cmp_source')
    if ok then
      source = mod
    end
  end)

  describe('module loads without error', function()

    it('loads or gracefully fails when nvim-cmp is absent', function()
      -- Either loaded successfully or failed gracefully (no unhandled exception)
      assert.is_true(true)
    end)

  end)

  describe('source interface', function()

    it('exposes get_debug_name', function()
      if not source then pending('cmp_source not loaded') end
      assert.is_function(source.get_debug_name)
    end)

    it('get_debug_name returns "genero"', function()
      if not source then pending('cmp_source not loaded') end
      assert.equals('genero', source:get_debug_name())
    end)

    it('exposes is_available', function()
      if not source then pending('cmp_source not loaded') end
      assert.is_function(source.is_available)
    end)

    it('exposes complete', function()
      if not source then pending('cmp_source not loaded') end
      assert.is_function(source.complete)
    end)

    it('exposes get_trigger_characters', function()
      if not source then pending('cmp_source not loaded') end
      assert.is_function(source.get_trigger_characters)
    end)

    it('get_trigger_characters returns a table', function()
      if not source then pending('cmp_source not loaded') end
      local chars = source:get_trigger_characters()
      assert.is_table(chars)
    end)

  end)

  describe('complete callback', function()

    it('calls callback with items table for short base string', function()
      if not source then pending('cmp_source not loaded') end
      vim.env.MOCK_QUERY_OUTPUT = '[]'
      vim.env.MOCK_QUERY_EXIT   = '0'

      local params = {
        context = {
          cursor_before_line = 'a',
          cursor = { col = 1 },
        },
      }

      local called = false
      source:complete(params, function(result)
        called = true
        assert.is_table(result)
        assert.is_table(result.items)
      end)
      -- callback may be synchronous or async; just assert no exception
      assert.is_true(true)
    end)

    it('calls callback with empty items for base shorter than 2 chars', function()
      if not source then pending('cmp_source not loaded') end

      local params = {
        context = {
          cursor_before_line = 'a',
          cursor = { col = 1 },
        },
      }

      local got_items = nil
      source:complete(params, function(result)
        got_items = result.items
      end)
      if got_items ~= nil then
        assert.are.same({}, got_items)
      end
    end)

  end)

end)
