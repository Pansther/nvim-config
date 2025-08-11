return {
  -- LSP config สำหรับ Godot GDScript
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local lspconfig = require("lspconfig")
      lspconfig.gdscript.setup({
        name = "godot",
        cmd = { "ncat", "127.0.0.1", "6005" }, -- port LSP ของ Godot
        filetypes = { "gd", "gdscript" },
        root_dir = lspconfig.util.root_pattern("project.godot"),
      })
    end,
  },

  -- DAP + UI สำหรับ Godot
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dap.adapters.godot = {
        type = "server",
        host = "127.0.0.1",
        port = 6006,
      }

      dap.configurations.gdscript = {
        {
          type = "godot",
          request = "attach",
          name = "Attach to Godot",
          host = "127.0.0.1",
          port = 6006,
        },
      }

      dapui.setup()

      vim.keymap.set("n", "<F5>", dap.continue)
      vim.keymap.set("n", "<F9>", dap.toggle_breakpoint)
      vim.keymap.set("n", "<F10>", dap.step_over)
      vim.keymap.set("n", "<F11>", dap.step_into)
      vim.keymap.set("n", "<F12>", dap.step_out)

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  -- เริ่ม server nvim อัตโนมัติ สำหรับ nvr เชื่อมกับ Godot
  {
    "ojroques/nvim-osc52",
    config = function()
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if vim.fn.has("unix") == 1 then
            local server = "/tmp/nvim-godot.sock"
            if vim.fn.filereadable(server) == 0 then
              vim.fn.serverstart(server)
            end
          end
        end,
      })
    end,
  },
}
