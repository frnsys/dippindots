return {
  --- sudo apt install lldb
  ---
  --- With Mason install:
  --- - codelldb
  --- - debugpy
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
    },
    keys = {
      {
        '<leader>db',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = 'Toggle breakpoint'
      },
      {
        '<leader>dc',
        function()
          require('dap').continue()
        end,
        desc = 'Continue'
      },
      {
        '<leader>ds',
        function()
          require('dap').step_over()
        end,
        desc = 'Step over'
      },
      {
        '<leader>di',
        function()
          require('dap').step_into()
        end,
        desc = 'Step into'
      },
      {
        '<leader>do',
        function()
          require('dap').step_out()
        end,
        desc = 'Step out'
      }
    },
    config = function()
      local dap = require('dap')
      local mason_registry = require("mason-registry")

      local codelldb = mason_registry.get_package("codelldb")
      local codelldb_path = codelldb:get_install_path() .. "/extension/adapter/codelldb"
      dap.adapters.codelldb = {
        type = 'server',
        port = '13000',
        executable = {
          command = codelldb_path,
          args = { '--port', '13000' },
        },
      }

      local debugpy = mason_registry.get_package("debugpy")
      local debugpy_path = debugpy:get_install_path() .. "/debugpy-adapter"
      dap.adapters.python = {
        type = 'executable',
        command = debugpy_path
      }

      local get_program = function()
        return vim.fn.input('program: ', vim.loop.cwd() .. '/' .. vim.fn.expand('%f'), 'file')
      end
      local get_args = function()
        return vim.split(vim.fn.input('args: ', '', 'file'), ' ')
      end

      dap.configurations.python = {
        {
          type = 'python',
          request = 'launch',
          cwd = '${workspaceFolder}',
          pythonPath = "/home/ftseng/.pyenv/shims/python",
          program = get_program,
          args = get_args
        }
      }

      dap.configurations.rust = {
        {
          type = "codelldb",
          request = "launch",
          program = function()
            local crate_name = vim.trim(vim.fn.system('cargo read-manifest | jq -r .name'))
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/' .. crate_name, 'file')
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        }
      }

      require("nvim-dap-virtual-text").setup();

      --- Auto-open/close DAP UI
      local dapui = require('dapui')
      dapui.setup({
        controls = {
          enabled = false,
        },
        layouts = { {
          elements = { {
            id = "scopes",
            size = 0.33
          }, {
            id = "breakpoints",
            size = 0.33
          }, {
            id = "stacks",
            size = 0.33
          } },
          position = "bottom",
          size = 10
        } },
      })
      dap.listeners.after.event_initialized["dap_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dap_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dap_config"] = function()
        dapui.close()
      end
    end
  },
}
