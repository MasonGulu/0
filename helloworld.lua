local gui = require("ccsg.gui") -- required
local text = require("ccsg.text")
local button = require("ccsg.button")

local win = gui.new({
  text.new{{1,1}, {14,1}, label = "Hello World!"},
  quit = button.new{{1,3}, {14,1}, label = "Quit!"}, -- the quit button is accessed through a key
}, {autofit=true})

while true do
  local events, values = win:read()
  if events == "quit" then
    -- The "Quit!" button was pressed.
    term.clear()
    term.setCursorPos(1,1)
    break
  end
end