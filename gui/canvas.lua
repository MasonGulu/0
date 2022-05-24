--- A widget that provides an emulated bitmap section of the screen.
-- Inherits from the widget object.
-- @see widget
-- @module canvas

local widget = require("gui.widget")
local canvas = require("gui.canvasraw")
local canvaselement = widget:new(nil, { 1, 1 }, { 1, 1 })

function canvaselement:draw()
  self.canvas:render()
end

function canvaselement:setPixel(x, y, state, foreground, background)
  self.canvas:setPixel(x, y, state, foreground, background)
end

function canvaselement:updateSize(width, height)
  -- Intentionally do not update the size, it's unsupported
end

function canvaselement:clear()
  self.canvas:clear()
end

function canvaselement:updatePos(x, y)
  self.pos = { x, y }
  self.canvas.pos = self.pos
  self.canvas.x = x + 1
  self.canvas.y = y + 1
end

function canvaselement:new(o, pos, size, p)
  o = o or {}
  o = widget:new(o, pos, size, p)
  setmetatable(o, self)
  self.__index = self
  -- TODO implement this in all the prior widgets and stuff I made so they all call widget's new function first. so that widget can handle all the default/common parameters
  o.value = ""
  o.canvas = canvas:new(nil, o.device, { 2, 1 }, { o.size[1] - 2, o.size[2] })
  o:_applyParameters(p)
  return o
end

return canvaselement
