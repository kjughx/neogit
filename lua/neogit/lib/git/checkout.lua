local notification = require("neogit.lib.notification")
local git = require("neogit.lib.git")

---@class NeogitGitCheckout
local M = {}

local function fire_checkout_event(data)
  vim.api.nvim_exec_autocmds("User", { pattern = "NeogitCheckout", modeline = false, data = data })
end

function M.commit(commit)
  local result = git.cli.checkout.rev(commit).call { await = true }
  if result.code ~= 0 then
    notification.error("Checkout Failed")
  else
    fire_checkout_event { commit = commit, mode = "commit" }
  end
end

return M
