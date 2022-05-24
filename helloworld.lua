local gui = require("gui.gui")
local text = require("gui.text")
local button = require("gui.button")
local divider = require("gui.divider")

local win = gui:new(nil, {
  divider:new(nil,      {1,1}, {10,1}, {top=true}),
  text:new(nil,         {1,2}, {10,1}, "Hello!"),
  divider:new(nil,      {1,3}, {10,1}),
  bye = button:new(nil, {1,4}, {10,1}, "Bye!"),
  divider:new(nil,      {1,5}, {10,1}, {bottom=true})
}, {autofit=true})

while true do
 local event, values = win:read()
 if event == "bye" then
   term.clear()
   term.setCursorPos(1,1)
   return
 end
end
