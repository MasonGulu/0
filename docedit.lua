local gui = require("gui/gui") -- required
local page = require("gui/page")
local text = require("gui/text")
local button = require("gui/button")
local listbox = require("gui/listbox")
local printoutput = require("gui/printoutput")
local divider = require("gui/divider")
local popup = require("gui/popup")


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

local offset = 2
local win = gui:new(nil, {fileInfo = text:new(nil, {1,19}, {28,1}, "1"),
                saveButton = button:new(nil, {29,16}, {11,1},"Save"),
                loadButton = button:new(nil,{40,16},{12,1},"Load"),
                colorSelector = listbox:new(nil, {29, 7}, {23, 6}, colorHexStrings, 15),
                printoutput = printoutput:new(nil, {29,2},{23,4}),
                printButton = button:new(nil, {29,14},{23,1},"Print"),
                quitButton = button:new(nil, {29,18},{23,1}, "Quit"),
                divider:new(nil, {29,1},{23,1},{top=true}),
                divider:new(nil, {29,6},{23,1}),
                divider:new(nil, {29,13},{23,1}),
                divider:new(nil, {29,15},{23,1}),
                divider:new(nil, {29,17},{23,1}),
                divider:new(nil, {29,19},{23,1},{bottom=true}),
                page = page:new(nil, {1,1},{28,18})}, {devMode=false})

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
        if #openDocument == 1 then
            return
        end
        openDocument[#openDocument] = nil
    end
    
end

local function printDocument(document, color)
    local modem = peripheral.find("modem")
    -- print document starting at startPage and ending at endPage
    if type(modem) == "table" then
        rednet.open(peripheral.getName(modem))
        if color then
            local id = rednet.lookup("printerColor")
            if id then
                rednet.send(id, document, "printerColor")
                print("Document sent to printer..")
            else
                print("Color printer not found..")
            end
        else
            local id = rednet.lookup("printerMono")
            if id then
                rednet.send(id, document, "printerMono")
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
    local events, values = win:read()
    local lineNumber = win.widgets[pageWidget].viewLine+win.widgets[pageWidget].cursorPos[2]-1
    win.widgets[fileInfoWidget]:updateParameters(string.format("Line %2u/21 | Page %u/%u", lineNumber, pageNumber, #openDocument))
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
        local filename = popup.fileBrowse(".scd", true)
        if filename then
            local f = fs.open(filename, "w")
            if f then
                f.write(textutils.serialize(openDocument))
                f.close()
            else
                print("File not saved")
            end
        else
            print("Cancelled")
        end
        
    elseif events == loadButtonWidget then
        local filename = popup.fileBrowse(".scd")
        if filename then
            local f = fs.open(filename, "r")
            if f then
                local d = f.readAll()
                openDocument = textutils.unserialise(d)
                f.close()
            else
                print("File not found")
            end
        else
            print("Cancelled")
        end
        updatePageWithDocument()
    elseif events == printButtonWidget then
        updateOpenDocument()
        removeWhitespace()
        local printinfo = {color=false,title="",startPage=1,endPage=#openDocument,confirm=false}
        popup.editT(printinfo, "Print setup; check confirm to print.",3,11)
        if printinfo.confirm then
            if printinfo.endPage < printinfo.startPage then
                local tmp = printinfo.endPage
                printinfo.endPage = printinfo.startPage
                printinfo.startPage = tmp
            end
            if printinfo.endPage > #openDocument then
                printinfo.endPage = #openDocument
            end
            if printinfo.startPage < 1 then
                printinfo.startPage = 1
            end
            local documentToPrint = {table.unpack(openDocument,printinfo.startPage,printinfo.endPage)}
            if string.len(printinfo.title) > 0 then
                documentToPrint.title = printinfo.title
            end
            printDocument(documentToPrint, printinfo.color)
        else
            print("Cancelled.")
        end
        
    elseif events == "quitButton" then
        if popup.confirm("Quit?", 1) then
            term.clear()
            term.setCursorPos(1,1)
            return
        end
    end
end