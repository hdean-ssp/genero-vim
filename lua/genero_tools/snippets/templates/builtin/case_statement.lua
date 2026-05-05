-- Genero Case Statement Snippets
-- Provides templates for case/when statements with various configurations

return {
  {
    trigger = "case",
    name = "Case Statement",
    description = "Define a case statement with when branches",
    body = "CASE ${1:expression}\n\tWHEN ${2:value1}\n\t\t${3:-- case body}\n\tWHEN ${4:value2}\n\t\t${5:-- case body}\n\tOTHERWISE\n\t\t${6:-- default body}\nEND CASE",
  },
  {
    trigger = "casew",
    name = "Case with Single When",
    description = "Define a case statement with single when branch",
    body = "CASE ${1:expression}\n\tWHEN ${2:value}\n\t\t${3:-- case body}\n\tOTHERWISE\n\t\t${4:-- default body}\nEND CASE",
  },
  {
    trigger = "casem",
    name = "Case with Multiple Whens",
    description = "Define a case statement with multiple when branches",
    body = "CASE ${1:expression}\n\tWHEN ${2:value1}\n\t\t${3:-- case body}\n\tWHEN ${4:value2}\n\t\t${5:-- case body}\n\tWHEN ${6:value3}\n\t\t${7:-- case body}\n\tOTHERWISE\n\t\t${8:-- default body}\nEND CASE",
  },
}
