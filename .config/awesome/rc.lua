-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
naughty.config.defaults.icon_size = 32

-- Custom completion
require("completion")

-- Widgets
vicious = require("vicious")
local widget_tooltip = require("widget_tooltip")
local cal = require("cal")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.fair,
    awful.layout.suit.max,
    awful.layout.suit.floating
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

-- {{{ Wibox
-- Widgets
datewidget = wibox.widget.textbox()
vicious.register(datewidget, vicious.widgets.date, "%a %b %d, %T ", 1)
cal.register(datewidget)

local battery_name = "BAT0"
local battery_present = io.open("/sys/class/power_supply/" .. battery_name .. "/present")
if battery_present ~= nil then
    battery_present:close()
    batterywidget = wibox.widget.textbox()
    vicious.register(batterywidget, vicious.widgets.bat, "$2$1 ", 10, battery_name)
    batterywidget:buttons(awful.util.table.join(
        awful.button({ }, 2, function () awful.util.spawn("suspend_monitor") end)
    ))
    batterytooltip = widget_tooltip.new({
        objects = { batterywidget },
        timer_function = function ()
            local f = io.popen("acpi")
            local acpi = f:read("*all")
            f:close()
            acpi = acpi:gsub("[\n\r]+", "")
            return "<b>Battery status</b>\n" .. acpi
        end
    })
end

netwidget = wibox.widget.textbox()

volumewidget = wibox.widget.textbox()
vicious.register(volumewidget, vicious.widgets.volume, "$1$2 ", 60, "Master")
vicious.unregister(volumewidget, true)
volumewidget:buttons(awful.util.table.join(
    awful.button({ }, 2, function () awful.util.spawn("vol mute", false) end),
    awful.button({ }, 3, function () awful.util.spawn(terminal .. " -e alsamixer") end),
    awful.button({ }, 4, function () awful.util.spawn("vol +", false) end),
    awful.button({ }, 5, function () awful.util.spawn("vol -", false) end)
))

mpdwidget = wibox.widget.textbox()
mpd_reg = vicious.register(mpdwidget, vicious.widgets.mpd,
    function(widget, args)
        local state
        if args["{state}"] == "Stop" then
            state = "MPD stopped"
        elseif args["{state}"] == "N/A" then
            state = "MPD not running"
        else
            state = args["{Artist}"] .. " - " .. args["{Title}"]
            if args["{state}"] == "Play" then
                state = "▶ " .. state
            end
        end
        local name = (mpd_reg and mpd_reg.warg.name or "")
        if name ~= "" then
            name = name .. ": "
        end
        return name .. state .. " "
    end,
    5, { }
)
vicious.unregister(mpdwidget, true)

local mpd_hosts_file = io.open(os.getenv("HOME") .. "/.config/awesome/mpd_hosts.yml")
local cur_attr
for line in mpd_hosts_file:lines() do
    local tmp = line:match("^(%a+):$")
    if tmp then
        cur_attr = tmp
        mpd_reg.warg[cur_attr] = { }
    else
        tmp = line:match("^%s*%- (.*)")
        if tmp then
            table.insert(mpd_reg.warg[cur_attr], tmp)
        end
    end
end
mpd_hosts_file:close()

function mpd_change_host(i)
    mpd_reg.warg.cur_host = ((mpd_reg.warg.cur_host or 1) + i - 1) % #mpd_reg.warg.hosts + 1
    mpd_reg.warg.host, mpd_reg.warg.port = mpd_reg.warg.hosts[mpd_reg.warg.cur_host]:match("([%a%d.-]+):?(%d*)")
    if mpd_reg.warg.port == "" then
        mpd_reg.warg.port = "6600"
    end
    mpd_reg.warg.name = mpd_reg.warg.names[mpd_reg.warg.cur_host]
    awful.util.spawn("update-mpd-widget.pl " .. mpd_reg.warg.host .. " " .. mpd_reg.warg.port, false)
end
mpd_change_host(0)

mpdwidget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("music -h " .. mpd_reg.warg.host .. " -p " .. mpd_reg.warg.port .. " toggle", false) end),
    awful.button({ }, 2, function () awful.util.spawn("music -h " .. mpd_reg.warg.host .. " -p " .. mpd_reg.warg.port .. " next", false) end),
    awful.button({ }, 3, function () awful.util.spawn("music -h " .. mpd_reg.warg.host .. " -p " .. mpd_reg.warg.port, false) end),
    awful.button({ }, 4, function () mpd_change_host(1) end),
    awful.button({ }, 5, function () mpd_change_host(-1) end),
    awful.button({ }, 8, function () mpd_change_host(-1) end),
    awful.button({ }, 9, function () mpd_change_host(1) end)
))

