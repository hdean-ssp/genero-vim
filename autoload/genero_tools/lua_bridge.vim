" Genero-Tools Plugin - Lua Bridge
" Provides interface between VimScript and Lua layer
" Allows VimScript to call Lua functions when available
" Gracefully falls back to VimScript implementations

" Check if Lua layer is available
function! genero_tools#lua_bridge#available() abort
  return has('nvim') && genero_tools#config#get('lua_enabled')
endfunction

" Call a Lua function from VimScript
" Args:
"   module: Lua module name (e.g., 'async', 'ui', 'ai')
"   function: Function name in module (e.g., 'execute_async')
"   args: List of arguments to pass to Lua function
" Returns: Result from Lua function or empty dict on error
function! genero_tools#lua_bridge#call(module, function, args) abort
  if !genero_tools#lua_bridge#available()
    return {}
  endif
  
  try
    let lua_call = 'require("genero_tools.' . a:module . '").' . a:function
    return luaeval(lua_call . '(...)', a:args)
  catch
    call genero_tools#error#log('Lua bridge error: ' . v:exception)
    return {}
  endtry
endfunction

" Call a Lua function and handle errors
function! genero_tools#lua_bridge#call_safe(module, function, args, fallback) abort
  if !genero_tools#lua_bridge#available()
    return a:fallback
  endif
  
  try
    let lua_call = 'require("genero_tools.' . a:module . '").' . a:function
    return luaeval(lua_call . '(...)', a:args)
  catch
    call genero_tools#error#log('Lua bridge error in ' . a:module . '.' . a:function . ': ' . v:exception)
    return a:fallback
  endtry
endfunction

" Execute async operation (Lua only)
" Args:
"   command: Command to execute
"   args: Command arguments
"   callback: VimScript function to call with results
function! genero_tools#lua_bridge#execute_async(command, args, callback) abort
  if !genero_tools#lua_bridge#available()
    " Fallback to sync execution
    let result = genero_tools#command#execute_shell(a:command, a:args)
    call function(a:callback)(result)
    return
  endif
  
  try
    call luaeval('require("genero_tools.async").execute_async(...)', [a:command, a:args, a:callback])
  catch
    call genero_tools#error#log('Async execution error: ' . v:exception)
    let result = genero_tools#command#execute_shell(a:command, a:args)
    call function(a:callback)(result)
  endtry
endfunction

" Show floating window (Lua only)
" Args:
"   content: Content to display
"   options: Display options (title, width, height, etc.)
function! genero_tools#lua_bridge#show_floating_window(content, options) abort
  if !genero_tools#lua_bridge#available()
    " Fallback to quickfix
    call genero_tools#display#quickfix(a:content)
    return
  endif
  
  try
    call luaeval('require("genero_tools.ui").show_floating_window(...)', [a:content, a:options])
  catch
    call genero_tools#error#log('Floating window error: ' . v:exception)
    call genero_tools#display#quickfix(a:content)
  endtry
endfunction

" Get AI explanation for error (Lua only)
" Args:
"   error_message: Error message from compiler
"   context: Code context around error
" Returns: Explanation and suggestions
function! genero_tools#lua_bridge#explain_error(error_message, context) abort
  if !genero_tools#lua_bridge#available()
    return {}
  endif
  
  if !genero_tools#config#get('ai_enabled')
    return {}
  endif
  
  try
    return luaeval('require("genero_tools.ai").explain_error(...)', [a:error_message, a:context])
  catch
    call genero_tools#error#log('AI error explanation failed: ' . v:exception)
    return {}
  endtry
endfunction

" Generate code using AI (Lua only)
" Args:
"   prompt: Code generation prompt
"   context: Codebase context
" Returns: Generated code
function! genero_tools#lua_bridge#generate_code(prompt, context) abort
  if !genero_tools#lua_bridge#available()
    return ''
  endif
  
  if !genero_tools#config#get('ai_enabled')
    return ''
  endif
  
  try
    return luaeval('require("genero_tools.ai").generate_code(...)', [a:prompt, a:context])
  catch
    call genero_tools#error#log('AI code generation failed: ' . v:exception)
    return ''
  endtry
endfunction

" Initialize Lua layer
function! genero_tools#lua_bridge#init() abort
  if !has('nvim')
    return
  endif
  
  try
    call luaeval('require("genero_tools").setup(...)', [g:genero_tools_config])
  catch
    call genero_tools#error#log('Lua layer initialization failed: ' . v:exception)
  endtry
endfunction
