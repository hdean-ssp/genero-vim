-- Genero Array Declaration Snippets
-- Provides templates for array declarations with various configurations

return {
  {
    trigger = "arr",
    name = "Array Declaration",
    description = "Declare an array with element type and size",
    body = "DEFINE ${1:array_name} ARRAY[${2:size}] OF ${3:element_type}",
  },
  {
    trigger = "arrd",
    name = "Dynamic Array",
    description = "Declare a dynamic array without fixed size",
    body = "DEFINE ${1:array_name} DYNAMIC ARRAY OF ${2:element_type}",
  },
  {
    trigger = "arri",
    name = "Array of Integers",
    description = "Declare an array of integers",
    body = "DEFINE ${1:array_name} ARRAY[${2:size}] OF INT",
  },
  {
    trigger = "arrs",
    name = "Array of Strings",
    description = "Declare an array of strings",
    body = "DEFINE ${1:array_name} ARRAY[${2:size}] OF STRING",
  },
  {
    trigger = "arrr",
    name = "Array of Records",
    description = "Declare an array of record types",
    body = "DEFINE ${1:array_name} ARRAY[${2:size}] OF ${3:record_type}",
  },
  {
    trigger = "arrm",
    name = "Multidimensional Array",
    description = "Declare a multidimensional array",
    body = "DEFINE ${1:array_name} ARRAY[${2:rows}][${3:cols}] OF ${4:element_type}",
  },
}
