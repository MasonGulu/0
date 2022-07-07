--- A text displaying widget.
-- Text is autowrapped to fit into the area of the widget.
-- Inherits from the widget object.
-- @see widget
-- @module text
local widget = require("ccsg.widget")

--- Defaults for the text widget
-- @table marquee
local marquee = {
  type = "marquee",-- string, used for gui packing/unpacking (must match filename without extension!)
  selectable = false, -- bool, disable interaction with this widget
  VERSION = "3.0",
}
-- Setup inheritence
setmetatable(marquee, widget)
marquee.__index = marquee

--- Draw the marquee widget.
function marquee:draw()
  self:clear()
  self.label = self.label:sub(2, #self.label) .. self.label:sub(1, 1)
  self:write(self.label, 1, 1)
end

local function padString(string, len)
  while string:len() < len do
    string = string.." "
  end
  return string
end

--- Update size of text widget
-- @tparam int width
-- @tparam int height
function marquee:updateSize(width, height)
  widget.updateSize(self, width, height)
  self.label = padString(self.label, self.size[1])
end

--- Update parameters
-- @tparam string string
-- @tparam[opt] table p
function marquee:updateParameters(string, p)
  self:_applyParameters(p)
  self.label = padString(self.label, self.size[1])
end

--- Create a new marquee widget.
-- @tparam table p requires label
-- @treturn table marquee object
function marquee.new(p)
  p.label = p.label or p[3]
  assert(p.label ~= nil, "Marquee requires a label")
  local o = widget.new(nil, p[1] or p.pos, p[2] or p.size, p)
  setmetatable(o, marquee)
  o:_applyParameters(p)
  o.label = padString(o.label, o.size[1])
  return o
end

return marquee
