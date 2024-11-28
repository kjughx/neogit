local Ui = require("neogit.lib.ui")
local Component = require("neogit.lib.ui.component")
local util = require("neogit.lib.util")

local text = Ui.text
local row = Ui.row

local M = {}

---Parses output of `git remote -v` and splits elements into table
M.Remote = Component.new(function(remote)
  return row({
    text(remote.name),
    text(" -> "),
    text(remote.url),
  },{id = remote.url})
end)

---@param remotes RemoteInfo[]
---@return table
function M.View(remotes)
  return util.map(remotes, function(remote)
    return M.Remote(remote)
  end)
end

return M
