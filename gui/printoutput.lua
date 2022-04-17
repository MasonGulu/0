local widget = require("gui/widget")

local printoutput = widget:new(nil, {1,1}, {1,1})

function printoutput:draw()
    self:clear()
    for i = 1, self.textArea[2] do
        local preppedString = ""
        if self.value[i] then
            preppedString = self.value[i]:sub(1, self.size[1]-2)
        end
        self:writeTextToLocalXY(preppedString,1,self.textArea[2]+1-i)
    end
end

function printoutput:scroll()
    for x = #self.value+1, 2, -1 do
        self.value[x] = self.value[x-1]
    end
    self.value[1] = ""
end

function printoutput:print(str)
    str = tostring(str)
    self:scroll()
    self.value[1] = str:sub(1, self.textArea[1])
    if str:len() > self.textArea[1] then
        self:print(str:sub(self.textArea[1]+1, -1))
    end
end

function printoutput:updateSize(width, height)
    self.size = {width, height}
    self.textArea = {self.size[1] - 2, self.size[2] - 2}
end

function printoutput:new(o, pos, size, p)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.pos = pos
    o.size = size
    o.focused = false
    o.value = {}
    o.textArea = {o.size[1] - 2, o.size[2] - 2}
    for i = 1, o.textArea[2] do
        o.value[i] = ""
    end
    if p then
        o.enable_events = p.enable_events or false
        o.device = p.device or term
    else
        o.enable_events = false
        o.device = term
    end
    return o
end

return printoutput