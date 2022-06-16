--- A visual divider that has no additional functionality
-- Inherits from the widget object.
-- @see widget
-- @module divider
local widget = require("gui.widget")

--- Defaults for the divider widget
-- @table button
local divider = {
  type = "divider", -- string, used for gui packing/unpacking (must match filename without extension!)
  selectable = false, -- bool, disable interaction with this widget.
  modifyWalls = true, -- bool, whether to modify the walls from the default
  top = false, -- bool, whether this divider is the top (requires modifyWalls)
  bottom = false, -- bool, whether this divider is the bottom (requires modifyWalls)
}
-- Setup inheritence
setmetatable(divider, widget)
divider.__index = divider

--- Draw the divider widget.
function divider:draw()
  self:clear()
  self:drawFrame()
  self:writeTextToLocalXY(self.value, 1, 1)
  if self.modifyWalls then
    if self.top then
      self:setFrameColor()
      self.device.setCursorPos(1, 1)
      self.device.write(string.char(156))
      self:setPreviousColor()
      self:setFrameColor(true)
      self.device.setCursorPos(self.size[1], 1)
      self.device.write(string.char(147))
      self:setPreviousColor()
    elseif self.bottom then
      self:setFrameColor()
      self.device.setCursorPos(1, 1)
      self.device.write(string.char(141))
      self.device.setCursorPos(self.size[1], 1)
      self.device.write(string.char(142))
      self:setPreviousColor()
    else
      self:setFrameColor()
      self.device.setCursorPos(1, 1)
      self.device.write(string.char(157))
      self:setPreviousColor()
      self:setFrameColor(true)
      self.device.setCursorPos(self.size[1], 1)
      self.device.write(string.char(145))
      self:setPreviousColor()
    end
  end
end

--- Function called to update the size of the widget.
-- @tparam int width
-- @tparam int height
function divider:updateSize(width, height)
  self.value = string.rep(string.char(140), width - 2)
  widget.updateSize(self, width, height)
end

--- Create a new divider widget.
-- @tparam table pos {x,y}
-- @tparam table size {width,height}
-- @tparam[opt] table p
-- @treturn table divider
function divider:new(pos, size, p)
  o = o or {}
  o = widget:new(o, pos, size, p)
  setmetatable(o, self)
  self.__index = self
  o.value = string.rep(string.char(140), o.size[1] - 2)
  o:_applyParameters(p)
  return o
end

return divider
