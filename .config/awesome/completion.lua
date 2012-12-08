local io = io
local pairs = pairs
local table = table
local awful = require("awful")
module("completion")

function custom(text, cur_pos, ncomp)
    local keywords = {}
    local f = io.open(awful.util.getdir("cache") .. "/history", "r")
    for line in f:lines() do
        table.insert(keywords, 1, line)
    end
    f:close()

    -- The keywords table may be empty
    if #keywords == 0 then
        return text, #text + 1
    end

    local matches = {}
    if text == nil or #text == 0 then
        matches = keywords
    else
        -- Filter out only keywords starting with text
        for _, x in pairs(keywords) do
            if x:sub(1, #text) == text then
                table.insert(matches, x)
            end
        end
    end

    if #matches == 0 or ncomp > #matches then
        return awful.completion.shell(text, cur_pos, ncomp - #matches)
    else
        return matches[ncomp], #matches[ncomp] + 1, matches
    end
end

