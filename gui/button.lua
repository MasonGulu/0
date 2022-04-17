--- A simple button widget.
-- Inherits from the widget object.
-- @see widget
-- @module button
local widget = require("gui/widget")

local button = widget:new(nil, {1,1}, {1,1})

--- Draw the button widget.
function button:draw()
    self:clear()
    local preppedString = self.value:sub(1, self.size[1]-2)
    self:writeTextToLocalXY(preppedString, 1, 1)
end

--- Handle mouse_click events
-- @return true if mouse click is within widget area/on button
function button:handleMouseClick(mouseButton, mouseX, mouseY)
    local x,y = self:convertGlobalXYToLocalXY(mouseX, mouseY)
    if y > 0 and y < self.size[2]-1 then
        return self.enable_events
    end
end

--- Handle key events
-- @return true if enter is pressed
function button:handleKey(keycode, held)
    if keycode == 28 then
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
function button:new(o, pos, size, string)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.pos = pos
    o.size = size
    o.focused = false
    o.value = string
    o.enable_events = true
    o.device = term
    o.theme.internalBG = colors.white
    o.theme.internalFG = colors.black
    return o
end

return button