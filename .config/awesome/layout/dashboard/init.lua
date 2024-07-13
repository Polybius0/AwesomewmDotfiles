-- Minimal Dashbaord
--------------------
-- Copyleft © 2022 Saimoomedits


-- requirements
---------------
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local helpers = require("helpers")
local wibox = require("wibox")
local gears = require("gears")
local rubato = require("mods.rubato")


-- widgets
----------
local notifs = require("layout.dashboard.notifs.build")
local ram = require("layout.dashboard.resour.ram")
local cpu = require("layout.dashboard.resour.cpu")
local hdd = require("layout.dashboard.resour.hdd")

awful.screen.connect_for_each_screen(function(s)

    local screen_height = s.geometry.height


    -- Mainbox
    ---------------------
    dashbaord_d = wibox({
        type = "dock",
        screen = s,
        width = dpi(430),
        height = screen_height - (s.wibar_wid.height + beautiful.useless_gap * 4),
        shape = helpers.rrect(beautiful.rounded),
        bg = beautiful.bg_color,
        ontop = true,
        visible = false
    })

    -- animations
    --------------
    local slide_right = rubato.timed{
        pos = s.geometry.width,
        rate = 60,
        intro = 0.14,
        duration = 0.33,
        subscribed = function(pos) dashbaord_d.x = s.geometry.x + pos end
    }


    local slide_end = gears.timer({
        single_shot = true,
        timeout = 0.33 + 0.08,
        callback = function()
            dashbaord_d.visible = false
        end,
    })


    -- toggler script
    --~~~~~~~~~~~~~~~
    local screen_backup = 1

    dd_toggle = function(screen)

        -- set screen to default, if none were found
        if not screen then
            screen = s
        end

        -- control center y position
        dashbaord_d.y = screen.geometry.y + beautiful.useless_gap * 6

        -- toggle visibility
        if dashbaord_d.visible then

            -- check if screen is different or the same
            if screen_backup ~= screen.index then
                dashbaord_d.visible = true
            else
                slide_end:again()
                slide_right.target = s.geometry.width
            end

        elseif not dashbaord_d.visible then

            slide_right.target = s.geometry.width - (dashbaord_d.width + beautiful.useless_gap * 2)
            dashbaord_d.visible = true

        end

        -- set screen_backup to new screen
        screen_backup = screen.index
    end
    -- Eof toggler script
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


    dashbaord_d:setup {
        {
            {
                {
                    {
                        ram,
                        cpu,
                        hdd,
                        spacing = dpi(30),
                        layout = wibox.layout.fixed.horizontal,
                    },
                    layout = wibox.layout.align.vertical,
                    expand = "none"
                },
                margins = dpi(25),
                widget = wibox.container.margin
            },
            widget = wibox.container.background,
            bg = beautiful.bg_color,
            forced_height = dpi(150),
        },
        {
            {
                notifs,
                widget = wibox.container.background,
                bg = beautiful.bg_color,
                shape = helpers.rrect(beautiful.rounded)
            },
            margins = dpi(15),
            widget = wibox.container.margin
        },
        layout = wibox.layout.align.vertical
    }

end)

-- eof
------
