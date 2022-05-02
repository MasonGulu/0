local widget = require("gui/widget")

local text = {}
setmetatable(text, widget)
text.__index = text

function text:draw()
    self:clear()
    self:drawFrame()
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
    widget.updateSize(self, width, height)
    self.textArea = {self.size[1]-2, self.size[2]}
    for i = 1, self.textArea[2] do
        self.value[i] = ""
    end
    self:formatStringToFitWidth(self.string)
end

function text:updateParameters(string, p)
    self.string = string
    self:formatStringToFitWidth(self.string)
    self:_applyParameters(p)
end

function text:new(o, pos, size, string, p)
    o = o or {}
    o = widget:new(o, pos, size, p)
    setmetatable(o, self)
    self.__index = self
    -- TODO implement this in all the prior widgets and stuff I made so they all call widget's new function first. so that widget can handle all the default/common parameters
    o.value = {}
    o.textArea = {o.size[1]-2, o.size[2]}
    for i = 1, o.textArea[2] do
        o.value[i] = ""
    end
    o.string = string
    o:formatStringToFitWidth(o.string)
    o.selectable = false
    o:_applyParameters(p)
    return o
end

return text