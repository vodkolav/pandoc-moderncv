-- Minimal Pandoc Lua filter for moderncv
-- Converts DefinitionList entries into \cventry or \cvitem* macros

local function debug_log(msg)
  local log_file = io.open("logs/debug_log.txt", "a")
  log_file:write(msg .. "\n")
  log_file:close()
end

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local stringify = (require 'pandoc.utils').stringify

local function repr(obj)
  if type(obj) == "table" then
    local s = type(obj) .. ": { "
    for k, v in pairs(obj) do
      local key = type(k) == "string" and '"' .. k .. '"' or k
      s = s .. "[" .. key .. "] = " .. repr(v) .. ", "
    end
    return s .. "}"
  elseif type(obj) == "string" then
    return type(obj) .. ': "' .. obj .. '"'
  else
    return type(obj) .. ': ' .. tostring(obj)
  end
end

local function escape_tex(s)
  if not s then return '' end  -- Handle nil values
  s = s:gsub('\\', '\\textbackslash{}')
  s = s:gsub('%%', '\\%')
  s = s:gsub('{', '\\{')
  s = s:gsub('}', '\\}')
  s = s:gsub('#', '\\#')
  s = s:gsub('%$', '\\$')
  s = s:gsub('&', '\\&')
  s = s:gsub('_', '\\_')
  return s
end


local function split_inlines_by_sep(inlines)
  local sep = "|"
  local groups, current = {}, {}
  for b, el in ipairs(inlines) do
    if el.t == 'Str' and  el.text == sep then
      -- if type(el) == 'userdata' then
      --   elc = el.c or 'nul'
      --   debug_log("el: " .. attrs(el) .. " el.c:" .. elc .. " type(el.c):" .. type(el.c) .. " el.t: " .. el.t)
      -- end
        table.insert(groups, current)
        current = {}
      -- else
      --   table.insert(current, el)
      --end
    else
      table.insert(current, el)
    end
  end
  table.insert(groups, current)
  return groups
end


function preserve(field)
  return pandoc.write(pandoc.Pandoc({pandoc.Plain(field)}), 'latex')
end



function DefinitionList(el)
  debug_log("hello")
  local out = {}
  for _, item in ipairs(el.c or {}) do
    local term, definitions = item[1], item[2]
    local term_tex = preserve(term or {})

    if #definitions == 0 then
      -- No definitions, produce \cvitem with an empty description
      debug_log("No definitions for item: " .. stringify(item))
      table.insert(out, pandoc.RawBlock('latex', '\\cvitem{' .. term_tex .. '}{ }'))
    else
      local first_def = definitions[1]
      local fields, description_blocks = {}, {}
      
      -- debug_log("item1: " .. stringify(item[1])) -- .. " el.t:" .. stringify(definitions))
      -- debug_log("item2: " .. stringify(item[2])) -- .. " el.t:" .. stringify(definitions))
      -- debug_log("first_def: " .. stringify(first_def)) -- .. " el.t:" .. stringify(definitions))
      -- debug_log("first_def[1]: " .. stringify(first_def[1])) -- .. " el.t:" .. stringify(definitions))
      fields = split_inlines_by_sep(first_def[1].c)
      
      if first_def[2] then  --and first_def[2].t == 'Para' then
        
        desc =  {table.unpack(first_def, 2)} -- from second element to end 
        -- Split the first paragraph into fields using the separator
        -- debug_log("first_def[2]: " .. stringify(first_def[2])) -- .. " el.t:" .. stringify(definitions))
        -- debug_log("first_def[2].t: " .. stringify(first_def[2].t)) -- .. " el.t:" .. stringify(definitions))

        -- If there are block elements, produce \cventry
        local desc = pandoc.write(pandoc.Pandoc(desc), 'latex')
        -- desc = string.format("\\parbox[t]{\\textwidth}{%s}", desc)  -- Wrap in \parbox
        -- desc = string.format("\\begin{minipage}[t]{\\textwidth}%s\\end{minipage}", desc)
        desc = desc:gsub("\n\n", "\n")
        -- debug_log("desc:" .. desc)
        table.insert(out, pandoc.RawBlock('latex', string.format(
          '\\cventry{%s}{%s}{%s}{%s}{%s}{%s}',
          term_tex,  -- Term
          preserve(fields[1] or '') ,  -- Field 1
          preserve(fields[2] or '') ,  -- Field 2
          preserve(fields[3] or '') ,  -- Field 3
          preserve(fields[4] or '') ,  -- Field 4
          desc              -- Description
        )))
      else
        -- If no block elements, produce \cvitem family
        -- debug_log("cvitem fields: " .. stringify(fields))
        if #fields == 0 then
          table.insert(out, pandoc.RawBlock('latex', string.format(
            '\\cvitem{%s}{}',
            term_tex
          )))
        elseif #fields == 1 then
          table.insert(out, pandoc.RawBlock('latex', string.format(
            '\\cvitem{%s}{%s}',
            term_tex, preserve(fields[1])
          )))
        elseif #fields == 2 then
          table.insert(out, pandoc.RawBlock('latex', string.format(
            '\\cvitemwithcomment{%s}{%s}{%s}',
            term_tex, preserve(fields[1]), preserve(fields[2])
          )))
        elseif #fields == 3 then
          table.insert(out, pandoc.RawBlock('latex', string.format(
            '\\cvdoubleitem{%s}{%s}{%s}{%s}',
            term_tex, preserve(fields[1]), preserve(fields[2]), preserve(fields[3])
          )))
        else
          table.insert(out, pandoc.RawBlock('latex', string.format(
            '\\cvdoubleitem{%s}{%s}{%s}{%s}',
            term_tex, preserve(fields[1]), preserve(fields[2]) , preserve(fields[3]) .. preserve(fields[4])
          )))
        end
      end
    end
  end
  return out
