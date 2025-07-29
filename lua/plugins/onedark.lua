return {
  "navarasu/onedark.nvim",
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    require("onedark").setup({
      -- style = "darker",

      colors = {
        -- light_grey = "#ABB2BF",
        -- grey = "#282C34",
        red = "#E06C75",
        cyan = "#56B6C2",
        yellow = "#E5C07B",
        orange = "#C79D52",
        green = "#98C379", -- redefine an existing color
        blue = "#61AFEF",
        purple = "#C678DD",
      },
      highlights = {
        ["@tag"] = { fg = "$yellow" },
        ["@tag.attribute"] = { fg = "$orange" },
        -- TSTag = { fg = "$red" },
        -- TSInclude = { fg = "$red" },
        -- TSKeyword = { fg = "$red" },
        -- TSKeywordFunction = { fg = "$red" },
        -- TSKeywordOperator = { fg = "$red" },
        -- TSKeyword = { fg = "$green" },
        -- TSString = { fg = "$bright_orange", bg = "#00ff00", fmt = "bold" },
        -- TSFunction = { fg = "#0000ff", sp = "$cyan", fmt = "underline,italic" },
        -- TSFuncBuiltin = { fg = "#0059ff" },
      },
    })
    -- Enable theme
    require("onedark").load()
  end,
}
