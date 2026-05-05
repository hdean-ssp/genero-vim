-- Genero Function Definition Snippets
-- Provides templates for function definitions with various parameter and return type configurations

return {
  {
    trigger = "fn",
    name = "Function Definition",
    description = "Define a function with comment header, parameters and return type",
    body = "#\n# Function ${1:function_name}\n# -------------------\n# Parameters    :   ${2:param_name}        ${3:TYPE}\n#\n# Returns       :   ${4:return_value}      ${5:TYPE}\n#\n# Description of the function\n#   ${6:Description}\n#\nFUNCTION ${1:function_name}(${7:parameters})\n  DEFINE ${7:parameters}\n  \n  ${8:-- function body}\n  \n  RETURN ${4:return_value}\nEND FUNCTION { ${1:function_name} }",
  },
  {
    trigger = "fnr",
    name = "Function with Return Type",
    description = "Define a function with return type and comment header",
    body = "#\n# Function ${1:function_name}\n# -------------------\n# Parameters    :   ${2:param_name}        ${3:TYPE}\n#\n# Returns       :   ${4:return_value}      ${5:return_type}\n#\n# Description of the function\n#   ${6:Description}\n#\nFUNCTION ${1:function_name}(${7:parameters}) RETURNS ${5:return_type}\n  DEFINE ${7:parameters}\n  DEFINE ${4:return_value} ${5:return_type}\n  \n  ${8:-- function body}\n  \n  RETURN ${4:return_value}\nEND FUNCTION { ${1:function_name} }",
  },
  {
    trigger = "fnv",
    name = "Function Returning Variable",
    description = "Define a function that returns a variable with comment header",
    body = "#\n# Function ${1:function_name}\n# -------------------\n# Parameters    :   ${2:param_name}        ${3:TYPE}\n#\n# Returns       :   ${4:result}            ${5:return_type}\n#\n# Description of the function\n#   ${6:Description}\n#\nFUNCTION ${1:function_name}(${7:parameters}) RETURNS ${5:return_type}\n  DEFINE ${7:parameters}\n  DEFINE ${4:result} ${5:return_type}\n  \n  ${8:-- function body}\n  \n  RETURN ${4:result}\nEND FUNCTION { ${1:function_name} }",
  },
  {
    trigger = "fns",
    name = "Simple Function",
    description = "Define a simple function without comment header",
    body = "FUNCTION ${1:function_name}(${2:parameters})\n  DEFINE ${2:parameters}\n  \n  ${3:-- function body}\n  \nEND FUNCTION { ${1:function_name} }",
  },
}
