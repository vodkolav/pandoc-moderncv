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


function  Inline(inl)
  -- debug_log("Inline found")
  if inl.t == 'LineBreak' or inl.t == 'SoftBreak' then
    return pandoc.RawInline('latex', '\\newline ')
    --- return pandoc.Str(escape_tex(inl.text))
  else
    -- if inl.t ~= 'Str' and inl.t ~= 'Space' then
    --   -- debug_log( inl.t .. " found")
    -- end
    return inl
  end
end

function  Block(blck)
  -- debug_log("Inline found")
  -- debug_log( blck.t .. " found: " .. repr(blck))
  -- if blck.t == 'Para' or blck.t == 'Plain' or blck.t == 'RawBlock' then
  --   return pandoc.RawInline('latex', stringify(blck)  .. " (" .. blck.t .. ")")
  --   --- return pandoc.Str(escape_tex(inl.text))
  -- -- else
  -- --   if blck.t ~= 'Para' and blck.t ~= 'Plain' then
  -- --   end
  -- --   return blck
  -- end
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
    local def_fields = split_inlines_by_sep(def[1].c)
    local items = {}
    for _, field in ipairs(def_fields) do
      table.insert(items, string.format("\\item %s", preserve(field)))
    end
    table.insert(columns, string.format("\\cvcolumn{%s}{\\begin{itemize}%s\\end{itemize}}",
                  preserve(term_fields[i] or ''), table.concat(items, ' ')))
  end

  return pandoc.RawBlock('latex', string.format(
                "\\begin{cvcolumns} %s \\end{cvcolumns}",
                table.concat(columns, ' ')
              ))
end



function DefinitionList(el)
  local out = {}
  debug_log("el:  " .. repr(el))
  for _, item in ipairs(el.c or {}) do
    debug_log("item:  " .. repr(item))

    local term, definitions = item[1], item[2]
    local term_tex = preserve(term or {})

    if #definitions == 0 then
      -- No definitions, produce \cvitem with an empty description
      table.insert(out, pandoc.RawBlock('latex', string.format(
        "\\cvitem{%s}{}",
        term_tex
      )))
    else -- #definitions > 0 
      -- Single definition: check for \cventry or \cvitem family
      local first_def = definitions[1]
      local desc_blocks = {table.unpack(first_def, 2)}
      
      if #desc_blocks > 0 then
        if #definitions > 1 then
          error("Invalid structure: Multiple definitions with block content is not supported for \\cventry.")
        end
        local desc = pandoc.write(pandoc.Pandoc(desc_blocks), 'latex')
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
      else
        -- No block content, use \cvitem family
        if #definitions == 1 then
          local fields = split_inlines_by_sep(first_def[1].c)
          -- debug_log("fields: " .. repr(fields))
          if fields and #fields == 0 then
            error("Definition has no fields for \\cvitem family.")
          elseif #fields == 1 then
            table.insert(out, pandoc.RawBlock('latex', string.format(
              "\\cvitem{%s}{%s}", term_tex, preserve(fields[1])
            )))
          elseif #fields == 2 then
            table.insert(out, pandoc.RawBlock('latex', string.format(
              "\\cvitemwithcomment{%s}{%s}{%s}",
              term_tex, preserve(fields[1]), preserve(fields[2])
            )))          
          elseif #fields > 2 then
            debug_log("\\cvitem family supports a maximum of 2 fields in the definition.")
            debug_log("fields: " .. repr(fields))
            error("\\cvitem family supports a maximum of 2 fields in the definition.")
          end
        end


        if #definitions > 1 then
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

          term_fields = split_inlines_by_sep(term)

          if #term_fields ~= #definitions then
            error("Mismatch between number of term fields and definitions for multiple definitions.")
          else
            -- Term.#fields matches #definitions - Complex Items...

            local temp = {}
            for i, def in ipairs(definitions) do
              local def_fields = split_inlines_by_sep(def[1].c)
              if #def_fields > 1 then
                -- Treat as \cvcolumns. iterate again on all the fields of the definition and create an itemize list for each definition
                debug_log("item(cvcolumns): " .. repr(item))
                
                cvcols = make_cvcolumns(term_fields, definitions)
                table.insert(out, cvcols)
                break
              end

              -- If we get here, it means none of the definitions had more than 1 field, so we can treat as \cvdoubleitem or \cvtripleitem              
              temp = {}
              if #definitions == 2 then
                --term_fields = split_inlines_by_sep(term[1].c)
                temp = pandoc.RawBlock('latex', string.format(
                  "\\cvdoubleitem{%s}{%s}{%s}{%s}",
                  preserve(term_fields[1]), stringify(definitions[1]),
                  preserve(term_fields[2]), stringify(definitions[2])
                ))
              elseif #definitions == 3 then
                --term_fields = split_inlines_by_sep(term[1].c)
                debug_log("item: " .. repr(item))
                temp = pandoc.RawBlock('latex', string.format(
                  "\\cvtripleitem{%s}{%s}{%s}{%s}{%s}{%s}",
                   preserve(term_fields[1]), stringify(definitions[1]),
                   preserve(term_fields[2]), stringify(definitions[2]),
                   preserve(term_fields[3]), stringify(definitions[3])
                ))
              else -- #definitions > 3
                --debug_log("definitions: " .. repr(definitions))
              error("Invalid structure: \\cvdouble and tripleitem family supports up to 3 fields.")
              end
            end
            table.insert(out, temp)
          end
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
  --debug_log("user_theme: " .. repr(user_theme))

  local theme = merge_defaults(defaults, user_theme)
  sep = stringify(theme.separationsymbol or "|")
  debug_log("sep: " .. sep)
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
    Meta = Meta,
    Inline = Inline,
    Block = Block
    }
}