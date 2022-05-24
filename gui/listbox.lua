local widget = require("gui.widget")
local listbox = {
  type = "listbox",
  minSelected = 1,
  maxSelected = 1,
  _selectedAmount = 0,
  deselectOldSelections = true, -- deselect the last selected element to make room for the next element
  scrollOffset = 0,
  enable_events = true
}
setmetatable(listbox, widget)
listbox.__index = listbox

function listbox:draw()
  self:clear()
  self:drawFrame()
  self:writeTextToLocalXY(string.char(30), self.size[1] - 2, 1)
  self:writeTextToLocalXY(string.char(31), self.size[1] - 2, self.size[2])
  for key, value in ipairs(self.T) do
    -- print(key,value,self.scrollOffset)
    self.device.setCursorPos(2, key - self.scrollOffset)
    self:setInternalColor(self.value[key] == true)
    self.device.write(tostring(value):sub(1, self.size[1] - 3))
    self:setPreviousColor()
  end
end

local function getIndexOfItemInList(list, item)
  for index, v in pairs(list) do
    if v == item then
      return index
    end
  end
  return 0
end

function listbox:_selectElement(elementIndex)
  elementIndex = math.min(elementIndex, #self.T)
  if type(self.value[elementIndex]) == "boolean" then
    if not self.value[elementIndex] and self._selectedAmount < self.maxSelected then
      -- this element would normally get selected AND we have space to select it
      self.value[elementIndex] = true
      self._selectedAmount = self._selectedAmount + 1
      self._selectedOrder[#self._selectedOrder + 1] = elementIndex
    elseif not self.value[elementIndex] and self.deselectOldSelections then
      -- deselect the oldest selected element
      self.value[table.remove(self._selectedOrder, 1)] = false
      self.value[elementIndex] = true
      self._selectedOrder[#self._selectedOrder + 1] = elementIndex
    elseif self._selectedAmount > self.minSelected then
      -- Either this element was being deselected, or we tried to select it but didn't have the space
      -- make sure that we *can* deselect an element first
      if self.value[elementIndex] then
        self._selectedAmount = self._selectedAmount - 1
        local elementSelectOrderIndex = getIndexOfItemInList(self._selectedOrder, elementIndex)
        table.remove(self._selectedOrder, elementSelectOrderIndex)
      end
      self.value[elementIndex] = false
    end
  elseif self._selectedAmount < self.maxSelected then
    self.value[elementIndex] = true
    self._selectedAmount = self._selectedAmount + 1
  elseif self.deselectOldSelections then
    self.value[table.remove(self._selectedOrder, 1)] = false
    self.value[elementIndex] = true
    self._selectedOrder[#self._selectedOrder + 1] = elementIndex
  end
end

function listbox:handleMouseClick(mouseButton, mouseX, mouseY)
  local x, y = self:convertGlobalXYToLocalXY(mouseX, mouseY)

  if x == self.size[1] - 2 then
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
      if self.scrollOffset > #self.T - 1 then
        self.scrollOffset = #self.T - 1
      end
    end
  elseif x > 1 and x < self.size[1] - 2 and mouseButton == 1 then
    -- Click is on an element
    self:_selectElement(y + self.scrollOffset)
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
    if self.scrollOffset > #self.T - 1 then
      self.scrollOffset = #self.T - 1
    end
  elseif code == keys.enter then
    self:_selectElement(self.scrollOffset + 1)
    return self.enable_events
  end
  return false
end

function listbox:handleMouseScroll(scrollDirection)
  if scrollDirection == 1 then
    self.scrollOffset = self.scrollOffset + 1
    if self.scrollOffset > #self.T - 1 then
      self.scrollOffset = #self.T - 1
    end
  elseif scrollDirection == -1 then
    self.scrollOffset = self.scrollOffset - 1
    if self.scrollOffset < 0 then
      self.scrollOffset = 0
    end
  end
  return false
end

function listbox:updateParameters(T, p)
  self.T = T
  self.value = {}
  self.scrollOffset = 0
  self:_applyParameters(p)
  local i = 1
  while (self._selectedAmount < self.minSelected) do
    self.value[i] = true
    self._selectedOrder[#self._selectedOrder + 1] = i
    self._selectedAmount = self._selectedAmount + 1
    i = i + 1
  end
end

function listbox:getValue()
  local returnValue = {}
  for key, value in pairs(self.value) do
    if value then
      returnValue[#returnValue + 1] = key
    end
  end
  return returnValue
end

function listbox:new(o, pos, size, T, p)
  -- takes an ordered table of string displayable objects, value is the index of the selected element
  o = o or {}
  o = widget:new(o, pos, size, p)
  setmetatable(o, self)
  self.__index = self
  -- TODO implement this in all the prior widgets and stuff I made so they all call widget's new function first. so that widget can handle all the default/common parameters
  o.T = T
  o.value = {}
  o._selectedOrder = {} -- start -> end = oldest -> newest selected
  o.textWidth = o.size[2] - 3
  o:_applyParameters(p)
  local i = 1
  while (o._selectedAmount < o.minSelected) do
    o.value[i] = true
    o._selectedOrder[#o._selectedOrder + 1] = i
    o._selectedAmount = o._selectedAmount + 1
    i = i + 1
  end
  o._selectedAmount = o.minSelected
  return o
end

return listbox
