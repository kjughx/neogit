local parse_string, parse_array, parse_object, parse_anything, parse_builtin

local M = {}

function parse_string(raw, idx)
  local str = ""
  local function advance()
    local c = string.sub(raw, idx, idx)
    idx = idx + 1
    return c
  end

  while true do
    local c = advance()
    if c == '"' then
      break
    end
    str = str .. c
  end

  return { str, idx }
end

function parse_array(raw, idx)
  local arr = {}

  local function advance()
    local c = string.sub(raw, idx, idx)
    idx = idx + 1
    return c
  end

  while true do
    local c = advance()
    if c == "]" then
      break
    end
  end

  return { arr, idx }
end

function parse_builtin(raw, idx)
  local function advance()
    local c = string.sub(raw, idx, idx)
    idx = idx + 1
    return c
  end

  local function peek()
    return string.sub(raw, idx, idx)
  end

  local str = ""
  while true do
    local c = peek()
    if c == "," or c == "}" then
      break
    end

    str = str .. c
    advance()
  end

  return { str, idx }
end

function parse_object(raw, idx)
  local object = {}

  local function advance()
    local c = string.sub(raw, idx, idx)
    idx = idx + 1
    return c
  end

  local c = advance()

  local key = ""
  if c == '"' then
    key, idx = unpack(parse_string(raw, idx))
  end

  assert(advance() == ":", string.format("Expected ':' at %d, found '%s'", idx - 1, raw[idx - 1]))

  local value
  value, idx = unpack(parse_anything(raw, idx))

  object[key] = value

  return { object, idx }
end

function parse_anything(raw, idx)
  local function advance()
    local c = string.sub(raw, idx, idx)
    idx = idx + 1
    return c
  end

  local function peek()
    return string.sub(raw, idx, idx)
  end

  local c = peek()
  local value
  if c == "{" then
    advance()
    value, idx = unpack(parse_object(raw, idx))
  elseif c == '"' then
    advance()
    value, idx = unpack(parse_string(raw, idx))
  elseif c == "[" then
    advance()
    value, idx = unpack(parse_array(raw, idx))
  else
    value, idx = unpack(parse_builtin(raw, idx))
  end

  return { value, idx }
end

function M.parse(raw)
  local obj = {}
  local idx = 1

  local function advance()
    local c = string.sub(raw, idx, idx)
    idx = idx + 1
    return c
  end

  local function peek()
    return string.sub(raw, idx, idx)
  end

  if peek() == '' then
    return obj
  end
  assert(advance() == "{", string.format("Expected '{' at %d, found '%s'", idx -1, string.sub(raw, idx -1 ,idx -1)))

  while true do
    local c = peek()
    if c == "" then
      break
    end

    local key
    if c == '"' then
      advance()
      key, idx = unpack(parse_string(raw, idx))
    end

    assert(advance() == ":", string.format("Expected ':' at %d, found '%s'", idx - 1, raw[idx - 1]))
    local value
    value, idx = unpack(parse_anything(raw, idx))

    obj[key] = value

    c = advance()
    if c == "}" then
      c = advance()
    end
    assert(c == "," or c == "}" or c == '', string.format("Expected ',' or '}' at %d, found '%s'", idx, string.sub(raw, idx, idx)))
  end

  return obj
end

return M
