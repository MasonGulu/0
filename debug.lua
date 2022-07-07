local gui = require"ccsg.gui"
local printoutput = require"ccsg.printoutput"
local button = require"ccsg.button"
local checkbox = require"ccsg.checkbox"
local scrollinput = require"ccsg.scrollinput"
local listbox     = require "ccsg.listbox"
local progressbar = require "ccsg.progressbar"
local textinput   = require "ccsg.textinput"

local options = {"Option1","Option2","Option3"}

local win = gui.new({
  p=printoutput.new{{1,1},{10,5}},
  b=button.new{{1,6},{10,1},label="Button!"},
  checkbox.new{{1,7},{10,1},label="Checkbox"},
  scrollinput.new{{1,8},{10,1},options=options},
  listbox.new{{11,1},{10,5},options=options},
  pb = progressbar.new{{11,6},{10,1},maxValue=10},
  textinput.new{{11,7},{10,1}},
  textinput.new{{11,8},{10,1},hideInput=true},
},{autofit=true})

local i = 0

while true do
  win:read()
  win.widgets.p:print(i, "Hello")
  i = (i + 1) % 10
  win.widgets.pb:updateValue(i)
end