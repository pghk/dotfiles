-- Filter for `jira-md`: turns the issue-wiki template's frontmatter code block into YAML front matter, and tightens lists.
function CodeBlock(block)
  if block.classes[1] == 'frontmatter' then
    return pandoc.RawBlock('markdown', '---\n' .. block.text:gsub('\n+$', '') .. '\n---')
  end
end

-- The Jira reader makes every list item a paragraph, which renders as a loose list. Items without a second paragraph become tight.
local function tighten(list)
  for _, item in ipairs(list.content) do
    local paragraphs = 0
    for _, block in ipairs(item) do
      if block.t == 'Para' then paragraphs = paragraphs + 1 end
    end
    if paragraphs == 1 and item[1].t == 'Para' then
      item[1] = pandoc.Plain(item[1].content)
    end
  end
  return list
end

BulletList = tighten
OrderedList = tighten
