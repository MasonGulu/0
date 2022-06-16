--- A simple button widget.
-- Inherits from the widget object.
-- @see widget
-- @module button
local widget = require("gui.widget")

--- Defaults for the button widget
-- @table button
local button = {
  type = "button", -- string, used for gui packing/unpacking (must match filename without extension!)
  enable_events = true, -- bool, events are enabled by default for buttons
  theme = {
    internalInvert = true -- bool, invert internal colors
  }
}
-- Setup inheritence
setmetatable(button, widget)
button.__index = button
setmetatable(button.theme, widget.theme) -- This is necessary because we modified the default theme table

--- Draw the button widget.
function button:draw()
  self:clear()
  self:drawFrame()
  local preppedString = self.value:sub(1, self.size[1] - 2)
  self:writeTextToLocalXY(preppedString, 1, 1)
end

--- Handle mouse_click events
-- @tparam number mouseButton
-- @tparam number mouseX
-- @tparam number mouseY
-- @treturn boolean mouseclick is on button and enable_events
function button:handleMouseClick(mouseButton, mouseX, mouseY)
  local x, y = self:convertGlobalXYToLocalXY(mouseX, mouseY)
  if y > 0 and y < self.size[2] + 1 and x > 0 and x < self.size[1] - 1 then
    return self.enable_events
  end
  return false
end

--- Handle key events
-- @tparam int keycode
-- @tparam bool held
-- @treturn bool enter is pressed and enable_events
function button:handleKey(keycode, held)
  if keycode == keys.enter then
    -- enter
    return self.enable_events
  end
  return false
end

--- Update string or parameters
-- @tparam string string single line string to display
-- @tparam[opt] table p
function widget:updateParameters(string, p)
  self.value = string
  self:_applyParameters(p)
end

--- Create a new button widget.
-- @tparam table pos {x,y}
-- @tparam table size {width,height}
-- @tparam string string single line string to display
-- @tparam[opt] table p
-- @treturn table button
function button:new(pos, size, string, p)
  o = o or {}
  o = widget:new(o, pos, size, p)
  setmetatable(o, button)
  -- TODO implement this in all the prior widgets and stuff I made so they all call widget's new function first. so that widget can handle all the default/common parameters
  o.value = string
  o:_applyParameters(p)
  return o
end

return button
