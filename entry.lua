Class = require "hump.class"

local Entry = Class{
    init = function(self, row, col, active, rate)
        self.row = row
        self.col = col
        self.active = active
        self.rate = rate
        self.timer = rate
        self.frame = 0
        self.frames = 27
        self.color = "red"
        if active then self.frame = self.frames end
    end,
    fps = 10,
    frame_timer = 0
}

function Entry:draw()
    love.graphics.setColor(255, 255, 255)

    pos = game.getQuad(self.row, self.col)
    quad = love.graphics.newQuad(self.frame * 32, 0, 32, 32, game.entrySprites:getWidth(), game.entrySprites:getHeight())
    love.graphics.draw(game.entrySprites, quad, pos[1], pos[2])
end

function Entry:setActive(active)

    if self.active == false and active == true then
        self.timer = -3.2
        self.frame = 0
    end
    
    self.active = active
end

function Entry:setColor(color)
    self.color = color
end

function Entry:getEntryPoint()
    local pos = game.gridToXY(self.row, self.col)
    return {x = pos.x + 16, y = pos.y + 33}
end

function Entry:update(dt)
    self.timer = self.timer + dt

    if self.active and self.frame == self.frames then
        if self.timer > self.rate then
            self.timer = 0

            -- Check if a package is needed
            if game.waveController:scoreNeeded() - #game.packages > 0 then
                local entryPoint = self:getEntryPoint()

                -- Timer hit, so add a package
                local package = Package(entryPoint.x, entryPoint.y, self.color)

                table.insert(game.packages, package)
            end
        end
    end

    -- Run trhough animation if needed
    if self.active == true and self.frame ~= self.frames then
        self.frame_timer = self.frame_timer + dt

        if self.frame_timer > 1 / self.fps then
            self.frame_timer = 0

            self.frame = self.frame + 1
        end
    elseif self.active == false and self.frame ~= 0 then
        self.frame_timer = self.frame_timer + dt

        if self.frame_timer > 1 / self.fps then
            self.frame_timer = 0

            self.frame = self.frame - 1
        end
    end
end

return Entry
