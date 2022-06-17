local gui = require("ccsg.gui") -- required
local text = require("ccsg.text")
local button = require("ccsg.button")
local divider = require("ccsg.divider")

local win = gui.new({
  divider.new({1,1}, {14,1}, {top=true}), -- setup a nice top border
  text.new({1,2}, {14,1}, "Hello World!"), 
  quit = button.new({1,3}, {14,1}, "Quit!"), -- the quit button is accessed through a key
  divider.new({1,4}, {14,1}, {bottom=true})}, -- and a nice bottom border
  {autofit=true})

while true do
  local events, values = win:read()
  if events == "quit" then
    -- The "Quit!" button was pressed.
    term.clear()
    term.setCursorPos(1,1)
    break
  end
end