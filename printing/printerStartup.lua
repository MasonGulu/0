local modem = peripheral.wrap("left")
print("Attempting to download printerController.lua")

modem.open(12)
modem.transmit(13,12,{"download", "printerController.lua"})

local state = 0
while state == 0 do
    local event, side, channel, responseChannel, message, distance = os.pullEvent()
    if event == "modem_message" then
        if message[1] and message[2] == "printerController.lua" then
            -- true was recieved as status, filename is correct
            print("Successfully downloaded printerController.lua")
            local f = fs.open("printerController.lua", "w")
            f.write(message[3])
            f.close()
            state = 1
        else
            print("Something went wrong with the download, retrying..")
            os.sleep(1)
            modem.transmit(13,12,{"download", "printerController.lua"})
        end
    end
end

if state == 1 then
    print("Executing printerController.lua")
    shell.run("printerController.lua")
end