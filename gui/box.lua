local box = {}

function box:drawWalls()
    self.device.setCursorPos(self.pos[1], self.pos[2])
    self.device.write(string.rep('-', self.size[1]))
    self.device.setCursorPos(self.pos[1], self.pos[2]+self.size[2]-1)
    self.device.write(string.rep('-', self.size[1]))
    for y = 1, self.size[2]-1 do
        self.device.setCursorPos(self.pos[1], y+self.pos[2])
        self.device.write('|')
        self.device.setCursorPos(self.pos[1]+self.size[1]-1, y+self.pos[2])
        self.device.write('|')
    end
end

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

function box:clearInside()
    for y = 1, self.size[2]-2 do
        self.device.setCursorPos(self.pos[1]+1, self.pos[2]+y)
        self.device.write(string.rep(" ", self.size[1]-2))
    end
end

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