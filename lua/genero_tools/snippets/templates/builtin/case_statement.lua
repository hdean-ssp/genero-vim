-- Genero Case Statement Snippets
-- Provides templates for case/when statements with various configurations

return {
  {
    trigger = "case",
    name = "Case Statement",
    description = "Define a case statement with when branches",
    body = "CASE ${1:expression}\n  WHEN ${2:value1}\n    ${3:-- case body}\n  WHEN ${4:value2}\n    ${5:-- case body}\n  OTHERWISE\n    ${6:-- default body}\nEND CASE",
  },
  {
    trigger = "casew",
    name = "Case with Single When",
    description = "Define a case statement with single when branch",
    body = "CASE ${1:expression}\n  WHEN ${2:value}\n    ${3:-- case body}\n  OTHERWISE\n    ${4:-- default body}\nEND CASE",
  },
  {
    trigger = "casem",
    name = "Case with Multiple Whens",
    description = "Define a case statement with multiple when branches",
    body = "CASE ${1:expression}\n  WHEN ${2:value1}\n    ${3:-- case body}\n  WHEN ${4:value2}\n    ${5:-- case body}\n  WHEN ${6:value3}\n    ${7:-- case body}\n  OTHERWISE\n    ${8:-- default body}\nEND CASE",
  },
}
