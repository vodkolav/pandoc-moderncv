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
      
      debug_log("item1: " .. stringify(item[1])) -- .. " el.t:" .. stringify(definitions))
      debug_log("item2: " .. stringify(item[2])) -- .. " el.t:" .. stringify(definitions))
      debug_log("first_def: " .. stringify(first_def)) -- .. " el.t:" .. stringify(definitions))
      debug_log("first_def[1]: " .. stringify(first_def[1])) -- .. " el.t:" .. stringify(definitions))
      fields = split_inlines_by_sep(first_def[1].c)
      
      if first_def[2] then  --and first_def[2].t == 'Para' then
        
        desc =  {table.unpack(first_def, 2)} -- from second element to end 
        -- Split the first paragraph into fields using the separator
        debug_log("first_def[2]: " .. stringify(first_def[2])) -- .. " el.t:" .. stringify(definitions))
        debug_log("first_def[2].t: " .. stringify(first_def[2].t)) -- .. " el.t:" .. stringify(definitions))

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