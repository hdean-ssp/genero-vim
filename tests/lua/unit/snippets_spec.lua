-- tests/lua/unit/snippets_spec.lua
-- Tests for genero_tools snippets (manager and init)

describe('genero_tools.snippets', function()

  local manager

  before_each(function()
    package.loaded['genero_tools.snippets.manager'] = nil
    manager = require('genero_tools.snippets.manager')
    manager.clear_caches()
  end)

  describe('manager module structure', function()

    it('exposes load_builtin', function()
      assert.is_function(manager.load_builtin)
    end)

    it('exposes load_custom', function()
      assert.is_function(manager.load_custom)
    end)

    it('exposes list_snippets', function()
      assert.is_function(manager.list_snippets)
    end)

    it('exposes get_snippet', function()
      assert.is_function(manager.get_snippet)
    end)

    it('exposes get_snippet_count', function()
      assert.is_function(manager.get_snippet_count)
    end)

    it('exposes clear_caches', function()
      assert.is_function(manager.clear_caches)
    end)

    it('exposes reload_all', function()
      assert.is_function(manager.reload_all)
    end)

  end)

  describe('load_builtin', function()

    it('returns a table', function()
      local snippets = manager.load_builtin()
      assert.is_table(snippets)
    end)

    it('loads at least one built-in snippet', function()
      local snippets = manager.load_builtin()
      local count = vim.tbl_count(snippets)
      assert.is_true(count > 0, 'expected at least one built-in snippet, got ' .. count)
    end)

    it('each snippet has a trigger field', function()
      local snippets = manager.load_builtin()
      for trigger, snippet in pairs(snippets) do
        assert.is_string(trigger)
        assert.is_not_nil(snippet.trigger)
      end
    end)

    it('each snippet has a body field', function()
      local snippets = manager.load_builtin()
      for _, snippet in pairs(snippets) do
        assert.is_not_nil(snippet.body)
      end
    end)

  end)

  describe('list_snippets', function()

    it('returns a table combining builtin and custom', function()
      manager.load_builtin()
      local all = manager.list_snippets()
      assert.is_table(all)
    end)

    it('count matches get_snippet_count after loading', function()
      manager.load_builtin()
      local all = manager.list_snippets()
      local count = manager.get_snippet_count()
      assert.equals(vim.tbl_count(all), count)
    end)

  end)

  describe('get_snippet', function()

    it('returns nil for unknown trigger', function()
      local s = manager.get_snippet('nonexistent_trigger_xyz')
      assert.is_nil(s)
    end)

    it('returns snippet for known built-in trigger', function()
      local snippets = manager.load_builtin()
      -- Pick the first trigger from built-ins
      local first_trigger = nil
      for t, _ in pairs(snippets) do
        first_trigger = t
        break
      end
      if first_trigger then
        local s = manager.get_snippet(first_trigger)
        assert.is_not_nil(s)
        assert.equals(first_trigger, s.trigger)
      end
    end)

  end)

  describe('parse_snippet_nodes', function()

    it('returns a table of nodes for simple body', function()
      local ok, luasnip = pcall(require, 'luasnip')
      if not ok then pending('LuaSnip not installed') end
      local nodes = manager.parse_snippet_nodes('FUNCTION ${1:name}()\n  ${2:-- body}\nEND FUNCTION')
      assert.is_table(nodes)
      assert.is_true(#nodes > 0)
    end)

    it('returns a table for empty body', function()
      local ok, luasnip = pcall(require, 'luasnip')
      if not ok then pending('LuaSnip not installed') end
      local nodes = manager.parse_snippet_nodes('')
      assert.is_table(nodes)
    end)

  end)

end)
