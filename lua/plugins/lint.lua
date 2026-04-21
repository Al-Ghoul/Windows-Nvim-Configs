return {
  "mfussenegger/nvim-lint",
  event = "VeryLazy",
  config = function()
    local lint = require("lint")
    lint.linters_by_ft = {
      cpp = { "cpplint" },
    }

    local lint_group = vim.api.nvim_create_augroup("ivim_lint", { clear = true })

    vim.api.nvim_create_autocmd("BufWritePost", {
      group = lint_group,
      callback = function(args)
        if vim.bo[args.buf].buftype ~= "" then
          return
        end

        local filetype = vim.bo[args.buf].filetype
        local linters = lint.linters_by_ft[filetype]

        if not linters or vim.tbl_isempty(linters) then
          return
        end

        lint.try_lint()
      end,

    })
  end
}
