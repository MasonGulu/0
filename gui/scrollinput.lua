local widget = require("gui/widget")

local scrollinput = widget:new(nil, {1,1}, {1,1})

function scrollinput:draw()
    self:clear()
    local preppedString = string.sub(self.options[self.value], 1, self.size[1]-3)
    self:writeTextToLocalXY(preppedString, 2, 1)
    self:writeTextToLocalXY(string.char(18), 1, 1)
end

function scrollinput:handleMouseClick(mouseButton, mouseX, mouseY)
    local x,y = self:convertGlobalXYToLocalXY(mouseX, mouseY)
    if x > 0 and y > 0 then
        if mouseButton == 1 then
            self.value = self.value + 1
            if self.value > self.length then
                self.value = 1
            end
        elseif mouseButton == 2 then
            self.value = self.value - 1
            if self.value < 1 then
                self.value = self.length
            end
        end
    end
    return self.enable_events
end

function scrollinput:handleMouseScroll(scrollDirection, mouseX, mouseY)
    if scrollDirection == 1 then
        self.value = self.value + 1
        if self.value > self.length then
            self.value = 1
        end
    elseif scrollDirection == -1 then
        self.value = self.value - 1
        if self.value < 1 then
            self.value = self.length
        end
    end
    return self.enable_events
end

-- Create a new scroll input
-- options: a 1d array of text options. Value = index of selected option
-- length, amount of options
function scrollinput:new(o, pos, size, options, length, p)
    size = {size[1], 3}
    o = o or {}
    o = widget:new(o, pos, size, p)
    setmetatable(o, self)
    self.__index = self
    -- TODO implement this in all the prior widgets and stuff I made so they all call widget's new function first. so that widget can handle all the default/common parameters
    o.value = 1
    o.options = options
    o.enable_events = true
    o.length = length
    return o
end

return scrollinput