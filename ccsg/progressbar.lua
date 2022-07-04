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
  VERSION = "2.0",
}
-- Setup inheritence
setmetatable(progressbar, widget)
progressbar.__index = progressbar

--- Draw the progressbar widget.
function progressbar:draw()
  self:clear()
  self:drawFrame()
  local percentage = self.value / self.maxValue
  local fullCharactersFloat = percentage * (self.size[1]-2)
  local preppedString = string.rep(self.fullChar, math.floor(fullCharactersFloat))
  if (fullCharactersFloat > (math.floor(fullCharactersFloat) + 0.5)) then
    preppedString = preppedString..self.halfChar
  end
  self:writeTextToLocalXY(preppedString,1,1)
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
function progressbar:updateParameters(maxValue, p)
  self.value = math.min(self.value, maxValue)
  self.maxValue = maxValue
  self:_applyParameters(p)
end

--- Create a new progressbar widget.
-- @tparam table pos {x,y}
-- @tparam table size {width,height}
-- @tparam number maxValue
-- @tparam[opt] table p
-- @treturn table progressbar
function progressbar.new(pos, size, maxValue, p)
  local o = widget.new(nil, pos, size, p)
  setmetatable(o, progressbar)
  o:_applyParameters(p)
  o.maxValue = maxValue
  o.value = 0
  return o
end

return progressbar
