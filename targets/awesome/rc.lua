local gears = require('gears')
local awful = require('awful')
require('awful.autofocus')
local wibox = require('wibox')
local beautiful = require('beautiful')
local naughty = require('naughty') local menubar = require('menubar')
local hotkeys_popup = require('awful.hotkeys_popup').widget
local vicious = require('vicious')

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = 'Oops, there were errors during startup!',
    text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal('debug::error', function (err)
    -- Make sure we don't go into an endless error loop
    if in_error then return end
    in_error = true

    naughty.notify({
      preset = naughty.config.presets.critical,
      title = 'Oops, an error happened!',
      text = tostring(err) })
    in_error = false
  end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_configuration_dir() .. 'themes/df-theme/theme.lua')


terminal = 'x-terminal-emulator'
local browser = 'x-www-browser'
local screenshot = 'gnome-screenshot -a'
editor = os.getenv('EDITOR') or 'editor'
editor_cmd = editor

-- Default modkey.
modkey = 'Mod4'

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
  -- awful.layout.suit.floating,
  awful.layout.suit.fair,
  awful.layout.suit.max,
}
-- }}}

-- {{{ Wibar
-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
  -- Left mouse button
  awful.button({ }, 1, function(t) t:view_only() end),
  -- Right mouse button
  awful.button({ }, 3, awful.tag.viewtoggle),
  -- Down mouse wheel
  awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
  -- Up mouse wheel
  awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
  awful.button({ }, 1, function (c)
    if c == client.focus then
      c.minimized = true
    else
      -- Without this, the following
      -- :isvisible() makes no sense
      c.minimized = false
      if not c:isvisible() and c.first_tag then
        c.firsttag:view_only()
      end
        -- This will also un-minimize
        -- the client, if needed
        client.focus = c
        c:raise()
    end
  end),
  awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
  awful.button({ }, 5, function () awful.client.focus.byidx(-1) end)
)

local function set_wallpaper(s)
  -- Wallpaper
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == 'function' then
        wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal('property::geometry', set_wallpaper)

local vw = vicious.widgets

-- Clock
local clocktext = wibox.widget.textbox()
vicious.register(clocktext, vw.date, ' <tt>%Y.%m.%d <span color="#54ffc8"><b>%H:%M:%S</b></span> </tt>', 1)

-- Keyboard
function get_kb_layout ()
  -- popen is blocking!
  local f = io.popen('xkblayout-state print %s')
  local lang = f:read('*all')
  f:close()
  return { string.upper(lang) }
end
local kbtext = wibox.widget.textbox()
vicious.register(kbtext, get_kb_layout, '<tt>KB $1</tt>', 43)

-- Battery
local battext = wibox.widget.textbox()
if os.getenv('DF_THIS_MACHINE') == 'home2' then
  vicious.register(battext, vw.bat, '<tt>BAT $1 $2% ($3)</tt>', 11, 'BAT1')
end

-- Volume
local volumetext = wibox.widget.textbox()
if os.getenv('DF_THIS_MACHINE') == 'home2' then
  vicious.register(
    volumetext,
    vw.volume,
    function (widget, args)
      return string.format('<tt>VOL %3d</tt>', args[1])
    end,
    47,
    'Master')
end

-- Brightness
function get_brigthness ()
  -- popen is blocking!
  local f = io.popen('xbacklight -get')
  local brightness = f:read('*all')
  f:close()
  local brightness_num = tonumber(brightness)
  if brightness_num == nil then
    return { -1 }
  end
  return { math.floor(brightness_num) }
end
local brighttext = wibox.widget.textbox()
if os.getenv('DF_THIS_MACHINE') == 'home2' then
  vicious.register(
    brighttext,
    get_brigthness,
    function (widget, args)
      return string.format('<tt>BRI %3d</tt>', args[1])
    end,
    53)
end

-- Disk
local disktext = wibox.widget.textbox()
vicious.register(
  disktext,
  vw.fs,
  function (widget, args)
    local used_p, used_gb, total_gb, x = args['{/ used_p}'], args['{/ used_gb}'], args['{/ size_gb}']
    local color = beautiful.get().fg_normal
    if used_p >= 75 then
      color = 'yellow'
    elseif used_p >= 95 then
      color = 'red'
    end
    return string.format('<tt>DISK <span color=\'%s\'>%3.1fG</span> / %3.1fG</tt>', color, used_gb, total_gb)
  end,
  5)

-- Memory
vicious.cache(vw.mem)
local memgraph = wibox.widget.graph()
vicious.register(memgraph, vw.mem, '$1', 3)
memgraph:set_width(32)
memgraph.color = beautiful.get().fg_normal
memgraph.background_color = beautiful.get().bg_normal
memgraph = wibox.container.mirror(memgraph, { horizontal = true })
local memtext = wibox.widget.textbox()
vicious.register(
  memtext,
  vw.mem,
  function (widget, args)
    local percents, used, total = args[1], args[2], args[3]
    local color = beautiful.get().fg_normal
    if percents >= 75 then
      color = 'yellow'
    elseif percents >= 95 then
      color = 'red'
    end
    return string.format(
      '<tt>MEM <span color=\'%s\'>%2.2fG</span> / %2.2fG </tt>',
      color,
      math.floor(used * 100 / 1024) / 100,
      math.floor(total * 100 / 1024) / 100)
  end,
  1)

-- CPU
vicious.cache(vw.cpu)
local cpugraph = wibox.widget.graph()
vicious.register(cpugraph, vw.cpu, '$1', 3)
cpugraph:set_width(32)
cpugraph.color = beautiful.get().fg_normal
cpugraph.background_color = beautiful.get().bg_normal
cpugraph = wibox.container.mirror(cpugraph, { horizontal = true })
local cputext = wibox.widget.textbox()
vicious.register(
  cputext,
  vw.cpu,
  function (widget, args)
    local percents = args[1]
    local color = beautiful.get().fg_normal
    if percents >= 75 then
      color = 'yellow'
    elseif percents >= 95 then
      color = 'red'
    end
    return string.format('<tt>CPU <span color="%s">%3d%%</span> </tt>', color, percents)
  end,
  1)

-- Separator
local sep=wibox.widget.textbox('<tt><span color="'..beautiful.get().bg_focus..'"> | </span></tt>')

-- net
local net_widgets = require("net_widgets")
local nettext = wibox.widget.textbox('<tt>NET </tt>')
local net_wireless = net_widgets.wireless({interface="wlp7s0", popup_position = "bottom_right" })

awful.screen.connect_for_each_screen(
  function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    local tagnames = { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' }
    local l = awful.layout.suit  -- Just to save some typing: use an alias.
    local layouts = { l.max, l.max, l.max, l.max, l.max, l.max, l.max, l.max, l.max, l.max }
    awful.tag(tagnames, s, layouts)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
      awful.button({ }, 1, function () awful.layout.inc( 1) end),
      awful.button({ }, 3, function () awful.layout.inc(-1) end),
      awful.button({ }, 4, function () awful.layout.inc( 1) end),
      awful.button({ }, 5, function () awful.layout.inc(-1) end))
    )
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- function reverse(t)
    --   local n = #t
    --   local i = 1
    --   while i < n do
    --     t[i],t[n] = t[n],t[i]
    --     i = i + 1
    --     n = n - 1
    --   end
    -- end

    -- Create a tasklist widget
    function update(w, buttons, label, data, clients)
      -- TODO: How to do this properly
      -- reverse(clients)
      return awful.widget.common.list_update(w, buttons, label, data, clients)
    end
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons, {}, update)

    -- Create the wibox
    s.mywiboxtop = awful.wibar({ position = 'top', screen = s })
    s.mywiboxbot = awful.wibar({ position = 'bottom', screen = s })

    -- Add widgets to the top wibox
    s.mywiboxtop:setup {
      layout = wibox.layout.align.horizontal,
      { -- Left widgets
        layout = wibox.layout.fixed.horizontal,
        s.mytaglist,
      },
      s.mytasklist, -- Middle widget
      { -- Right widgets
        layout = wibox.layout.fixed.horizontal,
        wibox.widget.systray(),
        s.mylayoutbox
      },
    }

    local infowidgets = { layout = wibox.layout.fixed.horizontal }
    table.insert(infowidgets, nettext)
    table.insert(infowidgets, net_wireless)
    table.insert(infowidgets, sep)
    table.insert(infowidgets, cputext)
    table.insert(infowidgets, cpugraph)
    table.insert(infowidgets, sep)
    table.insert(infowidgets, memtext)
    table.insert(infowidgets, memgraph)
    table.insert(infowidgets, sep)
    table.insert(infowidgets, disktext)
    table.insert(infowidgets, sep)
    if os.getenv('DF_THIS_MACHINE') == 'home2' then
      table.insert(infowidgets, brighttext)
      table.insert(infowidgets, sep)
      table.insert(infowidgets, volumetext)
      table.insert(infowidgets, sep)
      table.insert(infowidgets, battext)
      table.insert(infowidgets, sep)
    end
    table.insert(infowidgets, kbtext)
    table.insert(infowidgets, sep)
    table.insert(infowidgets, clocktext)
    s.mywiboxbot:setup {
      layout = wibox.layout.align.horizontal,
      {
        layout = wibox.layout.fixed.horizontal,
        s.mypromptbox,
      },
      { layout = wibox.layout.fixed.horizontal },
      infowidgets,
    }
  end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
  awful.button({ }, 3, function () mymainmenu:toggle() end),
  awful.button({ }, 4, awful.tag.viewnext),
  awful.button({ }, 5, awful.tag.viewprev)))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
  -- Brightness
  awful.key({}, 'XF86MonBrightnessDown',
    function ()
      awful.spawn.easy_async('xbacklight -dec 15', function () vicious.force({ brighttext }) end)
    end),
  awful.key({}, 'XF86MonBrightnessUp',
    function ()
      awful.spawn.easy_async('xbacklight -inc 15', function () vicious.force({ brighttext }) end)
    end),

  -- Volume
  awful.key({}, 'XF86AudioRaiseVolume',
    function ()
      awful.spawn('pactl -- set-sink-volume alsa_output.pci-0000_00_1f.3.analog-stereo +5%')
      vicious.force({ volumetext })
    end),
  awful.key({}, 'XF86AudioLowerVolume',
    function ()
      awful.spawn('pactl -- set-sink-volume alsa_output.pci-0000_00_1f.3.analog-stereo -5%')
      vicious.force({ volumetext })
    end),


  -- Keyboard language layout
  awful.key({ modkey }, 'space',
    function ()
      vicious.force({ kbtext })
    end),

  awful.key({ modkey }, 's', hotkeys_popup.show_help, { description='show help', group='awesome' }),
  awful.key({ modkey }, 'j', function () awful.client.focus.byidx(1) end,
    { description = 'focus next by index', group = 'client' }),
  awful.key({ modkey }, 'k', function () awful.client.focus.byidx(-1) end,
    {description = 'focus previous by index', group = 'client'}),

  --- Layout manipulation
  -- Change tag layout
  awful.key({ modkey }, 'l', function () awful.layout.inc(1) end,
    { description = 'select next', group = 'layout' }),
  awful.key({ modkey, 'Shift' }, 'l', function () awful.layout.inc(-1) end,
    { description = 'select previous', group = 'layout' }),
  -- Move client right/left
  awful.key({ modkey, 'Shift' }, 'j', function () awful.client.swap.byidx(1) end,
    { description = 'swap with next client by index', group = 'client' }),
  awful.key({ modkey, 'Shift' }, 'k', function () awful.client.swap.byidx(-1) end,
    { description = 'swap with previous client by index', group = 'client' }),
  -- Move to other screen
  awful.key({ modkey, 'Control' }, 'j', function () awful.screen.focus_relative(1) end,
    { description = 'focus the next screen', group = 'screen' }),
  awful.key({ modkey, 'Control' }, 'k', function () awful.screen.focus_relative(-1) end,
    { description = 'focus the previous screen', group = 'screen' }),

  -- Misc
  awful.key({ modkey, 'Control' }, 'l', function () awful.spawn('df-lockscreen') end),
  awful.key({ modkey }, 'u', awful.client.urgent.jumpto,
    { description = 'jump to urgent client', group = 'client' }),
  awful.key({ modkey }, 'Tab',
    function ()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end,
    { description = 'go back', group = 'client' }),

  -- Standard program
  awful.key({ modkey }, 'Return', function () awful.spawn(terminal) end,
    { description = 'open a terminal', group = 'launcher' }),
  awful.key({ modkey, 'Control' }, 'r', awesome.restart,
    { description = 'reload awesome', group = 'awesome' }),
  awful.key({ modkey, 'Control' }, 'b', function () awful.spawn(browser) end),
  awful.key({ modkey, 'Control' }, 't', function () awful.spawn(screenshot) end),

  awful.key({ modkey, 'Control' }, 'n',
    function ()
        local c = awful.client.restore()
        -- Focus restored client
        if c then
            client.focus = c
            c:raise()
        end
    end,
    { description = 'restore minimized', group = 'client' }),

  -- Prompt
  awful.key({ modkey }, 'r', function () awful.screen.focused().mypromptbox:run() end,
    { description = 'run prompt', group = 'launcher' }),

  awful.key({ modkey }, 'x',
    function ()
        awful.prompt.run {
          prompt = 'Run Lua code: ',
          textbox = awful.screen.focused().mypromptbox.widget,
          exe_callback = awful.util.eval,
          history_path = awful.util.get_cache_dir() .. '/history_eval'
        }
    end,
    { description = 'lua execute prompt', group = 'awesome' }),

  -- Menubar
  awful.key({ modkey }, 'p', function() menubar.show() end,
    { description = 'show the menubar', group = 'launcher' })
)

