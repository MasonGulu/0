local widget = require("gui/widget")
local listbox = {}
setmetatable(listbox, widget)
listbox.__index = listbox

function listbox:draw()
    self:clear()
    self:drawFrame()
    self:writeTextToLocalXY(string.char(30),self.size[1]-2, 1)
    self:writeTextToLocalXY(string.char(31),self.size[1]-2, self.size[2])
    for key, value in ipairs(self.T) do
        -- print(key,value,self.scrollOffset)
        self.device.setCursorPos(2,key-self.scrollOffset)
        self:setInternalColor(key == self.value)
        self.device.write(tostring(value):sub(1, self.size[1]-3))
        self:setPreviousColor()
    end
end

function listbox:handleMouseClick(mouseButton, mouseX, mouseY)
    local x, y = self:convertGlobalXYToLocalXY(mouseX, mouseY)
    
    if x == self.size[1]-2 then
        -- Click is on the sidebar
        if y == 1 then
            -- up
            self.scrollOffset = self.scrollOffset - 1
            if self.scrollOffset < 0 then
                self.scrollOffset = 0
            end
        elseif y == self.size[2] then
            -- down
            self.scrollOffset = self.scrollOffset + 1
            if self.scrollOffset > #self.T-1 then
                self.scrollOffset = #self.T-1
            end
        end
    elseif x > 1 and x < self.size[1]-2 and mouseButton == 1 then
        -- Click is on an element
        self.value = y + self.scrollOffset
        if self.value > #self.T then
            self.value = #self.T
        end
        return self.enable_events
    end
    return false
end

function listbox:handleKey(code, held)
    if code == keys.up then
        self.scrollOffset = self.scrollOffset - 1
        if self.scrollOffset < 0 then
            self.scrollOffset = 0
        end
    elseif code == keys.down then
        -- down
        self.scrollOffset = self.scrollOffset + 1
        if self.scrollOffset > #self.T-1 then
            self.scrollOffset = #self.T-1
        end
    elseif code == keys.enter then
        self.value = self.scrollOffset + 1
        return self.enable_events
    end
    return false
end

function listbox:handleMouseScroll(scrollDirection)
    if scrollDirection == 1 then
        self.scrollOffset = self.scrollOffset + 1
        if self.scrollOffset > #self.T-1 then
            self.scrollOffset = #self.T-1
        end
    elseif scrollDirection == -1 then
        self.scrollOffset = self.scrollOffset - 1
        if self.scrollOffset < 0 then
            self.scrollOffset = 0
        end
    end
    return false
end

function listbox:updateParameters(T,p)
    self.T = T
    self.value = 1
    self.scrollOffset = 0
    self:_applyParameters(p)
end

function listbox:new(o, pos, size, T, p)
    -- takes an ordered table of string displayable objects, value is the index of the selected element
    o = o or {}
    o = widget:new(o, pos, size, p)
    setmetatable(o, self)
    self.__index = self
    -- TODO implement this in all the prior widgets and stuff I made so they all call widget's new function first. so that widget can handle all the default/common parameters
    o.T = T
    o.value = 1
    o.scrollOffset = 0
    o.textWidth = o.size[2] - 3
    o.enable_events = true
    o:_applyParameters(p)
    return o
end

return listbox