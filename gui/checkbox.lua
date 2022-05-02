--- A simple checkbox widget.
-- Inherits from the widget object.
-- @see widget
-- @module checkbox

local widget = require("gui/widget")

local checkbox = {}
setmetatable(checkbox, widget)
checkbox.__index = checkbox

--- Draw the checkbox widget.
function checkbox:draw()
    self:clear()
    self:drawFrame()
    if self.value then
        self:writeTextToLocalXY(string.char(7),1,1)
        -- closed checkbox
    else
        self:writeTextToLocalXY(string.char(164),1,1)
        -- open checkbox
    end
    local preppedString = self.text:sub(1, self.size[1]-3)
    self:writeTextToLocalXY(preppedString, 2, 1)
end

--- Handle mouse_click events.
-- @return enable_events, false by default
function checkbox:handleMouseClick(mouseButton, mouseX, mouseY)
    local x, y = self:convertGlobalXYToLocalXY(mouseX, mouseY)
    if x == 1 and y == 1 then
        self.value = not self.value
    end
    return self.enable_events
end

function checkbox:handleKey(keycode, held)
    if keycode == keys.space then
        self.value = not self.value
        return self.enable_events
    end
end

--- Create a new checkbox widget.
-- @param o original object, usually set to `nil`
-- @param pos table {x,y}
-- @param size table {width,height}
-- @param string String to display, single line.
-- @return checkbox widget
function checkbox:new(o,pos,size,text,p)
    o = o or {}
    o = widget:new(o, pos, size, p)
    setmetatable(o, self)
    self.__index = self
    -- TODO implement this in all the prior widgets and stuff I made so they all call widget's new function first. so that widget can handle all the default/common parameters
    o.text = text
    o:_applyParameters(p)
    return o
end

return checkbox