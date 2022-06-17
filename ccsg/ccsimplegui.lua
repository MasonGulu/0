--- This is an alternative way to use ccsimplegui. This will allow you to position elements based on physical location in a table.
-- All sizing will be handled automatically for you.
-- @module ccsimplegui

local gui = require("ccsg.gui")
local expect = require("cc.expect")
local CCSimpleGUI = {}

-- This converts a guiTable (a table of specially formatted tables that don't contain any functions or metatables) to a widget table ready to be used with gui.new()
local function convertGUITableToWidgetTable(guiTable)
  expect(1, guiTable, "table")
  expect.field(guiTable, "width", "number")
  expect.field(guiTable, "widgets", "table")
  local widgets = {}
  local requiredWidgets = {}
  local rowWidths = {}



  guiTable.parameters = guiTable.parameters or {}
  guiTable.parameters.device = guiTable.parameters.device or term

  if guiTable.width <= 1 then
    local width, _ = guiTable.parameters.device.getSize()
    guiTable.width = math.floor(width * guiTable.width)
  end

  for kRow, vRow in pairs(guiTable.widgets) do
    rowWidths[kRow] = rowWidths[kRow] or {}
    for kColumn, vColumn in pairs(vRow) do
      -- iterate over every widget

      vColumn.width = vColumn.width or (1 / (#vRow - (rowWidths[kRow].fixedWidthCount or 0)))
      vColumn.height = vColumn.height or 1 -- apply defaults
      local remainingWidth
      remainingWidth = guiTable.width - (rowWidths[kRow][0] or 0) - (rowWidths[kRow].fixedWidthTotal or 0)
      if vColumn.width > 1 then
        rowWidths[kRow][kColumn] = vColumn.width
        rowWidths[kRow].fixedWidthTotal = (rowWidths[kRow].fixedWidthTotal or 0) + rowWidths[kRow][kColumn]
        rowWidths[kRow].fixedWidthCount = (rowWidths[kRow].fixedWidthCount or 0) + 1
      else
        rowWidths[kRow][kColumn] = math.floor(remainingWidth * vColumn.width)
      end
      if vColumn.height > 1 then
        -- this elements spans multiple rows
        -- for now this operates on the assumption that tall widgets are aligned to the left
        -- example
        -- 1123
        -- 1124
        -- 1156 is valid
        -- 1123
        -- 1143 is not
        for rowOffset = 1, vColumn.height - 1 do
          rowWidths[kRow + rowOffset] = rowWidths[kRow + rowOffset] or {}
          rowWidths[kRow + rowOffset][0] = (0 or rowWidths[kRow + rowOffset][0]) + rowWidths[kRow][kColumn]
        end
      end
      if type(requiredWidgets[vColumn.type]) == "nil" then
        -- this hasn't been included yet
        requiredWidgets[vColumn.type] = require("ccsg." .. vColumn.type)
      end
    end
  end


  for kRow, vRow in pairs(guiTable.widgets) do
    for kColumn, vColumn in pairs(vRow) do
      local widgetXPos = 1
      if vColumn.height == 1 then
        widgetXPos = widgetXPos + (rowWidths[kRow][0] or 0) -- Adjust for any multiline elements prior to it
      end
      for i = 1, kColumn - 1 do
        -- sum the widths of each previous widget in that column
        widgetXPos = widgetXPos + rowWidths[kRow][i]
      end
      widgetXPos = math.max(1, widgetXPos)
      local widgetWidth = rowWidths[kRow][kColumn]

      if kColumn == #rowWidths[kRow] then
        -- this is the last element in the row
        widgetWidth = widgetWidth + (guiTable.width - (widgetXPos + widgetWidth))
      end
      if widgetWidth < 1 then
        error(string.format("Row %u is already full, cannot insert element %u.", kRow, kColumn))
      end
      print(widgetWidth)
      vColumn.posArgs = vColumn.posArgs or {}
      local tmpWidget = nil
      if #vColumn.posArgs > 0 then
        tmpWidget = requiredWidgets[vColumn.type].new({ widgetXPos, kRow }, { widgetWidth, vColumn.height }, table.unpack(vColumn.posArgs), vColumn.parameters)
      else
        tmpWidget = requiredWidgets[vColumn.type].new({ widgetXPos, kRow }, { widgetWidth, vColumn.height }, vColumn.parameters)
      end
      if vColumn.key then
        widgets[vColumn.key] = tmpWidget
      else
        widgets[#widgets + 1] = tmpWidget
      end

    end
  end
  return widgets
end

--- Create a gui from a positional based table of CCSimpleGUI objects.
-- These objects should be from this class
-- @tparam table guiTable
-- @return table gui object (from gui.lua)
function CCSimpleGUI.new(guiTable)
  expect(1, guiTable, "table")
  guiTable.parameters = guiTable.parameters or {}
  guiTable.parameters.autofit = true
  return gui.new(convertGUITableToWidgetTable(guiTable), guiTable.parameters)
end

--- Create a text widget.
-- @see text
-- @tparam string text
-- @tparam[opt] int width
-- @tparam[optchain] int height
-- @tparam[optchain] table parameters
-- @treturn table
function CCSimpleGUI.text(text, width, height, parameters)
  expect(1, text, "string")
  expect(2, width, "number", "nil")
  expect(3, height, "number", "nil")
  expect(4, parameters, "table", "nil")
  return {
    type = "text",
    posArgs = { text },
    width = width,
    height = height,
    parameters = parameters,
  }
end

--- Create a top divider widget.
-- @see divider
-- @tparam[opt] int width
-- @tparam[optchain] table parameters
-- @treturn table
function CCSimpleGUI.top(width, parameters)
  expect(1, width, "number", "nil")
  expect(2, parameters, "table", "nil")
  parameters = parameters or {}
  parameters.top = true
  return {
    type = "divider",
    parameters = parameters,
    width = width,
  }
end

--- Create a bottom divider widget.
-- @see divider
-- @tparam[opt] int width
-- @tparam[optchain] table parameters
-- @treturn table
function CCSimpleGUI.bottom(width, parameters)
  expect(1, width, "number", "nil")
  expect(2, parameters, "table", "nil")
  parameters = parameters or {}
  parameters.bottom = true
  return {
    type = "divider",
    parameters = parameters,
    width = width,
  }
end

--- Create a divider widget.
-- @see divider
-- @tparam[opt] int width
-- @tparam[optchain] table parameters
-- @treturn table
function CCSimpleGUI.divider(width, parameters)
  expect(1, width, "number", "nil")
  expect(2, parameters, "table", "nil")
  return {
    type = "divider",
    parameters = parameters,
    width = width,
  }
end

--- Create a button widget.
-- @see button
-- @tparam string label
-- @tparam[opt] string key
-- @tparam[optchain] int width
-- @tparam[optchain] int height
-- @tparam[optchain] table parameters
-- @treturn table
function CCSimpleGUI.button(label, key, width, height, parameters)
  expect(1, label, "string")
  expect(2, key, "string", "nil")
  expect(3, width, "number", "nil")
  expect(4, height, "number", "nil")
  expect(5, parameters, "table", "nil")
  return {
    type = "button",
    posArgs = { label },
    width = width,
    height = height,
    parameters = parameters,
    key = key,
  }
end

--- Create a checkbox widget.
-- @see checkbox
-- @tparam string label
-- @tparam[opt] string key
-- @tparam[optchain] int width
-- @tparam[optchain] table parameters
-- @treturn table
function CCSimpleGUI.checkbox(label, key, width, parameters)
  expect(1, label, "string")
  expect(2, key, "string", "nil")
  expect(3, width, "number", "nil")
  expect(4, parameters, "table", "nil")
  return {
    type = "checkbox",
    posArgs = { label },
    width = width,
    parameters = parameters,
    key = key,
  }
end

--- Create a listbox widget.
-- @see listbox
-- @tparam table T
-- @tparam[opt] string key
-- @tparam[optchain] int width
-- @tparam[optchain] int height
-- @tparam[optchain] table parameters
-- @treturn table
function CCSimpleGUI.listbox(T, key, width, height, parameters)
  expect(1, T, "table")
  expect(2, key, "string", "nil")
  expect(3, width, "number", "nil")
  expect(4, height, "number", "nil")
  expect(5, parameters, "table", "nil")
  return {
    type = "listbox",
    posArgs = { T },
    width = width,
    height = height,
    parameters = parameters,
    key = key,
  }
end

--- Create a printoutput widget.
-- @see printoutput
-- @tparam[opt] string key
-- @tparam[optchain] int width
-- @tparam[optchain] int height
-- @tparam[optchain] table parameters
-- @treturn table
function CCSimpleGUI.printoutput(key, width, height, parameters)
  expect(1, key, "string", "nil")
  expect(2, width, "number", "nil")
  expect(3, height, "number", "nil")
  expect(4, parameters, "table", "nil")
  return {
    type = "printoutput",
    width = width,
    height = height,
    parameters = parameters,
    key = key,
  }
end

--- Create a scrollinput widget.
-- @see scrollinput
-- @tparam table T
-- @tparam[opt] string key
-- @tparam[optchain] int width
-- @tparam[optchain] table parameters
-- @treturn table
function CCSimpleGUI.scrollinput(T, key, width, parameters)
  expect(1, T, "table")
  expect(2, key, "string", "nil")
  expect(3, width, "number", "nil")
  expect(4, parameters, "table", "nil")
  return {
    type = "scrollinput",
    posArgs = { T },
    width = width,
    parameters = parameters,
    key = key,
  }
end

--- Create a textinput widget.
-- @see textinput
-- @tparam[opt] string key
-- @tparam[optchain] int width
-- @tparam[optchain] table parameters
-- @treturn table
function CCSimpleGUI.textinput(key, width, parameters)
  expect(1, key, "string", "nil")
  expect(2, width, "number", "nil")
  expect(3, parameters, "table", "nil")
  return {
    type = "textinput",
    width = width,
    parameters = parameters,
    key = key,
  }
end

--- Create a progressbar widget.
-- @see progressbar
-- @tparam number maxValue
-- @tparam[opt] string key
-- @tparam[optchain] int width
-- @tparam[optchain] table parameters
-- @treturn table
function CCSimpleGUI.progressbar(maxValue, key, width, parameters)
  expect(1, maxValue, "number")
  expect(2, key, "string", "nil")
  expect(3, width, "number", "nil")
  expect(4, parameters, "table", "nil")
  return {
    type = "progressbar",
    width = width,
    key = key,
    posArgs = {maxValue},
    parameters = parameters
  }
end

return CCSimpleGUI
