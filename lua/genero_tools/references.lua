-- Genero-Tools References - Telescope Integration
-- Shows function references in a Telescope picker with file preview
-- Falls back to VimScript floating window if Telescope is not available

local M = {}

-- Resolve a file path from query.sh output to an absolute path
local function resolve_path(file)
  if not file or file == "" then
    return nil
  end

  -- Already absolute
  if file:sub(1, 1) == "/" then
    return file
  end

  -- Strip leading ./
  if file:sub(1, 2) == "./" then
    file = file:sub(3)
  end

  -- Try relative to codebase root
  local root = vim.fn["genero_tools#codebase#get_root"]()
  if root and root ~= "" then
    local candidate = root .. "/" .. file
    if vim.fn.filereadable(candidate) == 1 then
      return candidate
    end
  end

  -- Try relative to CWD
  local candidate = vim.fn.getcwd() .. "/" .. file
  if vim.fn.filereadable(candidate) == 1 then
    return candidate
  end

  return file
end

-- Extract fields from a reference entry (handles varying JSON shapes from query.sh)
local function parse_ref(ref)
  local name = ref.name or ref["function"] or ref.caller or "?"
  local file = ref.file or ref.file_path or ref.path or ""
  local line = ref.line or ref.line_start or 0
  local module = ref.module or ""

  -- Handle line as table {start, end}
  if type(line) == "table" then
    line = line.start or 0
  end

  return {
    name = name,
    file = file,
    line = tonumber(line) or 0,
    module = module,
  }
end

-- Show references using Telescope picker
-- Uses the grep previewer which natively handles lnum scrolling
function M.show_telescope(func_name, data)
  local ok_pickers, pickers = pcall(require, "telescope.pickers")
  local ok_finders, finders = pcall(require, "telescope.finders")
  local ok_conf, conf = pcall(require, "telescope.config")
  local ok_actions, actions = pcall(require, "telescope.actions")
  local ok_state, action_state = pcall(require, "telescope.actions.state")
  local ok_entry, entry_display = pcall(require, "telescope.pickers.entry_display")
  local ok_utils, utils = pcall(require, "telescope.utils")

  if not (ok_pickers and ok_finders and ok_conf and ok_actions and ok_state) then
    return false
  end

  -- Build entries with resolved paths
  local results = {}
  for _, ref in ipairs(data) do
    local parsed = parse_ref(ref)
    local full_path = resolve_path(parsed.file)

    if full_path then
      -- Offset line number: show 10 lines before the function for context
      -- The cursor lands on the function line, but the view starts earlier
      local context_line = math.max(1, parsed.line - 10)

      table.insert(results, {
        name = parsed.name,
        filename = full_path,
        lnum = parsed.line > 0 and parsed.line or 1,
        context_lnum = context_line,
        col = 1,
        module = parsed.module,
        short_file = vim.fn.fnamemodify(full_path, ":t"),
      })
    end
  end

  if #results == 0 then
    vim.notify("No references with valid file paths", vim.log.levels.WARN)
    return true
  end

  local count = #results
  local title = count == 1
    and "1 reference to " .. func_name
    or count .. " references to " .. func_name

  -- Use the grep previewer — it handles filename + lnum natively and scrolls to the line
  local previewer = conf.values.grep_previewer({})

  pickers.new({}, {
    prompt_title = title,
    finder = finders.new_table({
      results = results,
      entry_maker = function(item)
        -- Build display string
        local display = item.name .. "  " .. item.short_file .. ":" .. item.lnum
        if item.module ~= "" then
          display = display .. "  [" .. item.module .. "]"
        end

        -- Telescope's grep previewer reads filename/lnum/col from the entry
        -- to position the preview at the right line
        return {
          value = item,
          display = display,
          ordinal = item.name .. " " .. item.short_file,
          filename = item.filename,
          lnum = item.lnum,
          col = item.col,
        }
      end,
    }),
    sorter = conf.values.generic_sorter({}),
    previewer = previewer,
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.cmd("normal! m'")
          vim.cmd("edit " .. vim.fn.fnameescape(selection.filename))
          if selection.lnum > 0 then
            vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
            vim.cmd("normal! zz")
          end
        end
      end)
      return true
    end,
  }):find()

  return true
end

-- Entry point called from VimScript
-- Tries Telescope first, returns 1 if handled, 0 to fall back to floating window
function M.find(func_name, data_json)
  if not func_name or func_name == "" then
    return 0
  end

  -- Parse JSON data from VimScript
  local ok, data = pcall(vim.fn.json_decode, data_json)
  if not ok or type(data) ~= "table" or #data == 0 then
    return 0
  end

  -- Try Telescope
  local telescope_ok = pcall(function()
    return M.show_telescope(func_name, data)
  end)

  if telescope_ok then
    return 1
  end

  return 0
end

return M
