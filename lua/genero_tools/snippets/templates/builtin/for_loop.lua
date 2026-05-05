-- Genero For Loop Snippets
-- Provides templates for for loop statements with various configurations

return {
  {
    trigger = "for",
    name = "For Loop",
    description = "Define a for loop with start and end values",
    body = "FOR ${1:i} = ${2:start} TO ${3:end}\n  ${4:-- loop body}\nEND FOR",
  },
  {
    trigger = "fors",
    name = "For Loop with Step",
    description = "Define a for loop with step increment",
    body = "FOR ${1:i} = ${2:start} TO ${3:end} STEP ${4:step}\n  ${5:-- loop body}\nEND FOR",
  },
  {
    trigger = "ford",
    name = "For Loop Descending",
    description = "Define a for loop counting down",
    body = "FOR ${1:i} = ${2:start} TO ${3:end} STEP -1\n  ${4:-- loop body}\nEND FOR",
  },
  {
    trigger = "fore",
    name = "For Each Loop",
    description = "Define a for each loop over array",
    body = "FOR ${1:item} IN ${2:array}\n  ${3:-- loop body}\nEND FOR",
  },
}
