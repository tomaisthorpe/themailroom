Class = require "hump.class"

local Conveyor = Class{
    init = function(self, row, col, direction)
       self.row = row
       self.col = col
       self.direction = direction
    end
}

function Conveyor:draw()
    if self.direction == "west" then
        love.graphics.setColor(120, 30, 30)
    elseif self.direction == "east" then
        love.graphics.setColor(30, 120, 30)
    elseif self.direction == "north" then
        love.graphics.setColor(30, 30, 120)
    elseif self.direction == "south" then
        love.graphics.setColor(120, 120, 30)
    end

    love.graphics.polygon("fill", game.getQuad(self.row, self.col)) 
end

function Conveyor:getEndPoint()
    -- Get top left position
    x = (self.col - 1) * 32
    y = (self.row - 1) * 32
    
    if self.direction == "west" then
        return {x = x - 1, y = y + 16}
    elseif self.direction == "east" then
        return {x = x + 33, y = y + 16}
    elseif self.direction == "north" then
        return {x = x + 16, y = y - 1}
    elseif self.direction == "south" then
        return {x = x + 16, y = y + 33}
    end
end

return Conveyor
