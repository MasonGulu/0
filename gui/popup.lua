local gui = require("gui.gui")
local popup = {}


function popup.getInput(message, width)
  term.clear()
  local wWidth, wHeight = term.getSize()
  width = width or 25
  local x = math.floor(wWidth / 2 - width / 2)
  local y = math.floor(wHeight / 2) - 3
  local text = require("gui.text")
  local textinput = require("gui.textinput")
  local button = require("gui.button")
  local divider = require("gui.divider")
  message = message or "Enter filename:"
  local win = gui:new(nil, {
    divider:new(nil, { x, y }, { width, 1 }, { top = true }),
    text:new(nil, { x, y + 1 }, { width, 1 }, message),
    input = textinput:new(nil, { x, y + 2 }, { width, 1 }),
    cancelButton = button:new(nil, { x, y + 3 }, { math.floor(width / 2), 1 }, "Cancel"),
    submitButton = button:new(nil, { x + math.ceil(width / 2), y + 3 }, { math.floor(width / 2), 1 }, "Submit"),
    divider:new(nil, { x, y + 4 }, { width, 1 }, { bottom = true })
  })
  while true do
    local event, values = win:read()
    if event == "cancelButton" then
      return false
    elseif event == "submitButton" then
      if string.len(values.input) > 0 then
        return values.input
      end
    end
  end
end

function popup.pickFromList(message, list, p)
  term.clear()
  local text = require("gui.text")
  local listbox = require("gui.listbox")
  local button = require("gui.button")
  local divider = require("gui.divider")

  p = p or {}
  local width = 20 or p.width

  local buttonWidth = math.floor(width / 2)

  local win = gui:new(nil, {
    divider:new(nil, { 1, 1 }, { width, 1 }, { top = true }),
    text:new(nil, { 1, 2 }, { width, 2 }, message),
    listbox = listbox:new(nil, { 1, 4 }, { width, 5 }, list),
    text:new(nil, { 1, 9 }, { width, 1 }, ""),
    cancelButton = button:new(nil, { 1, 10 }, { buttonWidth, 1 }, "Cancel"),
    submitButton = button:new(nil, { buttonWidth + 1, 10 }, { buttonWidth, 1 }, "Submit"),
    divider:new(nil, { 1, 11 }, { width, 1 }, { bottom = true })
  }, { autofit = true })
  while true do
    local winEvent, values = win:read()
    if winEvent == "cancelButton" then
      return false
    elseif winEvent == "submitButton" then
      return list[values.listbox], values.listbox
    end
  end
end

local function getFoldersAndFiles(directory, fileExtension)
  local allList = fs.list(directory)
  local dirList = {}
  if directory ~= "/" and directory ~= "" then
    dirList[1] = ".."
  end
  local fileList = {}
  for key, value in ipairs(allList) do
    if fs.isDir(fs.combine(directory, value)) then
      table.insert(dirList, value .. '/')
    else
      if fileExtension then
        if string.sub(value, -string.len(fileExtension), -1) == fileExtension then
          table.insert(fileList, value)
        end
      else
        table.insert(fileList, value)
      end
    end
  end
  return dirList, fileList
end

function popup.test(directory, fileExtension)
  return getFoldersAndFiles(directory, fileExtension)
end

