local gui = require("gui/gui")
local canvas = require("gui/canvas")
local textinput = require("gui/textinput")
local printoutput = require("gui/printoutput")
local cadLib = require("gui/cadExtension")

local screensize = {term.getSize()}

local layout = {canvas:new(nil, {1,1}, {screensize[1], screensize[2]-6}), printoutput:new(nil, {1,screensize[2]-6}, {screensize[1], 5}), textinput:new(nil, {1, screensize[2]-2}, {screensize[1], 3})}
local win = gui:new(nil, layout)

local canvasWidget = win.widgets[1]
-- leftx, topy, rightx, bottomy
local iterationSize = 0.1
local selectedMaterial = 0



local function print(a)
    win.widgets[2]:print(a)
end

local function setPrintOutputView(doPrintOutputView)
    if doPrintOutputView then
        canvasWidget.enable = false
        win.widgets[2]:updatePos(1,1)
        win.widgets[2]:updateSize(screensize[1], screensize[2]-2)
    else
        canvasWidget.enable = true
        win.widgets[2]:updatePos(1,screensize[2]-6)
        win.widgets[2]:updateSize(screensize[1], 5)
    end
    win:draw()
end

local function getNextTextInputEvent()
    local events, values
    repeat
        events, values = win:read()
    until events == 3
    local value = values[3]
    win.widgets[3].value = ""
    if win.widgets[3].numOnly then
        return tonumber(value)
    end
    return value
end

local function setNumOnly(state)
    win.widgets[3].numOnly = state
end

local function getNTextInputs(n, strings)
    local inputs = {}
    for x = 1, n do
        print(strings[x])
        inputs[x] = getNextTextInputEvent()
        if not inputs[x] or inputs[x] == "" then
            print("Cancelled")
            return false
        end
    end
    return inputs
end

local redraw = true
local cad = cadLib:new(nil, canvasWidget)

