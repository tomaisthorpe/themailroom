Class = require "hump.class"

local Conveyor = Class{
    init = function(self, row, col, direction)
       self.row = row
       self.col = col
       self.direction = direction
       self.timer = 0
       self.frame = 0
    end,
    fps = 10
}

function Conveyor:draw()
    rotation = 0
    ninety = 1.57

    if self.direction == "west" then
        rotation = ninety * 1
    elseif self.direction == "east" then
        rotation = ninety * 3
    elseif self.direction == "north" then
        rotation = ninety * 2
    end


    
    love.graphics.setColorMask()
    love.graphics.setColor(255, 255, 255)
    pos = game.getQuad(self.row, self.col)
    quad = love.graphics.newQuad(self.frame * 32, 0, 32, 32, game.conveyorSprites:getWidth(), game.conveyorSprites:getHeight())
    love.graphics.draw(game.conveyorSprites, quad, pos[1] + 16, pos[2] + 16, rotation, 1, 1, 16, 16)
    --love.graphics.polygon("fill", game.getQuad(self.row, self.col)) 
end

function Conveyor:update(dt)
    self.timer = self.timer + dt

    if self.timer > 1 / self.fps then
        self.frame = self.frame + 1

        if self.frame > 4 then self.frame = 0 end
        self.timer = 0 
    end
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
