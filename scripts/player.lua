Player = {}

function Player:new(scene)
    local obj = {}

    obj.started = false

    obj.death_timer = Timer()

    obj.speed = 0
    obj.pos = { x = love.graphics.getWidth() / 2, y = scene.map_height / 2 }
    obj.radius = 15
    obj.impact_k = 1
    obj.side = 1
    obj.can_jump = false
    obj.gravity_vel = 0
    obj.gravity = 0
    obj.jump_str = 5

    obj.delete_exp = false
    obj.exp = {}

    obj.taps = 0
    obj.impact = 1

    obj.eyes = {
        offset = 5,
        x = 10,
        raduis = 7,
        gap = 18,
    }

    obj.can_wall = true
    obj.wall_timer = Timer()


    obj.to_delete_trail = false
    obj.trail = {}
    obj.trail_timers = {}

    function obj:load()
        obj:create_trail()
    end

    function obj:update(dt)
        obj.death_timer:update(dt)

        obj.impact = lerp(obj.impact, 1, dt * 10)
        obj.impact_k = lerp(obj.impact_k, obj.impact, dt * 20)

        obj.pos.x = obj.pos.x + obj.side * dt * obj.speed
        obj.gravity_vel = obj.gravity_vel + obj.gravity * dt
        obj.pos.y = obj.pos.y + obj.gravity_vel

        for i = 1, #obj.trail do
            obj.trail[i].timer:update(dt)
            obj.trail[i].radius = clamp(0, obj.trail[i].radius - dt * 30, 99)
        end

        for i = 1, #obj.exp do
            obj.exp[i].timer:update(dt)
            obj.exp[i].width = lerp(obj.exp[i].width, 0, dt * 5) - 1
            obj.exp[i].radius = lerp(obj.exp[i].radius, 40, dt * 5)
            -- obj.exp[i].pos = obj.pos
        end

        for i = 1, #obj.trail_timers do
            obj.trail_timers[i]:update(dt)
        end

        obj.wall_timer:update(dt)
        if obj.can_wall then
            if obj.pos.x <= obj.radius then
                obj:goal(1)
            elseif obj.pos.x >= love.graphics.getWidth() - obj.radius then
                obj:goal(-1)
            end
        end

        obj.eyes.x = lerp(obj.eyes.x, obj.eyes.offset * obj.side, dt * 15)

        if obj.to_delete_trail then
            table.remove(obj.trail, 1)
            obj.to_delete_trail = false
        end

        if obj.delete_exp then
            table.remove(obj.exp, 1)
            obj.delete_exp = false
        end
    end

    function obj:draw()
        love.graphics.setColor(1, 1, 1, 1)

        for i = 1, #obj.exp do
            circle_line(obj.exp[i].pos.x, obj.exp[i].pos.y, obj.exp[i].radius, clamp(obj.exp[i].width, 0, obj.radius * 2))
        end

        for i = 1, #obj.trail do
            love.graphics.circle("fill", obj.trail[i].pos.x, obj.trail[i].pos.y, obj.trail[i].radius)
        end

        love.graphics.circle("fill", obj.pos.x, obj.pos.y, obj.radius * obj.impact_k)

        -- love.graphics.setColor(0, 0, 0, 1)
        -- love.graphics.circle("fill", obj.eyes.x * obj.impact_k + obj.eyes.gap * obj.impact_k / 2 + obj.pos.x   , obj.pos.y,
        --     obj.eyes.raduis * obj.impact_k)
        -- love.graphics.circle("fill", obj.eyes.x * obj.impact_k - obj.eyes.gap * obj.impact_k / 2 + obj.pos.x, obj.pos.y,
        --     obj.eyes.raduis * obj.impact_k)
    end

    function obj:keypressed(k)
        if k == "space" then
            obj:jump()
            if not obj.started then
                obj.started = true
                obj:start()
            end
        elseif k == "x" then
            love.event.quit()
        elseif k == "r" then
            love.event.quit("restart")
        end
    end

    function obj:start()
        obj.speed = 150
        obj.can_jump = true
        obj.gravity = 15
        obj:jump()
    end

    function obj:mousepressed(x, y, button, is_touch)
        if button == 1 then
            obj:jump()
            if not obj.started then
                obj.started = true
                obj:start()
            end
        end
    end

    function obj:wheelmoved(x, y)
    end

    function obj:mousereleased(x, y, button)
    end

    function obj:mousemoved(x, y, dx, dy)
    end

    function obj:goal(side)
        obj.can_wall = false
        local death = scene:check_coll(obj.side)
        if not death then
            sounds.click:setPitch(1)
            sounds.click:setVolume(.35)
            sounds.click:play()
            scene:generate_pattern()
            obj.speed = clamp(obj.speed + 1, 150, 300)
            scene.score = scene.score + 1
            obj.side = side
            obj.wall_timer:after(.2, function()
                obj.can_wall = true
            end)
            return
        end
        obj:death()
    end

    function obj:death()
        obj.speed = 0
        obj.gravity = 0
        obj.gravity_vel = 0
        obj.can_jump = false
        obj.death_timer:after(2, function()
            scene:draw_last_frame()
            start_new()
        end)
    end

    function obj:jump()
        if obj.can_jump then
            sounds.click:setPitch(2)
            sounds.click:setVolume(.38)
            sounds.click:play()
            obj.impact = 2
            obj.gravity_vel = -obj.jump_str
            obj.taps = obj.taps + 1

            local e = {
                radius = obj.radius,
                width = obj.radius * 4,
                pos = { x = obj.pos.x, y = obj.pos.y },
                timer = Timer()
            }
            e.timer:after(1, function()
                obj.delete_exp = true
            end)
            obj.exp[#obj.exp + 1] = e
        end
    end

    function obj:create_trail()
        local trail = { timer = Timer(), radius = obj.radius, pos = { x = obj.pos.x, y = obj.pos.y } }
        obj.trail[#obj.trail + 1] = trail
        trail.timer:after(.025, function()
            obj:create_trail()
        end)

        if #obj.trail > 31 then
            obj.to_delete_trail = true
        end
    end

    setmetatable(obj, self)
    self.__index = self
    return obj
end