mpdtooltip = widget_tooltip.new({
    objects = { mpdwidget },
    timer_function = function ()
        local f = io.popen("music -h " .. mpd_reg.warg.host .. " -p " .. mpd_reg.warg.port .. " status")
        local status = f:read("*all")
        f:close()
        status = status:gsub("%s*$", "")
        status = status:gsub("[<>&]", { ["<"] = "&lt;", [">"] = "&gt;", ["&"] = "&amp;" })

        f = io.popen("spotify-album-art -h " .. mpd_reg.warg.host .. " -p " .. mpd_reg.warg.port)
        local album_art = f:read("*line")
        f:close()

        return "<b>MPD status</b>\n" .. status, album_art
    end
})

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 2, function(c)
                                              c:kill()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, 1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mpdwidget)
    right_layout:add(volumewidget)
    right_layout:add(netwidget)
    if batterywidget ~= nil then right_layout:add(batterywidget) end
    right_layout:add(datewidget)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 4, awful.tag.viewprev),
    awful.button({ }, 5, awful.tag.viewnext)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ "Mod1",           }, "Tab",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ "Mod1", "Shift"   }, "Tab",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Mod1"    }, "Tab", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey, "Mod1", "Shift" }, "Tab", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey }, "r",
        function ()
            awful.prompt.run({ prompt = mypromptbox[mouse.screen].prompt },
            mypromptbox[mouse.screen].widget,
            function (...)
                local result = awful.util.spawn(...)
            end,
            completion.custom,
            awful.util.getdir("cache") .. "/history",
            500)
        end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),

    awful.key({ modkey }, ".", function() awful.util.spawn(os.getenv("HOME") .. "/bin/lock", false) end),
    awful.key({ modkey }, "a", function() awful.util.spawn(terminal .. " -e mosh trygve@kramer.samfundet.no") end),
    awful.key({ modkey }, "s", function() awful.util.spawn(terminal .. " -e ssh -X trygve@kramer.samfundet.no") end),
    awful.key({ modkey }, "<", function () awful.util.spawn(terminal) end),
    awful.key({ modkey }, "-", function () awful.util.spawn("music -h " .. mpd_reg.warg.host .. " -p " .. mpd_reg.warg.port .. " toggle", false) end),
    awful.key({ modkey, "Shift" }, "-", function () awful.util.spawn("mpdfade", false) end),
    awful.key({ }, "XF86AudioPlay",    function () awful.util.spawn("music -h " .. mpd_reg.warg.host .. " -p " .. mpd_reg.warg.port .. " toggle", false) end),
    awful.key({ }, "XF86AudioMute",    function () awful.util.spawn("vol mute", false) end),
    awful.key({ }, "XF86AudioRaiseVolume",    function () awful.util.spawn("vol +", false) end),
    awful.key({ }, "XF86AudioLowerVolume",    function () awful.util.spawn("vol -", false) end),
    awful.key({ }, "XF86MonBrightnessUp",    function () awful.util.spawn("xbacklight -inc 5", false) end),
    awful.key({ }, "XF86MonBrightnessDown",    function () awful.util.spawn("xbacklight -dec 5", false) end),
    awful.key({ }, "XF86TouchpadToggle",    function () awful.util.spawn("sh -c 'synclient TouchpadOff=$(synclient -l | grep -c TouchpadOff.*=.*0)'", false) end),
    awful.key({ modkey }, "q", function () awful.util.spawn("browser -c") end),
    awful.key({ modkey, "Control" }, "q", function () awful.util.spawn("browser -cb") end),
    awful.key({ modkey }, "F8", function () awful.util.spawn("update-monitor") end),

    awful.key({ }, "Print", function () awful.util.spawn("scrot -e 'mv $f ~/images/ 2>/dev/null'") end),
    awful.key({ modkey }, "Print", nil, function () awful.util.spawn("scrot -s -e 'mv $f ~/images/ 2>/dev/null'") end),

    awful.key({ modkey }, "c", function ()
        awful.prompt.run({ prompt = "Calculate: " }, mypromptbox[mouse.screen].widget,
            function (expr)
                local result = awful.util.eval("return (" .. expr .. ")")
                naughty.notify({ text = expr .. " = " .. result, timeout = 10 })
            end,
            nil, awful.util.getdir("cache") .. "/history_calc"
        )
    end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { focus = awful.client.focus.filter,
                     size_hints_honor = false,
                     keys = clientkeys,
                     buttons = clientbuttons } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)
-- }}}
