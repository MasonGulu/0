--- A visual divider that has no additional functionality
-- Inherits from the widget object.
-- @see widget
-- @module divider
local widget = require("ccsg.widget")

-- TODO
-- redo this whole widget concept

--- Defaults for the divider widget
-- @table divider
local divider = {
  type = "divider", -- string, used for gui packing/unpacking (must match filename without extension!)
  selectable = false, -- bool, disable interaction with this widget.
  top = false, -- bool, whether this divider is the top (requires modifyWalls)
  bottom = false, -- bool, whether this divider is the bottom (requires modifyWalls)
  VERSION = "3.0",
}
-- Setup inheritence
setmetatable(divider, widget)
divider.__index = divider

--- Draw the divider widget.
function divider:draw()
  self:clear()
  self.window.setCursorPos(1,1)
  -- self:setFrameColor()
  self.window.write(self.value)
  -- self:setPreviousColor()
end

--- Function called to update the size of the widget.
-- @tparam int width
-- @tparam int height
function divider:updateSize(width, height)
  self.value = string.rep(string.char(140), width)
  widget.updateSize(self, width, height)
end

--- Create a new divider widget.
-- @tparam table pos {x,y}
-- @tparam table size {width,height}
-- @tparam[opt] table p
-- @treturn table divider
function divider.new(pos, size, p)
  local o = widget.new(nil, pos, size, p)
  setmetatable(o, divider)
  o.value = string.rep(string.char(140), o.size[1])
  o:_applyParameters(p)
  return o
end

return divider
