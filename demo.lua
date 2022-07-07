local gui = require"ccsg.gui"
local printoutput = require"ccsg.printoutput"
local button = require"ccsg.button"
local checkbox = require"ccsg.checkbox"
local scrollinput = require"ccsg.scrollinput"
local listbox     = require "ccsg.listbox"
local progressbar = require "ccsg.progressbar"
local textinput   = require "ccsg.textinput"
local text        = require "ccsg.text"
local marquee     = require "ccsg.marquee"

local options = {"Option1","Option2","Option3","4","5","6"}

local win = gui.new({
  p=printoutput.new{{11,1},{10,5}},
  marquee.new{{11,6},{10,1},label="Oh a marquee!"},
  pb = progressbar.new{{11,7},{10,1},maxValue=100},
  text.new{{11,8},{10,1},label="TEXT!"},

  listbox.new{{1,1},{10,3},options=options},
  b=button.new{{1,4},{10,1},label="Button!"},
  checkbox.new{{1,5},{10,1},label="Checkbox"},
  scrollinput.new{{1,6},{10,1},options=options},
  textinput.new{{1,7},{10,1}},
  textinput.new{{1,8},{10,1},hideInput=true},
},{autofit=true, theme = gui.themes.bios, timeout = 0})

local i = 0

while true do
  win:read()
  win.widgets.p:print(i, "Hello")
  i = (i + 5) % 101
  win.widgets.pb:updateValue(i)
end