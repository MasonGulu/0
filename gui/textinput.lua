local widget = require("gui/widget")
local textinput = widget:new(nil, {1,1}, {1,1})

function textinput:draw()
    self:clear()
    if self.numOnly then
        self:writeTextToLocalXY('#',1,1)
    else
        self:writeTextToLocalXY('?',1,1)
    end
    self:writeTextToLocalXY(self.value,2,1)
end

function textinput:handleKey(keycode, held)
    if keycode == 14 then
        self.value = self.value:sub(1,-2)
    elseif keycode == 28 then
        -- enter
        return true
    end
    return false
end

function textinput:handleChar(char)
    if self.numOnly then
        if tonumber(self.value..char) then
            if self.value:len() < self.maxTextLen then
                self.value = self.value..char
            end
        end
    else
        if self.value:len() < self.maxTextLen then
            self.value = self.value..char
        end
    end
    return false
end

function textinput:updateSize(width, height)
    self.size = {width, height}
    self.maxTextLen = self.size[1]-3
end

function textinput:new(o, pos, size, p)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.pos = pos
    o.size = size
    o.focused = false
    o.value = ""
    o.maxTextLen = o.size[1]-3
    if p then
        o.enable_events = p.enable_events or false
        o.device = p.device or term
        o.numOnly = p.numOnly or false
    else
        o.enable_events = false
        o.device = term
        o.numOnly = false
    end
    return o
end

return textinput