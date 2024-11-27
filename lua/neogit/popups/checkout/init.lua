local popup = require("neogit.lib.popup")
local actions = require("neogit.popups.checkout.actions")

local M = {}

function M.create(env)
  local p = popup
    .builder()
    :name("NeogitCheckoutPopup")
    :switch("o", "ours", "Check out stage #2 (ours) for unmerged paths", { incompatible = { "theirs", "merge" } })
    :switch("t", "theirs", "Check out stage #3 (theirs) for unmerged paths", { incompatible = { "ours","merge" } })
    :switch("m", "merge", "Try to merge local changes when switching branches",{ incompatible = { "ours", "theirs" } })
    :group_heading("Checkout")
    -- :action("b", "branch", actions.branch)
    :action("c", "commit", actions.commit)
    :action("f", "file", actions.a_file)
    :env(env)
    :build()

  p:show()

  return p
end

return M

