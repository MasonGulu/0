-- This element will be responsible for handling all cad operations on the viewport, and all objects within the cad like lines and circles
local cad = {}

function cad:new(o, canvasWidget)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.elements = {}
  o.canvasWidget = canvasWidget
  o.resolution = { canvasWidget.canvas.resolution[1], canvasWidget.canvas.resolution[2] }
  o.ratio = {}
  o:setViewport({ 1, 1, o.resolution[1] + 1, o.resolution[2] + 1 })
  o.grid = { enabled = true, size = { 5, 5 }, offset = { 0, 0 }, color = 0 }
  return o
end

function cad:scaleXY(x, y)
  return 1 + (x - self.viewport[1]) * self.ratio[1], 1 + (y - self.viewport[2]) * self.ratio[2]
end

function cad:setViewport(newviewport)
  self.viewport = newviewport
  print(self.viewport[1])
  self.ratio[1] = self.resolution[1] / (self.viewport[3] - self.viewport[1])
  self.ratio[2] = self.resolution[2] / (self.viewport[4] - self.viewport[2])
end

function cad:newElement(element)
  table.insert(self.elements, element)
end

function cad:undo()
  table.remove(self.elements)
end

function cad:draw(iterationSize)
  self.canvasWidget:clear()
  if self.grid.enabled then
    self:drawGrid()
  end
  for index, value in ipairs(self.elements) do
    value:draw(self, iterationSize)
  end
end

function cad:drawGrid()
  for y = (self.viewport[2] - (self.viewport[2] % self.grid.size[2]) + self.grid.offset[2]), self.viewport[4], self.grid.size[2] do
    for x = (self.viewport[1] - (self.viewport[1] % self.grid.size[1]) + self.grid.offset[1]), self.viewport[3], self.grid.size[1] do
      local x1, y1 = self:scaleXY(x, y)
      self.canvasWidget:setPixel(x1, y1, true, self.grid.color, 15)
    end
  end
end

function cad:getPointAlongLine(startPos, endPos, T)
  return startPos[1] + (endPos[1] - startPos[1]) * T, startPos[2] + (endPos[2] - startPos[2]) * T
end

cad.line = {}
function cad.line:new(startPos, endPos, material)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.type = "line"
  o.startPos = startPos
  o.endPos = endPos
  o.material = material or 0
  return o
end

function cad.line:load(table)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.type = "line"
  o.startPos = table.startPos
  o.endPos = table.endPos
  o.material = table.material
  return o
end

function cad.line:getXYAtT(T)
  return cad:getPointAlongLine(self.startPos, self.endPos, T)
end

function cad.line:draw(cad, iterationSize)
  for T = 0, 1, iterationSize do
    local x, y = cad:scaleXY(self:getXYAtT(T))
    cad.canvasWidget:setPixel(x, y, true, cad.canvasWidget.canvas.colors[self.material])
  end
end

function cad.line:saveString()
  return { self.type, self.startPos, self.endPos, self.material }
end

cad.quadratic = {}
function cad.quadratic:new(startPos, weight1Pos, endPos, material)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.type = "quadratic"
  o.startPos = startPos
  o.endPos = endPos
  o.weight1Pos = weight1Pos
  o.material = material or 0
  return o
end

function cad.quadratic:load(table)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.type = "quadratic"
  o.startPos = table.startPos
  o.weight1Pos = table.weight1Pos
  o.endPos = table.endPos
  o.material = table.material
  return o
end

function cad.quadratic:getXYAtT(T)
  local A = { cad:getPointAlongLine(self.startPos, self.weight1Pos, T) }
  local B = { cad:getPointAlongLine(self.weight1Pos, self.endPos, T) }

  return cad:getPointAlongLine(A, B, T)
end

function cad.quadratic:draw(cad, iterationSize)
  for T = 0, 1, iterationSize do
    local x, y = cad:scaleXY(self:getXYAtT(T))
    cad.canvasWidget:setPixel(x, y, true, cad.canvasWidget.canvas.colors[self.material])
  end
end

function cad.quadratic:saveString()
  return { self.type, self.startPos, self.endPos, self.material }
end

