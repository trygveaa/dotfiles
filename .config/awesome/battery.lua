---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2009 Julien Danjou
-- @release v3.4.5
---------------------------------------------------------------------------

local setmetatable = setmetatable
local os = os
local io = io
local capi = { widget = widget,
               timer = timer }

--- Text clock widget.
module("battery")

--- Create a textclock widget. It draws the time it is in a textbox.
-- @param args Standard arguments for textbox widget.
-- @param timeout How often update the time. Default is 60.
-- @return A textbox widget.
function new(args, timeout)
    local args = args or {}
    local timeout = timeout or 5
    args.type = "textbox"
    local w = capi.widget(args)
    local timer = capi.timer { timeout = timeout }
    update(w)
    timer:add_signal("timeout", function() update(w) end)
    timer:start()
    return w
end

function update(w)
    --local f = io.popen("acpi | sed 's/.* \([0-9]\+%\).*/\1/'")
    --local f = io.popen("acpi | awk '{print $4}'")
    local f = io.popen("battery")
    w.text = f:read("*a")
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
