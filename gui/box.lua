--- A low level object that manages boxes and frames.
-- @module box

local box = {}

--- Draw the walls of the box.
-- @param horizontalChar the character to use for the top and bottom walls, optional defaults to '-'
-- @param verticalChar the character to use for the left and right walls, optional defaults to '|'
function box:drawWalls(horizontalChar, verticalChar)
    horizontalChar = horizontalChar or '-'
    verticalChar = verticalChar or '|'
    self.device.setCursorPos(self.pos[1], self.pos[2])
    self.device.write(string.rep(horizontalChar, self.size[1]))
    self.device.setCursorPos(self.pos[1], self.pos[2]+self.size[2]-1)
    self.device.write(string.rep(horizontalChar, self.size[1]))
    for y = 1, self.size[2]-1 do
        self.device.setCursorPos(self.pos[1], y+self.pos[2])
        self.device.write(verticalChar)
        self.device.setCursorPos(self.pos[1]+self.size[1]-1, y+self.pos[2])
        self.device.write(verticalChar)
    end
end

--- Draw the corners of the box.
-- @param char the caracter to use for the corners.
function box:drawCorners(char)
    char = char or "+"
    self.device.setCursorPos(self.pos[1], self.pos[2])
    self.device.write(char)
    self.device.setCursorPos(self.pos[1]+self.size[1]-1, self.pos[2])
    self.device.write(char)
    self.device.setCursorPos(self.pos[1], self.pos[2]+self.size[2]-1)
    self.device.write(char)
    self.device.setCursorPos(self.pos[1]+self.size[1]-1, self.pos[2]+self.size[2]-1)
    self.device.write(char)
end

--- Clear the internal space of the box.
function box:clearInside()
    for y = 1, self.size[2]-2 do
        self.device.setCursorPos(self.pos[1]+1, self.pos[2]+y)
        self.device.write(string.rep(" ", self.size[1]-2))
    end
end

--- Create a box object.
-- @param o original object, usually set to `nil`
-- @param pos table {x,y}
-- @param size table {width,height}
-- @param device the device to display the box on, usually `term`
-- @return a box object
function box:new(o, pos, size, device)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.pos = pos
    o.size = size
    o.device = device or term
    return o
end

return box