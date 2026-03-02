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

local sep = "|"

local function split_inlines_by_sep(inlines)
  local groups, current = {}, {}
  --debug_log("sep in split_inlines_by_sep: " .. repr(sep))
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



-- Ensure pandoc global is defined
if not pandoc then
  error("Pandoc Lua API is not available. This script must be run as a Pandoc filter.")
end


function make_cvcolumns(term_fields, definitions)
--  local items = {}
  local columns = {}
  
  --local term_fields = split_inlines_by_sep(term)
  for i, def in ipairs(definitions) do
    --debug_log("term " .. i ..  repr(term[i]))
    local def_fields = def[1].c

    local def_blocks = {table.unpack(def, 2)}

    -- debug_log("def_block: " .. repr(def_blocks))

    local desc = pandoc.write(pandoc.Pandoc(def_blocks), 'latex')

    -- debug_log("desc: " .. repr(desc))

    table.insert(columns, string.format("\\cvcolumn{%s}{%s}",
                  preserve(def_fields or ''), 
                  desc or ''))
                  --  pandoc.write(pandoc.Pandoc(def_block[1]), 'latex')))
  end

  return pandoc.RawBlock('latex', string.format(
                "\\begin{cvcolumns}\n    %s \n\\end{cvcolumns}",
                table.concat(columns, '\n    ')
              ))
end

function tack(term_fields,i)
  if i ~= 1 then
    -- 
    term_fields = {{""},{""},{""}}
  end
  return term_fields
end

function mk_item(type, term_fields, def_fields, i)

  if type == "empty" then
    macros = string.format("\\cvitem{%s}{}", preserve(term_fields[1])) --empty

  elseif type == "cvitem" then
    term_fields = tack(term_fields,i)
    -- debug_log("term_fields:  " .. repr(term_fields))
    macros = string.format("\\cvitem{%s}{%s}", 
                            preserve(term_fields[1]), preserve(def_fields[1]))

  elseif type == "cvitemwithcomment" then
    term_fields = tack(term_fields,i)
    macros = string.format("\\cvitemwithcomment{%s}{%s}{%s}",
                           preserve(term_fields[1]), preserve(def_fields[1]), preserve(def_fields[2]))

  elseif type == "cvdoubleitem" then
    term_fields = tack(term_fields,i)
    debug_log("i, term_fields: " .. i .. " " .. repr(term_fields))

    macros = string.format("\\cvdoubleitem{%s}{%s}{%s}{%s}",
                           preserve(term_fields[1]), preserve(def_fields[1]),
                           preserve(term_fields[2]), preserve(def_fields[2]))

  elseif type == "cvtripleitem" then
    term_fields = tack(term_fields,i)
    macros = string.format("\\cvtripleitem{%s}{%s}{%s}{%s}{%s}{%s}",
                          preserve(term_fields[1]), preserve(def_fields[1]),
                          preserve(term_fields[2]), preserve(def_fields[2]),
                          preserve(term_fields[3]), preserve(def_fields[3]))

  elseif type == "cvlistdoubleitem" then
    macros = string.format("\\cvlistdoubleitem{%s}{%s}", 
                          preserve(def_fields[1]), preserve(def_fields[2]))

    if i == 1 then
      tf = string.gsub(preserve(term_fields[1]), ": ", "")
      macros = string.format("\\cvlistdoubleitem{%s}{%s}",
                          tf, preserve(term_fields[2])) .. "\n\n" .. macros
    end

  elseif type == "cvlistitem" then
    macros = string.format("\\cvlistitem{%s}",
                            preserve(def_fields[1]))

    if i == 1 then
      tf = string.gsub(preserve(term_fields[1]), ": ", "")
      macros = string.format("\\cvlistitem{%s}",
                            tf) .. "\n\n" .. macros
    end

  else 
    error("Unknown item type: " .. type)
  end

  return pandoc.RawBlock('latex', macros)

end

