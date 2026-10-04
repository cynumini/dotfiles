require("vis")

vis.events.subscribe(vis.events.START, function()
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
    win.options.expandtab = true
    win.options.tabwidth = 4
end)

local lspc = require("plugins.vis-lspc")

lspc.ls_map.dmd = {
    name = 'serve-d',
    cmd = 'serve-d',
}

vis:map(vis.modes.NORMAL, ' f', function()
    vis:command('lspc-format')
end)
