local gui = require("gui/gui") -- required
local text = require("gui/text")
local button = require("gui/button")

local win = gui:new(nil, {text:new(nil, {1,1}, {14,3}, "Hello World!"), button:new(nil, {1,3}, {14,3}, "Quit!")}, {timeout=0.10,devMode=true})

while true do
    local events, values = win:read()
    if events == 2 then
        -- The "Quit!" button was pressed.
        term.clear()
        term.setCursorPos(1,1)
        break
    end
end