while true do
    local events, values = win:read()
    if redraw then
        cad:draw(iterationSize)
        redraw = false
    end
    if events == 3 then
        -- Enter pressed
        local input = values[3]
        win.widgets[3].value = ""

        -- Views
        if input == "printview" then setPrintOutputView(true)
        elseif input == "canvasview" then
            setPrintOutputView(false)
            redraw = true
        

        -- Shape drawing
        elseif input == "line" then
            setNumOnly(true)
            local inputs = getNTextInputs(4, {"X1","Y1","X2","Y2"})
            if inputs then
                cad:newElement(cad.line:new({inputs[1], inputs[2]}, {inputs[3], inputs[4]}, selectedMaterial))
                redraw = true
            end

        elseif input == "circle" then
            setNumOnly(true)
            local inputs = getNTextInputs(3, {"X","Y","Radius"})
            if inputs then
                cad:newElement(cad.circle:new({inputs[1],inputs[2]},inputs[3],selectedMaterial))
                redraw = true
            end

        elseif input == "rect" then
            setNumOnly(true)
            local inputs = getNTextInputs(4, {"X","Y","Width","Height"})
            if inputs then
                setNumOnly(false)
                print("Filled? [y] or n")
                local fill = getNextTextInputEvent()
                if fill == "n" then
                    cad:newElement(cad.rect:new(inputs[1], inputs[2], inputs[3], inputs[4], false, selectedMaterial))
                else
                    cad:newElement(cad.rect:new(inputs[1], inputs[2], inputs[3], inputs[4], true, selectedMaterial))
                end
                redraw = true
            end

        elseif input == "quadratic" then
            setNumOnly(true)
            local inputs = getNTextInputs(6, {"X1", "Y1", "X2", "Y2", "X3", "Y3"})
            if inputs then
                cad:newElement(cad.quadratic:new({inputs[1], inputs[2]}, {inputs[3], inputs[4]}, {inputs[5], inputs[6]}, selectedMaterial))
                redraw = true
            end

        elseif input == "bezier" then
            setNumOnly(true)
            local inputs = getNTextInputs(8, {"X1", "Y1", "X2", "Y2", "X3", "Y3", "X4", "Y4"})
            if inputs then
                cad:newElement(cad.bezier:new({inputs[1], inputs[2]}, {inputs[3], inputs[4]}, {inputs[5], inputs[6]}, {inputs[7], inputs[8]}, selectedMaterial))
                redraw = true
            end

        elseif input == "undo" then
            cad:undo()
            redraw = true

        elseif input == "setiterationsize" then
            setNumOnly(true)
            local inputs = getNTextInputs(1, {"Iterationsize"})
            if inputs then
                iterationSize = inputs[1]
                redraw = true
            end

        elseif input == "setmaterial" then
            setNumOnly(true)
            print("Enter a material number (0-14)")
            selectedMaterial = getNextTextInputEvent()
            if (not selectedMaterial) or selectedMaterial < 0 or selectedMaterial > 14 then
                print("Invalid material, reverting to 0")
                selectedMaterial = 0
            end


        -- Grid stuff
        elseif input == "togglegrid" then
            cad.grid.enabled = not cad.grid.enabled
            print(cad.grid.enabled)
            redraw = true

        elseif input == "grid" then
            print("Grid size "..cad.grid.size[1].." "..cad.grid.size[2])
            print("Grid offset "..cad.grid.offset[1].." "..cad.grid.offset[2])

        elseif input == "setgrid" then
            cad.grid.enabled = true
            setNumOnly(true)
            local inputs = getNTextInputs(4, {"Grid X Size", "Grid Y Size", "Grid X Offset", "Grid Y Offset"})
            if inputs then
                cad.grid.size = {inputs[1], inputs[2]}
                cad.grid.offset = {inputs[3], inputs[4]}
            end
            redraw = true

        -- Viewport stuff
        elseif input == "setviewport" then
            setNumOnly(true)
            local newviewport = getNTextInputs(4, {"Left","Top","Right","Bottom"})
            if newviewport then
                cad:setViewport(newviewport)
                redraw = true
            end

        elseif input == "setviewportauto" then
            setNumOnly(true)
            local inputs = getNTextInputs(3, {"X","Y","Scale"})
            if inputs then
                inputs[5] = inputs[3]
                inputs[3] = inputs[1]+(canvasWidget.canvas.resolution[1]/inputs[5])
                inputs[4] = inputs[2]+(canvasWidget.canvas.resolution[2]/inputs[5])
                cad:setViewport(inputs)
                redraw = true
            end

        elseif input == "resetviewport" then
            cad:setViewport({1,1,cad.resolution[1]+1,cad.resolution[2]+1})
            redraw = true
        
        elseif input == "viewport" then
            print("Viewport Point 1: "..cad.viewport[1].." "..cad.viewport[2])
            print("Viewport Point 2: "..cad.viewport[3].." "..cad.viewport[4])
            print("Pixel/Unit ratio: "..cad.ratio[1].." "..cad.ratio[2]) -- TODO


        -- Other
        elseif input == "quit" then
            print("Type yes to quit.")
            local option = getNextTextInputEvent()
            if option == "yes" then
                term.clear()
                term.setCursorPos(1,1)
                break
            end

        elseif input == "redraw" then
            redraw = true

        elseif input == "help" then
            setPrintOutputView(true)
            print("--- HELP ---")
            print("printview canvasview")
            print("line circle rect")
            print("quadratic bezier")
            print("undo setiterationsize")
            print("setmaterial setviewport")
            print("resetviewport viewport")
            print("setviewportauto")
            print("togglegrid grid setgrid")
            print("save load print")
            print("quit redraw")

        elseif input == "save" then
            local inputs = getNTextInputs(1, {"Filename"})
            if inputs then
                local file = io.open(inputs[1], "w")
                local stringtosave = ""
                stringtosave = textutils.serialize(cad.elements)
                file:write(stringtosave)
                file:close()
            end

        elseif input == "load" then
            local inputs = getNTextInputs(1, {"Filename"})
            if inputs then
                local file = io.open(inputs[1], "r")
                local elementsTable = textutils.unserialize(file:read("a"))
                cad.elements = {}
                file:close()
                for x = 1, table.getn(elementsTable) do
                    cad:newElement(cad[elementsTable[x].type]:load(elementsTable[x]))
                end
                redraw = true
            end

        elseif input == "print" then
            local inputs = getNTextInputs(1, {"Printer side"})
            if inputs then
                local printer = peripheral.wrap(inputs[1])
                if printer then
                    if printer.getPaperLevel() < 1 then
                        print("Printer is out of paper.")
                    elseif printer.getInkLevel() < 1 then
                        print("Printer is out of ink.")
                    else
                        -- printer is ready.
                        local x, y = printer.getPageSize()
                        function printer.blit(a)
                            print(a)
                            printer.write(a)
                        end
                        local tmpCanvas = canvas:new(nil, {0,0}, {x+1,y+1}, {device=printer})
                        cad.canvasWidget = tmpCanvas
                        setNumOnly(true)
                        inputs = getNTextInputs(3, {"X", "Y", "Scale"})
                        if inputs then
                            inputs[5] = inputs[3]
                            inputs[3] = inputs[1]+(tmpCanvas.canvas.resolution[1]/inputs[5])
                            inputs[4] = inputs[2]+(tmpCanvas.canvas.resolution[2]/inputs[5])
                            cad:setViewport(inputs)
                            printer.newPage()
                            cad:draw(iterationSize)
                            tmpCanvas:draw()
                            printer.endPage()
                        end
                        cad.canvasWidget = canvasWidget
                    end
                else
                    print("Printer not found.")
                end
            end
        else
            print(input.." not a command.")
        end
        setNumOnly(false)
    end
end