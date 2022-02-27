local widget = require("gui/widget")

local button = widget:new(nil, {1,1}, {1,1})

function button:draw()
    self:clear()
    local preppedString = self.value:sub(1, self.size[1]-2)
    self:writeTextToLocalXY(preppedString, 1, 1)
end

function button:handleMouseClick(mouseButton, mouseX, mouseY)
    local x,y = self:convertGlobalXYToLocalXY(mouseX, mouseY)
    if y > 0 and y < self.size[2]-1 then
        return self.enable_events
    end
end

function widget:handleKey(keycode, held)
    if keycode == 28 then
        -- enter
        return self.enable_events
    end
    return false
end

function button:new(o, pos, size, string, p)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.pos = pos
    o.size = size
    o.focused = false
    o.value = string
    if p then
        o.enable_events = p.enable_events or true
        o.device = p.device or term
        o.theme.internalBG = p.internalBG or colors.white
        o.theme.internalFG = p.internalFG or colors.black
    else
        o.enable_events = true
        o.device = term
        o.theme.internalBG = colors.white
        o.theme.internalFG = colors.black
    end
    return o
end

return button