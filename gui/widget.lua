--- The base widget object.
-- @module widget

--local box = require("gui.box")

--- Default widget parameters
-- @table widget
local widget = {
  focused = false, -- bool, is the widget focused?
  value = "", -- String, the data contained in the widget, sometimes other types
  enable_events = false, -- TOOD, badly implemented at the moment
  device = term, -- Device the widget is displayed on, term by default
  enable = true, -- bool, render and process events
  frame = true, -- bool, draw frame around widget
  selectable = true, -- bool, should this object be selectable?
  theme = {}, -- table, theme information
  type = "widget", -- string, name of file / widget type
}

widget.__index = widget

--- Default widget theme, table is contents of widget.theme
-- @table widget.theme
widget.theme = {
  wallLeft = string.char(149), -- char, character used for left side vertical widget walls
  wallRight = string.char(149), -- char, character used for right side vertical widget walls
  wallLeftInvert = false, -- should fg/bg colors be swapped for wallLeft
  wallRightInvert = true, -- should fg/bg colors be swapped for wallRight
  wallLeftFocused = string.char(16), -- char, character used for left side widget walls when focused
  wallRightFocused = string.char(17), -- char, character used for right side widget walls when focused
  wallLeftFocusedInvert = false, -- should fg/bg colors be swapped for wallLeft
  wallRightFocusedInvert = false, -- should fg/bg colors be swapped for wallRight
  frameFG = colors.white, -- color, text color of frame
  frameBG = colors.black, -- color, background color of frame
  internalFG = colors.white, -- color, text color of internal widget
  internalBG = colors.black -- color, text color of internal widget
}

function widget:_drawCharacterVertically(char, x, height)
  for y = 1, height do
    self.device.setCursorPos(x, y)
    self.device.write(char)
  end
end

--- Draw the frame of the widget.
-- This creates/overwrites the previous box object the widget had and applies theme colors.
function widget:drawFrame()
  if self.frame then
    if self.focused then
      self:setFrameColor(self.theme.wallLeftFocusedInvert)
      self:_drawCharacterVertically(self.theme.wallLeftFocused, 1, self.size[2])
      self:setPreviousColor()
      self:setFrameColor(self.theme.wallRightFocusedInvert)
      self:_drawCharacterVertically(self.theme.wallRightFocused, self.size[1], self.size[2])
    else
      self:setFrameColor(self.theme.wallLeftInvert)
      self:_drawCharacterVertically(self.theme.wallLeft, 1, self.size[2])
      self:setPreviousColor()
      self:setFrameColor(self.theme.wallRightInvert)
      self:_drawCharacterVertically(self.theme.wallRight, self.size[1], self.size[2])
    end
  end
  self:setPreviousColor()
end

--- Draw the internal area of the widget.
-- Applies theme colors.
function widget:draw()
  self:clear()
end

--- Clear the internal area of the widget.
-- Applies theme colors.
function widget:clear(FG, BG)
  --self.debugStop()
  self:setInternalColor(false, FG, BG)
  self.device.clear()
  self:setPreviousColor()
  --self:drawFrame()
end

--- Convert from device X,Y space to local X,Y space with 1,1 being the top left corner of the inside of the widget.
-- @param x device X
-- @param y device y
-- @return local X
-- @return local Y
function widget:convertGlobalXYToLocalXY(x, y)
  return x - self.pos[1], y - self.pos[2] + 1
end

--- Convert from local X,Y space to device X,Y space
-- @param x local x
-- @param y local y
-- @return local x
-- @return local y
function widget:convertLocalXYToGlobalXY(x, y)
  return x + self.pos[1], y + self.pos[2]
end

--- Set the focus state of the widget, basically just sets the object's focused flag and draws the corners with the corrosponding characters.
-- Applies theme colors.
-- @param focus focus flag bool
function widget:setFocus(focus)
  self.focused = focus
  self:drawFrame()
end

