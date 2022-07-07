--- A simple button widget.
-- Inherits from the widget object.
-- @see widget
-- @module button
local widget = require("ccsg.widget")

--- Defaults for the button widget
-- @table button
local button = {
  type = "button", -- string, used for gui packing/unpacking (must match filename without extension!)
  enable_events = true, -- bool, events are enabled by default for buttons
  VERSION = "3.0",
}
-- Setup inheritence
setmetatable(button, widget)
button.__index = button

--- Draw the button widget.
function button:draw()
  self:clearClickable()
  local preppedString = self.label:sub(1, self.size[1])
  self:writeClickable(preppedString, 1, 1)
end

--- Handle mouse_click events
-- @tparam number mouseButton
-- @tparam number mouseX
-- @tparam number mouseY
-- @treturn boolean mouseclick is on button and enable_events
function button:handleMouseClick(mouseButton, mouseX, mouseY)
  local x, y = self:convertGlobalXYToLocalXY(mouseX, mouseY)
  if y > 0 and y <= self.size[2] and x > 0 and x <= self.size[1] then
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

--- Create a new button widget.
-- @tparam table p requires label
-- @treturn table button
function button.new(p)
  -- expects a label
  p.label = p.label or p[3]
  assert(p.label ~= nil, "Button requires a label")
  local o = widget.new(nil, p[1] or p.pos, p[2] or p.size, p)
  setmetatable(o, button)
  o:_applyParameters(p)
  return o
end

return button