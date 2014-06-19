---------------------------
-- Default awesome theme --
---------------------------

local theme_dir = os.getenv("HOME") .. "/.config/awesome/themes/default/"

theme = {}

theme.font          = "sans 8"

theme.bg_normal     = "#222222"
theme.bg_focus      = "#282c33"
theme.bg_urgent     = "#880000"
theme.bg_minimize   = "#111111"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#aaaaaa"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#aaaaaa"

-- Display the taglist squares
theme.taglist_squares_sel   = theme_dir .. "squarefw.png"
theme.taglist_squares_unsel = theme_dir .. "squarew.png"

theme.wallpaper = theme_dir .. "background.jpg"

-- You can use your own layout icons like this:
theme.layout_tile = "/usr/share/awesome/themes/default/layouts/tilew.png"
theme.layout_tilebottom = "/usr/share/awesome/themes/default/layouts/tilebottomw.png"
theme.layout_fairv = "/usr/share/awesome/themes/default/layouts/fairvw.png"
theme.layout_max = "/usr/share/awesome/themes/default/layouts/maxw.png"
theme.layout_floating  = "/usr/share/awesome/themes/default/layouts/floatingw.png"

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
