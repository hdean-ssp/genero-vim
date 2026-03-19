-- Genero-Tools UI Components
-- Provides modern UI for Neovim (floating windows, popups, etc.)

local M = {}

-- Initialize UI module
function M.init()
  -- Set up UI-specific configuration
end

-- Show floating window with content
-- Args:
--   content: Content to display (string or list of strings)
--   options: Display options {title, width, height, border, position, etc.}
function M.show_floating_window(content, options)
  if not vim.fn.has('nvim') then
    error('Floating windows require Neovim')
  end

  options = options or {}

  -- Normalize content to list of strings
  local lines = type(content) == 'string' and vim.split(content, '\n') or content

  -- Get configuration values from Vim config
  local config_border = vim.fn['genero_tools#config#get']('floating_window_border')
  local config_width = vim.fn['genero_tools#config#get']('floating_window_width')
  local config_height = vim.fn['genero_tools#config#get']('floating_window_height')
  local config_position = vim.fn['genero_tools#config#get']('floating_window_position')
  local config_title = vim.fn['genero_tools#config#get']('floating_window_title')

  -- Calculate dimensions with config defaults
  local width = options.width or config_width or math.min(80, vim.o.columns - 4)
  local height = options.height or config_height or math.min(#lines + 2, vim.o.lines - 4)

  -- Ensure reasonable bounds
  width = math.max(40, math.min(width, vim.o.columns - 4))
  height = math.max(5, math.min(height, vim.o.lines - 4))

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')

  -- Calculate window position based on config
  local position = options.position or config_position or 'center'
  local row, col, anchor, relative

  if position == 'center' then
    relative = 'editor'
    row = math.floor((vim.o.lines - height) / 2)
    col = math.floor((vim.o.columns - width) / 2)
    anchor = 'NW'
  elseif position == 'top' then
    relative = 'editor'
    row = 1
    col = math.floor((vim.o.columns - width) / 2)
    anchor = 'NW'
  elseif position == 'bottom' then
    relative = 'editor'
    row = vim.o.lines - height - 1
    col = math.floor((vim.o.columns - width) / 2)
    anchor = 'NW'
  else -- cursor (position just above cursor)
    relative = 'cursor'
    row = -height - 1
    col = 0
    anchor = 'SW'
  end

  -- Create window with config values
  local border = options.border or config_border or 'rounded'
  local title = options.title or config_title or 'Genero-Tools'

  local win = vim.api.nvim_open_win(buf, true, {
    relative = relative,
    row = row,
    col = col,
    width = width,
    height = height,
    anchor = anchor,
    border = border,
    title = title,
    title_pos = 'center',
  })

  -- Set window options
  vim.api.nvim_win_set_option(win, 'wrap', true)
  vim.api.nvim_win_set_option(win, 'cursorline', true)

  -- Set up keybindings for floating window
  M.setup_floating_window_keys(buf, win)

  return { buf = buf, win = win }
end

-- Set up keybindings for floating window
function M.setup_floating_window_keys(buf, win)
  local opts = { noremap = true, silent = true, buffer = buf }

  -- Close window
  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(win, true)
  end, opts)

  vim.keymap.set('n', '<Esc>', function()
    vim.api.nvim_win_close(win, true)
  end, opts)

  -- Navigate
  vim.keymap.set('n', 'j', '<C-j>', opts)
  vim.keymap.set('n', 'k', '<C-k>', opts)
  vim.keymap.set('n', 'G', 'G', opts)
  vim.keymap.set('n', 'gg', 'gg', opts)
end

-- Show popup menu with items
-- Args:
--   items: List of items to display
--   callback: Function to call when item selected
-- Returns: Window and buffer info
function M.show_popup_menu(items, callback)
  if not vim.fn.has('nvim') then
    error('Popup menus require Neovim')
  end

  -- Get configuration values
  local config_border = vim.fn['genero_tools#config#get']('floating_window_border')
  local config_position = vim.fn['genero_tools#config#get']('floating_window_position')

  local lines = {}
  for i, item in ipairs(items) do
    local display = type(item) == 'string' and item or item.display or tostring(item)
    table.insert(lines, string.format('%d. %s', i, display))
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = math.max(unpack(vim.tbl_map(function(line)
    return #line
  end, lines))) + 2

  local height = math.min(#lines + 2, 20)

  -- Calculate position based on config
  local position = config_position or 'center'
  local row, col, relative, anchor

  if position == 'center' then
    relative = 'editor'
    row = math.floor((vim.o.lines - height) / 2)
    col = math.floor((vim.o.columns - width) / 2)
    anchor = 'NW'
  elseif position == 'top' then
    relative = 'editor'
    row = 1
    col = math.floor((vim.o.columns - width) / 2)
    anchor = 'NW'
  elseif position == 'bottom' then
    relative = 'editor'
    row = vim.o.lines - height - 1
    col = math.floor((vim.o.columns - width) / 2)
    anchor = 'NW'
  else -- cursor (position just above cursor)
    relative = 'cursor'
    row = -height - 1
    col = 0
    anchor = 'SW'
  end

  local win = vim.api.nvim_open_win(buf, true, {
    relative = relative,
    row = row,
    col = col,
    width = width,
    height = height,
    anchor = anchor,
    border = config_border or 'rounded',
  })

  -- Set up selection keybindings
  local opts = { noremap = true, silent = true, buffer = buf }

  for i = 1, #items do
    vim.keymap.set('n', tostring(i), function()
      if callback then
        callback(items[i], i)
      end
      vim.api.nvim_win_close(win, true)
    end, opts)
  end

  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(win, true)
  end, opts)

  return { buf = buf, win = win }
end

-- Show notification
-- Args:
--   message: Message to display
--   level: Log level (INFO, WARN, ERROR)
function M.notify(message, level)
  level = level or vim.log.levels.INFO
  vim.notify(message, level, { title = 'Genero-Tools' })
end

-- Show progress indicator
-- Args:
--   message: Progress message
--   percentage: Progress percentage (0-100)
function M.show_progress(message, percentage)
  local bar_length = 20
  local filled = math.floor((percentage / 100) * bar_length)
  local empty = bar_length - filled

  local bar = '[' .. string.rep('=', filled) .. string.rep(' ', empty) .. ']'
  local display = string.format('%s %d%% %s', bar, percentage, message)

  M.notify(display, vim.log.levels.INFO)
end

-- Create a split window with content
-- Args:
--   content: Content to display
--   options: Display options {direction, size, etc.}
function M.show_split(content, options)
  options = options or {}

  local direction = options.direction or 'horizontal'
  local size = options.size or 10

  -- Create new buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, '\n'))

  -- Create split
  if direction == 'horizontal' then
    vim.cmd('split')
  else
    vim.cmd('vsplit')
  end

  -- Set buffer in current window
  vim.api.nvim_set_current_buf(buf)

  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')

  return { buf = buf }
end

-- Highlight text in buffer
-- Args:
--   buf: Buffer number
--   pattern: Pattern to highlight
--   hl_group: Highlight group name
function M.highlight_pattern(buf, pattern, hl_group)
  hl_group = hl_group or 'Search'

  local ns_id = vim.api.nvim_create_namespace('genero_tools_highlight')
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  for line_num, line in ipairs(lines) do
    local start = 1
    while true do
      local match_start, match_end = line:find(pattern, start)
      if not match_start then
        break
      end

      vim.api.nvim_buf_add_highlight(buf, ns_id, hl_group, line_num - 1, match_start - 1, match_end)
      start = match_end + 1
    end
  end
end

return M