-- adapted from https://stackoverflow.com/a/15278426
local function tableConcat(t1, t2)
  local t3 = {}
  for i = 1, #t1 do
    t3[i] = t1[i]
  end
  for i = 1, #t2 do
    t3[#t3 + 1] = t2[i]
  end
  return t3
end

function popup.fileBrowse(fileExtension, write, width, height)
  -- file extension is expected to contain dot ie ".scd"
  term.clear()
  local wWidth, wHeight = term.getSize()
  width = width or 25
  height = height or 5
  if type(write) == "nil" then
    write = false
  end
  local x = math.floor(wWidth / 2 - width / 2)
  local y = math.floor(wHeight / 2) - 7
  local buttonWidth = math.floor(width / 2)

  local text = require("gui.text")
  local button = require("gui.button")
  local listbox = require("gui.listbox")
  local divider = require("gui.divider")
  local textinput = require("gui.textinput")
  local win = gui:new(nil, {
    divider:new(nil, { x, y }, { width, 1 }, { top = true }),
    directoryLabel = text:new(nil, { x, y + 1 }, { width - 9, 1 }, "/"),
    directoryAddButton = button:new(nil, { x + width - 9, y + 1 }, { 9, 1 }, "New Dir"),
    divider:new(nil, { x, y + 2 }, { width, 1 }),
    directoryListbox = listbox:new(nil, { x, y + 3 }, { width, height }, { "example" }),
    divider:new(nil, { x, y + height + 3 }, { width, 1 }),
    filenameInput = textinput:new(nil, { x, y + height + 4 }, { width - 6, 1 }),
    text:new(nil, { x + width - 6, y + height + 4 }, { 6, 1 }, fileExtension),
    divider:new(nil, { x, y + height + 5 }, { width, 1 }),
    cancelButton = button:new(nil, { x, y + height + 6 }, { buttonWidth + 1, 1 }, "Cancel"),
    selectButton = button:new(nil, { x + buttonWidth + 1, y + height + 6 }, { buttonWidth, 1 }, "Submit"),
    divider:new(nil, { x, y + height + 7 }, { width, 1 }, { bottom = true })
  })

  local dirChanged = true -- whether to recalculate the current directory
  local currentDir = "/"

  local dirList, fileList

  while true do
    if dirChanged then
      dirList, fileList = getFoldersAndFiles(currentDir, fileExtension)
      win.widgets.directoryListbox:updateParameters(tableConcat(dirList, fileList))
      win.widgets.directoryLabel:updateParameters(currentDir)
      dirChanged = false
    end
    local event, values = win:read()
    if event == "directoryListbox" then
      -- directory changed or file selected
      if values.directoryListbox > #dirList then
        -- this is a file
        win.widgets.filenameInput:updateParameters({ value = string.sub(fileList[values.directoryListbox - #dirList], 1, -5) })
      else
        -- this is a folder
        dirChanged = true
        currentDir = fs.combine(currentDir, dirList[values.directoryListbox])
      end
    elseif event == "selectButton" then
      local returnFilename = currentDir .. values.filenameInput .. fileExtension
      if write and fs.exists(returnFilename) then
        -- give warning about overwriting a file
        if popup.confirm("Overwrite " .. returnFilename .. "?") then
          return returnFilename
        end
      else
        return returnFilename
      end
    elseif event == "cancelButton" then
      return false
    elseif event == "directoryAddButton" then
      local newDirName = popup.getInput("Enter new directory name:", 27)
      if newDirName then
        fs.makeDir(fs.combine(currentDir, newDirName))
        dirChanged = true
      end
    end
  end
end

function popup.info(message, buttonLabel, width, height)
  local wWidth, wHeight = term.getSize()
  width = width or 25
  height = height or 3
  local x = math.floor(wWidth / 2 - width / 2)
  local y = math.floor(wHeight / 2) - 3
  local text = require("gui.text")
  local button = require("gui.button")
  local divider = require("gui.divider")
  buttonLabel = buttonLabel or "Close"
  local win = gui:new(nil, {
    divider:new(nil, { x, y }, { width, 1 }, { top = true }),
    text:new(nil, { x, y + 1 }, { width, height }, message),
    ackButton = button:new(nil, { x, y + 1 + height }, { width, 1 }, buttonLabel),
    divider:new(nil, { x, y + 2 + height }, { width, 1 }, { bottom = true })
  })
  local event, values
  repeat
    event, values = win:read()
  until event == "ackButton"
  term.clear()
end

function popup.confirm(message, height, width)
  local wWidth, wHeight = term.getSize()
  width = width or 25
  height = height or 3
  local x = math.floor(wWidth / 2 - width / 2)
  local y = math.floor(wHeight / 2) - 3
  local buttonWidth = math.floor(width / 2)
  local text = require("gui.text")
  local button = require("gui.button")
  local divider = require("gui.divider")
  local win = gui:new(nil, {
    divider:new(nil, { x, y }, { width, 1 }, { top = true }),
    text:new(nil, { x, y + 1 }, { width, height }, message),
    noButton = button:new(nil, { x, y + 1 + height }, { buttonWidth, 1 }, "No"),
    yesButton = button:new(nil, { x + buttonWidth + 1, y + 1 + height }, { buttonWidth, 1 }, "Yes"),
    divider:new(nil, { x, y + height + 2 }, { width, 1 }, { bottom = true })
  })
  local event, values
  repeat
    event, values = win:read()
  until event == "yesButton" or event == "noButton"
  term.clear()
  return event == "yesButton"
end

function popup.editT(T, textString, textHeight, keyWidth, valueWidth)
  keyWidth = keyWidth or 5
  valueWidth = valueWidth or 12
  textHeight = textHeight or 3
  local width = keyWidth + valueWidth
  local wWidth, wHeight = term.getSize()
  local x = math.floor(wWidth / 2 - width / 2)
  local y = math.floor(wHeight / 2 - (#T + textHeight + 6) / 2)

  local text = require("gui.text")
  local button = require("gui.button")
  local divider = require("gui.divider")
  local textinput = require("gui.textinput")
  local checkbox = require("gui.checkbox")

  local widgets = {
    DIV1 = divider:new(nil, { x, y }, { width, 1 }, { top = true }),
    TXT1 = text:new(nil, { x, y + 1 }, { width, textHeight }, textString),
    DIV2 = divider:new(nil, { x, y + textHeight + 1 }, { width, 1 })
  }
  local offset = textHeight + 2 -- offset from ypos
  for key, value in pairs(T) do
    if keyWidth > 0 then
      widgets["DIV" .. tostring(offset)] = text:new(nil, { x, y + offset }, { keyWidth, 1 }, key)
    end
    if type(value) == "boolean" then
      widgets[key] = checkbox:new(nil, { x + keyWidth, y + offset }, { valueWidth, 1 }, tostring(key), { value = value })
    elseif type(value) == "number" then
      widgets[key] = textinput:new(nil, { x + keyWidth, y + offset }, { valueWidth, 1 }, { numOnly = true, value = value })
    elseif type(value) == "table" then
      widgets[key] = button:new(nil, { x + keyWidth, y + offset }, { valueWidth, 1 }, "TABLE")
    elseif type(value) == "string" then
      widgets[key] = textinput:new(nil, { x + keyWidth, y + offset }, { valueWidth, 1 }, { value = value })
    end
    offset = offset + 1
  end
  widgets.DIV3 = divider:new(nil, { x, y + offset }, { width, 1 })
  widgets.ackButton = button:new(nil, { x, y + offset + 1 }, { width, 1 }, "Submit")
  widgets.DIV4 = divider:new(nil, { x, y + offset + 2 }, { width, 1 }, { bottom = true })
  local win = gui:new(nil, widgets, { devMode = false })
  local event, values
  repeat
    event, values = win:read()
    if type(T[event]) == "table" then
      T[event] = popup.editT(T[event], textString, textHeight, keyWidth, valueWidth)
    end
  until event == "ackButton"
  for key, _ in pairs(T) do
    T[key] = values[key]
  end
  term.clear()
  return T
end

return popup
