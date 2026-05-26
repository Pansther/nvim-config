local arrow_func_parents = {
  "function_declaration",
  "function_signature",
  "expression_statement",
  "variable_declaration",
  "lexical_declaration",
  "method_definition",
  "export_statement",
}

return {
  "danymat/neogen",
  opts = {
    languages = {
      typescript = {
        parent = { func = arrow_func_parents },
      },
      typescriptreact = {
        parent = { func = arrow_func_parents },
      },
    },
  },
}