--- Event handler function called when a mouse_click event occurs on the widget.
-- @param mouseButton
-- @param mouseX
-- @param mouseY
-- @return true if this widget wants to notify an event occured
function widget:handleMouseClick(mouseButton, mouseX, mouseY)
  local x, y = self:convertGlobalXYToLocalXY(mouseX, mouseY)
  return self.enable_events
end

--- Event handler function called when a key event occurs with the widget focused.
-- @param keycode
-- @param held
-- @return true if this widget wants to notify an event occured
function widget:handleKey(keycode, held)
  return self.enable_events
end

--- Event handler function called when a mouse_scroll event occurs with the widget focused
function widget:handleMouseScroll(direction, mouseX, mouseY)
  return false
end

--- Event handler function called when a paste event occurs with the widget focused
function widget:handlePaste(text)
  return false
end

--- Event handler function called when a char event occurs with the widget focused.
-- @param char
-- @return true if this widget wants to notify an event occured
function widget:handleChar(char)
  return self.enable_events
end

--- Function called to update the position of the widget.
-- @param x
-- @param y
function widget:updatePos(x, y)
  self.pos = { x, y }
  self.device.reposition(x, y)
end

--- Function called to update the size of the widget.
-- @param width
-- @param height
function widget:updateSize(width, height)
  self.size = { width, height }
  self.device.reposition(self.pos[1], self.pos[2], width, height)
end

--- Internally used function called to set the colors to match the widget's internal theme and store the previous colors.
function widget:setInternalColor(invert, FG, BG)
  self.previousBG = self.device.getBackgroundColor()
  self.previousFG = self.device.getTextColor()
  if invert then
    self.device.setBackgroundColor(FG or self.theme.internalFG)
    self.device.setTextColor(BG or self.theme.internalBG)
  else
    self.device.setBackgroundColor(BG or self.theme.internalBG)
    self.device.setTextColor(FG or self.theme.internalFG)
  end

end

--- Internally used function called to set the colors to match the widget's frame theme and store the previous colors.
function widget:setFrameColor(invert)
  self.previousBG = self.device.getBackgroundColor()
  self.previousFG = self.device.getTextColor()
  if invert then
    self.device.setBackgroundColor(self.theme.frameFG)
    self.device.setTextColor(self.theme.frameBG)
  else
    self.device.setBackgroundColor(self.theme.frameBG)
    self.device.setTextColor(self.theme.frameFG)
  end

end

--- Internally used function called to reset colors to the previously stored values.
function widget:setPreviousColor()
  self.device.setBackgroundColor(self.previousBG)
  self.device.setTextColor(self.previousFG)
end

--- Writes text to a relative X,Y position in the widget.
--- Relative X,Y as in offset by + 1 on the X axis because of the left/right walls
-- @param text
-- @param x
-- @param y
function widget:writeTextToLocalXY(text, x, y)
  self.device.setCursorPos(x + 1, y)
  self:setInternalColor()
  self.device.write(text)
  self:setPreviousColor()
end

function widget.debugStop()
  peripheral.call("back", "stop")
end

--- This function should be overwritten to allow changing conditions as if they were set in the new() function
function widget:updateParameters(p)
  self:_applyParameters(p)
end

--- This function returns the "value" of the widget
function widget:getValue()
  return self.value
end

--- Create a new widget object.
-- @param o original object, usually set to `nil`
-- @param pos table {x,y}
-- @param size table {width, height}
-- @return widget object
function widget:new(o, pos, size, p)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.pos = pos
  o.size = size
  o.theme = {}
  setmetatable(o.theme, self.theme)
  self.theme.__index = self.theme
  o.device = window.create(term.current(), o.pos[1], o.pos[2], o.size[1], o.size[2])
  return o
end

function widget:_applyParameters(p)
  if type(p) == "table" then
    for key, value in pairs(p) do
      if key == "device" then
        self.device = window.create(value, self.pos[1], self.pos[2], self.size[1], self.size[2])
      else
        self[key] = value
      end
    end
  end
end

return widget
