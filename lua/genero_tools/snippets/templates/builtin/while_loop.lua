-- Genero While Loop Snippets
-- Provides templates for while loop statements with various configurations

return {
  {
    trigger = "while",
    name = "While Loop",
    description = "Define a while loop with condition",
    body = "WHILE ${1:condition}\n\t${2:-- loop body}\nEND WHILE",
  },
  {
    trigger = "whilec",
    name = "While Loop with Counter",
    description = "Define a while loop with counter variable",
    body = "DEFINE ${1:counter} INT\nLET ${1:counter} = ${2:start}\nWHILE ${1:counter} <= ${3:end}\n\t${4:-- loop body}\n\tLET ${1:counter} = ${1:counter} + 1\nEND WHILE",
  },
  {
    trigger = "whilet",
    name = "While True Loop",
    description = "Define a while true loop with break condition",
    body = "WHILE TRUE\n\t${1:-- loop body}\n\tIF ${2:break_condition} THEN\n\t\tEXIT WHILE\n\tEND IF\nEND WHILE",
  },
}
