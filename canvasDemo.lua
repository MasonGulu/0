local gui = require("gui/gui")
local canvas = require("gui/canvas")
local button = require("gui/button")
local printoutput = require("gui/printoutput")
local checkbox = require("gui/checkbox")

local termsize = {term.getSize()}
local win = gui:new(nil, {canvas:new(nil, {1,1}, {termsize[1]-9, termsize[2]-4}),
                          printoutput:new(nil, {termsize[1]-9, 1}, {10, termsize[2]-6}),
                          checkbox:new(nil, {termsize[1]-9,termsize[2]-5}, {10, 1}, "Timeout"),
                          button:new(nil, {1,termsize[2]-2}, {termsize[1], 1}, "Next"),
                          button:new(nil, {1,termsize[2]-1}, {termsize[1], 1}, "Quit")}, {devMode=false, timeout=0.05})

local function print(a)
    win.widgets[2]:print(a)
end

local canvasraw = win.widgets[1].canvas
local res = canvasraw.resolution
local mode = 0
local function randomVector()
    return {math.random(res[1]), math.random(res[2])}
end

local modeDescriptions = {"Random bezier curves.",
                          "Colored random bezier curves.",
                          "Random pixel states with position dependent color.",
                          "Random colored circles"}

while true do
    local events, values = win:read()
    if values[3] then
        win.timeout = 0.05
    else
        win.timeout = false
    end
    if events == 4 then
        mode = (mode + 1) % 4
        print(modeDescriptions[mode+1])
        win.widgets[1].canvas:clear()
    elseif events == 5 then
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        term.setCursorPos(1,1)
        term.clear()
        break
    end
    
    if mode == 0 then
        win.widgets[1].canvas:clear()
        canvasraw:drawBezier(randomVector(),randomVector(),randomVector(),randomVector(),0.01,math.random(15))
    elseif mode == 1 then
        win.widgets[1].canvas:clear(true)
        canvasraw:drawBezier(randomVector(),randomVector(),randomVector(),randomVector(),0.01,math.random(15),math.random(15))
    elseif mode == 2 then
        win.widgets[1].canvas:clear()
        for x = 1, res[1] do
            for y = 1, res[2] do
                win.widgets[1]:setPixel(x,y, math.random() < 0.5, math.floor(x/2 % 16), math.floor(y/3 % 15))
            end
        end
    elseif mode == 3 then
        win.widgets[1].canvas:clear()
        for i = 1, 20 do
            canvasraw:drawCircle({math.random(res[1]), math.random(res[2])}, math.random(5,10), 0.01, math.random(15))
        end
    end

end