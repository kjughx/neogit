local git = require("neogit.lib.git")
local util = require("neogit.lib.util")
local notification = require("neogit.lib.notification")
local FuzzyFinderBuffer = require("neogit.buffers.fuzzy_finder")

local M = {}

---@param popup PopupData
---@param prompt string
---@return string|nil
local function target(popup, prompt)
  if popup.state.env.commit then
    return popup.state.env.commit
  end

  local commit = {}
  local refs = util.merge(commit, git.refs.list_branches(), git.refs.list_tags(), git.refs.heads())
  return FuzzyFinderBuffer.new(refs):open_async { prompt_prefix = prompt }
end

---@param popup PopupData
---@param prompt string
local function checkout(popup, prompt)
  local target = target(popup, prompt)
  if target then
    git.checkout.commit(target)
  end
end

---@param popup PopupData
function M.commit(popup)
  checkout(popup, ("Checkout %s"):format(git.branch.current()))
end

---@param popup PopupData
function M.branch(popup)
  local popups = require("neogit.popups")
  popups.open("branch", function(p)
    p(popup.state.env.branch)
  end)
end

---@param popup PopupData
function M.a_file(popup)
  local target = target(popup, "Checkout from revision")
  if not target then
    return
  end

  local files = util.deduplicate(util.merge(git.files.all(), git.files.diff(target)))
  if not files[1] then
    notification.info(("No files differ between HEAD and %s"):format(target))
    return
  end

  local files = FuzzyFinderBuffer.new(files):open_async { allow_multi = true }
  if not files[1] then
    return
  end

  git.reset.file(target, files)
end

return M
