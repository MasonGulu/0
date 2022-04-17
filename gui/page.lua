local widget = require("gui/widget")

local page = widget:new(nil, {1,1},{1,1})

page.PAGESIZE = {x=25,y=21}
page.COLORS = {[0]=colors.white,
    [1]=colors.orange,
    [2]=colors.magenta,
    [3]=colors.lightBlue,
    [4]=colors.yellow,
    [5]=colors.lime,
    [6]=colors.pink,
    [7]=colors.gray,
    [8]=colors.lightGray,
    [9]=colors.cyan,
    a=colors.purple,
    b=colors.blue,
    c=colors.brown,
    d=colors.green,
    e=colors.red,
    f=colors.black
}

function page:draw()
    self:clear(colors.black, colors.white)
    -- manual positioning and printing of the rulers
    self.device.setCursorPos(self.pos[1]+1, self.pos[2])
    local tmpString = string.rep("....|", math.ceil((self.size[1]-2)/5))
    tmpString = string.sub(tmpString, 1, self.size[1]-3)
    self.device.write(tmpString)
    for dy = 1, self.size[2]-2 do
        local ypos = dy + self.pos[2]
        self.device.setCursorPos(self.pos[1], ypos)
        tmpString = "."
        if dy % 5 == 0 then
            tmpString = "-"
        end
        self.device.write(tmpString)
        self.device.setCursorPos(self.pos[1]+self.buttonX, ypos)
        if dy == self.prevLineY then
            self.device.blit(string.char(30), "0","f")
        elseif dy == self.prevPageY then
            self.device.blit(string.char(27), "0","f")
        elseif dy == self.nextLineY then
            self.device.blit(string.char(31), "0","f")
        elseif dy == self.nextPageY then
            self.device.blit(string.char(26), "0","f")
        else
            self.device.blit(" ", "0","f")
        end
    end

    for line = self.viewLine, self.viewLine + self.viewSize[2] - 1 do
        local ypos = line - self.viewLine + 1 + self.pos[2]
        self.device.setCursorPos(self.pos[1]+1, ypos)
        self.device.blit(self.pageText[line], self.pageColor[line], string.rep("0",self.PAGESIZE.x))
    end

    self.device.setCursorPos(self.pos[1]+self.cursorPos[1], self.pos[2]+self.cursorPos[2])
    local tmpIndex = self.cursorPos[1]
    local tmpString = string.sub(self.pageText[self.cursorPos[2]+self.viewLine-1], tmpIndex, tmpIndex)
    local tmpCol =    string.sub(self.pageColor[self.cursorPos[2]+self.viewLine-1], tmpIndex, tmpIndex)
    local tmpFG = "f"
    if tmpCol == "f" or tmpCol == "7" then
        tmpFG = '0'
    end
    self.device.blit(tmpString, tmpFG, tmpCol)
end

function page:getColorTextFromLine(line, color)
    local textString = self.pageText[line]
    local colorString = self.pageColor[line]

    local outputString = ""
    for x = 1, self.PAGESIZE.x do
        if string.sub(colorString, x, x) == color then
            outputString = outputString .. string.sub(textString, x, x)
        else
            outputString = outputString .. " "
        end
    end
    return outputString
end

function page:mergeStringByColor(line, inputString, color)
    local textString = self.pageText[line]
    local colorString = self.pageColor[line]

    for x = 1, self.PAGESIZE.x do
        if string.sub(inputString, x, x) ~= " " then
            textString = self._replaceCharInString(textString, string.sub(inputString, x, x), x)
            colorString = self._replaceCharInString(colorString, color, x)
        end
    end
    self.pageText[line] = textString
    self.pageColor[line] = colorString
end

function page:updateSize(_, height)
    self.size = {self.PAGESIZE.x+3, height}
    self.verticalScroll = false
    self.horizontalScroll = false
    self.viewSize = {self.size[1]-3,self.size[2]-2}
    self.viewLine = 1 -- line viewport is drawn starting at
    self.maxViewLine = self.PAGESIZE.y - self.viewSize[2] + 1
    self.cursorPos = {1,1}

    self.nextLineY = self.size[2]-2
    self.prevLineY = 1

    self.nextPageY = self.size[2]-3
    self.prevPageY = 2

    self.buttonX = self.size[1]-2

end

function page:handleMouseClick(mouseButton, mouseX, mouseY)
    local x,y = self:convertGlobalXYToLocalXY(mouseX, mouseY)
    if y > 0 and y < self.size[2]-1 and x > 0 and x < self.size[1]-1 then
        -- mouse click is in the window area
        if x == self.buttonX then
            -- mouse click is somewhere in the button area
            if y == self.nextLineY then
                self.viewLine = self.viewLine+1
                if self.viewLine > self.maxViewLine then
                    self.viewLine = self.maxViewLine
                end
                self.value = "changeLine"
            elseif y == self.prevLineY then
                self.viewLine = self.viewLine-1
                if self.viewLine < 1 then
                    self.viewLine = 1
                end
                self.value = "changeLine"
            elseif y == self.nextPageY then
                self.value = "nextPage"
                return true
            elseif y == self.prevPageY then
                self.value = "prevPage"
                return true
            end
        else
            if mouseButton == 3 then
                -- middle click
                self.selectedColor = string.sub(self.pageColor[y], x, x)
            elseif mouseButton == 2 then
                -- intentionally do not update cursor pos
            else
                self.cursorPos = {x,y}
            end
            
        end
    end
