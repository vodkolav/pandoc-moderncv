
-- Remove everything that isn't a CodeBlock
function Pandoc(doc)
  local blocks = {}
  for i, el in ipairs(doc.blocks) do
    if el.t == "CodeBlock" then
        if el.classes[1] == 'markdown' then
            table.insert(blocks, pandoc.RawBlock('markdown', el.text .. "\n\n\\newpage"))
        end
    end
  end
  return pandoc.Pandoc(blocks)
end