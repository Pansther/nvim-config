return {
  "Root-lee/screensaver.nvim",
  config = function()
    require("screensaver").setup({
      idle_ms = 60 * 5 * 1000, -- Idle time in milliseconds (1 minute)
    })
  end,
}
