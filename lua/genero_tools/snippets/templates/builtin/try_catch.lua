-- Genero Error Handling Snippets
-- Provides templates for try/catch error handling blocks

return {
  {
    trigger = "try",
    name = "Try-Catch Block",
    description = "Define a try-catch error handling block",
    body = "TRY\n\t${1:-- try body}\nCATCH\n\t${2:-- catch body}\nEND TRY",
  },
  {
    trigger = "trye",
    name = "Try-Catch with Error Variable",
    description = "Define a try-catch block with error variable",
    body = "TRY\n\t${1:-- try body}\nCATCH\n\tDEFINE ${2:error_msg} STRING\n\tLET ${2:error_msg} = SQLCA.SQLERRM\n\t${3:-- error handling}\nEND TRY",
  },
  {
    trigger = "tryf",
    name = "Try-Catch-Finally",
    description = "Define a try-catch-finally error handling block",
    body = "TRY\n\t${1:-- try body}\nCATCH\n\t${2:-- catch body}\nFINALLY\n\t${3:-- finally body}\nEND TRY",
  },
  {
    trigger = "trys",
    name = "Try with Status Check",
    description = "Define a try block with status checking",
    body = "TRY\n\t${1:-- try body}\n\tIF SQLCA.SQLCODE != 0 THEN\n\t\tRAISE EXCEPTION ${2:error_code}, ${3:error_message}\n\tEND IF\nCATCH\n\t${4:-- catch body}\nEND TRY",
  },
}
