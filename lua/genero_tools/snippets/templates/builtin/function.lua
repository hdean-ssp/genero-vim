-- Genero Function Definition Snippets
-- Provides templates for function definitions with various parameter and return type configurations

return {
  {
    trigger = "fn",
    name = "Function Definition",
    description = "Define a function with parameters and return type",
    body = [[
FUNCTION ${1:function_name}(${2:parameters})
  ${3:-- function body}
END FUNCTION
    ]],
  },
  {
    trigger = "fnr",
    name = "Function with Return Type",
    description = "Define a function with return type",
    body = [[
FUNCTION ${1:function_name}(${2:parameters}) RETURNS ${3:return_type}
  ${4:-- function body}
  RETURN ${5:value}
END FUNCTION
    ]],
  },
  {
    trigger = "fnv",
    name = "Function Returning Variable",
    description = "Define a function that returns a variable",
    body = [[
FUNCTION ${1:function_name}(${2:parameters}) RETURNS ${3:return_type}
  DEFINE ${4:result} ${3:return_type}
  ${5:-- function body}
  RETURN ${4:result}
END FUNCTION
    ]],
  },
  {
    trigger = "fnp",
    name = "Function with Parameters",
    description = "Define a function with typed parameters",
    body = [[
FUNCTION ${1:function_name}(${2:param1} ${3:type1}, ${4:param2} ${5:type2})
  ${6:-- function body}
END FUNCTION
    ]],
  },
}
