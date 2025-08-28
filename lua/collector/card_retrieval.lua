local BB = require('collector.basic')

local CD = {}
function CD.card_file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function CD.card_file_read(file_name)
  local file, err = io.open(file_name, "r")
  if not file then
    print("Error opening file:", err)
    return ""
  end

  local content = file:read("*a")
  file:close()
  return content;
end

function CD.cacheCardSearchResponse(file_name, card_response)
  local file, error = io.open(file_name, "w")
  if not file then
    print("Error opening file:", error)
    return
  end

  file:write(card_response)

  file:close()
end

function CD.readArtworkFile(card_name)
  local image_path = BB.crapHash(card_name)..".png"
  local image_file, err = io.open(image_path, "rb")
  if not image_file then
    print("failed to open image file", err)
    return ""
  end

  local contents = image_file:read("*a")
  image_file:close()
end

function CD.downloadImage(card_name, artwork_url)
  local h = io.popen('curl -X GET "'..artwork_url..'"  \
  -H "Content-Type: image/png"')
  if(h == nil) then
    print("network error")
    return
  end

  local rawdata = h:read("all")
  h:close()

  local file = io.open(BB.crapHash(card_name)..".png", "w")
  if not file then
    print("Error opening file:", error)
    return
  end

  file:write(rawdata)

  file:close()
end

function CD.requestSearchCard(card_name)
  local h = io.popen('curl -X GET "https://api.scryfall.com/cards/search?q='..string.gsub(card_name, " ", "%%20")..'"  \
  -H "Content-Type: application/json"')
  if(h == nil) then
    print("network error")
    return
  end

  local rawdata = h:read("all")
  h:close()
  local t = vim.json.decode(rawdata)
  -- local cardStuff = vim.json.decode(rawdata)
  -- print(vim.inspect(t))

  return t;
end

function CD.getCardData(card_name)
  if(card_name == nil) then
    print("missing card name")
  end

  local crappy_card_hash = BB.crapHash(card_name)
  print(crappy_card_hash)

  if(CD.card_file_exists(crappy_card_hash)) then
    print("using cached file")
    local card_file_contents = CD.card_file_read(crappy_card_hash)
    local card_json = vim.json.decode(card_file_contents)

    if(CD.card_file_exists(crappy_card_hash..".png") == false) then
      local art_crop_url = card_json["data"][1]["image_uris"]["art_crop"]
      CD.downloadImage(card_name, art_crop_url)
    end

    return card_json["data"][1]
  else
    print("using network request")
    local requested_card_data = CD.requestSearchCard(card_name)
    if requested_card_data == nil then
      print("failed request")
    end

    CD.cacheCardSearchResponse(crappy_card_hash, vim.json.encode(requested_card_data))

    if(CD.card_file_exists(crappy_card_hash..".png") == false) then
      local art_crop_url = requested_card_data["image_uris"]["art_crop"]
      CD.downloadImage(card_name, art_crop_url)
    end

    return requested_card_data["data"][1]
  end
end

return CD
