local widget = require("gui.widget")
local textinput = {
  type = "textinput",
  default = 0,
  numOnly = false,
  hideInput = false,
}
setmetatable(textinput, widget)
textinput.__index = textinput

function textinput:draw()
  self:clear()
  self:drawFrame()
  if self.hideInput then
    self:writeTextToLocalXY('\7', 1, 1)
    self:writeTextToLocalXY(string.rep("*", string.len(self.value)), 2, 1)
  else
    if self.numOnly then
      self:writeTextToLocalXY('#', 1, 1)
    else
      self:writeTextToLocalXY('?', 1, 1)
    end
    self:writeTextToLocalXY(self.value, 2, 1)
  end


end

function textinput:handleKey(keycode, held)
  if keycode == keys.backspace then
    -- backspace
    self.hasDecimal = self.hasDecimal and tostring(self.value):sub(-1, -1) ~= '.'
    self.value = tostring(self.value):sub(1, -2)
  elseif keycode == keys.enter then
    -- enter
    return true
  end
  return false
end

function textinput:handleChar(char)
  if self.numOnly then
    if (char >= '0' and char <= '9') or (char == '.' and not self.hasDecimal) then
      if string.len(self.value) < self.maxTextLen then
        self.hasDecimal = self.hasDecimal or char == '.'
        self.value = self.value .. char
      end
    end
  else
    if string.len(self.value) < self.maxTextLen then
      self.value = self.value .. char
    end
  end
  return false
end

function textinput:handleMouseClick()
  if tonumber(self.value) and tostring(self.value):sub(-1, -1) ~= "." then
    self.value = tonumber(self.value)
  end
  return false
end

function textinput:updateSize(width, height)
  widget.updateSize(self, width, height)
  self.maxTextLen = self.size[1] - 3
end

function textinput:getValue()
  if self.numOnly and self.value == "" then
    return self.default
  elseif self.numOnly then
    return tonumber(self.value)
  end
  return self.value
end

function textinput:new(o, pos, size, p)
  o = o or {}
  o = widget:new(o, pos, size, p)
  setmetatable(o, self)
  self.__index = self
  -- TODO implement this in all the prior widgets and stuff I made so they all call widget's new function first. so that widget can handle all the default/common parameters
  o.value = ""
  o.maxTextLen = o.size[1] - 3
  o.hasDecimal = false
  o:_applyParameters(p)
  return o
end

return textinput
