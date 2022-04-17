--- The base widget object.
-- @module widget

local box = require("gui/box")

--- Default widget parameters
-- @table widget
local widget = {
    focused = false, -- bool, is the widget focused?
    value = "", -- String, the data contained in the widget, sometimes other types
    enable_events = false, -- TOOD, badly implemented at the moment
    device = term, -- Device the widget is displayed on, term by default
    enable = true, -- bool, render and process events
    frame = true, -- bool, draw frame around widget
    box = nil, -- box object, the box that is drawn around the widget
    theme = {} -- table, theme information
}

--- Default widget theme, table is contents of widget.theme
-- @table widget.theme
widget.theme = {
    corner='+', -- char, character used for unfocused widget corners
    focusedCorner = 'x', -- char, character used for focused widget corners
    wallVertical = '|', -- char, character used for vertical widget walls
    wallHorizontal = '-', -- char, character used for horizontal widget walls
    frameFG = colors.white, -- color, text color of frame
    frameBG = colors.black, -- color, background color of frame
    internalFG = colors.white, -- color, text color of internal widget
    internalBG = colors.black -- color, text color of internal widget
}

--- Draw the frame of the widget.
-- This creates/overwrites the previous box object the widget had and applies theme colors.
function widget:drawFrame()
    self:setFrameColor()
    self.box = box:new(self.box, self.pos, self.size, self.device)
    if self.frame then
        self.box:drawWalls()
        if self.focused then
            self.box:drawCorners(self.theme.focusedCorner)
        else
            self.box:drawCorners(self.theme.corner)
        end
    end
    self:setPreviousColor()
    self:setInternalColor()
    self:clear()
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
    self:setInternalColor(FG, BG)
    self.box:clearInside()
    self:setPreviousColor()
end

--- Convert from device X,Y space to local X,Y space with 1,1 being the top left corner of the inside of the widget.
-- @param x device X
-- @param y device y
-- @return local X
-- @return local Y
function widget:convertGlobalXYToLocalXY(x,y)
    return x-self.pos[1], y-self.pos[2]
end


--- Convert from local X,Y space to device X,Y space
-- @param x local x
-- @param y local y
-- @return local x
-- @return local y
function widget:convertLocalXYToGlobalXY(x,y)
    return x+self.pos[1], y+self.pos[2]
end

--- Set the focus state of the widget, basically just sets the object's focused flag and draws the corners with the corrosponding characters.
-- Applies theme colors.
-- @param focus focus flag bool
function widget:setFocus(focus)
    self.focused = focus
    self:setFrameColor()
    if focus then
        self.box:drawCorners(self.theme.focusedCorner)
    else
        self.box:drawCorners(self.theme.corner)
    end
    self:setPreviousColor()
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

--- Event handler function called when a char event occurs with the widget focused.
-- @param char
-- @return true if this widget wants to notify an event occured
function widget:handleChar(char)
    return self.enable_events
end

--- Function called to update the position of the widget.
-- @param x
-- @param y
function widget:updatePos(x,y)
    self.pos = {x,y}
end

--- Function called to update the size of the widget.
-- @param width
-- @param height
function widget:updateSize(width, height)
    self.size = {width, height}
end

--- Internally used function called to set the colors to match the widget's internal theme and store the previous colors.
function widget:setInternalColor(FG, BG)
    self.previousBG = self.device.getBackgroundColor()
    self.previousFG = self.device.getTextColor()
    self.device.setBackgroundColor(BG or self.theme.internalBG)
    self.device.setTextColor(FG or self.theme.internalFG)
end

--- Internally used function called to set the colors to match the widget's frame theme and store the previous colors.
function widget:setFrameColor()
    self.previousBG = self.device.getBackgroundColor()
    self.previousFG = self.device.getTextColor()
    self.device.setBackgroundColor(self.theme.frameBG)
    self.device.setTextColor(self.theme.frameFG)
end

--- Internally used function called to reset colors to the previously stored values.
function widget:setPreviousColor()
    self.device.setBackgroundColor(self.previousBG)
    self.device.setTextColor(self.previousFG)
end

--- Writes text to a relative X,Y position in the widget.
-- @param text
-- @param x
-- @param y
function widget:writeTextToLocalXY(text, x, y)
    self.device.setCursorPos(self:convertLocalXYToGlobalXY(x,y))
    self:setInternalColor()
    self.device.write(text)
    self:setPreviousColor()
end

function widget:debug(...)
    peripheral.call("back", "transmit", 1, 1, {arg})
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
    if p then
        o.enable_events = p.enable_events or false
        o.device = p.device or term
    else
        o.enable_events = false
        o.device = term
    end
    return o
end

return widget