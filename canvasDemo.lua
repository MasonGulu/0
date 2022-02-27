local gui = require("gui/gui")
local canvas = require("gui/canvas")

local a = gui:new(nil, {canvas:new(nil, {1,1}, {term.getSize()})}, {devMode=false, timeout=0.05})

while true do
    local events, values, b = a:read()
    a.widgets[1].canvas:clear()
    local canvasraw = a.widgets[1].canvas
    local res = canvasraw.resolution
    for x = 1, res[1] do
        for y = 1, res[2] do
            a.widgets[1]:setPixel(x,y, math.random() < 0.5, math.floor(x/2 % 16), math.floor(y/3 % 15))
        end
    end

end