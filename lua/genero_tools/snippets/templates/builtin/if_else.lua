-- Genero Conditional Snippets
-- Provides templates for if/else and if/then/else conditional statements

return {
  {
    trigger = "if",
    name = "If Statement",
    description = "Define an if conditional statement",
    body = "IF ${1:condition} THEN\n\t${2:-- then body}\nEND IF",
  },
  {
    trigger = "ife",
    name = "If-Else Statement",
    description = "Define an if-else conditional statement",
    body = "IF ${1:condition} THEN\n\t${2:-- then body}\nELSE\n\t${3:-- else body}\nEND IF",
  },
  {
    trigger = "ifei",
    name = "If-Else If Statement",
    description = "Define an if-else if conditional statement",
    body = "IF ${1:condition1} THEN\n\t${2:-- then body}\nELSE IF ${3:condition2} THEN\n\t${4:-- else if body}\nELSE\n\t${5:-- else body}\nEND IF",
  },
  {
    trigger = "ifm",
    name = "If with Multiple Conditions",
    description = "Define an if statement with multiple conditions",
    body = "IF ${1:condition1} AND ${2:condition2} THEN\n\t${3:-- body}\nEND IF",
  },
}
