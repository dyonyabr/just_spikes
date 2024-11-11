MainGame = {}
require "scripts.player"

function MainGame:new()
    local obj = {}

    obj.is_game_over = false

    obj.delete_exp = false
    obj.exp = {}

    obj.hue = 0

    obj.up_offset = (700 - 535) / 2
    obj.map_height = 535

    obj.alert = 0
    obj.alert_pos = 0
    obj.alert_stop = false
    obj.cur_off = 0
    obj.ceil_offset = 0
    obj.floor_offset = 0
    obj.lerp_ceil_offset = 0
    obj.lerp_floor_offset = 0

    obj.prev_bg = {
        color = {},
        pos = { x = love.graphics.getWidth() / 2, y = obj.map_height / 2 },
        radius = love
            .graphics.getHeight()
    }
    obj.cur_bg = {
        color = {},
        pos = { x = love.graphics.getWidth() / 2, y = obj.map_height / 2 },
        radius = love
            .graphics.getHeight()
    }

    obj.hitted = { 0, 0 }
    obj.hitted_green = { 0, 0 }

    obj.death_screen = {
        pos = { x = 0, y = 0 },
        radius = 0
    }

    obj.start_screen = {
        radius = 0
    }

    obj.score = 0

    obj.spikes = { { place = { false, false, false, false, false, false, false, false, false, false }, offset = 0, lerp_offset = 0 },
        { place = { false, false, false, false, false, false, false, false, false, false }, offset = 0, lerp_offset = 0 } }
    obj.cur_side = 1

    obj.player = Player:new(obj)

    function obj:load()
        obj.player:load()
        obj:random_color()
        obj.prev_bg.color = obj.cur_bg.color
    end

    function obj:update(dt)
        obj.player:update(dt)
        if not obj.is_game_over then
            for i = 1, 2 do
                obj.spikes[i].lerp_offset = lerp(obj.spikes[i].lerp_offset, obj.spikes[i].offset, dt * 10)
            end
        end

        obj.lerp_ceil_offset = lerp(obj.lerp_ceil_offset, obj.ceil_offset, dt * 5)
        obj.lerp_floor_offset = lerp(obj.lerp_floor_offset, obj.floor_offset, dt * 5)

        obj.cur_bg.radius = lerp(obj.cur_bg.radius, love.graphics.getHeight(), dt * 2)

        for i = 1, #obj.exp do
            obj.exp[i].timer:update(dt)
            obj.exp[i].width = lerp(obj.exp[i].width, 0, dt * 8) - 1
            obj.exp[i].radius = lerp(obj.exp[i].radius, 50, dt * 8)
        end

        if (obj.player.pos.y <= obj.player.radius + 5 + obj.lerp_ceil_offset or obj.player.pos.y >= obj.map_height - obj.player.radius - 5 - obj.lerp_floor_offset) then
            obj:game_over()
        end

        if obj.delete_exp then
            table.remove(obj.exp, 1)
            obj.delete_exp = false
        end

        if obj.alert ~= 0 then
            obj.alert_pos = lerp(obj.alert_pos, obj.map_height / 2, dt * 10)
        else
            obj.alert_pos = 0
        end

        if obj.is_game_over then
            obj.death_screen.pos = obj.player.pos
            obj.death_screen.radius = lerp(obj.death_screen.radius, love.graphics.getHeight(),
                dt * 1.5)
        end

        obj.start_screen.radius = lerp(obj.start_screen.radius, love.graphics.getHeight(), dt * 1)
    end

    function obj:game_over()
        obj.player:death()
        obj.is_game_over = true
    end

    function obj:check_coll(side)
        local death = false
        local x
        local s
        if side == 1 then
            s = 2
            x = love.graphics.getWidth()
        else
            s = 1
            x = 0
        end
        for i = 1, 10 do
            if (obj.spikes[s].place[i] and math.abs((obj.player.pos.y) - (i * 45 + 20)) <= obj.player.radius + 10) then
                obj.is_game_over = true
                death = true
                return death
            end
        end

        local e = { radius = 25, width = 100, pos = { x = x, y = obj.player.pos.y }, timer = Timer() }
        e.timer:after(1, function()
            obj.delete_exp = true
        end)
        obj.exp[#obj.exp + 1] = e

        return death
    end

    function obj:draw()
        if last_screen == nil then
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        else
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(last_screen)
        end

        love.graphics.stencil(function()
            love.graphics.circle("fill", love.graphics.getWidth() / 2, obj.up_offset + obj.map_height / 2,
                obj.start_screen.radius)
        end, "replace", 1)
        love.graphics.setStencilTest("greater", 0)
        love.graphics.translate(0, obj.up_offset)

        love.graphics.setColor(obj.prev_bg.color)
        love.graphics.circle("fill", obj.prev_bg.pos.x, obj.prev_bg.pos.y, obj.prev_bg.radius)

        love.graphics.setColor(obj.cur_bg.color)
        love.graphics.circle("fill", obj.cur_bg.pos.x, obj.cur_bg.pos.y, obj.cur_bg.radius)

        if obj.alert ~= 0 then
            love.graphics.stencil(function()
                if obj.alert == 1 then
                    love.graphics.rectangle("fill", 0, obj.map_height - obj.alert_pos, love.graphics.getWidth(),
                        obj.alert_pos)
                elseif obj.alert == 2 then
                    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), obj.alert_pos)
                end
            end, "replace", 1)
            love.graphics.setStencilTest("greater", 0)
            love.graphics.setColor(0, 0, 0, .5)
            love.graphics.push()
            love.graphics.origin()
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

            love.graphics.rotate(math.pi / 4)
            love.graphics.setColor(0, 0, 0, .15)
            local offset = ((love.timer.getTime() * 30) % 60)
            for i = -10, 20 do
                love.graphics.rectangle("fill", 0, i * 60 + offset, love.graphics.getWidth() * 4, 30)
            end

            love.graphics.pop()
            love.graphics.setStencilTest()
        end

        love.graphics.setColor(0, 0, 0, .25)
        love.graphics.printf(obj.score, fonts.score, 8, 120 + obj.lerp_ceil_offset / 2 - obj.lerp_floor_offset / 2,
            love.graphics.getWidth(), "center")

        obj.player:draw()

        local gap = 45
        local ox = 20
        local oy = 0
        love.graphics.setColor(0, 0, 0, 1)
        for i = 1, 7 do
            obj:draw_triangle("down", i * gap - ox, obj.lerp_ceil_offset)
        end
        for i = 1, 7 do
            obj:draw_triangle("up", i * gap - ox, obj.map_height - obj.lerp_floor_offset)
        end
        for i = 1, 10 do
            if obj.spikes[1].place[i] then
                obj:draw_triangle("right", -obj.spikes[1].lerp_offset, i * gap - oy)
            end
        end
        for i = 1, 10 do
            if obj.spikes[2].place[i] then
                local da = 0
                obj:draw_triangle("left", love.graphics.getWidth() + obj.spikes[2].lerp_offset, i * gap - oy)
            end
        end

        love.graphics.origin()
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), obj.up_offset + obj.lerp_ceil_offset)
        love.graphics.rectangle("fill", 0, obj.up_offset + obj.map_height - obj.lerp_floor_offset,
            love.graphics.getWidth(),
            (love.graphics.getHeight() - obj.up_offset - obj.map_height) + obj.lerp_floor_offset)

        for i = 1, #obj.exp do
            circle_line(obj.exp[i].pos.x, obj.exp[i].pos.y + obj.up_offset, obj.exp[i].radius,
                clamp(obj.exp[i].width, 0, 50))
        end

        if obj.is_game_over then
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.circle("fill", obj.death_screen.pos.x, obj.death_screen.pos.y + obj.up_offset,
                obj.death_screen.radius)

            love.graphics.stencil(function()
                love.graphics.circle("fill", obj.death_screen.pos.x, obj.death_screen.pos.y + obj.up_offset,
                    obj.death_screen.radius)
            end, "replace", 1)
            love.graphics.setStencilTest("greater", 0)

            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf(obj.score, fonts.score, 8, 120 + obj.up_offset, love.graphics.getWidth(), "center")

            love.graphics.setStencilTest()
        end
        love.graphics.setStencilTest()
    end

    function obj:draw_last_frame()
        local canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setCanvas(canvas)
        love.graphics.clear()

        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.circle("fill", obj.death_screen.pos.x, obj.death_screen.pos.y + obj.up_offset,
            obj.death_screen.radius)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(obj.score, fonts.score, 8, 120 + obj.up_offset, love.graphics.getWidth(), "center")

        love.graphics.setCanvas()
        local id = canvas:newImageData()
        last_screen = love.graphics.newImage(id)
    end

    function obj:keypressed(k)
        obj.player:keypressed(k)
    end

    function obj:mousepressed(x, y, button, is_touch)
        obj.player:mousepressed(x, y, button, is_touch)
    end

    function obj:wheelmoved(x, y, button)
    end

    function obj:mousereleased(x, y, button)
    end

    function obj:mousemoved(x, y, dx, dy)
    end

    function obj:random_color()
        obj.prev_bg.color = obj.cur_bg.color
        obj.hue = (obj.hue + 1) % 2
        local bgcolorh, bgcolors, bgcolorv = (love.math.random(0, 50) + 50 * obj.hue) / 100, .5, .5
        local bgcolorr, bgcolorg, bgcolorb = hsv2rgb(bgcolorh, bgcolors, bgcolorv)
        obj.cur_bg.color = { bgcolorr, bgcolorg, bgcolorb }
        obj.cur_bg.radius = 0
        obj.cur_bg.pos = { x = obj.player.pos.x, y = obj.player.pos.y }
    end

    function obj:generate_pattern()
        local count = clamp(love.math.random((obj.score + 1) % 10 - 2, (obj.score + 1) % 10 + 2),
            clamp(2 + math.floor(obj.score / 20), 2, 5), 8)
        local num = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
        local sp = {}
        if (obj.score + 1) % 5 == 0 then obj:random_color() end

        if obj.alert_stop then
            obj.alert = 0
        end

        local to_stop_alert = false
        local just_alerted = false
        if obj.alert == 0 then
            if love.math.random(1, 100) < 50 and not obj.alert_stop then
                obj.cur_off = love.math.random(0, 1)
                obj.alert = obj.cur_off + 1
                obj.alert_score = obj.score
                just_alerted = true
                if obj.cur_off == 0 then
                    num = { 2, 3, 4, 5 }
                else
                    num = { 6, 7, 8, 9 }
                end
                count = math.floor(count / 2)
            end
            obj.ceil_offset = 0
            obj.floor_offset = 0
        else
            if just_alerted == false then
                if obj.cur_off == 0 then
                    obj.floor_offset = obj.map_height / 2
                    num = { 1, 2, 3, 4, 5 }
                else
                    obj.ceil_offset = obj.map_height / 2
                    num = { 6, 7, 8, 9, 10 }
                end
                count = math.floor(count / 2)
            end
            to_stop_alert = true
        end
        local other_side = (obj.cur_side + 2) % 2 + 1
        obj.spikes[(obj.cur_side + 2) % 2 + 1].offset = 20
        obj.spikes[obj.cur_side].offset = 0
        for i = 1, 10 do
            obj.spikes[obj.cur_side].place[i] = false
        end

        for i = 1, count do
            local pos = love.math.random(1, #num)
            local m_sp = num[pos]
            table.remove(num, pos)
            sp[#sp + 1] = m_sp
        end
        for i = 1, #sp do
            obj.spikes[obj.cur_side].place[sp[i]] = true
        end
        obj.cur_side = other_side
        obj.alert_stop = false or to_stop_alert
    end

    function obj:draw_triangle(dir, x, y)
        local w = 40
        local h = 20
        if dir == "up" then
            love.graphics.polygon("fill", x, y, x + w, y, x + w / 2, y - h)
        elseif dir == "down" then
            love.graphics.polygon("fill", x, y, x + w, y, x + w / 2, y + h)
        elseif dir == "right" then
            love.graphics.polygon("fill", x, y, x, y + w, x + h, y + w / 2)
        elseif dir == "left" then
            love.graphics.polygon("fill", x, y, x, y + w, x - h, y + w / 2)
        end
    end

    setmetatable(obj, self)
    self.__index = self
    return obj
end
