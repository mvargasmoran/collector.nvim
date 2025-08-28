local BB = require("collector.basic")
local CD = require("collector.card_retrieval")

local mtgBuff = vim.api.nvim_create_buf(false, true)
local mtgWin = nil

function fillInBlanks(textTable, maxHeight)
  if BB.tableLength(textTable) >= maxHeight then
    return textTable
  end

  local filled = {}
  local currentRow = 0
  local height = 0
  local book_end = "│ │"
  local is_statement = false
  for line in pairs(textTable) do
    currentRow = currentRow + 1
    table.insert(filled, currentRow, line)

    local hasDot = string.find(line, "%. ") ~= nil
    local hasSpare = string.find(line, "           ") ~= nil

    if hasDot or hasSpare then
      is_statement = true
    else
      is_statement = false
    end

    height = BB.tableLength(filled)
    if height < maxHeight and is_statement then
      currentRow = currentRow + 1
      table.insert(filled, currentRow, fillLine("", "", 56, book_end).."\n")
    end
  end

  return filled
end

function fillInOracleText(oracle_text)
  local fitting_length = 56
  local book_end = "│ │"
  local padding = ""

  local fitted_text = {}
  local fitted = ""
  local ready_line = ""
  local current_row = 1
  local filler_line = ""

  filler_line = fillLine("", "", fitting_length, book_end, padding).."\n"
  local lines = BB.split(oracle_text, "\n")
  for index, line in pairs(lines) do
    if (string.len(line) < fitting_length) then
      ready_line = fillLine(BB.cleanUnicodeWeirdness(line), "", fitting_length, book_end, padding).."\n"
      table.insert(fitted_text, current_row, ready_line)
      current_row = current_row + 1
      table.insert(fitted_text, current_row, filler_line)
      current_row = current_row + 1
    else
      local accumulated_length = 0
      local words = BB.split(line, " ")
      for key, word in pairs(words) do
        accumulated_length = accumulated_length + string.len(word) + 1

        if(accumulated_length < fitting_length) then
          if key == 1 then
            fitted = word
          else
            fitted = fitted.." "..word
          end
        else
          -- Case add a line made of whatever fits into a lin, but there's still more
          ready_line = fillLine(BB.cleanUnicodeWeirdness(fitted), "", fitting_length, book_end, padding).."\n"
          table.insert(fitted_text, current_row, ready_line)
          current_row = current_row + 1

          accumulated_length = 0 + string.len(word) + 1
          fitted = word
        end

        -- Case add the last bit of words into a new line
        if (key == BB.tableLength(words)) then
          ready_line = fillLine(BB.cleanUnicodeWeirdness(fitted), "", fitting_length, book_end, padding).."\n"
          table.insert(fitted_text, current_row, ready_line)
          current_row = current_row + 1

          table.insert(fitted_text, current_row, filler_line)
          current_row = current_row + 1
          accumulated_length = 0
        end
      end
    end

  end
  -- return table.concat(fillInBlanks(fitted_text, 10), "")
  return table.concat(fitted_text, "")
end

function fillLine(left, right, size, book_end, padding)
  if(right == nil or right == '') then
    right = ""
  end
  if(size == nil) then
    size = 0
  end
  if book_end == nil then
    book_end = "│"
  end
  if(padding == nil) then
    padding = ""
  end

  local leftlen = string.len(left)
  local rightlen = string.len(right)
  local blank_space_size = size - (leftlen + rightlen + 2)
  local format = "%"..blank_space_size.."s"

  local line =  book_end..padding..left..string.format(format, "")..right..padding..book_end
  return line
end

-- Crummy getters
-- Crummy getters
-- Crummy getters

function getOracleText(card_data)
  return card_data["oracle_text"]
end

function getFlavorText(card_data)
  if (card_data["flavor_text"] == nil) then
    return ""
  end

  return card_data["flavor_text"]
end

function getName(card_data)
  return card_data["name"]
end

function getCost(card_data)
  if (card_data["mana_cost"] == nil or card_data["mana_cost"] == "") then
    return ""
  end
  return "|"..card_data["mana_cost"]
end

function getTypeLine(card_data)
  local type_line = card_data["type_line"]
  return string.gsub(type_line, "—", "-")
end

function getLargeImageURL(card_data)
  return card_data["image_uris"]["large"]
end

function getArtworkImageURL(card_data)
  return card_data["image_uris"]["art_crop"]
end

function getSetName(card_data)
  return card_data["set_name"]
end

function getSet(card_data)
  return "|"..card_data["set"]
end

function getPower(card_data)
  return card_data["power"]
end

function getToughness(card_data)
  return card_data["toughness"]
end

function getStats(card_data)
  if(getPower(card_data)) then
    return "["..getPower(card_data).."/"..getToughness(card_data).."]"
  end
  return ""
end

function downloadArtwork(card_data)
  local image_url = getArtworkImageURL(card_data)
  
end

function getAsciiArtwork(card_data)
  
end


local M = {}