end

function page._enforceRange(value, vmin, vmax)
    if value > vmax then
        value = vmax
    end
    if value < vmin then
        value = vmin
    end
    return value
end

function page:handleKey(keycode, held)
    self:debug("Key was pressed", keycode)
    if keycode == keys.left then
        -- left
        self.cursorPos[1] = self.cursorPos[1] - 1
        if self.cursorPos[1] < 1 then
            self.cursorPos[2] = self.cursorPos[2] - 1
            self.cursorPos[1] = self.viewSize[1]
        end
    elseif keycode == keys.right then
        -- right
        self.cursorPos[1] = self.cursorPos[1] + 1
        if self.cursorPos[1] > self.viewSize[1] then
            self.cursorPos[2] = self.cursorPos[2] + 1
            self.cursorPos[1] = 1
        end
    elseif keycode == keys.up then
        -- up
        self.cursorPos[2] = self.cursorPos[2] - 1
    elseif keycode == keys.down then
        -- down
        self.cursorPos[2] = self.cursorPos[2] + 1
    elseif keycode == keys.enter then
        -- enter
        self.cursorPos[2] = self.cursorPos[2] + 1
        self.cursorPos[1] = 1
    elseif keycode == keys.home then
        -- home
        self.cursorPos[1] = 1
    elseif keycode == keys["end"] then
        -- end
        self.cursorPos[1] = self.PAGESIZE.x
    elseif keycode == keys.backspace then
        -- backspace
        self.cursorPos[1] = self.cursorPos[1] - 1
        if self.cursorPos[1] > 0 then
            self:putCharAtCursorPos(" ")
        else
            self.cursorPos[1] = self.PAGESIZE.x
            self.cursorPos[2] = self.cursorPos[2] - 1
            if self.cursorPos[2] < 1 then
                self.cursorPos[2] = 1
            end
            self:putCharAtCursorPos(" ")
        end
    elseif keycode == keys.delete then
        -- delete
        self:putCharAtCursorPos(" ")
    end
    if self.cursorPos[2] > self.viewSize[2] then
        self.viewLine = self.viewLine+1
        if self.viewLine > self.maxViewLine then
            self.viewLine = self.maxViewLine
        end
    elseif self.cursorPos[2] < 1 then
        self.viewLine = self.viewLine-1
        if self.viewLine < 1 then
            self.viewLine = 1
        end
    end
    self.cursorPos[1] = self._enforceRange(self.cursorPos[1], 1, self.PAGESIZE.x)
    self.cursorPos[2] = self._enforceRange(self.cursorPos[2], 1, self.viewSize[2])
end

function page:handleMouseScroll(direction, mouseX, mouseY)
    self.viewLine = self.viewLine + direction
    self.viewLine = self._enforceRange(self.viewLine, 1, self.maxViewLine)
end

function page._replaceCharInString(str, char, index)
    str = string.sub(str, 1, index-1) .. char .. string.sub(str, index+1)
    return str
end

function page:putCharAtCursorPos(char, color)
    if color then
        self.selectedColor = color
    end
    local ypos = self.cursorPos[2]+self.viewLine-1
    self.pageText[ypos] = self._replaceCharInString(self.pageText[ypos], char, self.cursorPos[1])
    self.pageColor[ypos] = self._replaceCharInString(self.pageColor[ypos], self.selectedColor, self.cursorPos[1])
end

function page:handleChar(char)
    self:debug("Char pressed ", char)
    self:putCharAtCursorPos(char)
    self.cursorPos[1] = self.cursorPos[1] + 1
    if self.cursorPos[1] > self.viewSize[1] then
        self.cursorPos[1] = 1
        self.cursorPos[2] = self.cursorPos[2] + 1
        if self.cursorPos[2] > self.viewSize[2] then
            self.viewLine = self.viewLine+1
            if self.viewLine > self.maxViewLine then
                self.viewLine = self.maxViewLine
            end
        elseif self.cursorPos[2] < 1 then
            self.viewLine = self.viewLine-1
            if self.viewLine < 1 then
                self.viewLine = 1
            end
        end
        self.cursorPos[2] = self._enforceRange(self.cursorPos[2], 1, self.viewSize[2])
    end
end

function page:erase()
    for y = 1, self.PAGESIZE.y do
        self.pageText[y] = string.rep(" ",self.PAGESIZE.x)
        self.pageColor[y] = string.rep("f",self.PAGESIZE.x)
    end
end

function page:new(o,pos,size,p)
    size = {25+3, size[2]}

    o = o or {}
    o = widget:new(o, pos, size, p)
    setmetatable(o, self)
    self.__index = self
    -- TODO implement this in all the prior widgets and stuff I made so they all call widget's new function first. so that widget can handle all the default/common parameters
    self:updateSize(size[1],size[2])
    self.theme.internalBG = colors.white -- this works but I don't understand why. these should be o.
    self.pageText = {}
    self.pageColor= {}
    self.selectedColor = "f"
    o:erase()
    return o
end

return page