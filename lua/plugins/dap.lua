return {
  "rcarriga/nvim-dap-ui",
  dependencies = {
    "mfussenegger/nvim-dap",
    "nvim-neotest/nvim-nio",
    { "theHamsta/nvim-dap-virtual-text", opts = {} }
  },
  event = "VeryLazy",
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")
    
    dapui.setup()

    -- Get project root (using git or fallback to cwd)
    local function get_project_root()
      local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
      if git_root and git_root ~= "" then
        return git_root
      end
      return vim.fn.getcwd()
    end

    -- Get session cache file path for current project
    local function get_cache_file_path()
      local project_root = get_project_root()
      local cache_dir = vim.fn.stdpath("data") .. "/dap-sessions"
      if vim.fn.isdirectory(cache_dir) == 0 then
        vim.fn.mkdir(cache_dir, "p")
      end
      local safe_name = project_root:gsub("[^%w%-_]", "_"):gsub("__+", "_"):gsub("^_", ""):gsub("_$", "")
      return cache_dir .. "/" .. safe_name .. ".json"
    end

    local function load_cached_session()
      local cache_file = get_cache_file_path()
      if vim.fn.filereadable(cache_file) == 1 then
        local ok, data = pcall(vim.fn.json_decode, vim.fn.readfile(cache_file))
        if ok and data and data.program and data.cwd then
          return data
        end
      end
      return { program = nil, cwd = nil }
    end

    local function save_cached_session(program, cwd)
      local cache_file = get_cache_file_path()
      local data = {
        program = program,
        cwd = cwd,
        project_root = get_project_root(),
        timestamp = os.time()
      }
      vim.fn.writefile({ vim.fn.json_encode(data) }, cache_file)
    end

    local current_session = load_cached_session()

    local function kill_codelldb_processes()
      if vim.fn.has("win32") == 1 then
        vim.fn.jobstart("taskkill /f /im codelldb.exe", { detach = true })
      else
        vim.fn.jobstart("pkill -f codelldb", { detach = true })
      end
    end

    dap.adapters.codelldb = {
      type = "server",
      port = "${port}",
      executable = {
        command = "codelldb",
        args = { "--port", "${port}" },
        detached = false,
      },
    }

    dap.configurations.cpp = {
      {
        name = "Launch",
        type = "codelldb",
        request = "launch",
        program = function()
          if current_session.program and current_session.program ~= "" then
            return current_session.program
          end
          
          local input = vim.fn.input(
            "Path to executable: ",
            vim.fn.getcwd() .. "/",
            "file"
          )

          if input == "" then
            error("Canceled")
          end

          current_session.program = input
          save_cached_session(current_session.program, current_session.cwd)
          return current_session.program
        end,
        cwd = function()
          if current_session.cwd and current_session.cwd ~= "" then
            return current_session.cwd
          end
          
          local input = vim.fn.input(
            "Path to working directory: ",
            vim.fn.getcwd() .. "/",
            "dir"
          )

          if input == "" then
            error("Canceled")
          end

          current_session.cwd = input
          save_cached_session(current_session.program, current_session.cwd)
          return current_session.cwd
        end,
        stopOnEntry = false,
      },
    }

    -- Clear existing listeners
    dap.listeners.after.event_initialized["dapui_config"] = nil
    dap.listeners.after.event_terminated["dapui_config"] = nil
    dap.listeners.after.event_exited["dapui_config"] = nil
    
    -- Add proper event handlers
    dap.listeners.after.event_initialized["dapui_config"] = function()
      vim.schedule(function()
        pcall(function()
          dapui.open({ reset = true })
        end)
      end)
    end

    dap.listeners.after.event_terminated["dapui_config"] = function()
      vim.schedule(function()
        pcall(function()
          dapui.close()
          kill_codelldb_processes()
        end)
      end)
    end
    
    dap.listeners.after.event_exited["dapui_config"] = function()
      vim.schedule(function()
        pcall(function()
          dapui.close()
          kill_codelldb_processes()
        end)
      end)
    end

    -- Manual cache management keymaps
    vim.keymap.set("n", "<leader>Dc", function()
      -- Clear cache for current project
      local cache_file = get_cache_file_path()
      if vim.fn.filereadable(cache_file) == 1 then
        vim.fn.delete(cache_file)
      end
      current_session = { program = nil, cwd = nil }
      print("Cleared DAP session cache for this project")
    end)

    vim.keymap.set("n", "<leader>Ds", function()
      -- Show current cached values
      if current_session.program or current_session.cwd then
        print(string.format("Cached: program=%s, cwd=%s", 
          current_session.program or "not set", 
          current_session.cwd or "not set"))
      else
        print("No cached session for this project")
      end
    end)

    vim.keymap.set("n", "<F5>", function()
      require("dap").continue()
    end)
    
    -- Hard reset (clears cache)
    vim.keymap.set("n", "<leader>D", function()
      if dap.session() then
        pcall(dap.terminate)
      end
      dapui.close()
      kill_codelldb_processes()
      -- Clear the cache file
      local cache_file = get_cache_file_path()
      if vim.fn.filereadable(cache_file) == 1 then
        vim.fn.delete(cache_file)
      end
      current_session = { program = nil, cwd = nil }
      vim.defer_fn(function()
        require("dap").continue()
      end, 200)
    end)

    -- Clean disconnect
    vim.keymap.set("n", "<leader>dq", function()
      local session = dap.session()
      if session then
        pcall(function()
          dapui.close()
          dap.terminate()
        end)
      else
        pcall(dapui.close)
        print("No active debug session")
      end
    end)

    -- Standard keymaps
    vim.keymap.set("n", "<F10>", function()
      require("dap").step_over()
    end)
    vim.keymap.set("n", "<F11>", function()
      require("dap").step_into()
    end)
    vim.keymap.set("n", "<F12>", function()
      require("dap").step_out()
    end)
    
    -- Restart
    vim.keymap.set("n", "<leader>dr", function()
      local session = dap.session()
      if session then
        pcall(function()
          dapui.close()
          dap.restart()
        end)
      else
        require("dap").continue()
      end
    end)

    vim.keymap.set("n", "<leader>db", function()
      require("dap").toggle_breakpoint()
    end)
    vim.keymap.set("n", "<leader>dB", function()
      require("dap").set_breakpoint()
    end)

    vim.keymap.set("n", "<leader>dor", function()
      require("dap").repl.open()
    end)
    vim.keymap.set("n", "<leader>drl", function()
      require("dap").run_last()
    end)

    vim.keymap.set({ "n", "v" }, "<leader>dh", function()
      require("dap.ui.widgets").hover()
    end)
    vim.keymap.set({ "n", "v" }, "<leader>dp", function()
      require("dap.ui.widgets").preview()
    end)
    vim.keymap.set("n", "<leader>df", function()
      local widgets = require("dap.ui.widgets")
      widgets.centered_float(widgets.frames)
    end)
    vim.keymap.set("n", "<leader>ds", function()
      local widgets = require("dap.ui.widgets")
      widgets.centered_float(widgets.scopes)
    end)
  end,
}
