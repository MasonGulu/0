local box = require("gui/box")

local widget = {}

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

function widget:draw()
    self:clear()
end

function widget:clear()
    self:setInternalColor()
    self.box:clearInside()
    self:setPreviousColor()
end

function widget:convertGlobalXYToLocalXY(x,y)
    return x-self.pos[1], y-self.pos[2]
end

function widget:convertLocalXYToGlobalXY(x,y)
    return x+self.pos[1], y+self.pos[2]
end

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

function widget:handleMouseClick(mouseButton, mouseX, mouseY)
    local x, y = self:convertGlobalXYToLocalXY(mouseX, mouseY)
    return self.enable_events
end

function widget:handleKey(keycode, held)
    return self.enable_events
end

function widget:handleChar(char)
    return self.enable_events
end

function widget:updatePos(x,y)
    self.pos = {x,y}
end

function widget:updateSize(width, height)
    self.size = {width, height}
end

function widget:setInternalColor()
    self.previousBG = self.device.getBackgroundColor()
    self.previousFG = self.device.getTextColor()
    self.device.setBackgroundColor(self.theme.internalBG)
    self.device.setTextColor(self.theme.internalFG)
end

function widget:setFrameColor()
    self.previousBG = self.device.getBackgroundColor()
    self.previousFG = self.device.getTextColor()
    self.device.setBackgroundColor(self.theme.frameBG)
    self.device.setTextColor(self.theme.frameFG)
end

function widget:setPreviousColor()
    self.device.setBackgroundColor(self.previousBG)
    self.device.setTextColor(self.previousFG)
end

function widget:writeTextToLocalXY(text, x, y)
    self.device.setCursorPos(self:convertLocalXYToGlobalXY(x,y))
    self:setInternalColor()
    self.device.write(text)
    self:setPreviousColor()
end

function widget:new(o, pos, size, p)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.pos = pos
    o.size = size
    o.focused = false
    o.value = ""
    o.theme = {}
    o.enable_events = false
    o.device = term
    o.enable = true
    o.frame = true
    o.theme = {
        corner='+',
        focusedCorner = 'x',
        wallVertical = '|',
        wallHorizontal = '-',
        frameFG = colors.white,
        frameBG = colors.black,
        internalFG = colors.white,
        internalBG = colors.black
    }
    return o
end

return widget