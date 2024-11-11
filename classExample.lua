Example = {}

function Example:new()
    local obj = {}

    function obj:load()
    end

    function obj:update(dt)
    end

    function obj:draw()
    end

    function obj:keypressed(k)
    end

    function obj:mousepressed(x, y, button)
    end

    function obj:wheelmoved(x, y)
    end

    function obj:mousereleased(x, y, button)
    end

    function obj:mousemoved(x, y, dx, dy)
    end

    setmetatable(obj, self)
    self.__index = self
    return obj
end
