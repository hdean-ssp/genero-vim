-- Genero Error Handling Snippets
-- Provides templates for try/catch error handling blocks

return {
  {
    trigger = "try",
    name = "Try-Catch Block",
    description = "Define a try-catch error handling block",
    body = [[
TRY
  ${1:-- try body}
CATCH
  ${2:-- catch body}
END TRY
    ]],
  },
  {
    trigger = "trye",
    name = "Try-Catch with Error Variable",
    description = "Define a try-catch block with error variable",
    body = [[
TRY
  ${1:-- try body}
CATCH
  DEFINE ${2:error_msg} STRING
  LET ${2:error_msg} = SQLCA.SQLERRM
  ${3:-- error handling}
END TRY
    ]],
  },
  {
    trigger = "tryf",
    name = "Try-Catch-Finally",
    description = "Define a try-catch-finally error handling block",
    body = [[
TRY
  ${1:-- try body}
CATCH
  ${2:-- catch body}
FINALLY
  ${3:-- finally body}
END TRY
    ]],
  },
  {
    trigger = "trys",
    name = "Try with Status Check",
    description = "Define a try block with status checking",
    body = [[
TRY
  ${1:-- try body}
  IF SQLCA.SQLCODE != 0 THEN
    RAISE EXCEPTION ${2:error_code}, ${3:error_message}
  END IF
CATCH
  ${4:-- catch body}
END TRY
    ]],
  },
}
