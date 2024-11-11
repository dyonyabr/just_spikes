function love.conf(t)
    t.window.title = "Just Spikes"
    t.window.width = 360
    t.window.height = 700
    t.window.vsync = true
    t.window.msaa = 4
    t.window.borderless = true


    t.modules.joystick = false
    t.externalstorage = true

    -- t.console = true
end
