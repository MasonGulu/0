local widget = require("gui/widget")

local divider = {}
setmetatable(divider, widget)
divider.__index = divider

function divider:draw()
    self:clear()
    self:drawFrame()
    self:writeTextToLocalXY(self.value, 1,1)
    if self.modifyWalls then
        if self.top then
            self:setFrameColor()
            self.device.setCursorPos(1,1)
            self.device.write(string.char(156))
            self:setPreviousColor()
            self:setFrameColor(true)
            self.device.setCursorPos(self.size[1], 1)
            self.device.write(string.char(147))
            self:setPreviousColor()
        elseif self.bottom then
            self:setFrameColor()
            self.device.setCursorPos(1,1)
            self.device.write(string.char(141))
            self.device.setCursorPos(self.size[1], 1)
            self.device.write(string.char(142))
            self:setPreviousColor()
        else
            self:setFrameColor()
            self.device.setCursorPos(1,1)
            self.device.write(string.char(157))
            self:setPreviousColor()
            self:setFrameColor(true)
            self.device.setCursorPos(self.size[1], 1)
            self.device.write(string.char(145))
            self:setPreviousColor()
        end
    end
end

function divider:updateSize(width, height)
    self.value = string.rep(string.char(140), width-2)
    widget.updateSize(self, width, height)
end

function divider:new(o, pos, size, p)
    o = o or {}
    o = widget:new(o, pos, size, p)
    setmetatable(o, self)
    self.__index = self
    -- TODO implement this in all the prior widgets and stuff I made so they all call widget's new function first. so that widget can handle all the default/common parameters
    o.value = string.rep(string.char(140), o.size[1]-2)
    o.selectable = false
    o.modifyWalls = true
    o:_applyParameters(p)
    return o
end

return divider