cad.bezier = {}
function cad.bezier:new(startPos, weight1Pos, weight2Pos, endPos, material)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.type = "bezier"
  o.startPos = startPos
  o.endPos = endPos
  o.weight1Pos = weight1Pos
  o.weight2Pos = weight2Pos
  o.material = material or 0
  return o
end

function cad.bezier:load(table)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.type = "bezier"
  o.startPos = table.startPos
  o.weight1Pos = table.weight1Pos
  o.weight2Pos = table.weight2Pos
  o.endPos = table.endPos
  o.material = table.material
  return o
end

function cad.bezier:getXYAtT(T)
  local A = { cad:getPointAlongLine(self.startPos, self.weight1Pos, T) }
  local B = { cad:getPointAlongLine(self.weight1Pos, self.weight2Pos, T) }
  local C = { cad:getPointAlongLine(self.weight2Pos, self.endPos, T) }

  return cad:getPointAlongLine({ cad:getPointAlongLine(A, B, T) }, cad:getPointAlongLine(B, C, T), T)
end

function cad.bezier:draw(cad, iterationSize)
  for T = 0, 1, iterationSize do
    local x, y = cad:scaleXY(self:getXYAtT(T))
    cad.canvasWidget:setPixel(x, y, true, cad.canvasWidget.canvas.colors[self.material])
  end
end

function cad.bezier:saveString()
  return { self.type, self.startPos, self.endPos, self.material }
end

cad.circle = {}
function cad.circle:new(pos, radius, material)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.type = "circle"
  o.pos = pos
  o.radius = radius
  o.material = material or 0
  return o
end

function cad.circle:load(table)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.type = "circle"
  o.pos = table.pos
  o.radius = table.radius
  o.material = table.material
  return o
end

function cad.circle:getXYAtT(T)
  local x = self.pos[1] + self.radius * math.cos(T)
  local y = self.pos[2] + self.radius * math.sin(T)
  return x, y
end

function cad.circle:draw(cad, iterationSize)
  for T = 0, 2 * math.pi, iterationSize do
    local x, y = cad:scaleXY(self:getXYAtT(T))
    cad.canvasWidget:setPixel(x, y, true, cad.canvasWidget.canvas.colors[self.material])
  end
end

function cad.circle:saveString()
  return { self.type, self.pos, self.radius, self.material }
end

cad.rect = {}
function cad.rect:new(x1, y1, width, height, filled, material)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.type = "rect"
  o.pos = { x1, y1 }
  o.size = { width, height }
  o.filled = filled
  o.material = material or 0
  return o
end

function cad.rect:load(table)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.type = "rect"
  o.pos = table.pos
  o.size = table.size
  o.filled = table.filled
  o.material = table.material
  return o
end

function cad.rect:draw(cad, iterationSize)
  if self.filled then
    for dx = 0, self.size[1] - 1, iterationSize do
      for dy = 0, self.size[2] - 1, iterationSize do
        local x, y = cad:scaleXY(self.pos[1] + dx, self.pos[2] + dy)
        cad.canvasWidget:setPixel(x, y, true, cad.canvasWidget.canvas.colors[self.material])
      end
    end
  else
    for dx = 0, self.size[1] - 1, iterationSize do
      local x, y = cad:scaleXY(self.pos[1] + dx, self.pos[2])
      cad.canvasWidget:setPixel(x, y, true, cad.canvasWidget.canvas.colors[self.material])
      x, y = cad:scaleXY(self.pos[1] + dx, self.pos[2] + self.size[2] - 1)
      cad.canvasWidget:setPixel(x, y, true, cad.canvasWidget.canvas.colors[self.material])
    end
    for dy = 0, self.size[2] - 1, iterationSize do
      local x, y = cad:scaleXY(self.pos[1], self.pos[2] + dy)
      cad.canvasWidget:setPixel(x, y, true, cad.canvasWidget.canvas.colors[self.material])
      x, y = cad:scaleXY(self.pos[1] + self.size[1] - 1, self.pos[2] + dy)
      cad.canvasWidget:setPixel(x, y, true, cad.canvasWidget.canvas.colors[self.material])
    end
  end
end

function cad.rect:saveString()
  return { self.type, self.pos, self.size, self.filled, self.material }
end

return cad
