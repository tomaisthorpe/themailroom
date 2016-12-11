Class = require "hump.class"

local Goal = Class{
    init = function(self, row, col, color, active)
        self.row = row
        self.col = col
        self.color = color
        self.active = active
        self.frame = 0
        self.timer = 0
        self.frameActive = 0
        self.timerActive = 0
    end,
    fps = 10
}

function Goal:setActive(active)
    self.active = active

    -- Make it's "box" tile active/inactive
    --[[local tile = game.getId(self.row, self.col) + 1
    if self.active then
        game.layer1[tile] = 13
    else
        game.layer1[tile] = 12
    end]]--
end

function Goal:setColor(color)
    self.color = color
end

function Goal:update(dt)
    self.timer = self.timer + dt
    self.timerActive = self.timerActive + dt

    if self.active then
        if self.timer > 1 / self.fps then 
            self.frame = self.frame + 1

            if self.frame > 4 then self.frame = 0 end
            self.timer = 0
        end
        
        if self.timerActive > 1 / self.fps then 
            self.frameActive = self.frameActive + 1

            if self.frameActive > 5 then self.frameActive = 0 end
            self.timerActive = 0
        end
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

    local quad = love.graphics.newQuad(self.frame * 32, 0, 32, 32, sprite:getWidth(), sprite:getHeight())
    love.graphics.draw(sprite, quad, pos[1], pos[2])

    -- Draw the box behind the box
    if self.active == false then
        love.graphics.draw(game.goalBoxSprites.inactive, pos[1] + 32, pos[2])
    else
        local spriteBox = game.goalBoxSprites.blue

        if self.color == "red" then spriteBox = game.goalBoxSprites.red end


        local quadBox = love.graphics.newQuad(self.frameActive * 32, 0, 32, 32, spriteBox:getWidth(), spriteBox:getHeight())
        love.graphics.draw(spriteBox, quadBox, pos[1] + 32, pos[2])
    end


    love.graphics.draw(game.goalBoxSprites.wire, pos[1] + 32, pos[2] + 32)

    if self.active then
        if self.color == "blue" then
            love.graphics.draw(game.lorrySprites.blue, pos[1] + 64, pos[2] - 32)
        elseif self.color == "red" then
            love.graphics.draw(game.lorrySprites.red, pos[1] + 64, pos[2] - 32)
        end
    end
end

return Goal

