require "lib.loader"

require "scenes.mainGame"

last_screen = nil
current_scene = MainGame:new()

function start_new()
    current_scene = MainGame:new()
    current_scene:load()
end

function love.load()
    if current_scene ~= nil then
        current_scene:load()
    end
end

function love.update(dt)
    if current_scene ~= nil then
        current_scene:update(dt)
    end
end

function love.draw()
    if current_scene ~= nil then
        current_scene:draw()
    end
end

function love.keypressed(k)
    if current_scene ~= nil then
        current_scene:keypressed(k)
    end
end

function love.mousepressed(x, y, button)
    if current_scene ~= nil then
        current_scene:mousepressed(x, y, button)
    end
end

function love.wheelmoved(x, y)
    if current_scene ~= nil then
        current_scene:wheelmoved(x, y)
    end
end

function love.mousereleased(x, y, button)
    if current_scene ~= nil then
        current_scene:mousereleased(x, y, button)
    end
end

function love.mousemoved(x, y, dx, dy)
    if current_scene ~= nil then
        current_scene:mousemoved(x, y, dx, dy)
    end
end
