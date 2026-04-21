return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300

    local wk = require("which-key")
    local harpoon = require("harpoon")

    wk.register({
      -- Fzf lua related
      ["<leader>ff"] = { "<cmd>FzfLua files<cr>", "Find a File" },
      ["<leader>fg"] = { "<cmd>FzfLua live_grep<cr>", "Parse files by keywords" },
      ["<leader>fk"] = { "<cmd>FzfLua keymaps<cr>", "Inspect keymaps" },
      ["<leader>fb"] = { "<cmd>FzfLua buffers<cr>", "List open buffers" },

      -- LSP related (lspconfig, mason, mason-lspconfig & etc)
      ["<space>e"] = { vim.diagnostic.open_float, "Open diagnostics float" },
      ["]d"] = { vim.diagnostic.goto_next, "Go to the next diagnostic" },
      ["[d"] = { vim.diagnostic.goto_prev, "Go to the prev diagnostic" },
      ["<space>q"] = { vim.diagnostic.setloclsit, "What does this to? (to be replaced)" },

      -- lspsaga related
      ["<leader>ca"] = { "<CMD>Lspsaga code_action<CR>", "Lspsaga's code actions" },
      ["<leader>gd"] = { "<CMD>Lspsaga peek_definition<CR>", "Peek symbol's definition" },
      ["<leader>gD"] = { "<CMD>Lspsaga goto_definition<CR>", "Goto symbol's definition" },
      ["<leader>fd"] = { "<CMD>Lspsaga finder<CR>", "Find symbol's definition in current buffer" },
      ["<leader>rn"] = { "<CMD>Lspsaga rename<CR>", "Rename all occurrences for the current symbol" },
      ["<leader>D"] = { "<CMD>Lspsaga show_line_diagnostics<CR>", "Show diagnostic for the current line" },
      ["<leader>d"] = {
        "<CMD>Lspsaga show_cursor_diagnostics<CR>",
        "Show diagnostics for the symbol under the cursor",
      },
      ["<leader>nd"] = { "<CMD>Lspsaga diagnostic_jump_next<CR>", "Jump to next diagnostic in current buffer" },
      ["<leader>pd"] = {
        "<CMD>Lspsaga diagnostic_jump_prev<CR>",
        "Jump to previous diagnostic in current buffer",
      },
      ["K"] = { "<CMD>Lspsaga hover_doc<CR>", "Show documentation for the symbol under the cursor" },

      -- indentation related
      [">"] = { ">gv", "Shift indentation to the right" },
      ["<"] = { "<gv", "Shift indentation to the left" },

      -- search highlight
      ["<esc>"] = { "<CMD>noh<CR>", "Turns off search highlighting" },

      -- lazygit related
      ["<leader>lg"] = { "<CMD>LazyGit<CR>", "Launch LazyGit" },

      -- undotree related
      ["<leader><F5>"] = { "<CMD>UndotreeToggle<CR>", "Toggle Undotree" },

      -- Navbuddy related
      ["<leader>b"] = { "<CMD>Navbuddy<CR>", "Open up navbuddy" },

      -- LSP buffer formatting
      ["<space>f"] = { function() vim.lsp.buf.format({ async = true }) end, "Format current buffer" },

      -- Harpoon related
      ["<leader>a"] = { function() harpoon:list():add() end, "Add current buffer to harpoon" },
      ["<C-e>"] = { function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, "Show harpoon's buffer list" },
      ["<leader>pp"] = { function() harpoon:list():prev() end, "Navigate to next buffer in harpoon" },
      ["<leader>nn"] = { function() harpoon:list():next() end, "Navigate to prev buffer in harpoon" },
    })
  end,
}
