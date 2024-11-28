local M = {}

local git = require("neogit.lib.git")
local input = require("neogit.lib.input")
local notification = require("neogit.lib.notification")
local util = require("neogit.lib.util")

local RemoteListBuffer = require("neogit.buffers.remote_view")
local FuzzyFinderBuffer = require("neogit.buffers.fuzzy_finder")
local RemoteConfigPopup = require("neogit.popups.remote_config")

local function ask_to_set_pushDefault()
  local repo_config = git.config.get("neogit.askSetPushDefault")
  local current_value = git.config.get("remote.pushDefault")

  if current_value:is_unset() and (repo_config:is_unset() or repo_config:read() == "ask-if-unset") then
    return true
  elseif repo_config:read() == "ask" then
    return true
  else
    return false
  end
end

function M.add(popup)
  local name = input.get_user_input("Add remote")
  if not name then
    return
  end

  local origin = git.config.get("remote.origin.url"):read()
  if not origin then
    return
  end

  assert(type(origin) == "string", "remote.origin.url isn't a string")
  local host, _, remote = origin:match("([^:/]+)[:/]([^/]+)/(.+)")
  remote = remote and remote:gsub("%.git$", "")

  local msg
  if host and remote then
    msg = string.format("%s:%s/%s.git", host, name, remote)
  end

  local remote_url = input.get_user_input("URL for " .. name, { default = msg })
  if not remote_url then
    return
  end

  local success = git.remote.add(name, remote_url, popup:get_arguments())
  if success then
    local set_default = ask_to_set_pushDefault()
      and input.get_permission([[Set 'remote.pushDefault' to "]] .. name .. [["?]])

    if set_default then
      git.config.set("remote.pushDefault", name)
      notification.info("Added remote " .. name .. " and set as remote.pushDefault")
    else
      notification.info("Added remote " .. name)
    end
  end
end

function M.rename(_)
  local selected_remote = FuzzyFinderBuffer.new(git.remote.list())
    :open_async { prompt_prefix = "Rename remote" }
  if not selected_remote then
    return
  end

  local new_name = input.get_user_input("Rename '" .. selected_remote .. "' to")
  if not new_name then
    return
  end

  local success = git.remote.rename(selected_remote, new_name)
  if success then
    notification.info("Renamed '" .. selected_remote .. "' -> '" .. new_name .. "'")
  end
end

function M.remove(_)
  local selected_remote = FuzzyFinderBuffer.new(git.remote.list()):open_async()
  if not selected_remote then
    return
  end

  local success = git.remote.remove(selected_remote)
  if success then
    notification.info("Removed remote '" .. selected_remote .. "'")
  end
end

function M.list(_)
  RemoteListBuffer.new(git.remote.list()):open()
end

function M.configure(_)
  local remote_name = FuzzyFinderBuffer.new(git.remote.list()):open_async()
  if not remote_name then
    return
  end

  RemoteConfigPopup.create(remote_name)
end

function M.prune_branches(_)
  local selected_remote = FuzzyFinderBuffer.new(git.remote.list()):open_async()
  if not selected_remote then
    return
  end

  notification.info("Pruning remote " .. selected_remote)
  git.remote.prune(selected_remote)
end

-- https://github.com/magit/magit/blob/main/lisp/magit-remote.el#L159
-- All of something's refspecs are stale.  replace with [d]efault refspec, [r]emove remote, or [a]abort
-- function M.prune_refspecs()
-- end

-- https://github.com/magit/magit/blob/430a52c4b3f403ba8b0f97b4b67b868298dd60f3/lisp/magit-remote.el#L259
-- function M.update_default_branch()
-- end

-- https://github.com/magit/magit/blob/430a52c4b3f403ba8b0f97b4b67b868298dd60f3/lisp/magit-remote.el#L291
-- function M.unshallow_remote()
-- end

return M
