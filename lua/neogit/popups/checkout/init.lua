local popup = require("neogit.lib.popup")
local actions = require("neogit.popups.checkout.actions")

local M = {}

function M.create(env)
  print(env.commit)
  local p = popup
    .builder()
    :name("NeogitCheckoutPopup")
    :group_heading("Checkout")
    -- :action("b", "branch", actions.branch)
    :action("c", "commit", actions.commit)
    :env(env)
    :build()

  p:show()

  return p
end

return M

