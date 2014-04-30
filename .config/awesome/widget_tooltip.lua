-- Originally tooltip.lua, @copyright 2009 Sébastien Gross
-- Modified, @copyright 2014 Trygve Aaberge
-- Licensed under GPLv2, see LICENSE

local timer = timer
local wibox = require("wibox")
local beautiful = require("beautiful")
local capi = {
    mouse = mouse,
    screen = screen
}

local widget_tooltip = { }
local data = { }

local border_width = 1
local margin_size = 5

-- Place the tooltip in the top right corner of the screen.
-- @param self A tooltip object.
local function set_geometry(self, force)
    local my_geo = self.wibox:geometry()
    local workarea = capi.screen[capi.mouse.screen].workarea
    -- calculate width / height / x / y
    local n_w, n_h = self.textbox:fit(-1, -1)
    n_w = n_w + self.textmargin.left + self.textmargin.right
    n_h = n_h + self.textmargin.top + self.textmargin.bottom
    if self.iconmargin then
        n_w = n_w + self.icon_size + self.iconmargin.left + self.iconmargin.right
        i_h = self.icon_size + self.iconmargin.top + self.iconmargin.bottom
        if i_h > n_h then
            n_h = i_h
        end
    end
    local n_x = workarea.x + workarea.width - n_w - 6
    local n_y = workarea.y + 4
    if force or my_geo.width ~= n_w or my_geo.height ~= n_h or my_geo.x ~= n_x or my_geo.y ~= n_y then
        self.wibox:geometry({ width = n_w, height = n_h, x = n_x, y = n_y })
    end
end

-- Show a tooltip.
-- @param self The tooltip to show.
local function show(self)
    -- do nothing if the tooltip is already shown
    if self.visible then return end
    if data[self].timer then
        if not data[self].timer.started then
            data[self].timer_function()
            data[self].timer:start()
        end
    end
    set_geometry(self, true)
    self.wibox.visible = true
    self.visible = true
end

-- Hide a tooltip.
-- @param self The tooltip to hide.
local function hide(self)
    -- do nothing if the tooltip is already hidden
    if not self.visible then return end
    if data[self].timer then
        if data[self].timer.started then
            data[self].timer:stop()
        end
    end
    self.visible = false
    self.wibox.visible = false
end

--- Change displayed text.
-- @param self The tooltip object.
-- @param text New tooltip text.
local function set_text(self, text)
    self.textbox:set_text(text)
    set_geometry(self)
end

--- Change displayed text.
-- @param self The tooltip object.
-- @param text New tooltip text, including pango markup.
local function set_markup(self, text)
    self.textbox:set_markup(text)
    set_geometry(self)
end

--- Change displayed icon.
-- @param self The tooltip object.
-- @param icon_path Path to new icon.
-- @param icon_size New icon size.
local function set_icon(self, icon_path, icon_size)
    if icon_path == self.icon_path and icon_size == self.icon_size then
        return
    end

    if not icon_size then
        icon_size = self.icon_size or 64
    end

    if not self.iconbox then
        self.iconbox = wibox.widget.imagebox(nil, true)
        self.iconconstraint = wibox.layout.constraint(self.iconbox, "exact", icon_size, icon_size)
        self.iconmargin = wibox.layout.margin(self.iconconstraint, margin_size, margin_size, margin_size, margin_size)
        local layout = wibox.layout.fixed.horizontal()
        layout:add(self.iconmargin)
        layout:add(self.textmargin)
        self.wibox:set_widget(layout)
    elseif icon_size ~= self.icon_size then
        self.iconconstraint:set_width(icon_size)
        self.iconconstraint:set_height(icon_size)
    end

    if icon_path ~= self.icon_path then
        if self.iconbox:set_image(icon_path) then
            self.icon_path = icon_path
        else
            self.icon_path = nil
            self.iconbox = nil
            self.iconmargin = nil
            self.wibox:set_widget(self.textmargin)
        end
    end

    self.icon_size = icon_size
    set_geometry(self)
end

--- Change the tooltip's update interval.
-- @param self A tooltip object.
-- @param timeout The timeout value.
local function set_timeout(self, timeout)
    if data[self].timer then
        data[self].timer.timeout = timeout
    end
end

--- Add tooltip to an object.
-- @param self The tooltip.
-- @param object An object.
local function add_to_object(self, object)
    object:connect_signal("mouse::enter", data[self].show)
    object:connect_signal("mouse::leave", data[self].hide)
end

--- Remove tooltip from an object.
-- @param self The tooltip.
-- @param object An object.
local function remove_from_object(self, object)
    object:disconnect_signal("mouse::enter", data[self].show)
    object:disconnect_signal("mouse::leave", data[self].hide)
end


--- Create a new tooltip and link it to a widget.
-- @param args Arguments for tooltip creation may containt:<br/>
-- <code>timeout</code>: The timeout value for update_func.<br/>
-- <code>timer_function</code>: A function to dynamically change the tooltip
--     text.<br/>
-- <code>objects</code>: A list of objects linked to the tooltip.<br/>
-- @return The created tooltip.
-- @see add_to_object
-- @see set_timeout
-- @see set_text
-- @see set_markup
function widget_tooltip.new(args)
    local self = {
        visible = false,
        set_text = set_text,
        set_markup = set_markup,
        set_icon = set_icon,
        set_timeout = set_timeout,
        add_to_object = add_to_object,
        remove_from_object = remove_from_object
    }

    -- private data
    data[self] = {
        show = function() show(self) end,
        hide = function() hide(self) end
    }

    -- setup the timer action only if needed
    if args.timer_function then
        data[self].timer = timer { timeout = args.timeout and args.timeout or 1 }
        data[self].timer_function = function()
                self:set_markup(args.timer_function())
            end
        data[self].timer:connect_signal("timeout", data[self].timer_function)
    end

    self.wibox = wibox({
        visible = false,
        ontop = true,
        border_width = border_width,
        border_color = beautiful.bg_focus
    })
    self.textbox = wibox.widget.textbox()
    self.textmargin = wibox.layout.margin(self.textbox, margin_size, margin_size, margin_size, margin_size)
    self.wibox:set_widget(self.textmargin)

    -- Add tooltip to objects
    if args.objects then
        for _, object in ipairs(args.objects) do
            self:add_to_object(object)
        end
    end

    return self
end

return widget_tooltip
