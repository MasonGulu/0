local widget = require("gui/widget")
local textinput = {}
setmetatable(textinput, widget)
textinput.__index = textinput

function textinput:draw()
    self:clear()
    self:drawFrame()
    if self.numOnly then
        self:writeTextToLocalXY('#',1,1)
    else
        self:writeTextToLocalXY('?',1,1)
    end
    self:writeTextToLocalXY(self.value,2,1)
end

function textinput:handleKey(keycode, held)
    if keycode == keys.backspace then
        -- backspace
        self.value = tostring(self.value):sub(1,-2)
    elseif keycode == keys.enter then
        -- enter
        return true
    end
    if tonumber(self.value) and tostring(self.value):sub(-1,-1) ~= "." then
        self.value = tonumber(self.value)
    end
    return false
end

function textinput:handleChar(char)
    if self.numOnly then
        if tonumber(self.value..char) or char == '.' then
            if tostring(self.value):len() < self.maxTextLen then
                self.value = self.value..char
            end
        end
    else
        if self.value:len() < self.maxTextLen then
            self.value = self.value..char
        end
    end
    if tonumber(self.value) and tostring(self.value):sub(-1,-1) ~= "." then
        self.value = tonumber(self.value)
    end
    return false
end

function textinput:handleMouseClick()
    if tonumber(self.value) and tostring(self.value):sub(-1,-1) ~= "." then
        self.value = tonumber(self.value)
    end
    return false
end

function textinput:updateSize(width, height)
    widget.updateSize(self, width, height)
    self.maxTextLen = self.size[1]-3
end


function textinput:new(o, pos, size, p)
    o = o or {}
    o = widget:new(o, pos, size, p)
    setmetatable(o, self)
    self.__index = self
    -- TODO implement this in all the prior widgets and stuff I made so they all call widget's new function first. so that widget can handle all the default/common parameters
    o.value = ""
    o.maxTextLen = o.size[1]-3
    o:_applyParameters(p)
    return o
end

return textinput