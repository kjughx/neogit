local git = require("neogit.lib.git")
local runner = require("neogit.runner")
local process = require("neogit.process")
local json = require("neogit.json")


---@class Identity
---@field name string
---@field email string
---@field username string
local I

---@class GerritChange
---@field project string
---@field branch string
---@field id string
---@field number string
---@field subject string
---@field owner Identity
local C = {}

local M = {}

function M.get_gerrit_info()
  local url = git.remote.get_url("origin")[1]

  local protocol, host, port, project = url:match("([a-z]+)://(.*):(%d+)%/(.*)%.git")
  return {
    protocol = protocol,
    host = host,
    port = port,
    project = project
  }
end

function M.get_reviews()
  local gerrit = M.get_gerrit_info()
  local query = string.format("status:open project:%s", gerrit.project)
  local cmd = { "ssh", "-q", "-p", tostring(gerrit.port), gerrit.host, "gerrit", "query", "--current-patch-set",
    "--format", "json", query }
  local p = process.new({
    cmd = cmd,
    suppress_console = true,
    git_hook = false,
    user_command = false,
    on_error = function()
      return true
    end
  })

  local pr = runner.call(p, {await = true})

  local changes = {}
  for _, raw in ipairs(pr.stdout) do
    changes[#changes] = json.parse(tostring(raw))
  end
end

return M
