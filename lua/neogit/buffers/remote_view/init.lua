local Buffer = require("neogit.lib.buffer")
local status_maps = require("neogit.config").get_reversed_status_maps()

local util = require("neogit.lib.util")
local ui = require("neogit.buffers.remote_view.ui")
local git = require("neogit.lib.git")

---@class RemoteListBuffer
---@field remotes string[]
local M = {}
M.__index = M

--- Gets all current remotes
function M.new(remotes)
  remotes = util.map(remotes, function(name)
    return {
      name = name,
      url = git.remote.get_url(name)[1]
    }
  end)
  local instance = {
    remotes = remotes,
  }

  setmetatable(instance, M)
  return instance
end

function M:close()
  self.buffer:close()
  self.buffer = nil
end

--- Creates a buffer populated with output of `git remote -v`
function M:open()
  self.buffer = Buffer.create {
    name = "NeogitRemoteView",
    filetype = "NeogitRemoteView",
    header = "Remotes (" .. #self.remotes .. ")",
    scroll_header = true,
    kind = "tab",
    context_highlight = true,
    mappings = {
      v = {
        [status_maps["Close"]] = require("neogit.lib.ui.helpers").close_topmost(self),
      },
      n = {
        [status_maps["Close"]] = require("neogit.lib.ui.helpers").close_topmost(self),
      }
    },
    after = function()
      vim.cmd([[setlocal nowrap]])
    end,
    render = function()
      return ui.View(self.remotes)
    end,
  }
end

return M
