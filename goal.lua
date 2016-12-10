Class = require "hump.class"

local Goal = Class{
    init = function(self, row, col, color, active)
        self.row = row
        self.col = col
        self.color = color
        self.active = active
        self.frame = 0
        self.timer = 0
    end,
    fps = 10
}

function Goal:setActive(active)
    self.active = active
end

function Goal:setColor(color)
    self.color = color
end

function Goal:update(dt)
    self.timer = self.timer + dt

    if self.active and self.timer > 1 / self.fps then
        self.frame = self.frame + 1

        if self.frame > 4 then self.frame = 0 end
        self.timer = 0
    end
end

function Goal:draw()
    love.graphics.setColor(255, 255, 255)

    local pos = game.getQuad(self.row, self.col)

    local sprite = game.goalSprites.inactive
    if self.active then
        if self.color == "blue" then
            sprite = game.goalSprites.blue
        else
            sprite = game.goalSprites.red
        end
    end

    quad = love.graphics.newQuad(self.frame * 32, 0, 32, 32, sprite:getWidth(), sprite:getHeight())
    love.graphics.draw(sprite, quad, pos[1], pos[2])
end

return Goal

