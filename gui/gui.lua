local gui = {}

function gui:drawFrames()
---@diagnostic disable-next-line: undefined-field
    for x = 1, table.getn(self.widgets) do
        if self.widgets[x].enable then
            self.widgets[x]:drawFrame()
        end
    end
end

function gui:draw()
---@diagnostic disable-next-line: undefined-field
    for x = 1, table.getn(self.widgets) do
        if self.widgets[x].enable then
            self.widgets[x]:draw()
        end
    end
end

function gui:isXYonWidget(x,y,widget)
    if x >= widget.pos[1] and y >= widget.pos[2] and x < widget.pos[1] + widget.size[1] and y < widget.pos[2] + widget.size[2] then
        return true
    end
    return false
end

function gui:read()
    if self.completeRedraw then
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)
        term.clear()
        self:drawFrames()
        self.completeRedraw = false
    end
    self:draw()
    local values = {}
    local timerID = -1
    if self.timeout then
        timerID = os.startTimer(self.timeout)
    end
    local event, a, b, c, d = os.pullEvent()
    os.cancelTimer(timerID)
    local eventn = false
    if event == "mouse_click" then
        if self.devMode and a == 3 then
            term.clear()
            term.setCursorPos(1,1)
            print("The widget focused has")
            print("index", self.focusedWidget)
            print("x", self.widgets[self.focusedWidget].pos[1], "y", self.widgets[self.focusedWidget].pos[2])
            print("width", self.widgets[self.focusedWidget].size[1], "height", self.widgets[self.focusedWidget].size[2])
            print("Push enter to continue.")
            io.read()
            self.completeRedraw = true
        elseif self:isXYonWidget(b,c, self.widgets[self.focusedWidget]) and self.widgets[self.focusedWidget].enable then
            if self.widgets[self.focusedWidget]:handleMouseClick(a,b,c,d) then eventn = self.focusedWidget end
        else
            for x = 1, table.getn(self.widgets) do
                if self:isXYonWidget(b,c, self.widgets[x]) and self.widgets[x].enable then
                    self.widgets[self.focusedWidget]:setFocus(false)
                    self.focusedWidget = x
                    self.widgets[x]:setFocus(true)
                    if self.widgets[x]:handleMouseClick(a,b,c,d) then eventn = x end
                    break
                end
            end
        end
    elseif event == "key" then
        if a == 15 then
            -- tab
            self.widgets[self.focusedWidget]:setFocus(false)
            self.focusedWidget = self.focusedWidget + 1
            if self.widgets[self.focusedWidget] and not self.widgets[self.focusedWidget].enable then self.focusedWidget = self.focusedWidget + 1 end
            if self.focusedWidget > table.getn(self.widgets) then
                self.focusedWidget = 1
            end
            self.widgets[self.focusedWidget]:setFocus(true)
        else
            if self.widgets[self.focusedWidget]:handleKey(a,b,c,d) then eventn = self.focusedWidget end
        end
    elseif event == "char" then
        self.widgets[self.focusedWidget]:handleChar(a,b,c,d)
    elseif event == "mouse_drag" then
        if self.devMode then
            if a == 1 then
                -- left click, move
                self.widgets[self.focusedWidget]:updatePos(b,c)
                self.completeRedraw = true
            elseif a == 2 then
                -- right click, resize
                local pos = self.widgets[self.focusedWidget].pos
                local newWidth, newHeight = self.widgets[self.focusedWidget].size[1], self.widgets[self.focusedWidget].size[2]
                if b-pos[1] > 3 then newWidth = b-pos[1]+1 else newWidth = 3 end
                if c-pos[2] > 3 then newHeight = c-pos[2]+1 else newHeight = 3 end
                self.widgets[self.focusedWidget]:updateSize(newWidth, newHeight)
                self.completeRedraw = true
            end
        end
    end
    for x = 1, table.getn(self.widgets) do
        values[x] = self.widgets[x].value
    end
    return eventn, values, {event,a,b,c,d}
end

function gui:new(o, widgets, p)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.widgets = widgets
    o.focusedWidget = 1
    o:drawFrames()
    o.widgets[1]:setFocus(true)
    o.completeRedraw = true
    if p then
        o.devMode = p.devMode or false
        o.device = p.device or term
        o.timeout = p.timeout or nil
    else
        o.devMode = false
        o.device = term
        o.timeout = nil
    end
    for x = 1, table.getn(o.widgets) do
        o.widgets[x].device = o.device
    end
    return o
end

return gui