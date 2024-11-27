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

function M.file(commit, files)
  local result = git.cli.checkout.rev(commit).files(unpack(files)).call { await = true }
  if result.code ~= 0 then
    notification.error("Reset Failed")
  else
    fire_checkout_event { commit = commit, mode = "files" }
    if #files > 1 then
      notification.info("Checkout " .. #files .. " files")
    else
      notification.info("Checkout " .. files[1])
    end
  end
end

return M
