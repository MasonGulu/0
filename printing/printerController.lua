local colorChar = "0"
local colorString = ""

local colorDistanceLookup = {
    [32] = {char="f",string="Black"},
    [30] = {char="e",string="Red"},
    [28] = {char="d",string="Green"},
    [26] = {char="c",string="Brown"},
    [24] = {char="b",string="Blue"},
    [22] = {char="a",string="Purple"},
    [20] = {char="9",string="Cyan"},
    [18] = {char="8",string="L.Gray"},
    [16] = {char="7",string="Gray"},
    [14] = {char="6",string="Pink"},
    [12] = {char="5",string="Lime"},
    [10] = {char="4",string="Yellow"},
    [8] = {char="3",string="L.Blue"},
    [6] = {char="2",string="Magenta"},
    [4] = {char="1",string="Orange"}
}

local modem = peripheral.wrap("left")
modem.open(12)
local printer = peripheral.wrap("back")
local pageNum = 1

local printQueue = {}



while true do
    local event, channel, responseChannel, distance, message, timerID, side
    if #printQueue > 0 then
        timerID = os.startTimer(0.1)
    else
        timerID = os.startTimer(8)
        -- longer timeout when there's no document to print
    end
    repeat
        event, side, channel, responseChannel, message, distance = os.pullEvent()
    until event == "modem_message" or event == "timer"

    -- send a status update
    modem.transmit(13, 12, {"status", tonumber(colorChar,16), colorString, printer.getInkLevel(), printer.getPaperLevel()})

    if event == "modem_message" then
        if message[1] == "print" then
            table.insert(printQueue, message[2])
        elseif message[1] == "reassignColor" then
            if colorDistanceLookup[distance] then
                colorChar = colorDistanceLookup[distance].char
                colorString = colorDistanceLookup[distance].string
            else
                colorChar = "0"
                colorString = "Error!"
            end
            print(string.format("Color Char %s, color string %s", colorChar, colorString))
        elseif message[1] == "restart" then
            os.reboot()
        end
    end
    
    if #printQueue > 0 then
        if printer.newPage() then
            if type(printQueue[1].title) == "nil" then
                printQueue[1].title = ""
            end
            printer.setPageTitle(string.format("%s %u", printQueue[1].title, pageNum))
            for row = 1, 21 do
                if type(printQueue[1][pageNum].text[row]) == "string" then
                    local rowString = printQueue[1][pageNum].text[row]
                    local rowColor = printQueue[1][pageNum].color[row]
                    for column = 1, 25 do
                        if string.sub(rowColor, column, column) == colorChar then
                            printer.setCursorPos(column, row)
                            printer.write(string.sub(rowString, column, column))
                        end
                    end
                end
            end
            printer.endPage()
            pageNum = pageNum + 1
        end
        if pageNum > #printQueue[1] then
            -- end of page
            table.remove(printQueue, 1)
            pageNum = 1
        end
        modem.transmit(13, 12, {"status", tonumber(colorChar,16), colorString, printer.getInkLevel(), printer.getPaperLevel()})
    end
end