function M.setup()
  vim.api.nvim_create_user_command('Collector', function ()
    -- print("hello from mtg-collector.nvim setup fn")

    if(mtgWin == nil) then
      mtgWin = vim.api.nvim_open_win(mtgBuff, false, {
        split = 'right',
      })
      -- vim.api.nvim_win_hide(mtgWin)
      -- vim.api.nvim_win_close(mtgWin, true)
    end
    vim.api.nvim_buf_set_text(mtgBuff, 0, 0, -1, -1, {"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",})

    local current_card = vim.api.nvim_get_current_line()
    local card_data = CD.getCardData(current_card)
    local collectorInfo = collectorPrint(card_data)
    -- local fittedOracle = fillInOracleText(getOracleText(card_data))

    -- CD.downloadImage(getName(card_data), getArtworkImageURL(card_data))

    local artwork_bin = CD.readArtworkFile(getName(card_data))

    -- -- vim.api.nvim_buf_set_lines(mtgBuff, 0, -1, false, collectorInfo)
    -- vim.api.nvim_buf_set_lines(mtgBuff, 0, -1, false, fittedOracle)
    -- vim.api.nvim_buf_set_text(mtgBuff, 0, -1, -1, -1, split(fittedOracle, "\n"))

    vim.api.nvim_buf_set_text(mtgBuff, 0, -1, -1, -1, collectorInfo)

  end, {})

  vim.api.nvim_set_keymap("n", "<leader>mcc", ":Collector<cr>", {})

  vim.keymap.set("n", "<leader>mcx", function ()
    if (mtgWin ~= nil) then
      vim.api.nvim_win_hide(mtgWin)
      mtgWin = nil
    end
  end, {})
end

function collectorPrint(card_data)
  local size = 60
  local book_end = "│"
  local padding = " "

  local card = [[
┌──────────────────────────────────────────────────────────┐
]]..fillLine(getName(card_data), getCost(card_data), size-2, book_end, padding)..[[

│ ┌──────────────────────────────────────────────────────┐ │
│ │█▓▒░▒▒░░▒                      ░░░                    │ │
│ │██▓▒░▒▒▒▒░                   ░░░░░░░                  │ │
│ │███▓▓▒▒▒▒░                  ░░░░░░░▒░░░               │ │
│ │▓▓▓▓▓▓▓▒░░                 ░▒▒▒░░▒▓▒▒▒░               │ │
│ │█▓▓▒▓▓█▒░░              ░ ░▒░▒░ ░▒▓▓▒▒                │ │
│ │▓▓▓▓▒▒▓▓▒░            ░░░░░░  ░░░░░░                  │ │
│ │█▓██████▓▒░            ░░░  ░░░▒░▒▒▒░░                │ │
│ │█████▓▓▓▓█▓░          ░░    ░▓▓▓▓▓▓▒░▒░               │ │
│ │▓▓██▓▓█▓▓▒▓▓      ░░       ░▓▓▓▓▓▓▓▒░░▒               │ │
│ │▓▒▓█▓▓▓▓▓▓▓░░             ░▒▓  ▓▓▓▒▒░░░               │ │
│ │▓▓▒▒▓███▓▓▒▒░░            ▒▓    ▓▒▓▓▒░░               │ │
│ │█▓▓▒▒░░▒▓▓▓▓▓▓            ░▒    ▒▒▓▓▒▒░░              │ │
│ │█▓█▓▓█▓▓░░░░░░░           ░▒    ▒▒▓▓▒░▒░░             │ │
│ │▓█████████▓▓░░▒░░░   ░          ░░░▒▒░░░░░░░░         │ │
│ │▒▓▓▓▓█████▓▓█▓▒▓▒▒▒░░         ░░░▒▒▓▓░   ░░░░░       ░│ │
│ │▒░░▒▒▒▒▓▓▓▓▓▒▓▓░▓▓▓▓▓▓▒▒▒░    ░░▒▓▒▒▓░               ▓│ │
│ │▒▒░░░░▒▓▓▓▓▒▒░░ ░▒░░     ░░ ░ ░▒▓▒▓▓▒░              ▒▓│ │
│ │▒▒▓▓▓▒▒▒▒▒░░░░░░░ ░  ░░░░ ░  ░  ░▒▒▓▒           ░░ ░▓▓│ │
│ │▒▒▓▓▓▒▒▒░▒▒▒▒░░░░░░▒░░░░░░░░░▒▒▓▒▓▓▒               ▒▓█│ │
│ │▒▒▒▒░░▒▓▒▓▓▓▓▒▒░░░░░░░░░░░▒▒▓▒▒▓▓▒▒▒▒░░  ░░      ░▓███│ │
│ │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒░░ ░░░░  ░░░▒▒▓▓██▓│ │
│ └──────────────────────────────────────────────────────┘ │
]]..fillLine(getTypeLine(card_data), getSet(card_data), size-2, book_end, padding)..[[

│ ┌──────────────────────────────────────────────────────┐ │
│ │                                                      │ │
]]..fillInOracleText(getOracleText(card_data))..[[
│ │                                                      │ │
│ └──────────────────────────────────────────────────────┘ │
]]..fillLine(getSetName(card_data), getStats(card_data), size-2, book_end, padding)..[[

└──────────────────────────────────────────────────────────┘

]]
  ..getFlavorText(card_data)
  return  BB.split(card, "\n")
end

return M

