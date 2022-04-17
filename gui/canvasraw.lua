-- Make a memory "ram" array, then allow writing to that memory "ram" array, then later writing that to the screen
local canvasraw = {}

canvasraw.colors = {
    a = 10,
    b = 11,
    c = 12,
    d = 13,
    e = 14,
    f = 15
}
for x = 0, 10 do
    canvasraw.colors[x] = tostring(x)
    canvasraw.colors[tostring(x)] = tostring(x)
end
canvasraw.colors[10] = "a"
canvasraw.colors[11] = "b"
canvasraw.colors[12] = "c"
canvasraw.colors[13] = "d"
canvasraw.colors[14] = "e"
canvasraw.colors[15] = "f"

function canvasraw:hashCharacterBools(x,y)
    local sumOne = 0
    local sumTwo = 0
    for dx = 0, 1 do
        for dy = 0, 2 do
            if(self.VRAM.P[x+dx][y+dy]) then
                sumOne = sumOne + 2^(dx + dy*2)
            else
                sumTwo = sumTwo + 2^(dx + dy*2)
            end
        end
    end
    return sumOne, sumTwo
end

function canvasraw:convertColorStringToColors(x,y)
    return self.VRAM.C[x][y]:sub(1,1), self.VRAM.C[x][y]:sub(2,2)
end

function canvasraw:convertColorXYToPixelXY(x,y)
    return 1+(x-1)*2, 1+(y-1)*3
    -- a = 1+(x-1)*2
    -- a-1 = (x-1)*2
    -- (a-1)/2 = x-1
    -- x = 1+(a-1)/2
end

function canvasraw:render()
    for y = 1, self.cResolution[2] do
        local linestring = ""
        local lineforeground = ""
        local linebackground = ""
        for x = 1, self.cResolution[1] do
            local sumOne, sumTwo = self:hashCharacterBools(self:convertColorXYToPixelXY(x,y))
            self.device.setCursorPos(self.x-1 + x, self.y-1 + y)
            local foreground, background = self:convertColorStringToColors(x,y)
            
            if sumOne < 31 then
                linestring = linestring..string.char(128+sumOne)
                lineforeground = lineforeground..foreground
                linebackground = linebackground..background
            else
                linestring = linestring..string.char(128+sumTwo)
                lineforeground = lineforeground..background
                linebackground = linebackground..foreground
            end
        end
        self.device.setCursorPos(self.x,self.y-1+y)
        self.device.blit(linestring, lineforeground, linebackground)
    end
end

function canvasraw:convertPixelXYToColorXY(x,y)
    return math.floor(1+(x-1)/2), math.floor(1+(y-1)/3)
end

function canvasraw:setPixel(x,y,state,foreground,background)
    if x < 1 or y < 1 or x > self.resolution[1] or y > self.resolution[2]+1 then
        return
    end
    x = math.floor(x+0.5)
    y = math.floor(y+0.5)
    local cX, cY = self:convertPixelXYToColorXY(x,y)
    if foreground then
        foreground = self.colors[foreground]
    else
        foreground = '0'
    end
    if background then
        background = self.colors[background]
    else
        background = 'f'
    end
    self.VRAM.C[cX][cY] = foreground..background
    self.VRAM.P[x][y] = state
end

function canvasraw:getPointAlongLine(startPos, endPos, T)
    return startPos[1] + (endPos[1] - startPos[1])*T, startPos[2] + (endPos[2] - startPos[2])*T
end

function canvasraw:drawLine(startPos, endPos, iterationSize, foreground, background)
    for T = 0,1,iterationSize do
        local x, y = self:getPointAlongLine(startPos, endPos, T)
        self:setPixel(x, y, true, foreground, background)
    end
end

function canvasraw:drawQuadratic(startPos, weight1Pos, endPos, iterationSize, foreground, background)
    for T = 0,1,iterationSize do
        local A = {self:getPointAlongLine(startPos, weight1Pos, T)}
        local B = {self:getPointAlongLine(weight1Pos, endPos, T)}

        local x, y = self:getPointAlongLine(A, B, T)
        self:setPixel(x, y, true, foreground, background)
    end
end

function canvasraw:drawBezier(startPos, weight1Pos, weight2Pos, endPos, iterationSize, foreground, background)
    for T = 0,1,iterationSize do
        local A = {self:getPointAlongLine(startPos, weight1Pos, T)}
        local B = {self:getPointAlongLine(weight1Pos, weight2Pos, T)}
        local C = {self:getPointAlongLine(weight2Pos, endPos, T)}

        local x, y = self:getPointAlongLine({self:getPointAlongLine(A,B,T)}, {self:getPointAlongLine(B,C,T)}, T)
        self:setPixel(x, y, true, foreground, background)
    end
end

function canvasraw:drawCircle(pos, radius, iterationSize, foreground, background)
    for T = 0, 2*math.pi, iterationSize do
        local x = pos[1] + radius * math.cos(T)
        local y = pos[2] + radius * math.sin(T)
        self:setPixel(x, y, true, foreground, background)
    end
end

function canvasraw:clear(doNotClearColor)
    for x = 1, self.resolution[1] do
        for y = 1, self.resolution[2] do
            self.VRAM.P[x][y] = false
        end
    end
    if not doNotClearColor then
        for x = 1, self.cResolution[1] do
            for y = 1, self.cResolution[2] do
                self.VRAM.C[x][y] = '0f'
            end
        end
    end
end

function canvasraw:new(o, device, pos, resolution)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.device = device
    if resolution then
        o.resolution = {resolution[1], resolution[2]}
        o.cResolution = {resolution[1], resolution[2]}
    else
        o.resolution = {o.device.getSize()}
        o.cResolution = {o.device.getSize()}
    end
    o.resolution[1] = o.resolution[1] * 2
    o.resolution[2] = o.resolution[2] * 3
    pos = pos or {1,1}
    o.x = pos[1]
    o.y = pos[2]
    o.VRAM = {}
    o.VRAM.P = {}
    -- Pixel information
    -- laid out linearly, pixel by pixel. Table of bools, true for foreground, false for background
    for x = 1, o.resolution[1] do
        o.VRAM.P[x] = {}
        for y = 1, o.resolution[2] do
            o.VRAM.P[x][y] = false
        end
    end

    o.VRAM.C = {}
    for x = 0, o.cResolution[1] do
        o.VRAM.C[x] = {}
        -- Bytes, MS 4 bits are foreground color, LS 4 bits are background color
        for y = 0, o.cResolution[2] do
            o.VRAM.C[x][y] = "0f"
        end
    end
    return o
end

return canvasraw