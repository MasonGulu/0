--- The base widget object.
-- @module widget
local expect = require("cc.expect")


-- MAJOR CHANGE IMPLEMENTED
-- device is now the device the object is shown on
-- window is the window that the widget is rendered on

--- Default widget parameters
-- @table widget
local widget = {
  focused = false, -- bool, is the widget focused?
  value = "", -- String, the data contained in the widget, sometimes other types
  enable_events = false, -- bool, if this widget should throw events
  device = term.current(), -- Device the widget is displayed on, not implemented currently. do not change.
  enable = true, -- bool, render and process events
  selectable = true, -- bool, should this object be selectable?
  theme = {}, -- table, theme information
  type = "widget", -- string, name of file / widget type
  VERSION = "3.0",
  render = true, -- bool, call draw() on the next frame
}

widget.theme = {}
setmetatable(widget.theme, require("ccsg.gui").theme)

widget.__index = widget

--- Draw a character repeated vertically
-- @tparam string char
-- @tparam int x
-- @tparam int height
function widget:_drawCharacterVertically(char, x, height)
  expect(1, char, "string")
  expect(2, x, "number")
  expect(3, height, "number")
  for y = 1, height do
    self.window.setCursorPos(x, y)
    self.window.write(char)
  end
end

--- Draw the frame of the widget.
-- Applies theme colors
function widget:drawFrame()
  -- For 3.0 frames are being removed
  print(debug.traceback())
  error()
end

--- Draw the internal area of the widget.
-- Applies theme colors.
function widget:draw()
  self:clear()
end

--- Clear the internal area of the widget.
-- Applies theme colors.
function widget:clear(FG, BG)
  if self.VERSION ~= widget.VERSION then
    error("Widget "+self.type+" does not match widget version!")
  end
  self:setInternalColor(FG, BG)
  self.window.clear()
end

--- Clear the internal area of the widget.
-- Applies theme colors.
function widget:clearClickable()
  self:setClickableColor()
  self.window.clear()
end

--- Convert from device X,Y space to local X,Y space with 1,1 being the top left corner of the widget (inside the frame!)
-- @tparam int x device X
-- @tparam int y device y
-- @treturn int local X
-- @treturn int local Y
function widget:convertGlobalXYToLocalXY(x, y)
  expect(1, x, "number")
  expect(2, y, "number")
  return x - self.pos[1] + 1, y - self.pos[2] + 1
end

--- Convert from local X,Y space to device X,Y space
-- @tparam int x local x
-- @tparam int y local y
-- @treturn int device x
-- @treturn int device y
function widget:convertLocalXYToGlobalXY(x, y)
  expect(1, x, "number")
  expect(2, y, "number")
  return x + self.pos[1], y + self.pos[2]
end

--- Set the focus state of the widget, basically just sets the object's focused flag and draws the corners with the corrosponding characters.
-- Applies theme colors.
-- @tparam bool focus
function widget:setFocus(focus)
  expect(1, focus, "boolean")
  self.focused = focus
end

--- Event handler function called when a mouse_click event occurs on the widget.
-- @tparam int mouseButton
-- @tparam int mouseX global X
-- @tparam int mouseY global Y
-- @treturn bool this widget wants to notify an event occured
function widget:handleMouseClick(mouseButton, mouseX, mouseY)
  local x, y = self:convertGlobalXYToLocalXY(mouseX, mouseY)
  return false
end

--- Event handler function called when a key event occurs with the widget focused.
-- @tparam int keycode
-- @tparam int held
-- @treturn bool this widget wants to notify an event occured
function widget:handleKey(keycode, held)
  return false
end

--- Event handler function called when a mouse_scroll event occurs with the widget focused
-- @tparam int direction
-- @tparam int mouseX global X
-- @tparam int mouseY global Y
-- @treturn bool this widget wants to notify an event occured
function widget:handleMouseScroll(direction, mouseX, mouseY)
  return false
end

--- Event handler function called when a paste event occurs with the widget focused
-- @tparam string text
-- @treturn bool this widget wants to notify an event occured
function widget:handlePaste(text)
  return false
end

--- Event handler function called when a char event occurs with the widget focused.
-- @tparam character char
-- @treturn bool this widget wants to notify an event occured
function widget:handleChar(char)
  return false
end

--- Event handler for any other events that aren't covered by the other handles
-- @tparam table e event table {os.pullEvent()}
-- @treturn bool this widget wants to notify an event occured
function widget:otherEvent(e)
  return false
end

--- Function called to update the position of the widget.
-- @tparam int x
-- @tparam int y
function widget:updatePos(x, y)
  expect(1, x, "number")
  expect(2, y, "number")
  self.pos = { x, y }
  self.window.reposition(x, y)
end

--- Function called to update the size of the widget.
-- @tparam int width
-- @tparam int height
function widget:updateSize(width, height)
  expect(1, width, "number")
  expect(2, height, "number")
  self.size = { width, height }
  self.window.reposition(self.pos[1], self.pos[2], width, height)
end

--- Function to set the term colors according to the internal color theme
-- @param[optchain] FG
-- @param[optchain] BG
function widget:setInternalColor(FG, BG)
  expect(1, FG, "number", "nil")
  expect(2, BG, "number", "nil")
  self.window.setBackgroundColor(BG or self.theme.internalBG)
  self.window.setTextColor(FG or self.theme.internalFG)
end

--- Function to set the term colors according to the internal color theme
-- @param[optchain] FG
-- @param[optchain] BG
function widget:setClickableColor()
  self:setInternalColor(self.theme.clickableFG, self.theme.clickableBG)
end

--- Writes text to a relative X,Y position in the widget.
-- @param text
-- @tparam int x local X
-- @tparam int y local y
function widget:write(text, x, y)
  expect(2, x, "number", nil)
  expect(3, y, "number", nil)
  local pos = self.window.getCursorPos()
  x = x or pos
  y = y or pos
  self.window.setCursorPos(x, y)
  self:setInternalColor()
  self.window.write(text)
end

--- Writes text to a relative X,Y position in the widget but in the clickable theme colors.
-- @param text
-- @tparam int x local X
-- @tparam int y local y
function widget:writeClickable(text, x, y)
  expect(2, x, "number", nil)
  expect(3, y, "number", nil)
  local pos = self.window.getCursorPos()
  x = x or pos
  y = y or pos
  self.window.setCursorPos(x, y)
  self:setClickableColor()
  self.window.write(text)
end

--- This function should be overwritten to allow changing conditions as if they were set in the new() function
-- @tparam[opt] table p
function widget:updateParameters(p)
  self:_applyParameters(p)
end

--- This function returns the "value" of the widget
function widget:getValue()
  return self.value
end

--- Create a new widget object.
-- @tparam table o original object
-- @tparam table pos table {x: int,y: int}
-- @tparam table size table {width: int, height: int}
-- @tparam[opt] table p
-- @treturn table widget object
function widget.new(o, pos, size, p)
  o = o or {}
  setmetatable(o, widget)
  o.pos = pos
  o.size = size
  o.theme = {}
  setmetatable(o.theme, widget.theme)
  o:_applyParameters(p)
  o.window = window.create(o.device, o.pos[1], o.pos[2], o.size[1], o.size[2])
  o.device = {} -- setup this so ALL calls to this device error.. part of the refactor
  setmetatable(o.device, {__index=function() error(debug.traceback()) end})
  return o
end

--- Function called when updating the GUI theme
-- @tparam table theme
function widget:updateTheme(theme)
  self.theme = theme
end

--- Apply parameters to this widget
-- @tparam[opt] table p
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
