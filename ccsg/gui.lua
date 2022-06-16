local gui = {
  disableBuffering = false,
  devMode = false,
  device = term,
  timeout = nil,
  autofit = false,
}

local errorBack = error
function error(message, level)
  term.setCursorPos(1, 1)
  term.clear()
  errorBack(message, level)
end

function gui:_draw()
  for key, v in pairs(self.widgets) do
    if v.enable then
      v.device.setVisible(self.disableBuffering)
      v:draw()
      v.device.setVisible(true)
    else
      v.device.setVisible(false)
    end
  end
  self.widgets[self.focusedWidget].device.setVisible(self.disableBuffering)
  self.widgets[self.focusedWidget]:draw() -- Double draw call, but whatever
  self.widgets[self.focusedWidget].device.setVisible(true)
end

function gui:_isXYonWidget(x, y, widget)
  if x >= widget.pos[1] and y >= widget.pos[2] and x < widget.pos[1] + widget.size[1] and y < widget.pos[2] + widget.size[2] then
    return true
  end
  return false
end

function gui:read()
  if self.completeRedraw then
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.clear()
    self.completeRedraw = false
  end
  self:_draw()
  local values = {}
  local timerID = -1
  if self.timeout then
    timerID = os.startTimer(self.timeout)
  end
  local event, a, b, c, d = os.pullEvent()
  os.cancelTimer(timerID)
  local eventn = false
  if event == "mouse_click" then
    if self.devMode and a == 3 then
      term.clear()
      term.setCursorPos(1, 1)
      print("The widget focused has")
      print("index", self.focusedWidget)
      print("x", self.widgets[self.focusedWidget].pos[1], "y", self.widgets[self.focusedWidget].pos[2])
      print("width", self.widgets[self.focusedWidget].size[1], "height", self.widgets[self.focusedWidget].size[2])
      print("Push enter to continue.")
      io.read()
      self.completeRedraw = true
    elseif self:_isXYonWidget(b, c, self.widgets[self.focusedWidget]) and self.widgets[self.focusedWidget].enable then
      if self.widgets[self.focusedWidget]:handleMouseClick(a, b, c, d) then eventn = self.focusedWidget end
    else
      for key, v in pairs(self.widgets) do
        if self:_isXYonWidget(b, c, v) and v.enable and (v.selectable or self.devMode) then
          self.widgets[self.focusedWidget]:setFocus(false)
          self.focusedWidget = key
          v:setFocus(true)
          if v:handleMouseClick(a, b, c, d) then eventn = key end
          break
        end
      end
    end
  elseif event == "key" then
    if a == keys.tab then
      self.selectedWidgetIndex = self.selectedWidgetIndex + 1
      if self.selectedWidgetIndex > #self.selectableWidgetKeys then
        self.selectedWidgetIndex = 1
      end
      self.widgets[self.focusedWidget]:setFocus(false)
      self.focusedWidget = self.selectableWidgetKeys[self.selectedWidgetIndex]
      self.widgets[self.focusedWidget]:setFocus(true)

    else
      if self.widgets[self.focusedWidget]:handleKey(a, b, c, d) then eventn = self.focusedWidget end
    end
  elseif event == "mouse_scroll" then
    if self.widgets[self.focusedWidget]:handleMouseScroll(a, b, c) then eventn = self.focusedWidget end
  elseif event == "char" then
    self.widgets[self.focusedWidget]:handleChar(a, b, c, d)
  elseif event == "paste" then
    self.widgets[self.focusedWidget]:handlePaste(a)
  elseif event == "mouse_drag" then
    if self.devMode then
      if a == 1 then
        -- left click, move
        self.widgets[self.focusedWidget]:updatePos(b, c)
        self.completeRedraw = true
      elseif a == 2 then
        -- right click, resize
        local pos = self.widgets[self.focusedWidget].pos
        local newWidth, newHeight = self.widgets[self.focusedWidget].size[1], self.widgets[self.focusedWidget].size[2]
        if b - pos[1] > 3 then newWidth = b - pos[1] + 1 else newWidth = 3 end
        if c - pos[2] > 1 then newHeight = c - pos[2] + 1 else newHeight = 1 end
        self.widgets[self.focusedWidget]:updateSize(newWidth, newHeight)
        self.completeRedraw = true
      end
    end
  elseif event == "term_resize" and self.autofit then
    self:doAutofit()
  else
    self.widgets[self.focusedWidget]:otherEvent({event,a,b,c,d})
  end
  for key, v in pairs(self.widgets) do
    values[key] = v:getValue()
  end
  return eventn, values, { event, a, b, c, d }
end

function gui:doAutofit()
  local yMax = 0
  local xMax = 0
  local yMin = math.huge
  local xMin = math.huge
  for key, value in pairs(self.widgets) do
    local xPos, yPos = table.unpack(value.pos)
    local width, height = table.unpack(value.size)
    yMax = math.max(yPos + height, yMax)
    yMin = math.min(yPos, yMin)
    xMax = math.max(xPos + width, xMax)
    xMin = math.min(xPos, xMin)
  end
  local width, height = self.device.getSize()
  local guiWidth = xMax - xMin + 1
  local guiHeight = yMax - yMin + 1
  local startingYPos = math.ceil((height - guiHeight) / 2) - yMin + 1
  local startingXPos = math.ceil((width - guiWidth) / 2) - xMin + 1
  for key, value in pairs(self.widgets) do
    value:updatePos(value.pos[1] + startingXPos, value.pos[2] + startingYPos)
  end
  self.completeRedraw = true
end

-- @param o original object, usually set to `nil`
function gui:new(o, widgets, parameters)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.widgets = widgets
  o.selectableWidgetKeys = {}
  for key, value in pairs(o.widgets) do
    if value.selectable then
      table.insert(o.selectableWidgetKeys, key)
    end
  end
  if #o.selectableWidgetKeys == 0 then
    error("Widgets must contain at least one selectable widget!")
  end
  o.selectedWidgetIndex = 1
  local widgetKey = o.selectableWidgetKeys[1]
  o.widgets[widgetKey]:setFocus(true)
  o.focusedWidget = widgetKey
  o.completeRedraw = true

  if type(parameters) == "table" then
    for key, value in pairs(parameters) do
      o[key] = value
    end
    if parameters.theme then
      for key, value in pairs(o.widgets) do
        value.theme = parameters.theme
      end
    end
  end

  if o.autofit then
    o:doAutofit()
  end

  return o
end

return gui
