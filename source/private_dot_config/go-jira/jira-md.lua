-- Filter for `jira-md`: turns the issue-wiki template's frontmatter code block into YAML front matter, replaces user mentions with @names from its people block, and tightens lists.
local people = {}

local function collect_people(doc)
  doc:walk({
    CodeBlock = function(block)
      if block.classes[1] == 'people' then
        for id, name in block.text:gmatch('(%S+) ([^\n]+)') do people[id] = name end
      end
    end,
  })
end

local function mention(link)
  if link.classes:includes('user-account') then
    local name = people[link.target:gsub('^~accountid:', '')]
    if name then return pandoc.Str('@' .. name) end
  end
end

local function unwrap(block)
  if block.classes[1] == 'frontmatter' then
    return pandoc.RawBlock('markdown', '---\n' .. block.text:gsub('\n+$', '') .. '\n---')
  elseif block.classes[1] == 'people' then
    return {}
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

return {
  { Pandoc = function(doc) collect_people(doc) end },
  { Link = mention },
  { CodeBlock = unwrap, BulletList = tighten, OrderedList = tighten },
}
