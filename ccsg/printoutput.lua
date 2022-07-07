--- A widget that allows you to print data out.
-- @see widget
-- @module printoutput
local widget = require("ccsg.widget")

--- Defaults for the printoutput widget
-- @table printoutput
local printoutput = {
  type = "printoutput", -- string, used for gui packing/unpacking (must match filename without extension!)
  selectable = false, -- bool, disable interaction with this widget
  VERSION = "3.0",
  firstRun = true, -- bool, clear this on next render call
}
-- Setup inheritence
setmetatable(printoutput, widget)
printoutput.__index = printoutput

--- Draw the printoutput widget.
function printoutput:draw()
  if self.firstRun then
    self.firstRun = false
    self:clear()
  end
end

--- Scroll the printoutput widget.
function printoutput:scroll(lines)
  self.window.scroll(lines)
end

function printoutput:_scrollCursor()
  local pos = {self.window.getCursorPos()}
  pos[1] = 1
  pos[2] = pos[2] + 1
  if pos[2] > self.size[2] then
    self:scroll(1) -- at bottom of screen
    pos[2] = self.size[2]
  end
  self.window.setCursorPos(pos[1], pos[2])
end

--- Print whatever is provided to the printoutput widget.
-- Scrolls before printing
-- @tparam any ...
-- @treturn number lines printed
function printoutput:print(...)
  self:setInternalColor()
  self.window.setVisible(false)
  local lines = 1 -- guaranteed to print at least one empty line
  for k,v in ipairs(arg) do
    local string = tostring(v)
    if k > 1 then -- not first element, add a space for padding
      self.window.write(" ")
    end
    for charIndex = 1, string:len() do
      self.window.write(string:sub(charIndex, charIndex)) -- write one character at a time
      local pos = {self.window.getCursorPos()}
      if pos[1] > self.size[1] then
        self:_scrollCursor()
        lines = lines + 1
      end
    end
  end
  -- perform final newline
  self:_scrollCursor()
  self.window.setVisible(self.enable)
  return lines
end

--- Create a new printoutput widget.
-- @tparam table pos {x,y}
-- @tparam table size {width,height}
-- @tparam[opt] table p
-- @treturn table printoutput
function printoutput.new(p)
  local o = widget.new(nil, p[1] or p.pos, p[2] or p.size, p)
  setmetatable(o, printoutput)
  o.value = {}
  o.selectable = false
  o:_applyParameters(p)
  return o
end

return printoutput
