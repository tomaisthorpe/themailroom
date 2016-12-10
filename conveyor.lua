Class = require "hump.class"

Conveyor = Class{
    init = function(self, row, col, direction)
       self.row = row
       self.col = col
       self.direction = direction
    end
}

function Conveyor:draw()
    love.graphics.setColor(120, 30, 30)

    love.graphics.polygon("fill", game.getQuad(self.row, self.col)) 
end

function Conveyor:getEndPoint()
    -- Get top left position
    x = (self.col - 1) * 32
    y = (self.row - 1) * 32
    
    if self.direction == "west" then
        return {x = x, y = y + 16}
    elseif self.direction == "east" then
        return {x =  x + 32, y = y + 16}
    elseif self.direction == "north" then
        return {x = x + 16, y = y}
    elseif self.direction == "south" then
        return {x = x + 16, y = y + 32}
    end
end
