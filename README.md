# GUI Library for ComputerCraft:Tweaked

This is a GUI library loosely inspired by PySimpleGUI intended for CC:Tweaked, but should function on just about any version of CC.

for more documentation see https://docs.google.com/document/d/1LMWfQ-tIe_AFUXph0VzJAEO2LVjeUGOOEspEsPrypEo/edit?usp=sharing

## Quickstart

Add the gui/ directory to your CC computer, include gui.lua, widget.lua, and any widget/extension files you'd like. To create a gui program first include what you require.

    local gui = require("gui/gui") -- required
    local text = require("gui/text")
    local button = require("gui/button")

Then create your window table/object

    local win = gui:new(nil, {text:new(nil, {1,1}, {13,3}, "Hello World!"), button:new(nil, {1,3}, {13,3}, "Quit!")}, {timeout=0.10})

The first parameter is an existing gui table, in this case we're creating a brand new one, so leave it `nil`. The second argument is a table of widgets, I set up a text and a button widget. The third argument is optional, it's a list of initial starting parameters for the gui, in this case I'm setting an auto timeout so the code will run either every 0.10 seconds, or anytime an event occurs. There is a `devMode` parameter, which when true allows dragging and resizing widgets with left/right click and will print out information about the selected widget on a middle click.

And finally set up your event loop.

    while true do
        local events, values = win:read()
        if events == 2 then
            -- The "Quit!" button was pressed.
            term.clear()
            term.setCursorPos(1,1)
            break
        end
    end

In this snippet `events` contains either a `number`, `string` or `nil`, if it contains anything other than nil then that is the index of the widget which was interracted with. `values` contains a table of the values of each widget at the moment win:read returns.

## Included example programs

* kinda works? canvasDemo.lua - a simple program that shows the capabilities of the canvas widget.
* helloworld.lua - a sample program

## Unrelated information

* docedit.lua - a 15 color document editor, saves files in a special format. Allows for color printing with a very specific computer setup, (There are pictures of it)
* printing/printerController.lua - the main executable that each printer computer runs, uploaded from a host computer on boot.
* printing/printerManager.lua - the control script for a main host printing computer.
* printing/printerStartup.lua - put in each printer as startup.lua


* DO NOT USE! UNUPDATED! cad.lua - [ADVANCED!] a 'cli' CAD interface that uses the textinput widget (swapping numOnly on the fly!), printoutput widget, and cadExtension for the canvas widget.