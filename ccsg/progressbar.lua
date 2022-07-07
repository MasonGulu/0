--- A progressbar widget.
-- Inherits from the widget object.
-- @see widget
-- @module progressbar
local widget = require("ccsg.widget")

--- Defaults for the progressbar widget
-- @table progressbar
local progressbar = {
  type = "progressbar", -- string, used for gui packing/unpacking (must match filename without extension!)
  fullChar = "\127", -- character to use for full segments
  halfChar = "\149", -- character to use for >half segments
  selectable = false,
  VERSION = "3.0",
}
-- Setup inheritence
setmetatable(progressbar, widget)
progressbar.__index = progressbar

--- Draw the progressbar widget.
function progressbar:draw()
  self:clear()
  local percentage = self.value / self.maxValue
  local fullCharactersFloat = percentage * (self.size[1])
  local preppedString = string.rep(self.fullChar, math.floor(fullCharactersFloat))
  if (fullCharactersFloat > (math.floor(fullCharactersFloat) + 0.5)) then
    preppedString = preppedString..self.halfChar
  end
  self:write(preppedString,1,1)
end

--- Update value of progressbar
-- The progress bar will display value/maxValue
-- @tparam number value
function progressbar:updateValue(value)
  self.value = math.min(value, self.maxValue)
end

--- Update maxValue or parameters
-- current value is capped by maxValue
-- @tparam number maxValue
-- @tparam[opt] table p
function progressbar:updateParameters(p)
  if p.maxValue then
    self.value = math.min(self.value, p.maxValue)
  end
  self:_applyParameters(p)
end

--- Create a new progressbar widget.
-- @tparam table p requires maxValue
-- @treturn table progressbar
function progressbar.new(p)
  assert(type(p.maxValue) == "number", "Progressbar requires a maxValue")
  local o = widget.new(nil, p[1] or p.pos, p[2] or p.size, p)
  setmetatable(o, progressbar)
  o:_applyParameters(p)
  o.maxValue = p.maxValue
  o.value = 0
  return o
end

return progressbar
