-- Genero-Tools AI IDE Features
-- Provides AI-powered code generation, error explanation, and refactoring suggestions

local M = {}

-- Initialize AI module
function M.init()
  -- Set up AI-specific configuration
  M.provider = vim.g.genero_tools_config.ai_provider or 'openai'
  M.api_key = vim.g.genero_tools_config.ai_api_key or os.getenv('OPENAI_API_KEY')
end

-- Explain compiler error using AI
-- Args:
--   error_message: Error message from compiler
--   context: Code context around error
-- Returns: Explanation and suggestions
function M.explain_error(error_message, context)
  if not M.api_key then
    return {
      success = false,
      error = 'AI API key not configured',
    }
  end

  local prompt = string.format(
    [[
You are a Genero/4GL programming expert. Explain this compiler error and suggest fixes.

Error: %s

Code context:
%s

Provide:
1. What the error means
2. Why it occurred
3. How to fix it
4. Example of corrected code
]],
    error_message,
    context
  )

  return M.call_api(prompt, 'error_explanation')
end

-- Generate code using AI
-- Args:
--   prompt: Code generation prompt
--   context: Codebase context (function signatures, etc.)
-- Returns: Generated code
function M.generate_code(prompt, context)
  if not M.api_key then
    return {
      success = false,
      error = 'AI API key not configured',
    }
  end

  local full_prompt = string.format(
    [[
You are a Genero/4GL programming expert. Generate code based on this request.

Request: %s

Available context:
%s

Generate clean, well-commented Genero/4GL code that follows best practices.
]],
    prompt,
    context
  )

  return M.call_api(full_prompt, 'code_generation')
end

-- Suggest refactoring improvements
-- Args:
--   code_section: Code to analyze
-- Returns: Refactoring suggestions
function M.suggest_refactoring(code_section)
  if not M.api_key then
    return {
      success = false,
      error = 'AI API key not configured',
    }
  end

  local prompt = string.format(
    [[
You are a Genero/4GL code quality expert. Analyze this code and suggest improvements.

Code:
%s

Provide:
1. Code quality issues
2. Performance improvements
3. Readability enhancements
4. Best practice violations
5. Refactored version of the code
]],
    code_section
  )

  return M.call_api(prompt, 'refactoring_suggestion')
end

-- Call AI API
-- Args:
--   prompt: Prompt for AI
--   request_type: Type of request (for logging/tracking)
-- Returns: API response
function M.call_api(prompt, request_type)
  request_type = request_type or 'general'

  if M.provider == 'openai' then
    return M.call_openai(prompt)
  elseif M.provider == 'claude' then
    return M.call_claude(prompt)
  elseif M.provider == 'local' then
    return M.call_local(prompt)
  else
    return {
      success = false,
      error = 'Unknown AI provider: ' .. M.provider,
    }
  end
end

-- Call OpenAI API
function M.call_openai(prompt)
  local curl_cmd = string.format(
    [[
curl -s https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer %s" \
  -d '{
    "model": "gpt-4",
    "messages": [{"role": "user", "content": %s}],
    "temperature": 0.7,
    "max_tokens": 2000
  }'
]],
    M.api_key,
    vim.fn.json_encode(prompt)
  )

  local handle = io.popen(curl_cmd)
  if not handle then
    return {
      success = false,
      error = 'Failed to call OpenAI API',
    }
  end

  local response = handle:read('*a')
  handle:close()

  local ok, parsed = pcall(vim.fn.json_decode, response)
  if not ok then
    return {
      success = false,
      error = 'Failed to parse OpenAI response',
    }
  end

  if parsed.error then
    return {
      success = false,
      error = parsed.error.message,
    }
  end

  local content = parsed.choices[1].message.content
  return {
    success = true,
    content = content,
    model = parsed.model,
    usage = parsed.usage,
  }
end

-- Call Claude API
function M.call_claude(prompt)
  local api_key = vim.g.genero_tools_config.claude_api_key or os.getenv('CLAUDE_API_KEY')

  if not api_key then
    return {
      success = false,
      error = 'Claude API key not configured',
    }
  end

  local curl_cmd = string.format(
    [[
curl -s https://api.anthropic.com/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: %s" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-3-opus-20240229",
    "max_tokens": 2000,
    "messages": [{"role": "user", "content": %s}]
  }'
]],
    api_key,
    vim.fn.json_encode(prompt)
  )

  local handle = io.popen(curl_cmd)
  if not handle then
    return {
      success = false,
      error = 'Failed to call Claude API',
    }
  end

  local response = handle:read('*a')
  handle:close()

  local ok, parsed = pcall(vim.fn.json_decode, response)
  if not ok then
    return {
      success = false,
      error = 'Failed to parse Claude response',
    }
  end

  if parsed.error then
    return {
      success = false,
      error = parsed.error.message,
    }
  end

  local content = parsed.content[1].text
  return {
    success = true,
    content = content,
    model = parsed.model,
    usage = parsed.usage,
  }
end

-- Call local AI model (e.g., Ollama)
function M.call_local(prompt)
  local local_url = vim.g.genero_tools_config.local_ai_url or 'http://localhost:11434/api/generate'

  local curl_cmd = string.format(
    [[
curl -s -X POST %s \
  -H "Content-Type: application/json" \
  -d '{
    "model": "mistral",
    "prompt": %s,
    "stream": false
  }'
]],
    local_url,
    vim.fn.json_encode(prompt)
  )

  local handle = io.popen(curl_cmd)
  if not handle then
    return {
      success = false,
      error = 'Failed to call local AI model',
    }
  end

  local response = handle:read('*a')
  handle:close()

  local ok, parsed = pcall(vim.fn.json_decode, response)
  if not ok then
    return {
      success = false,
      error = 'Failed to parse local AI response',
    }
  end

  return {
    success = true,
    content = parsed.response,
    model = parsed.model,
  }
end

-- Cache AI responses to avoid redundant calls
-- Args:
--   key: Cache key
--   value: Value to cache
function M.cache_response(key, value)
  if not vim.g.genero_tools_ai_cache then
    vim.g.genero_tools_ai_cache = {}
  end

  vim.g.genero_tools_ai_cache[key] = {
    value = value,
    timestamp = os.time(),
  }
end

-- Get cached AI response
-- Args:
--   key: Cache key
--   ttl: Time to live in seconds
-- Returns: Cached value or nil
function M.get_cached_response(key, ttl)
  ttl = ttl or 3600 -- 1 hour default

  if not vim.g.genero_tools_ai_cache then
    return nil
  end

  local cached = vim.g.genero_tools_ai_cache[key]
  if not cached then
    return nil
  end

  if os.time() - cached.timestamp > ttl then
    vim.g.genero_tools_ai_cache[key] = nil
    return nil
  end

  return cached.value
end

return M
