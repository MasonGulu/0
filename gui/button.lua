--- A simple button widget.
-- Inherits from the widget object.
-- @see widget
-- @module button
local widget = require("gui/widget")

local button = {ver='1.0'}
setmetatable(button, widget)
button.__index = button

--- Draw the button widget.
function button:draw()
    self:clear()
    self:drawFrame()
    local preppedString = self.value:sub(1, self.size[1]-2)
    self:writeTextToLocalXY(preppedString, 1, 1)
end

--- Handle mouse_click events
-- @return true if mouse click is within widget area/on button
function button:handleMouseClick(mouseButton, mouseX, mouseY)
    local x,y = self:convertGlobalXYToLocalXY(mouseX, mouseY)
    if y > 0 and y < self.size[2]+1 and x > 0 and x < self.size[1]-1 then
        return self.enable_events
    end
end

--- Handle key events
-- @return true if enter is pressed
function button:handleKey(keycode, held)
    if keycode == keys.enter then
        -- enter
        return self.enable_events
    end
    return false
end

--- Create a new button widget.
-- @param o original object, usually set to `nil`
-- @param pos table {x,y}
-- @param size table {width,height}
-- @param string String to display, single line.
-- @return button widget
function button:new(o, pos, size, string, p)
    o = o or {}
    o = widget:new(o, pos, size, p)
    setmetatable(o, button)
    -- TODO implement this in all the prior widgets and stuff I made so they all call widget's new function first. so that widget can handle all the default/common parameters
    o.value = string
    o.enable_events = true
    o:_applyParameters(p)
    local tmp = o.theme.internalBG
    o.theme.internalBG = o.theme.internalFG
    o.theme.internalFG = tmp
    return o
end

return button