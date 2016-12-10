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
