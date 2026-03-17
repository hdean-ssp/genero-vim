-- Genero Case Statement Snippets
-- Provides templates for case/when statements with various configurations

return {
  {
    trigger = "case",
    name = "Case Statement",
    description = "Define a case statement with when branches",
    body = [[
CASE ${1:expression}
  WHEN ${2:value1}
    ${3:-- case body}
  WHEN ${4:value2}
    ${5:-- case body}
  OTHERWISE
    ${6:-- default body}
END CASE
    ]],
  },
  {
    trigger = "casew",
    name = "Case with Single When",
    description = "Define a case statement with single when branch",
    body = [[
CASE ${1:expression}
  WHEN ${2:value}
    ${3:-- case body}
  OTHERWISE
    ${4:-- default body}
END CASE
    ]],
  },
  {
    trigger = "casem",
    name = "Case with Multiple Whens",
    description = "Define a case statement with multiple when branches",
    body = [[
CASE ${1:expression}
  WHEN ${2:value1}
    ${3:-- case body}
  WHEN ${4:value2}
    ${5:-- case body}
  WHEN ${6:value3}
    ${7:-- case body}
  OTHERWISE
    ${8:-- default body}
END CASE
    ]],
  },
}
