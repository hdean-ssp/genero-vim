-- Genero Conditional Snippets
-- Provides templates for if/else and if/then/else conditional statements

return {
  {
    trigger = "if",
    name = "If Statement",
    description = "Define an if conditional statement",
    body = [[
IF ${1:condition} THEN
  ${2:-- then body}
END IF
    ]],
  },
  {
    trigger = "ife",
    name = "If-Else Statement",
    description = "Define an if-else conditional statement",
    body = [[
IF ${1:condition} THEN
  ${2:-- then body}
ELSE
  ${3:-- else body}
END IF
    ]],
  },
  {
    trigger = "ifei",
    name = "If-Else If Statement",
    description = "Define an if-else if conditional statement",
    body = [[
IF ${1:condition1} THEN
  ${2:-- then body}
ELSE IF ${3:condition2} THEN
  ${4:-- else if body}
ELSE
  ${5:-- else body}
END IF
    ]],
  },
  {
    trigger = "ifm",
    name = "If with Multiple Conditions",
    description = "Define an if statement with multiple conditions",
    body = [[
IF ${1:condition1} AND ${2:condition2} THEN
  ${3:-- body}
END IF
    ]],
  },
}
