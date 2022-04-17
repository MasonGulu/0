local gui = require("gui/gui") -- required
local page = require("gui/page")
local text = require("gui/text")
local textinput = require("gui/textinput")
local button = require("gui/button")
local scrollinput = require("gui/scrollinput")
local printoutput = require("gui/printoutput")

local debug = peripheral.wrap("right")

local colorHexStrings = {
    [0] = "White",
    [1] = "Orange",
    [2] = "Magenta",
    [3] = "L.Blue",
    [4] = "Yellow",
    [5] = "Lime",
    [6] = "Pink",
    [7] = "Gray",
    [8] = "L.Gray",
    [9] = "Cyan",
    [10] = "Purple",
    a   = "Purple",
    [11] = "Blue",
    b   = "Blue",
    [12] = "Brown",
    c   = "Brown",
    [13] = "Green",
    d   = "Green",
    [14] = "Red",
    e   = "Red",
    [15] = "Black",
    f   = "Black"
}

local width, height = term.getSize()
local buffer = window.create(term.current(), 1, 1, width, height)

local win = gui:new(nil, {page = page:new(nil, {1,1},{28,17}),
                fileInfo = text:new(nil, {12,17}, {28,3}, "1"),
                filenameInput = textinput:new(nil, {28,11}, {19,3}),
                saveButton = button:new(nil, {28,13}, {12,3},"Save"),
                loadButton = button:new(nil,{39,13},{13,3},"Load"),
                colorSelector = scrollinput:new(nil, {1, 17}, {12, 3}, colorHexStrings, 15),
                printoutput = printoutput:new(nil, {28,1},{24,11}),
                printButton = button:new(nil, {39,15},{13,3},"Print Color"),
                quitButton = button:new(nil, {39,17},{13,3}, "Quit"),
                printMonoButton = button:new(nil, {28,15}, {12,3}, "Print Mono"),
                text:new(nil, {46,11}, {6,3}, ".scd")}, {device=buffer, devMode=false})

for x = 1, 9 do
    colorHexStrings[tostring(x)] = colorHexStrings[x]
end

local function print(x)
    win.widgets["printoutput"]:print(x)
end
local pageWidget = "page"
local fileInfoWidget = "fileInfo"
local filenameWidget = "filenameInput"
local saveButtonWidget = "saveButton"
local loadButtonWidget = "loadButton"
local colorInputWidget = "colorSelector"
local printButtonWidget = "printButton"
local pageNumber = 1
local openDocument = {
    -- Indexed by page number, then by text or color and line
    {
        text={},
        color={}
    }
}

win.widgets[colorInputWidget].value = 15


local colorChars = {"1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"}
local function updateOpenDocument()
    -- Update the copy of the document stored in openDocument
    openDocument[pageNumber] = {text={},color={}}
    for line = 1, 21 do
        openDocument[pageNumber].text[line] = win.widgets[pageWidget].pageText[line]
        openDocument[pageNumber].color[line] = win.widgets[pageWidget].pageColor[line]
    end
end

local function updatePageWithDocument()
    -- update the GUI page with the document stored in openDocument
    if openDocument[pageNumber] then
        for line = 1, 21 do
            if openDocument[pageNumber].text[line] then
                win.widgets[pageWidget].pageText[line] = openDocument[pageNumber].text[line]
                win.widgets[pageWidget].pageColor[line] = openDocument[pageNumber].color[line]
            else
                win.widgets[pageWidget].pageText[line] = string.rep(" ", 25)
                win.widgets[pageWidget].pageColor[line] = string.rep("f", 25)
            end
            
        end
    else
        win.widgets[pageWidget]:erase()
        openDocument[pageNumber] = {text={}, color={}}
    end
end

local function isEmpty(pageArray)
    for line = 1, 21 do
        if pageArray[line] ~= nil and pageArray[line] ~= string.rep(" ", 25) then
            return false
        end
    end
    return true
end

local function removeWhitespace()
    -- remove excess whitespace from the document
    for pageNum, value in ipairs(openDocument) do
        for line = 1, 21 do
            if openDocument[pageNum].text[line] == string.rep(" ", 25) then
                openDocument[pageNum].text[line] = nil
                openDocument[pageNum].color[line] = nil
            end
        end
    end
    while isEmpty(openDocument[#openDocument].text) do
        openDocument[#openDocument] = nil
    end
end

local function printDocument(color)
    local modem = peripheral.find("modem")
    -- print document starting at startPage and ending at endPage
    if type(modem) == "table" then
        rednet.open(peripheral.getName(modem))
        if color then
            local id = rednet.lookup("printerColor")
            if id then
                rednet.send(id, openDocument, "printerColor")
                print("Document sent to printer..")
            else
                print("Color printer not found..")
            end
        else
            local id = rednet.lookup("printerMono")
            if id then
                rednet.send(id, openDocument, "printerMono")
                print("Document sent to printer..")
            else
                print("Mono printer not found..")
            end
        end
        
    else
        print("Modem is not present")
    end
    
end

while true do
    buffer.setVisible(false)
    local events, values = win:read()
    buffer.setVisible(true)
    local lineNumber = win.widgets[pageWidget].viewLine+win.widgets[pageWidget].cursorPos[2]-1
    win.widgets[fileInfoWidget].value[1] = string.format("Line %2u/21 | Page %u/%u", lineNumber, pageNumber, #openDocument)
    if events == colorInputWidget then
        win.widgets[pageWidget].selectedColor = colorChars[values[colorInputWidget]]
    
    elseif events == pageWidget then
        updateOpenDocument()
        if values[pageWidget] == "nextPage" then
            win.widgets[pageWidget]:erase()
            pageNumber = pageNumber + 1
            updatePageWithDocument()
        elseif values[pageWidget] == "prevPage" then
            win.widgets[pageWidget]:erase()
            pageNumber = pageNumber - 1
            if pageNumber < 1 then
                pageNumber = 1
            end
            updatePageWithDocument()
        end
    elseif events == saveButtonWidget then
        updateOpenDocument()
        removeWhitespace()
        --debug.stop()
        local f = fs.open(values[filenameWidget]..".scd", "w")
        if f then
            f.write(textutils.serialize(openDocument))
            f.close()
        else
            print("File not saved")
        end
    elseif events == loadButtonWidget then
        local f = fs.open(values[filenameWidget]..".scd", "r")
        if f then
            local d = f.readAll()
            openDocument = textutils.unserialise(d)
            f.close()
        else
            print("File not found")
        end
        updatePageWithDocument()
    elseif events == printButtonWidget then
        updateOpenDocument()
        removeWhitespace()
        printDocument(true)
    elseif events == "printMonoButton" then
        updateOpenDocument()
        removeWhitespace()
        printDocument(false)
    elseif events == "quitButton" then
        term.clear()
        term.setCursorPos(1,1)
        return
    end
end