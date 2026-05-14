-- Genero Debug Snippets
-- Provides templates for debug output statements

return {
  {
    trigger = "dbg",
    name = "Debug Variable",
    description = "Insert elt_debug call to log a variable value using SFMT",
    body = 'CALL elt_debug(SFMT("${1:var_name} = %1", ${1:var_name}))',
  },
}