clientkeys = gears.table.join(
     awful.key({ modkey }, 'f',
       function (c)
         c.fullscreen = not c.fullscreen
         c:raise()
       end,
       { description = 'toggle fullscreen', group = 'client' }),
     awful.key({ modkey, 'Shift' }, 'q', function (c) c:kill() end,
       { description = 'close', group = 'client' }),
     awful.key({ modkey, 'Control' }, 'f', awful.client.floating.toggle,
       { description = 'toggle floating', group = 'client' }),
     awful.key({ modkey }, 't', function (c) c.ontop = not c.ontop end,
       { description = 'toggle keep on top', group = 'client' }),
     awful.key({ modkey }, 'n',
       function (c)
         -- The client currently has the input focus, so it cannot be
         -- minimized, since minimized clients can't have the focus.
         c.minimized = true
       end ,
       { description = 'minimize', group = 'client' }),
    awful.key({ modkey }, 'm',
      function (c)
        c.maximized = not c.maximized
        c:raise()
      end ,
      { description = '(un)maximize', group = 'client' })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 10 do
 globalkeys = gears.table.join(
   globalkeys,
   -- View tag only.
   awful.key({ modkey }, '#' .. i + 9,
     function ()
       local screen = awful.screen.focused()
       local tag = screen.tags[i]
       if tag then
         tag:view_only()
       end
     end,
     { description = 'view tag #'..i, group = 'tag' }),
   -- Toggle tag display.
   awful.key({ modkey, 'Control' }, '#' .. i + 9,
     function ()
       local screen = awful.screen.focused()
       local tag = screen.tags[i]
       if tag then
         awful.tag.viewtoggle(tag)
       end
     end,
     { description = 'toggle tag #' .. i, group = 'tag' }),
   -- Move client to tag.
   awful.key({ modkey, 'Shift' }, '#' .. i + 9,
     function ()
       if client.focus then
         local tag = client.focus.screen.tags[i]
         if tag then
           client.focus:move_to_tag(tag)
         end
      end
     end,
     { description = 'move focused client to tag #'..i, group = 'tag' }),
   -- Toggle tag on focused client.
   awful.key({ modkey, 'Control', 'Shift' }, '#' .. i + 9,
     function ()
       if client.focus then
         local tag = client.focus.screen.tags[i]
         if tag then
           client.focus:toggle_tag(tag)
         end
       end
     end,
     { description = 'toggle focused client on tag #' .. i, group = 'tag' })
 )
end

clientbuttons = gears.table.join(
  awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
  awful.button({ modkey }, 1, awful.mouse.client.move),
  awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the 'manage' signal).
awful.rules.rules = {
  -- All clients will match this rule.
  { rule = { },
    properties = {
      -- See https://stackoverflow.com/a/29788645/7788768
      size_hints_honor = false,
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      keys = clientkeys,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap+awful.placement.no_offscreen
    }
  },

  -- Floating clients.
  { rule_any = {
      instance = {
        'DTA',  -- Firefox addon DownThemAll.
        'copyq',  -- Includes session name in class.
      },
      class = {
        'Arandr',
        'Gpick',
        'Kruler',
        'MessageWin',  -- kalarm.
        'Sxiv',
        'Wpa_gui',
        'pinentry',
        'veromix',
        'xtightvncviewer'
      },

      name = {
        'Event Tester',  -- xev.
      },
      role = {
        'AlarmWindow',  -- Thunderbird's calendar.
        'pop-up',       -- e.g. Google Chrome's (detached) Developer Tools.
      }
    },
    properties = { floating = true }
  },

  -- Add titlebars to normal clients and dialogs
  { rule_any = {
      type = { 'normal', 'dialog' }
    },
    properties = { titlebars_enabled = true }
  },

  -- Set Firefox to always map on the tag named '2' on screen 1.
  -- { rule = { class = 'Firefox' },
  --   properties = { screen = 1, tag = '2' } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal('manage', function (c)
  -- Set the windows at the slave,
  -- i.e. put it at the end of others instead of setting it master.
  -- if not awesome.startup then awful.client.setslave(c) end

  if awesome.startup and
    not c.size_hints.user_position
    and not c.size_hints.program_position then
      -- Prevent clients from being unreachable after screen count changes.
      awful.placement.no_offscreen(c)
  end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal('request::titlebars', function(c)
  -- buttons for the titlebar
  local buttons = gears.table.join(
    awful.button({ }, 1, function()
      client.focus = c
      c:raise()
      awful.mouse.client.move(c)
    end),
    awful.button({ }, 3, function()
      client.focus = c
      c:raise()
      awful.mouse.client.resize(c)
    end)
  )

  awful.titlebar(c) : setup {
    { -- Left
      -- awful.titlebar.widget.iconwidget(c),
      buttons = buttons,
      layout  = wibox.layout.fixed.horizontal
    },
    { -- Middle
      { -- Title
        align  = 'center',
        widget = awful.titlebar.widget.titlewidget(c)
      },
      buttons = buttons,
      layout  = wibox.layout.flex.horizontal
    },
    { -- Right
      -- awful.titlebar.widget.floatingbutton(c),
      -- awful.titlebar.widget.maximizedbutton(c),
      -- awful.titlebar.widget.stickybutton(c),
      -- awful.titlebar.widget.ontopbutton(c),
      -- awful.titlebar.widget.closebutton(c),
      layout = wibox.layout.fixed.horizontal()
    },
    layout = wibox.layout.align.horizontal
  }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal('mouse::enter', function(c)
  if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
    and awful.client.focus.filter(c) then
    client.focus = c
  end
end)

client.connect_signal('focus', function(c) c.border_color = beautiful.border_focus end)
client.connect_signal('unfocus', function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Startup sctipt
awful.spawn(gears.filesystem.get_configuration_dir() .. './df-awesome-startup')
