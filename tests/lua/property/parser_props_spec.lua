-- tests/lua/property/parser_props_spec.lua
-- Feature: new-test-suite
-- Property 1: compiler parser round-trip (via VimScript bridge)
-- Property 2: SVN diff parser correctness (via VimScript bridge)

-- ── helpers ──────────────────────────────────────────────────────────────────

local filenames  = {'foo.4gl', 'bar.4gl', 'module/baz.4gl'}
local messages   = {'undefined variable', 'type mismatch', 'missing END'}
local severities = {'error', 'warning', 'info'}

--- Generate a deterministic v3.10 full-format compiler line from a seed.
local function generate_compiler_line(seed)
  local fname = filenames[(seed % #filenames) + 1]
  local lnum  = (seed % 999) + 1
  local col   = (seed % 79)  + 1
  local sev   = severities[(seed % #severities) + 1]
  local msg   = messages[(seed % #messages) + 1]
  local code  = (seed % 900) + 100
  return string.format('%s:%d:%d:%d:%d:%s:(-%d) %s',
    fname, lnum, col, lnum, col + 1, sev, code, msg),
    { file = fname, line = lnum, col = col, severity = sev, message = msg }
end

--- Generate a synthetic SVN unified diff with known added/deleted lines.
local function generate_svn_diff(seed)
  local added_count   = (seed % 4) + 1
  local deleted_count = seed % 3

  local added_lines   = {}
  local deleted_lines = {}

  for i = 1, added_count do
    table.insert(added_lines, (seed * 7 + (i - 1) * 13) % 900 + 10)
  end
  for i = 1, deleted_count do
    table.insert(deleted_lines, (seed * 11 + (i - 1) * 17) % 900 + 10)
  end

  local context = math.max(added_count, deleted_count) + 5
  local lines = {
    'Index: test.4gl',
    '===================================================================',
    '--- test.4gl\t(revision 100)',
    '+++ test.4gl\t(working copy)',
    string.format('@@ -1,%d +1,%d @@', deleted_count + context, added_count + context),
  }
  for i = 1, 3 do
    table.insert(lines, ' context line ' .. i)
  end
  for _, lnum in ipairs(deleted_lines) do
    table.insert(lines, '-deleted line ' .. lnum)
  end
  for _, lnum in ipairs(added_lines) do
    table.insert(lines, '+added line ' .. lnum)
  end

  return table.concat(lines, '\n'), added_lines, deleted_lines
end

-- ── Property 1: compiler parser round-trip ────────────────────────────────────

describe('Property 1: compiler parser round-trip', function()

  it('parse_v310 correctly extracts fields for 100 generated lines', function()
    for seed = 0, 99 do
      local line, expected = generate_compiler_line(seed)
      local result = vim.fn['genero_tools#compiler#parse_v310'](line, 'fgl')

      assert.equals(1, result.success,
        'seed ' .. seed .. ': parse should succeed')

      local entries
      if expected.severity == 'error' then
        entries = result.errors
      elseif expected.severity == 'warning' then
        entries = result.warnings
      else
        entries = result.info
      end

      assert.equals(1, #entries,
        'seed ' .. seed .. ': exactly one entry in ' .. expected.severity .. ' list')

      local e = entries[1]
      assert.equals(expected.file,     e.file,     'seed ' .. seed .. ': file')
      assert.equals(expected.line,     e.line,     'seed ' .. seed .. ': line')
      assert.equals(expected.col,      e.col,      'seed ' .. seed .. ': col')
      assert.equals(expected.severity, e.severity, 'seed ' .. seed .. ': severity')
      assert.is_true(e.message:find(expected.message, 1, true) ~= nil,
        'seed ' .. seed .. ': message contains expected text')
    end
  end)

end)

-- ── Property 2: SVN diff parser correctness ───────────────────────────────────

describe('Property 2: SVN diff parser correctness', function()

  it('parse_diff correctly identifies added and deleted lines for 100 generated diffs', function()
    for seed = 0, 99 do
      local diff, added_lines, deleted_lines = generate_svn_diff(seed)
      local result = vim.fn['genero_tools#svn#parser#parse_diff'](diff)

      -- Every added line must appear in result.added or result.modified
      local all_found = vim.list_extend(vim.deepcopy(result.added), result.modified)
      for _, lnum in ipairs(added_lines) do
        local found = false
        for _, v in ipairs(all_found) do
          if v == lnum then found = true; break end
        end
        assert.is_true(found,
          'seed ' .. seed .. ': added line ' .. lnum .. ' should be in added or modified')
      end

      -- Every deleted line must appear in result.deleted or result.modified
      local all_del = vim.list_extend(vim.deepcopy(result.deleted), result.modified)
      for _, lnum in ipairs(deleted_lines) do
        local found = false
        for _, v in ipairs(all_del) do
          if v == lnum then found = true; break end
        end
        assert.is_true(found,
          'seed ' .. seed .. ': deleted line ' .. lnum .. ' should be in deleted or modified')
      end
    end
  end)

end)
