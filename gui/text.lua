local widget = require("gui/widget")

local text = widget:new(nil, {1,1},{1,1})

function text:draw()
    self:clear()
    for i = 1, self.textArea[2] do
        local preppedString = self.value[i]:sub(1, self.size[1]-2)
        self:writeTextToLocalXY(preppedString,1,self.textArea[2]+1-i)
    end
end

function text:scrollTextArray()
    for x = self.textArea[2]+1, 2, -1 do
        self.value[x] = self.value[x-1]
    end
    self.value[1] = ""
end

function text:formatStringToFitWidth(str)
    str = tostring(str)
    self:scrollTextArray()
    self.value[1] = str:sub(1, self.textArea[1])
    if str:len() > self.textArea[1] then
        self:formatStringToFitWidth(str:sub(self.textArea[1]+1, -1))
    end
end

function text:updateSize(width, height)
    self.size = {width, height}
    self.textArea = {self.size[1]-2, self.size[2]-2}
    for i = 1, self.textArea[2] do
        self.value[i] = ""
    end
    self:formatStringToFitWidth(self.string)
end

function text:new(o, pos, size, string, p)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.pos = pos
    o.size = size
    o.value = {}
    o.focused = false
    o.textArea = {o.size[1]-2, o.size[2]-2}
    for i = 1, o.textArea[2] do
        o.value[i] = ""
    end
    o.string = string
    o:formatStringToFitWidth(o.string)
    if p then
        o.enable_events = p.enable_events or false
        o.device = p.device or term
    else
        o.enable_events = false
        o.device = term
    end
    return o
end

return text