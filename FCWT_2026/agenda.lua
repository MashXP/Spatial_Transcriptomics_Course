-- Shared lecture-slide filters.
--
-- 1) Agenda blocks
--    Declared once in the .qmd YAML header:
--        sections:
--          - R Data Structures
--          - Reading, Writing & Merging Files
--          - ...
--    and referenced in the body as:
--        ::: {.agenda data-section="2"}
--        :::
--    The number in data-section is the item that gets bolded.
--
--    Two control markers share the .agenda class. Note the leading dot on
--    every extra class - "{.agenda pause}" is silently ignored by Quarto,
--    it has to be "{.agenda .pause}":
--        ::: {.agenda .pause}   skip the section tag on the next slide only
--        ::: {.agenda .end}     stop inserting tags for the rest of the
--                              section (both reset at the next section)
--
-- 2) Section tags
--    Every "###" slide inside a numbered section gets a tag:
--        ::: {.section-tag}
--        2. Reading, Writing & Merging Files
--        :::
--    Write one explicitly to override it, e.g.
--        ::: {.section-tag}
--        1. R Data Structures · Extra
--        :::
--    "##" slides (section dividers, intro, recap, closing) are left alone.

local function read_sections(doc)
  local raw = doc.meta["sections"]
  if not raw then
    error("slides.lua: no `sections:` list found in the .qmd YAML header")
  end

  local titles = {}
  for _, item in ipairs(raw) do
    titles[#titles + 1] = pandoc.utils.stringify(item)
  end

  if #titles == 0 then
    error("slides.lua: the `sections:` list in the YAML header is empty")
  end

  return titles
end

-- ---------------------------------------------------------------- agenda ---

local function agenda_item(i, title, active)
  local text = ("%d. %s"):format(i, title)
  if active then
    return pandoc.Para({ pandoc.Strong({ pandoc.Str(text) }) })
  end
  return pandoc.Para({ pandoc.Str(text) })
end

-- Splits the agenda across two columns: first half left, remainder right.
local function agenda_div(titles, active)
  local half = math.ceil(#titles / 2)
  local left, right = {}, {}

  for i, title in ipairs(titles) do
    local line = agenda_item(i, title, active == i)
    if i <= half then
      left[#left + 1] = line
    else
      right[#right + 1] = line
    end
  end

  local function column(width, content)
    return pandoc.Div(content, pandoc.Attr("", { "column", "column-" .. width }))
  end

  return pandoc.Div(
    {
      column("50", left),
      pandoc.RawBlock("markdown", "\n"),
      column("50", right),
    },
    pandoc.Attr("", { "columns" })
  )
end

-- ---------------------------------------------------------- section tags ---

local function section_tag_div(text)
  return pandoc.Div({ pandoc.Para({ pandoc.Str(text) }) }, pandoc.Attr("", { "section-tag" }))
end

-- A level-2 heading opens a section when its text ends with one of the
-- declared titles ("## 📋 2. Reading, Writing & Merging Files").
local function match_section(header, titles)
  local plain = pandoc.utils.stringify(header.content)
  for n, title in ipairs(titles) do
    if plain:sub(-#title) == title then
      return n, title
    end
  end
  return nil
end

local function has_class(block, name)
  return block ~= nil and block.classes ~= nil and block.classes:includes(name)
end

-- The text inside a .section-tag div, as one string.
--
-- "1. R Data Structures · Extra" is parsed by pandoc as an ordered list, not
-- a paragraph, so the leading number is not a Str node and is lost by a plain
-- stringify. Rebuild the marker so explicit tags keep their full text.
local function tag_text(block)
  for _, child in ipairs(block.content) do
    if child.t == "Para" or child.t == "Plain" then
      return pandoc.utils.stringify(child)
    end
  end

  for _, child in ipairs(block.content) do
    if child.t == "OrderedList" then
      local parts = {}
      local n = child.start or 1
      for _, item in ipairs(child.content) do
        parts[#parts + 1] = n .. ". " .. pandoc.utils.stringify(item)
        n = n + 1
      end
      return table.concat(parts, " ")
    end
  end

  return pandoc.utils.stringify(block)
end

function Pandoc(doc)
  local titles = read_sections(doc)

  local out = pandoc.List()
  local current_num, current_title = nil, nil
  local pending_tag = nil
  local auto_on = true     -- `end` switches this off for the rest of the section
  local pause_once = false -- `pause` suppresses the tag on the next slide only

  for _, block in ipairs(doc.blocks) do
    if has_class(block, "agenda") then
      if has_class(block, "end") then
        -- Stop inserting tags for the remainder of this section.
        auto_on = false
        pending_tag = nil
      elseif has_class(block, "pause") then
        -- Skip the tag on the next slide only, then resume.
        pause_once = true
        pending_tag = nil
      else
        out:insert(agenda_div(titles, tonumber(block.attributes["data-section"])))
      end

    elseif has_class(block, "section-tag") then
      -- Hold it and re-emit immediately before its "###" heading: that is
      -- the position the .section-tag CSS assumes (small caps label above
      -- the title), and it keeps the div inside the slide.
      pending_tag = tag_text(block)

    elseif block.level == 2 then
      -- A "## 📋 N. Title" opens a section. Any other "##" (the intro, the
      -- recap, the closing slides) ends the run, so its subsections stay
      -- untagged just as they are today.
      local n, title = match_section(block, titles)
      current_num = n
      current_title = title
      pending_tag = nil
      auto_on = true
      pause_once = false
      out:insert(block)

    elseif block.level == 3 then
      -- The tag is emitted immediately before its heading, which is the
      -- position the .section-tag CSS assumes (small caps label above the
      -- title).
      if pending_tag then
        -- An explicit tag always wins, even outside a numbered section
        -- (the "🔁 Review: Lecture 5" tags sit in the intro).
        local text = pending_tag
        pending_tag = nil
        out:insert(section_tag_div(text))
      elseif current_num and auto_on and not pause_once then
        out:insert(section_tag_div(("%d. %s"):format(current_num, current_title)))
      end
      pause_once = false
      out:insert(block)

    else
      out:insert(block)
    end
  end

  -- A tag that never found a heading to attach to would otherwise vanish.
  if pending_tag then
    out:insert(section_tag_div(pending_tag))
  end

  doc.blocks = out
  return doc
end