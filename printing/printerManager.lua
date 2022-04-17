local modem = peripheral.wrap("back")

modem.open(13)
rednet.open("back")
rednet.host("printerColor", "megaPrinter")

term.clear()
term.setCursorPos(1,1)
term.write(string.format("%7s|%3s|%s","Color", "Ink", "Paper"))
term.setCursorPos(1,17)
term.write("<Reboot Printers>")

for y = 2, 16 do
    term.setCursorPos(1,y)
    term.write("DISCONNECTED..")
end

local printerTimers = {}
local printMessageTimer = -1

local function getIndexOfItemInList(list, item)
    for index,v in pairs(list) do
        if v == item then
            return index
        end
    end
    return 0
end

while true do
    local event, side, channel, responseChannel, message, distance = os.pullEvent()
    if event == "modem_message" and channel == 13 then
        if message[1] == "download" then
            if fs.exists(message[2]) then
                local f = fs.open(message[2], "r")
                local data = f.readAll()
                modem.transmit(responseChannel, 13, {true, message[2], data})
            end
        elseif message[1] == "status" then
            if message[2] == 0 then
                -- Invalid colors are present
                modem.transmit(responseChannel, 13, {"reassignColor"})
            elseif message[2] >= 1 and message[2] <= 15 then
                term.setCursorPos(1, 17 - message[2])
                term.clearLine()
                term.write(string.format("%7s|%3u|%02u", message[3], message[4], message[5]))
                if type(printerTimers[17-message[2]]) ~= "nil" then
                    os.cancelTimer(printerTimers[17-message[2]])
                end
                printerTimers[17-message[2]] = os.startTimer(10)
            end
        end
    elseif event == "mouse_click" then
        local button, x, y = side, channel, responseChannel
        if y == 17 then
            modem.transmit(12, 13, {"restart"})
        end
    elseif event == "timer" then
        local id = side
        if id == printMessageTimer then
            term.setCursorPos(1,18)
            term.clearLine()
        else
            term.setCursorPos(1, getIndexOfItemInList(printerTimers, id))
            term.clearLine()
            term.write("DISCONNECTED..")
        end
    elseif event == "rednet_message" then
        local sender, message, protocol = side, channel, responseChannel
        if protocol == "printerColor" then
            modem.transmit(12, 13, {"print", message})
        end
        term.setCursorPos(1,18)
        term.clearLine()
        term.write(string.format("Printing %u page document from %u.", #message, sender))
        printMessageTimer = os.startTimer(10)
    end
end