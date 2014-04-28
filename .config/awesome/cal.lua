-- original code made by Bzed and published on http://awesome.naquadah.org/wiki/Calendar_widget
-- modified by Marc Dequènes (Duck) <Duck@DuckCorp.org> (2009-12-29), under the same licence,
-- and with the following changes:
--   + transformed to module
--   + the current day formating is customizable
-- modified by Jörg Thalheim (Mic92) <jthalheim@gmail.com> (2011), under the same licence,
-- and with the following changes:
--   + use tooltip instead of naughty.notify
--   + rename it to cal
--   + lua52 compliant module
-- modified by Trygve Aaberge (2014), under GPLv2
--
-- 1. require it in your rc.lua
--  require("cal")
-- 2. attach the calendar to a widget of your choice (ex mytextclock)
--  cal.register(mytextclock)
--    If you don't like the default current day formating you can change it as following
--  cal.register(mytextclock, "<b>%s</b>") -- now the current day is bold instead of underlined
--
-- # How to Use #
-- Just hover with your mouse over the widget, you register and the calendar popup.
-- On clicking or by using the mouse wheel the displayed month changes.
-- Pressing Shift + Mouse click change the year.

local string = { format = string.format }
local os = { date = os.date, time = os.time }
local awful = require("awful")

local cal = { }

local tooltip
local state = { }
local current_day_format = "<u>%s</u>"

function displayMonth(month, year, weekStart)
    local t, wkSt = os.time { year = year, month = month + 1, day = 0 }, weekStart or 1
    local d = os.date("*t", t)
    local mthDays, stDay = d.day, (d.wday - d.day - wkSt + 1) % 7

    local lines = "    "

    for x = 0, 6 do
        lines = lines .. os.date("%a ", os.time { year = 2006, month = 1, day = x + wkSt })
    end

    lines = lines .. "\n" .. os.date(" %V", os.time { year = year, month = month, day = 1 })

    local writeLine = 1
    while writeLine < (stDay + 1) do
        lines = lines .. "    "
        writeLine = writeLine + 1
    end

    for d = 1, mthDays do
        local x = d
        local t = os.time { year = year, month = month, day = d }
        if writeLine == 8 then
            writeLine = 1
            lines = lines .. "\n" .. os.date(" %V", t)
        end
        if os.date("%Y-%m-%d") == os.date("%Y-%m-%d", t) then
            x = string.format(current_day_format, d)
        end
        if d < 10 then
            x = " " .. x
        end
        lines = lines .. "  " .. x
        writeLine = writeLine + 1
    end
    if stDay + mthDays < 36 then
        lines = lines .. "\n"
    end
    if stDay + mthDays < 29 then
        lines = lines .. "\n"
    end
    local header = os.date("%B %Y\n", os.time { year = year, month = month, day = 1 })

    return header .. "\n" .. lines
end

function switchMonth(delta)
    state[1] = state[1] + (delta or 1)
    tooltip:update()
end

function cal.register(mywidget, custom_current_day_format)
    if custom_current_day_format then current_day_format = custom_current_day_format end

    if not tooltip then
        tooltip = awful.tooltip({ })
        function tooltip:update()
            tooltip:set_markup(string.format('<span font_desc="monospace">%s</span>', displayMonth(state[1], state[2], 2)))
        end
        function tooltip:set_now()
            local month, year = os.date('%m'), os.date('%Y')
            state = { month, year }
            tooltip:update()
        end
        tooltip:set_now()
    end
    tooltip:add_to_object(mywidget)

    mywidget:connect_signal("mouse::enter", tooltip.set_now)

    mywidget:buttons(awful.util.table.join(
        awful.button({ }, 1, function()
            switchMonth(-1)
        end),
        awful.button({ }, 3, function()
            switchMonth(1)
        end),
        awful.button({ }, 4, function()
            switchMonth(-1)
        end),
        awful.button({ }, 5, function()
            switchMonth(1)
        end),
        awful.button({ 'Shift' }, 1, function()
            switchMonth(-12)
        end),
        awful.button({ 'Shift' }, 3, function()
            switchMonth(12)
        end),
        awful.button({ 'Shift' }, 4, function()
            switchMonth(-12)
        end),
        awful.button({ 'Shift' }, 5, function()
            switchMonth(12)
        end)
    ))
end

return cal
