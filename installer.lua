local a=require("cc.expect")local widget={focused=false,value="",enable_events=false,device=term,enable=true,frame=true,selectable=true,theme={},type="widget"}widget.__index=widget;widget.theme={wallLeft=string.char(149),wallRight=string.char(149),wallLeftInvert=false,wallRightInvert=true,wallLeftFocused=string.char(16),wallRightFocused=string.char(17),wallLeftFocusedInvert=false,wallRightFocusedInvert=false,frameFG=colors.white,frameBG=colors.black,internalFG=colors.white,internalBG=colors.black,internalInvert=false,topRightWall=string.char(147),invertTopRight=true,topLeftWall=string.char(156),invertTopLeft=false,bottomRightWall=string.char(142),invertBottomRight=false,bottomLeftWall=string.char(141),invertBottomLeft=false,centerLeftWall=string.char(157),invertCenterLeft=false,centerRightWall=string.char(145),invertCenterRight=true}widget.theme.__index=widget.theme;function widget:_drawCharacterVertically(c,d,e)a(1,c,"string")a(2,d,"number")a(3,e,"number")for f=1,e do self.device.setCursorPos(d,f)self.device.write(c)end end;function widget:drawFrame()if self.frame then if self.focused then self:setFrameColor(self.theme.wallLeftFocusedInvert)self:_drawCharacterVertically(self.theme.wallLeftFocused,1,self.size[2])self:setPreviousColor()self:setFrameColor(self.theme.wallRightFocusedInvert)self:_drawCharacterVertically(self.theme.wallRightFocused,self.size[1],self.size[2])else self:setFrameColor(self.theme.wallLeftInvert)self:_drawCharacterVertically(self.theme.wallLeft,1,self.size[2])self:setPreviousColor()self:setFrameColor(self.theme.wallRightInvert)self:_drawCharacterVertically(self.theme.wallRight,self.size[1],self.size[2])end end;self:setPreviousColor()end;function widget:draw()self:clear()self:drawFrame()end;function widget:clear(g,h)self:setInternalColor(self.theme.internalInvert,g,h)self.device.clear()self:setPreviousColor()end;function widget:convertGlobalXYToLocalXY(d,f)a(1,d,"number")a(2,f,"number")return d-self.pos[1],f-self.pos[2]+1 end;function widget:convertLocalXYToGlobalXY(d,f)a(1,d,"number")a(2,f,"number")return d+self.pos[1],f+self.pos[2]end;function widget:setFocus(i)a(1,i,"boolean")self.focused=i;self:drawFrame()end;function widget:handleMouseClick(j,k,l)local d,f=self:convertGlobalXYToLocalXY(k,l)return false end;function widget:handleKey(m,n)return false end;function widget:handleMouseScroll(o,k,l)return false end;function widget:handlePaste(p)return false end;function widget:handleChar(c)return false end;function widget:otherEvent(q)return false end;function widget:updatePos(d,f)a(1,d,"number")a(2,f,"number")self.pos={d,f}self.device.reposition(d,f)end;function widget:updateSize(r,e)a(1,r,"number")a(2,e,"number")self.size={r,e}self.device.reposition(self.pos[1],self.pos[2],r,e)end;function widget:setInternalColor(s,g,h)self.previousBG=self.device.getBackgroundColor()self.previousFG=self.device.getTextColor()if s then self.device.setBackgroundColor(g or self.theme.internalFG)self.device.setTextColor(h or self.theme.internalBG)else self.device.setBackgroundColor(h or self.theme.internalBG)self.device.setTextColor(g or self.theme.internalFG)end end;function widget:setFrameColor(s)self.previousBG=self.device.getBackgroundColor()self.previousFG=self.device.getTextColor()if s then self.device.setBackgroundColor(self.theme.frameFG)self.device.setTextColor(self.theme.frameBG)else self.device.setBackgroundColor(self.theme.frameBG)self.device.setTextColor(self.theme.frameFG)end end;function widget:setPreviousColor()self.device.setBackgroundColor(self.previousBG)self.device.setTextColor(self.previousFG)end;function widget:writeTextToLocalXY(p,d,f)a(2,d,"number")a(3,f,"number")self.device.setCursorPos(d+1,f)self:setInternalColor(self.theme.internalInvert)self.device.write(p)self:setPreviousColor()end;function widget:updateParameters(t)self:_applyParameters(t)end;function widget:getValue()return self.value end;function widget.new(u,v,w,t)u=u or{}setmetatable(u,widget)u.pos=v;u.size=w;u.theme={}setmetatable(u.theme,widget.theme)u.device=window.create(term.current(),u.pos[1],u.pos[2],u.size[1],u.size[2])return u end;function widget:updateTheme(x)setmetatable(x,widget.theme)self.theme=x end;function widget:_applyParameters(t)if type(t)=="table"then for y,z in pairs(t)do if y=="device"then self.device=window.create(z,self.pos[1],self.pos[2],self.size[1],self.size[2])else self[y]=z end end end end;
local checkbox={type="checkbox"}setmetatable(checkbox,widget)checkbox.__index=checkbox;function checkbox:draw()self:clear()self:drawFrame()if self.value then self:writeTextToLocalXY(string.char(7),1,1)else self:writeTextToLocalXY(string.char(186),1,1)end;local c=self.text:sub(1,self.size[1]-3)self:writeTextToLocalXY(c,2,1)end;function checkbox:handleMouseClick(d,e,f)local g,h=self:convertGlobalXYToLocalXY(e,f)if g==1 and h==1 then self.value=not self.value;return self.enable_events end;return false end;function checkbox:handleKey(i,j)if i==keys.space then self.value=not self.value;return self.enable_events end;return false end;function checkbox.new(k,l,m,n)local o=widget.new(nil,k,l,n)setmetatable(o,checkbox)o.text=m;o:_applyParameters(n)return o end
local button={type="button",enable_events=true}setmetatable(button,widget)button.__index=button;setmetatable(button.theme,widget.theme)function button:draw()self:clear()self:drawFrame()local c=self.value:sub(1,self.size[1]-2)self:writeTextToLocalXY(c,1,1)end;function button:handleMouseClick(d,e,f)local g,h=self:convertGlobalXYToLocalXY(e,f)if h>0 and h<self.size[2]+1 and g>0 and g<self.size[1]-1 then return self.enable_events end;return false end;function button:handleKey(i,j)if i==keys.enter then return self.enable_events end;return false end;function button:updateParameters(k,l)self.value=k;self:_applyParameters(l)end;function button:updateTheme(m)setmetatable(m,widget.theme)local n={internalInvert=true}m.__index=m;setmetatable(n,m)self.theme=n end;function button.new(o,p,k,l)local q=widget.new(nil,o,p,l)setmetatable(q,button)q.value=k;q.theme.internalInvert=true;q:_applyParameters(l)return q end
local divider={type="divider",selectable=false,modifyWalls=true,top=false,bottom=false}setmetatable(divider,widget)divider.__index=divider;function divider:draw()self:clear()self:drawFrame()self.device.setCursorPos(2,1)self:setFrameColor()self.device.write(self.value)self:setPreviousColor()if self.modifyWalls then if self.top then self:setFrameColor(self.theme.invertTopLeft)self.device.setCursorPos(1,1)self.device.write(self.theme.topLeftWall)self:setPreviousColor()self:setFrameColor(self.theme.invertTopRight)self.device.setCursorPos(self.size[1],1)self.device.write(self.theme.topRightWall)self:setPreviousColor()elseif self.bottom then self:setFrameColor(self.theme.invertBottomLeft)self.device.setCursorPos(1,1)self.device.write(self.theme.bottomLeftWall)self:setPreviousColor()self:setFrameColor(self.theme.invertBottomRight)self.device.setCursorPos(self.size[1],1)self.device.write(self.theme.bottomRightWall)self:setPreviousColor()else self:setFrameColor(self.theme.invertCenterLeft)self.device.setCursorPos(1,1)self.device.write(self.theme.centerLeftWall)self:setPreviousColor()self:setFrameColor(self.theme.invertCenterRight)self.device.setCursorPos(self.size[1],1)self.device.write(self.theme.centerRightWall)self:setPreviousColor()end end end;function divider:updateSize(c,d)self.value=string.rep(string.char(140),c-2)widget.updateSize(self,c,d)end;function divider.new(e,f,g)local h=widget.new(nil,e,f,g)setmetatable(h,divider)h.value=string.rep(string.char(140),h.size[1]-2)h:_applyParameters(g)return h end
local text={type="text",selectable=false}setmetatable(text,widget)text.__index=text;function text:draw()self:clear()self:drawFrame()for c=1,self.textArea[2]do local d=self.value[c]:sub(1,self.size[1]-2)self:writeTextToLocalXY(d,1,self.textArea[2]+1-c)end end;function text:scrollTextArray()for e=self.textArea[2]+1,2,-1 do self.value[e]=self.value[e-1]end;self.value[1]=""end;function text:formatStringToFitWidth(f)f=tostring(f)self:scrollTextArray()self.value[1]=f:sub(1,self.textArea[1])if f:len()>self.textArea[1]then self:formatStringToFitWidth(f:sub(self.textArea[1]+1,-1))end end;function text:updateSize(g,h)widget.updateSize(self,g,h)self.textArea={self.size[1]-2,self.size[2]}for c=1,self.textArea[2]do self.value[c]=""end;self:formatStringToFitWidth(self.string)end;function text:updateParameters(i,j)self.string=i;self:formatStringToFitWidth(self.string)self:_applyParameters(j)end;function text.new(k,l,i,j)local m=widget.new(nil,k,l,j)setmetatable(m,text)m.value={}m.textArea={m.size[1]-2,m.size[2]}for c=1,m.textArea[2]do m.value[c]=""end;m.string=i;m:formatStringToFitWidth(m.string)m:_applyParameters(j)return m end
local progressbar={type="progressbar",fullChar="\127",halfChar="\149",selectable=false}setmetatable(progressbar,widget)progressbar.__index=progressbar;function progressbar:draw()self:clear()self:drawFrame()local c=self.value/self.maxValue;local d=c*(self.size[1]-2)local e=string.rep(self.fullChar,math.floor(d))if d>math.floor(d)+0.5 then e=e..self.halfChar end;self:writeTextToLocalXY(e,1,1)end;function progressbar:updateValue(f)self.value=math.min(f,self.maxValue)end;function progressbar:updateParameters(g,h)self.value=math.min(self.value,g)self.maxValue=g;self:_applyParameters(h)end;function progressbar.new(i,j,g,h)local k=widget.new(nil,i,j,h)setmetatable(k,progressbar)k:_applyParameters(h)k.maxValue=g;k.value=0;return k end;
local gui={disableBuffering=false,devMode=false,device=term,timeout=nil,autofit=false}gui.__index=gui;function gui:_draw()for b,c in pairs(self.widgets)do if c.enable then c.device.setVisible(self.disableBuffering)c:draw()c.device.setVisible(true)else c.device.setVisible(false)end end;self.widgets[self.focusedWidget].device.setVisible(self.disableBuffering)self.widgets[self.focusedWidget]:draw()self.widgets[self.focusedWidget].device.setVisible(true)end;function gui:_isXYonWidget(d,e,f)if d>=f.pos[1]and e>=f.pos[2]and d<f.pos[1]+f.size[1]and e<f.pos[2]+f.size[2]then return true end;return false end;function gui:read()if self.completeRedraw then term.setTextColor(colors.white)term.setBackgroundColor(colors.black)term.clear()self.completeRedraw=false end;self:_draw()local g={}local h=-1;if self.timeout then h=os.startTimer(self.timeout)end;local i,j,k,l,m=os.pullEvent()os.cancelTimer(h)local n=false;if i=="mouse_click"then if self.devMode and j==3 then term.clear()term.setCursorPos(1,1)print("The widget focused has")print("index",self.focusedWidget)print("x",self.widgets[self.focusedWidget].pos[1],"y",self.widgets[self.focusedWidget].pos[2])print("width",self.widgets[self.focusedWidget].size[1],"height",self.widgets[self.focusedWidget].size[2])print("type ",self.widgets[self.focusedWidget].type)print("Push enter to continue.")io.read()self.completeRedraw=true elseif self:_isXYonWidget(k,l,self.widgets[self.focusedWidget])and self.widgets[self.focusedWidget].enable then if self.widgets[self.focusedWidget]:handleMouseClick(j,k,l,m)then n=self.focusedWidget end else for b,c in pairs(self.widgets)do if self:_isXYonWidget(k,l,c)and c.enable and(c.selectable or self.devMode)then self.widgets[self.focusedWidget]:setFocus(false)self.focusedWidget=b;c:setFocus(true)if c:handleMouseClick(j,k,l,m)then n=b end;break end end end elseif i=="key"then if j==keys.tab then self.selectedWidgetIndex=self.selectedWidgetIndex+1;if self.selectedWidgetIndex>#self.selectableWidgetKeys then self.selectedWidgetIndex=1 end;self.widgets[self.focusedWidget]:setFocus(false)self.focusedWidget=self.selectableWidgetKeys[self.selectedWidgetIndex]self.widgets[self.focusedWidget]:setFocus(true)else if self.widgets[self.focusedWidget]:handleKey(j,k,l,m)then n=self.focusedWidget end end elseif i=="mouse_scroll"then if self.widgets[self.focusedWidget]:handleMouseScroll(j,k,l)then n=self.focusedWidget end elseif i=="char"then if self.widgets[self.focusedWidget]:handleChar(j,k,l,m)then n=self.focusedWidget end elseif i=="paste"then if self.widgets[self.focusedWidget]:handlePaste(j)then n=self.focusedWidget end elseif i=="mouse_drag"then if self.devMode then if j==1 then self.widgets[self.focusedWidget]:updatePos(k,l)self.completeRedraw=true elseif j==2 then local o=self.widgets[self.focusedWidget].pos;local p,q=self.widgets[self.focusedWidget].size[1],self.widgets[self.focusedWidget].size[2]if k-o[1]>3 then p=k-o[1]+1 else p=3 end;if l-o[2]>1 then q=l-o[2]+1 else q=1 end;self.widgets[self.focusedWidget]:updateSize(p,q)self.completeRedraw=true end end elseif i=="term_resize"and self.autofit then self:doAutofit()end;for b,c in pairs(self.widgets)do g[b]=c:getValue()end;return n,g,{i,j,k,l,m}end;function gui:doAutofit()local r=0;local s=0;local t=math.huge;local u=math.huge;for b,v in pairs(self.widgets)do local w,x=table.unpack(v.pos)local y,z=table.unpack(v.size)r=math.max(x+z,r)t=math.min(x,t)s=math.max(w+y,s)u=math.min(w,u)end;local y,z=self.device.getSize()local A=s-u+1;local B=r-t+1;local C=math.ceil((z-B)/2)-t+1;local D=math.ceil((y-A)/2)-u+1;for b,v in pairs(self.widgets)do v:updatePos(v.pos[1]+D,v.pos[2]+C)end;self.completeRedraw=true end;function gui.new(E,F)local G={}setmetatable(G,gui)G.widgets=E;G.selectableWidgetKeys={}for b,v in pairs(G.widgets)do if v.selectable then G.selectableWidgetKeys[#G.selectableWidgetKeys+1]=b end end;if#G.selectableWidgetKeys==0 then error("Widgets must contain at least one selectable widget!")end;G.selectedWidgetIndex=1;local H=G.selectableWidgetKeys[1]G.widgets[H]:setFocus(true)G.focusedWidget=H;G.completeRedraw=true;if type(F)=="table"then for b,v in pairs(F)do G[b]=v end;if F.theme then for b,v in pairs(G.widgets)do v:updateTheme(F.theme)end end end;if G.autofit then G:doAutofit()end;return G end
local scrollinput={type="scrollinput",enable_events=true,VERSION="2.0"}setmetatable(scrollinput,widget)scrollinput.__index=scrollinput;function scrollinput:draw()self:clear()self:drawFrame()local c=string.sub(self.options[self.value],1,self.size[1]-3)self:writeTextToLocalXY(c,2,1)self:writeTextToLocalXY(string.char(18),1,1)end;function scrollinput:handleMouseClick(d,e,f)local g,h=self:convertGlobalXYToLocalXY(e,f)if g>0 and h>0 then if d==1 then self.value=self.value+1;if self.value>self.length then self.value=1 end elseif d==2 then self.value=self.value-1;if self.value<1 then self.value=self.length end end;return self.enable_events end;return false end;function scrollinput:handleMouseScroll(i,e,f)print("hhhhhhh")sleep(3)if i==1 then self.value=self.value+1;if self.value>self.length then self.value=1 end;return self.enable_events elseif i==-1 then self.value=self.value-1;if self.value<1 then self.value=self.length end;return self.enable_events end;return false end;function scrollinput:handleKey(j,k)if j==keys.down then self.value=self.value+1;if self.value>self.length then self.value=1 end;return self.enable_events elseif j==keys.up then self.value=self.value-1;if self.value<1 then self.value=self.length end;return self.enable_events end;return false end;function scrollinput:updateParameters(l,m)self.value=1;self.options=l;self.length=#self.options;self:_applyParameters(m)end;function scrollinput.new(n,o,l,m)local p=widget.new(nil,n,o,m)setmetatable(p,scrollinput)p.value=1;p.options=l;p.length=#p.options;p:_applyParameters(m)return p end
-- Ignore all this ^^
-- (Though if you're interested this is part of CCSimpleGUI v2.0 see https://github.com/MasonGulu/CCSimpleGUI)

 -- available version strings
local versions = {
  -- "latest",
  "v2.0",
}

local selectedVersion = 1 -- default version index (should be latest version)

 -- [versionstring] table of available modules
local availableModules = {
  ["v2.0"] = {
    "popup",
    "checkbox",
    "button",
    "divider",
    "listbox",
    "printoutput",
    "progressbar",
    "scrollinput",
    "text",
    "textinput",
  }, latest = {
    "popup",
    "checkbox",
    "button",
    "listbox",
    "printoutput",
    "progressbar",
    "scrollinput",
    "text",
    "textinput",
    "marquee",
  },
}

 -- [versionstring][modulename] table of unique filenames for modules. Defaults to modulename.lua
local moduleFilename = {
  latest = {},
  ["v2.0"] = {},
}

 -- [versionstring][modulename] table of module requirements
local moduleRequirements = {
  ["v2.0"] = {
    popup = {
      "text",
      "textinput",
      "button",
      "divider",
      "listbox",
      "checkbox",
    }
  }, latest = {
    popup = {
      "text",
      "textinput",
      "button",
      "listbox",
      "checkbox",
    }
  }
}

-- [versionstring] table of source urls, filenames are appended to the end of this
local urls = {
  latest = "https://raw.githubusercontent.com/MasonGulu/CCSimpleGUI/master/ccsg/",
  ["v2.0"] = "https://raw.githubusercontent.com/MasonGulu/CCSimpleGUI/v2.0/ccsg/",
}

local requiredModules = {
  latest = {"gui", "widget"},
  ["v2.0"] = {"gui", "widget"},
}

local installDir = "/ccsg/" -- base path to install to
local WIDTH = 40 -- width of installer window

local performInstall
local HALFWIDTH = math.floor(WIDTH/2)

local function main()
  while true do
    local selectedVersionString = versions[selectedVersion]
    local widgetLayout = {
      divider.new({1,1},{WIDTH,1},{top=true}),
      text.new({1,2},{WIDTH,1},"CCSimpleGUI Installer."),
      text.new({1,3},{HALFWIDTH,1},"Version: "), version = scrollinput.new({HALFWIDTH+1,3},{HALFWIDTH,1},versions,{value=selectedVersion}),
      divider.new({1,4},{WIDTH,1})
    }

    for i = 1, #availableModules[selectedVersionString], 2 do
      local valueLeft = availableModules[selectedVersionString][i]
      local valueRight = availableModules[selectedVersionString][i+1]
      widgetLayout[valueLeft] = checkbox.new({1, 5+math.floor(i/2)}, {HALFWIDTH,1},valueLeft)
      if valueRight then
        widgetLayout[valueRight] = checkbox.new({HALFWIDTH+1, 5+math.floor(i/2)}, {HALFWIDTH,1},valueRight)
      else
        widgetLayout[#widgetLayout+1] = text.new({HALFWIDTH+1, 5+math.floor(i/2)}, {HALFWIDTH,1} ,"")
      end
    end

    widgetLayout[#widgetLayout+1] = divider.new({1,5+math.ceil(#availableModules[selectedVersionString]/2)},{WIDTH,1})
    widgetLayout.cancel = button.new({1,6+math.ceil(#availableModules[selectedVersionString]/2)}, {HALFWIDTH, 1}, "Cancel")
    widgetLayout.submit = button.new({HALFWIDTH+1, 6+math.ceil(#availableModules[selectedVersionString]/2)}, {HALFWIDTH, 1}, "Install")
    widgetLayout[#widgetLayout+1] = divider.new({1,7+math.ceil(#availableModules[selectedVersionString]/2)},{WIDTH,1},{bottom=true})

    local win = gui.new(widgetLayout, {autofit=true})

    while true do
      local event, values = win:read()
      for widgetKey,widgetValue in pairs(values) do
        if moduleRequirements[selectedVersionString][widgetKey] and widgetValue then
          -- This widget requires some other widgets to be enabled
          for k,v in ipairs(moduleRequirements[selectedVersionString][widgetKey]) do
            win.widgets[v]:updateParameters({value=true})
          end
        end
      end
      if event == "cancel" then
        term.clear()
        term.setCursorPos(1,1)
        print("Cancelled installation.")
        return
      elseif event == "submit" then
        -- perform installation
        return performInstall(values, selectedVersionString)
      elseif event == "version" then
        selectedVersion = values.version
        break -- regenerate gui 
      end
    end
  end
end

function performInstall(values, selectedVersionString)
  local toInstall = requiredModules[selectedVersionString]
  for k,v in pairs(availableModules[selectedVersionString]) do
    if values[v] then
      -- this widget is selected for install
      toInstall[#toInstall+1] = v
    end
  end
  local win = gui.new({
    divider.new({1,1},{WIDTH,1}, {top=true}),
    bar = progressbar.new({1,2},{WIDTH,1},#toInstall,{selectable=true}),
    text.new({1,3},{HALFWIDTH,1},"Installing:"),
    installing = text.new({HALFWIDTH+1,3},{HALFWIDTH,1},""),
    divider.new({1,4},{WIDTH,1}, {bottom=true})
  },{autofit=true,timeout=0})

  fs.makeDir(installDir)

  for k,v in ipairs(toInstall) do
    win:read()
    win.widgets.bar:updateValue(k)
    win.widgets.installing:updateParameters(v)
    local filename = moduleFilename[selectedVersionString][v] or v..".lua"
    local file = fs.open(installDir..filename, "w")
    local web = http.get(urls[versions[selectedVersion]]..filename)
    if type(file) == "nil" then
      term.clear()
      term.setCursorPos(1,1)
      error("Unable to open"..installDir..filename)
    end
    if type(web) ~= "table" then
      term.clear()
      term.setCursorPos(1,1)
      error("Invalid URL")
    elseif web.getResponseCode() ~= 200 then
      term.clear()
      term.setCursorPos(1,1)
      error("Unable to download, got "..tostring(web.getResponseCode()).." as response.")
    end
    file.write(web.readAll())
    file.close()
    web.close()
  end
  term.clear()
  term.setCursorPos(1,1)
  print("Installation finished!")
end

main()