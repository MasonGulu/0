--- A compact single-line widget that allows you to select a single element from a list.
-- Inherits from the widget object.
-- @see widget
-- @module scrollinput
local widget = require("gui.widget")

--- Defaults for the scrollinput widget
-- @table scrollinput
local scrollinput = {
  type = "scrollinput", -- string, used for gui packing/unpacking (must match filename without extension!)
  enable_events = true -- bool, events are enabled by default for scrollinputs
}
-- Setup inheritence
setmetatable(scrollinput, widget)
scrollinput.__index = scrollinput

--- Draw the scrollinput widget.
function scrollinput:draw()
  self:clear()
  self:drawFrame()
  local preppedString = string.sub(self.options[self.value], 1, self.size[1] - 3)
  self:writeTextToLocalXY(preppedString, 2, 1)
  self:writeTextToLocalXY(string.char(18), 1, 1)
end

--- Handle mouse_click events
-- @tparam number mouseButton
-- @tparam number mouseX
-- @tparam number mouseY
-- @treturn boolean mouseclick is on scroll button and enable_events
function scrollinput:handleMouseClick(mouseButton, mouseX, mouseY)
  local x, y = self:convertGlobalXYToLocalXY(mouseX, mouseY)
  if x > 0 and y > 0 then
    if mouseButton == 1 then
      self.value = self.value + 1
      if self.value > self.length then
        self.value = 1
      end
    elseif mouseButton == 2 then
      self.value = self.value - 1
      if self.value < 1 then
        self.value = self.length
      end
    end
    return self.enable_events
  end
  return false
end

--- Handle mousescroll events
-- @tparam int direction
-- @tparam int mouseX global X
-- @tparam int mouseY global Y
-- @treturn bool value has changed and enable_events
function scrollinput:handleMouseScroll(direction, mouseX, mouseY)
  if direction == 1 then
    self.value = self.value + 1
    if self.value > self.length then
      self.value = 1
    end
    return self.enable_events
  elseif direction == -1 then
    self.value = self.value - 1
    if self.value < 1 then
      self.value = self.length
    end
    return self.enable_events
  end
  return false
end

--- Handle key events
-- @tparam int key
-- @tparam int held
-- @treturn bool selected value changed and enable_events
function scrollinput:handleKey(key, held)
  if key == keys.down then
    self.value = self.value + 1
    if self.value > self.length then
      self.value = 1
    end
    return self.enable_events
  elseif key == keys.up then
    self.value = self.value - 1
    if self.value < 1 then
      self.value = self.length
    end
    return self.enable_events
  end
  return false
end

--- Update parameters of this scrollinput widget
-- @tparam table options
-- @tparam[opt] table p
function scrollinput:updateParameters(options, p)
  self.value = 1
  self.options = options
  self.length = #self.options
  self:_applyParameters(p)
end

-- Create a new scroll input
-- options: a 1d array of text options. Value = index of selected option
function scrollinput:new(o, pos, size, options, p)
  o = o or {}
  o = widget:new(o, pos, size, p)
  setmetatable(o, self)
  self.__index = self
  o.value = 1
  o.options = options
  o.length = #o.options
  o:_applyParameters(p)
  return o
end

return scrollinput