end


function DocumClass(dc)
  -- debug_log("meta.theme: " .. stringify(meta.theme))
  -- debug_log("meta.theme: " .. stringify(theme))
  -- debug_log("meta.theme.documentclass: " .. stringify(theme.documentclass))

  --local documentclass = "\\documentclass[13pt,a4paper,sans]{moderncv}" -- Default

  -- local dc = theme.documentclass
  -- local font_size = dc.fontsize or "12pt"
  -- local paper_size = dc.papersize or "a4paper"
  -- local font_family = dc.fontfamily or "sans"
  local options = string.format("%s,%s,%s", dc["fontsize"], dc.papersize, dc.fontfamily)
  debug_log("dc: " .. repr(dc))
  --debug_log("dc.fontsize: " .. stringify(dc.fontsize))
  

  return options
end


-- Function to recursively merge user config with defaults
local function merge_defaults(defaults, user_config)
  --debug_log("user_config: " .. repr(user_config))
  --debug_log("defaults: " .. repr(defaults))
  if type(user_config) ~= "table" then
    return user_config or defaults
  end

  local merged = {}
  for key, default_value in pairs(defaults) do
    merged[key] = merge_defaults(default_value, user_config[key])
  end
  --debug_log("merged: " .. repr(merged))

  for key, user_value in pairs(user_config) do
    -- if merged[key] == nil then
      merged[key] = user_value
    -- end
  end

  return merged
end


-- Function to load default theme configuration as a Pandoc AST
local function load_default_theme()
  local file = io.open("templates/default-theme.md", "r")
  if not file then
    error("Default theme configuration file not found!")
  end
  local content = file:read("*all")
  file:close()

  -- Parse the YAML content into a Pandoc AST
  local parsed = pandoc.read(content, "markdown").meta
  --debug_log("parsed: " .. repr(parsed))
  return parsed.theme
end


-- Function to handle theme configurations
local function Theme(meta)
  -- Load default theme configuration
  local defaults = load_default_theme()
  --debug_log("defaults_loaded: " .. repr(defaults))

  -- Merge user-provided theme with defaults
  local user_theme = meta.theme or {}
  local theme = merge_defaults(defaults, user_theme)
  --debug_log("merged_theme: " .. repr(theme))
  local theme_blocks = {
    string.format("\\documentclass[%s,%s,%s]{moderncv}",
      stringify(theme.fontsize), stringify(theme.papersize), stringify(theme.fontfamily)
    ),
    string.format("\\moderncvstyle{%s}", stringify(theme.moderncvstyle)),
    string.format("\\moderncvcolor{%s}", stringify(theme.moderncvcolor)),
    string.format("\\usepackage[scale=%s]{geometry}", stringify(theme.scale))
  }
  
  return theme_blocks
