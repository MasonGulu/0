local gui = require("gui.gui")
local sg = require("gui.ccsimplegui")
local popup = require("gui.popup")

local loadedWidgets = {
  button = require("gui.button"),
  divider = require("gui.divider"),
  checkbox = require("gui.checkbox"),
  listbox = require("gui.listbox"),
  scrollinput = require("gui.scrollinput"),
  text = require("gui.text"),
  textinput = require("gui.textinput"),
}

local workingGUI = {
  widgets = {
    {sg.top()},
    {sg.textinput("h")},
    {sg.textinput("e",1,{numOnly=true, hasDecimal=true})},
    {sg.textinput("b",1,{hideInput=true})},
    {sg.bottom()}
  },
  width = 0.5, -- percentage of terminal width when "relative" mode, or characters in "absolute"
}

-- First ask for some gui parameters, or eventually to load a file

local win = sg.new({widgets={
  {sg.top()},
  {sg.textinput("width",nil,{numOnly=true,default=1})},
  {sg.button("Continue", "submit")},
  {sg.bottom()}
}, width=1})

local winEvent, values
repeat
  winEvent, values = win:read()
until winEvent == "submit"

workingGUI.width = values.width

local win2 = sg.new(workingGUI)
repeat
  winEvent, values = win2:read()
until winEvent