-- Genero Function Definition Snippets
-- Provides templates for function definitions with various parameter and return type configurations

return {
  {
    trigger = "fn",
    name = "Function Definition",
    description = "Define a function with parameters and return type",
    body = "FUNCTION ${1:function_name}(${2:parameters})\n  ${3:-- function body}\nEND FUNCTION",
  },
  {
    trigger = "fnr",
    name = "Function with Return Type",
    description = "Define a function with return type",
    body = "FUNCTION ${1:function_name}(${2:parameters}) RETURNS ${3:return_type}\n  ${4:-- function body}\n  RETURN ${5:value}\nEND FUNCTION",
  },
  {
    trigger = "fnv",
    name = "Function Returning Variable",
    description = "Define a function that returns a variable",
    body = "FUNCTION ${1:function_name}(${2:parameters}) RETURNS ${3:return_type}\n  DEFINE ${4:result} ${3:return_type}\n  ${5:-- function body}\n  RETURN ${4:result}\nEND FUNCTION",
  },
  {
    trigger = "fnp",
    name = "Function with Parameters",
    description = "Define a function with typed parameters",
    body = "FUNCTION ${1:function_name}(${2:param1} ${3:type1}, ${4:param2} ${5:type2})\n  ${6:-- function body}\nEND FUNCTION",
  },
}