function DefinitionList(el)
  local out = {}
  --debug_log("el:  " .. repr(el))
  for _, item in ipairs(el.c or {}) do

    local term, definitions = item[1], item[2]
    local term_tex = preserve(term or {})
    local term_fields = split_inlines_by_sep(term)

    if #definitions == 0 then
      -- No definitions, produce \cvitem with an empty description
      table.insert(out, mk_item("empty", term_fields , {}))

    else -- #definitions > 0 
      -- Single definition: check for \cventry or \cvitem family
      local first_def = definitions[1]      
      local first_def_fields = split_inlines_by_sep(first_def[1].c)

      if #first_def > 1 then -- first def has block content

        local first_def_blocks = {table.unpack(first_def, 2)}

        if #term_fields ~= 1 then
          error("complex items must have single field in term (no separators)")

        elseif #definitions == 1 then
          -- debug_log("term: " .. repr(term))
          -- debug_log("first_def: " .. repr(first_def))
          -- debug_log("first_def_fields: " .. repr(first_def_fields))
          -- debug_log("first_def_blocks: " .. repr(first_def_blocks))

          local desc = pandoc.write(pandoc.Pandoc(first_def_blocks), 'latex')
          local fields = split_inlines_by_sep(first_def[1].c)
          if #fields > 4 then
            error("\\cventry supports a maximum of 4 fields in the definition.")
          end
          -- only one definition; Block content exists; no more than 4 fields - use \cventry
          desc = desc:gsub("\n\n", "\n")
          --TODO: try to bypass this ugly hack with smth like Plain
          table.insert(out, pandoc.RawBlock('latex', string.format(
            "\\cventry{%s}{%s}{%s}{%s}{%s}{%s}",
            term_tex,
            preserve(fields[1] or ''),
            preserve(fields[2] or ''),
            preserve(fields[3] or ''),
            preserve(fields[4] or ''),
            desc
          )))
        elseif #definitions > 1 then
          cvcols = make_cvcolumns(term_fields, definitions)
          table.insert(out, cvcols)
        end

      else -- No block content, use \cvitem family

        for i, def in ipairs(definitions) do
          local def_fields = split_inlines_by_sep(def[1].c)

          if #def_fields ~= #first_def_fields then
            error("Invalid structure: all definitions must have same number of fields.")
          end

          -- debug_log("term[1].text: " .. repr(term[1].text))
          -- debug_log("term[1].text == \":\" " .. repr(term[1].text == ":"))
          
          if term[1].text ~= ":" then -- Term has no : in the beginning - regular item

            if #term_fields == 1 then
              -- either cvitem or cvitemwithcomment

              if first_def_fields and #first_def_fields == 0 then
                error("Definition has no fields for \\cvitem family.")

              elseif #first_def_fields == 1 then
                table.insert(out,  mk_item("cvitem", term_fields, def_fields, i))

              elseif #first_def_fields == 2 then
                table.insert(out, mk_item("cvitemwithcomment",  term_fields, def_fields, i))

              elseif #first_def_fields > 2 then
                -- debug_log("\\cvitem family supports a maximum of 2 fields in the definition.")
                -- debug_log("fields: " .. repr(first_def_fields))
                loc = stringify(item)
                error("Near " .. loc .."\n \\cvitem family supports a maximum of 2 fields in the definition.")
              end

            elseif #term_fields > 3 then
              error("\\cvitem family supports a maximum of 3 fields in the term.")

            elseif #term_fields ~= #first_def_fields then
              loc = "\nNear " .. stringify(item) .."\n"
              error(loc .. "double/triple items must have same number of term fields as definitions fields.")

            else -- #term_fields either 2 or 3
              if #first_def_fields == 2 then
                  --term_fields = split_inlines_by_sep(term[1].c)
                  table.insert(out, mk_item("cvdoubleitem", term_fields , def_fields, i))
              elseif #first_def_fields == 3 then
                -- debug_log("item: " .. repr(item))
                table.insert(out, mk_item("cvtripleitem", term_fields, def_fields, i))
              end
            end
        else -- Term begins with ":"

          -- debug_log("item: " .. repr(item))
          -- debug_log("term: " .. repr(term))
          -- debug_log("term.c: " .. repr(term.c))
          -- debug_log("definitions: " .. repr(definitions))
          -- def1 = definitions[1]
          -- debug_log("def[1]: " .. repr(def1.c))
          -- local fields = split_inlines_by_sep(definitions[1])
          -- debug_log("fields1: " .. repr(fields[1]))
          -- debug_log("term_tex: " .. repr(term_tex))
          -- debug_log("term_tex.c: " .. repr(term_tex.c))
            -- Term.#fields matches #definitions - Complex Items...

          -- debug_log("#def_fields: " .. repr(#def_fields))
          -- debug_log("#first_def_fields: " .. repr(#first_def_fields))
            if #def_fields == 2 then
              -- debug_log('were in cvlistdoubleitem')
              table.insert(out, mk_item("cvlistdoubleitem", term_fields, def_fields, i ))
            else
              -- debug_log('were in cvlistitem')

              table.insert(out, mk_item("cvlistitem", term_fields,  def_fields, i))
            end

            -- #definitions > 3
            -- debug_log("definitions: " .. repr(definitions))
            -- debug_log("term: " .. repr(term))
            -- debug_log("def_fields: " .. repr(def_fields))
            -- debug_log("first_def_fields: " .. repr(first_def_fields))
          end
        end
      end
    end
  end
  return out
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
  return parsed
end


-- Function to handle theme configurations
local function Theme(meta)

  local theme = meta.theme or {}
  sep = stringify(theme.separationsymbol or "|")
  -- debug_log("meta: " .. repr(meta))
  local theme_blocks = {
    -- string.format("\\documentclass[%s,%s,%s,%s]{moderncv}",
     --   stringify(theme.fontsize), stringify(theme.papersize),
     --   stringify(theme.fontfamily), "colorlinks=true"
    -- ),
    string.format("\\moderncvcolor{%s}", stringify(theme.moderncvcolor)),
    --cvcolor must be set before style, otherwise it will not be applied to the document
    string.format("\\moderncvstyle[left,details]{%s}", stringify(theme.moderncvstyle)), 
    --string.format("\\usepackage[scale=%s]{geometry}", stringify(theme.scale)),
    string.format("\\setlength{\\hintscolumnwidth}{%s}", stringify(theme.hintscolumnwidth))
    -- "\\setlength{\\separatorcolumnwidth}{0.05\\textwidth}"
  }
  return theme_blocks
end

function Meta(meta)
  debug_log("\nnew run =========================================")
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
    local patt = '[^' .. sep .. ']+'
    -- debug_log("Splitting address: " .. s .. " with pattern: " .. sep)
    for part in s:gmatch(patt) do
      parts[#parts+1] = trim(part)
    end
    return parts
  end

    -- Process theme configurations
  -- if meta.theme then

  -- debug_log("meta: " .. stringify(meta))
  -- debug_log("meta.theme: " .. stringify(meta.theme))

    -- Load default theme configuration
  local defaults = load_default_theme()
  --debug_log("defaults_loaded: " .. repr(defaults))

  -- Merge user-provided theme with defaults
  --local user_theme = meta.theme or {}
  --debug_log("user_theme: " .. repr(user_theme))

  meta = merge_defaults(defaults, meta)

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
    Meta = Meta,
    Inline = Inline,
    Block = Block
    }
}