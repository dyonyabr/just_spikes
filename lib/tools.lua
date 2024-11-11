function lerp(a, b, t)
    return a + (b - a) * t
end

function lerp_angle(a, b, t)
    local diff = (b - a + math.pi) % (2 * math.pi) - math.pi
    return a + diff * t
end

function posmod(a, b)
    return ((a % b) + b) % b
end

function clamp(val, lower, upper)
    assert(val and lower and upper, "not very useful error message here")
    if lower > upper then lower, upper = upper, lower end
    return math.max(lower, math.min(upper, val))
end

local cur_hover = { 0, 0, 0, 0 }
local cur_hover_circle = { 0, 0, 0 }
local new_hover = true

function is_hover(x, y, w, h, px, py, ox, oy)
    x = x + ox
    y = y + oy
    local da = not (px < x or py < y or px > x + w or py > y + h)
    local inside = not new_hover and
        ((cur_hover[1] == x and cur_hover[2] == y and cur_hover[3] == w and cur_hover[4] == h) or
            (cur_hover[1] <= x and cur_hover[2] <= y and cur_hover[3] >= w and cur_hover[4] >= h))
    if (new_hover or inside) and da then
        cur_hover = { x, y, w, h }
        new_hover = false
        return true
    end
    return false
end

function is_mouse_hover(x, y, w, h, ox, oy, pox, poy)
    if ox == nil then ox = 0 end
    if oy == nil then oy = 0 end
    if pox == nil then pox = 0 end
    if poy == nil then poy = 0 end
    local px, py = love.mouse.getPosition()
    px = px - pox
    py = py - poy
    return is_hover(x, y, w, h, px, py, ox, oy)
end

function is_hover_circle(x, y, radius, px, py, ox, oy)
    x = x + ox
    y = y + oy
    local distance = math.sqrt((px - x) ^ 2 + (py - y) ^ 2)
    local da = distance <= radius
    local inside = not new_hover and
        ((cur_hover_circle[1] == x and cur_hover_circle[2] == y and cur_hover_circle[3] == radius) or
            (cur_hover_circle[1] <= x and cur_hover_circle[2] <= y and cur_hover_circle[3] >= radius))
    if (new_hover or inside) and da then
        cur_hover_circle = { x, y, radius }
        new_hover = false
        return true
    end
    return false
end

function is_mouse_hover_circle(x, y, radius, ox, oy, pox, poy)
    if ox == nil then ox = 0 end
    if oy == nil then oy = 0 end
    if pox == nil then pox = 0 end
    if poy == nil then poy = 0 end
    local px, py = love.mouse.getPosition()
    px = px - pox
    py = py - poy
    return is_hover_circle(x, y, radius, px, py, ox, oy)
end

function drawLTWH(image, x, y, width, height, aspect)
    local imgWidth = image:getWidth()
    local imgHeight = image:getHeight()

    local scaleX = width / imgWidth
    local scaleY = height / imgHeight

    if aspect ~= nil then
        local scale
        if aspect == "vertical" then
            scale = math.max(scaleX, scaleY)
        elseif aspect == "horizontal" then
            scale = math.min(scaleX, scaleY)
        end
        scaleX = scale
        scaleY = scale
    end

    local offsetX = (width - imgWidth * scaleX) / 2
    local offsetY = (height - imgHeight * scaleX) / 2

    love.graphics.draw(image, x + offsetX, y + offsetY, 0, scaleX, scaleY)
end

function box_shadow(x, y, w, h, shadowSpread, shadowColor)
    box_shadow_shader:send("rectPos", { x, y })
    box_shadow_shader:send("rectSize", { w, h })
    box_shadow_shader:send("shadowSpread", shadowSpread)
    box_shadow_shader:send("shadowColor", shadowColor)

    love.graphics.setShader(box_shadow_shader)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setShader()
end

function circle_shadow(x, y, radius, shadowSpread, shadowColor)
    circle_shadow_shader:send("circleCenter", { x, y })
    circle_shadow_shader:send("radius", radius)
    circle_shadow_shader:send("shadowSpread", shadowSpread)
    circle_shadow_shader:send("shadowColor", shadowColor)

    love.graphics.setShader(circle_shadow_shader)
    love.graphics.circle("fill", x, y, radius + shadowSpread)
    love.graphics.setShader()
end

function set_cursor(type)
    love.mouse.setCursor(love.mouse.getSystemCursor(type))
end

function tools_update(dt)
    cur_hover = { 0, 0, 0, 0 }
    cur_hover_circle = { 0, 0, 0 }
    new_hover = true
end

function hsv2rgb(h, s, v)
    local r, g, b

    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    i = i % 6

    if i == 0 then
        r, g, b = v, t, p
    elseif i == 1 then
        r, g, b = q, v, p
    elseif i == 2 then
        r, g, b = p, v, t
    elseif i == 3 then
        r, g, b = p, q, v
    elseif i == 4 then
        r, g, b = t, p, v
    elseif i == 5 then
        r, g, b = v, p, q
    end

    return r, g, b
end

function rgb2hsv(r, g, b)
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local delta = max - min

    -- Calculate value (brightness)
    local v = max

    -- Calculate saturation
    local s
    if max == 0 then
        s = 0
    else
        s = delta / max
    end

    -- Calculate hue
    local h
    if delta == 0 then
        h = 0 -- undefined
    elseif max == r then
        h = (g - b) / delta % 6
    elseif max == g then
        h = (b - r) / delta + 2
    elseif max == b then
        h = (r - g) / delta + 4
    end

    h = h / 6 -- normalize hue to be between 0 and 1

    -- Return HSV values
    return h, s, v
end

function sign(value)
    if value > 0 then
        return 1
    elseif value < 0 then
        return -1
    else
        return 0
    end
end

function circle_line(x, y, radius, borderWidth, segments)
    segments = segments or 100 -- default number of segments for smoother circles
    for i = 0, borderWidth - 1 do
        love.graphics.circle("line", x, y, radius - i, segments)
    end
end