end

function Meta(meta)
  local blocks = {}

  local function mstr(key)
    local v = meta[key]
    if not v then return nil end
    return pandoc.utils.stringify(v)
  end

  local function split_name(s)
    if not s or s == '' then return nil, nil end
    local first, rest = s:match('^(%S+)%s+(.+)$')
    if first then return first, rest end
    return s, ''
  end

  local function split_comma(s)
    if not s then return {} end
    local parts = {}
    for part in s:gmatch('[^,]+') do
      parts[#parts+1] = trim(part)
    end
    return parts
  end

    -- Process theme configurations
  -- if meta.theme then

  debug_log("meta: " .. stringify(meta))
  -- debug_log("meta.theme: " .. stringify(meta.theme))


    local theme_blocks = Theme(meta)
    for _, block in ipairs(theme_blocks) do
      table.insert(blocks, pandoc.RawBlock('latex', block))
    end
  -- end


  -- name: prefer explicit firstname/lastname, else split `name` or `author`
  local firstname = mstr('firstname')
  local lastname = mstr('lastname')
  if not firstname and not lastname then
    local name = mstr('name')
    if name then 
      firstname, lastname = split_name(name) 
    else
      local author = mstr('author')
      if author then
        firstname, lastname = split_name(author)
      else
        error("moderncv.lua: No name information found in metadata (need 'name' or 'firstname'/'lastname' or 'author')")
      end
    end
  end
  if firstname or lastname then
    firstname = firstname or ''
    lastname = lastname or ''
    table.insert(blocks, pandoc.RawBlock('latex', string.format('\\name{%s}{%s}', escape_tex(firstname), escape_tex(lastname))))
  end

  -- title
  local title = mstr('title')
  if title and title ~= '' then
    table.insert(blocks, pandoc.RawBlock('latex', string.format('\\title{%s}', escape_tex(title))))
  end

  -- address: stringify and split on commas into up to three parts
  if meta['address'] then
    local addr_raw = pandoc.utils.stringify(meta['address'])
    local parts = split_comma(addr_raw)
    local street = parts[1] or ''
    local city = parts[2] or ''
    local country = parts[3] or ''
    table.insert(blocks, pandoc.RawBlock('latex', string.format('\\address{%s}{%s}{%s}', escape_tex(street), escape_tex(city), escape_tex(country))))
  end

  -- phones: support either single `phone` or a map `phones`
  local phone = mstr('phone')
  if phone and phone ~= '' then
    table.insert(blocks, pandoc.RawBlock('latex', string.format('\\phone[mobile]{%s}', escape_tex(phone))))
  end
  if meta['phones'] then
    for k, v in pairs(meta['phones']) do
      local num = pandoc.utils.stringify(v)
      if num and num ~= '' then
        table.insert(blocks, pandoc.RawBlock('latex', string.format('\\phone[%s]{%s}', escape_tex(k), escape_tex(num))))
      end
    end
  end

  -- email
  local email = mstr('email')
  if email and email ~= '' then
    table.insert(blocks, pandoc.RawBlock('latex', string.format('\\email{%s}', escape_tex(email))))
  end

  -- homepage
  local homepage = mstr('homepage') or mstr('url')
  if homepage and homepage ~= '' then
    table.insert(blocks, pandoc.RawBlock('latex', string.format('\\homepage{%s}', escape_tex(homepage))))
  end

  -- social: expect a map of type -> account or url
  if meta['social'] then
    for k, v in pairs(meta['social']) do
      local account = pandoc.utils.stringify(v)
      if account and account ~= '' then
        -- if looks like a url, put it as url argument; else as account
        if account:match('^https?://') then
          table.insert(blocks, pandoc.RawBlock('latex', string.format('\\social[%s]{%s}', escape_tex(k), escape_tex(account))))
        else
          table.insert(blocks, pandoc.RawBlock('latex', string.format('\\social[%s]{%s}', escape_tex(k), escape_tex(account))))
        end
      end
    end
  end


  -- append to header-includes (create or extend)
  local hi = meta['header-includes'] or {}
  for _, b in ipairs(blocks) do table.insert(hi, b) end
  meta['header-includes'] = hi
  return meta
end

return {
  { DefinitionList = DefinitionList,
    Meta = Meta}
}