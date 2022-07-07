--- A scrollable widget that allows selection of multiple elements from a list.
-- Inherits from the widget object.
-- @see widget
-- @module listbox
local widget = require("ccsg.widget")

-- @table listbox defaults for the listbox widget
local listbox = {
  type = "listbox", -- string, used for gui packing/unpacking (must match filename without extension!)
  minSelected = 1, -- int, maximum elements selected 1 default
  maxSelected = 1, -- int, minimum elements selected 1 default
  _selectedAmount = 0,
  deselectOldSelections = true, -- deselect the last selected element to make room for the next element, true default
  _scrollOffset = 0,
  enable_events = true, -- bool, events are enabled by default for listboxes
  VERSION = "3.0",
}

-- Setup inheritence
setmetatable(listbox, widget)
listbox.__index = listbox

--- Draw the listbox widget.
function listbox:draw()
  self:clear()
  self:writeClickable(string.char(30), self.size[1], 1)
  self:writeClickable(string.char(31), self.size[1], self.size[2])
  for key, value in ipairs(self.options) do
    if (self.value[key] == true) then
      self:writeClickable(tostring(value):sub(1, self.size[1] - 1), 1, key - self._scrollOffset)
    else
      self:write(tostring(value):sub(1, self.size[1] - 1), 1, key - self._scrollOffset)
    end
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
  elementIndex = math.min(elementIndex, #self.options)
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

--- Handle mouse_click events
-- @tparam number mouseButton
-- @tparam number mouseX
-- @tparam number mouseY
-- @treturn boolean element has been selected/deselected and enable_events
function listbox:handleMouseClick(mouseButton, mouseX, mouseY)
  local x, y = self:convertGlobalXYToLocalXY(mouseX, mouseY)

  if x == self.size[1] then
    -- Click is on the sidebar
    if y == 1 then
      -- up
      self._scrollOffset = self._scrollOffset - 1
      if self._scrollOffset < 0 then
        self._scrollOffset = 0
      end
    elseif y == self.size[2] then
      -- down
      self._scrollOffset = self._scrollOffset + 1
      if self._scrollOffset > #self.options - 1 then
        self._scrollOffset = #self.options - 1
      end
    end
  elseif x > 1 and x < self.size[1] and mouseButton == 1 then
    -- Click is on an element
    self:_selectElement(y + self._scrollOffset)
    return self.enable_events
  end
  return false
end

--- Handle key events
-- @tparam int code
-- @tparam bool held
-- @treturn bool enter is used to toggle selection of an element and enable_events
function listbox:handleKey(code, held)
  if code == keys.up then
    self._scrollOffset = self._scrollOffset - 1
    if self._scrollOffset < 0 then
      self._scrollOffset = 0
    end
  elseif code == keys.down then
    -- down
    self._scrollOffset = self._scrollOffset + 1
    if self._scrollOffset > #self.options - 1 then
      self._scrollOffset = #self.options - 1
    end
  elseif code == keys.enter then
    self:_selectElement(self._scrollOffset + 1)
    return self.enable_events
  end
  return false
end

--- Event handler function called when a mouse_scroll event occurs with the widget focused
-- @tparam int direction
-- @tparam int mouseX global X
-- @tparam int mouseY global Y
-- @treturn bool this widget wants to notify an event occured
function listbox:handleMouseScroll(direction, mouseX, mouseY)
  if direction == 1 then
    self._scrollOffset = self._scrollOffset + 1
    if self._scrollOffset > #self.options - 1 then
      self._scrollOffset = #self.options - 1
    end
  elseif direction == -1 then
    self._scrollOffset = self._scrollOffset - 1
    if self._scrollOffset < 0 then
      self._scrollOffset = 0
    end
  end
  return false
end

--- Update table and parameters
-- @tparam table T table of selections
-- @tparam[opt] table p
function listbox:updateParameters(p)
  if p.options then
    if #p.options < #self.options then
      -- list is smaller
      self.value = {}
      self._scrollOffset = 0
      self._selectedOrder = {}
      self._selectedAmount = 0
    end
    self.options = p.options
    self._scrollOffset = math.max(math.min(self._scrollOffset, #self.options-1),0)
    local i = 1
    while (self._selectedAmount < self.minSelected) do
      self.value[i] = true
      self._selectedOrder[#self._selectedOrder + 1] = i
      self._selectedAmount = self._selectedAmount + 1
      i = i + 1
    end
  end
  self:_applyParameters(p)
end

--- Get listbox's value
-- @treturn table integer indexed array of selected options
function listbox:getValue()
  local returnValue = {}
  for key, value in pairs(self.value) do
    if value and key <= #self.options then
      returnValue[#returnValue + 1] = key
    elseif key > #self.options then
      self.value[key] = nil
    end
  end
  return returnValue
end

--- Create a new divider widget.
-- @tparam table p requires options
-- @treturn table divider
function listbox.new(p)
  -- takes an ordered table of string displayable objects, value is the index of the selected element
  p.options = p.options or p[3]
  assert(p.options ~= nil, "Listbox requires options")
  local o = widget.new(nil, p[1] or p.pos, p[2] or p.size, p)
  setmetatable(o, listbox)
  o.value = {}
  o._selectedOrder = {} -- start -> end = oldest -> newest selected
  o.textWidth = o.size[2] - 1
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
