-- Genero Record Definition Snippets
-- Provides templates for record type definitions with various field configurations

return {
  {
    trigger = "rec",
    name = "Record Definition",
    description = "Define a record type with fields",
    body = [[
TYPE ${1:record_name}
  ${2:field1} ${3:type1},
  ${4:field2} ${5:type2}
END RECORD
    ]],
  },
  {
    trigger = "recf",
    name = "Record with Single Field",
    description = "Define a record type with single field",
    body = [[
TYPE ${1:record_name}
  ${2:field_name} ${3:field_type}
END RECORD
    ]],
  },
  {
    trigger = "recm",
    name = "Record with Multiple Fields",
    description = "Define a record type with multiple fields",
    body = [[
TYPE ${1:record_name}
  ${2:field1} ${3:type1},
  ${4:field2} ${5:type2},
  ${6:field3} ${7:type3},
  ${8:field4} ${9:type4}
END RECORD
    ]],
  },
  {
    trigger = "recn",
    name = "Record with Nested Record",
    description = "Define a record type with nested record field",
    body = [[
TYPE ${1:record_name}
  ${2:field1} ${3:type1},
  ${4:nested_record} RECORD
    ${5:nested_field1} ${6:nested_type1},
    ${7:nested_field2} ${8:nested_type2}
  END RECORD
END RECORD
    ]],
  },
}
