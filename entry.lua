Class = require "hump.class"

local Entry = Class{
    init = function(self, row, col, active, rate)
        self.row = row
        self.col = col
        self.active = active
        self.rate = rate
        self.timer = rate
    end
}

function Entry:draw()
    love.graphics.setColor(0, 0, 0)
    love.graphics.polygon("fill", game.getQuad(self.row, self.col))
end

function Entry:setActive(active)
    self.active = active

    if active == true then
        timer = 0
    end
end

function Entry:getEntryPoint()
    local pos = game.gridToXY(self.row, self.col)
    return {x = pos.x + 16, y = pos.y + 33}
end

function Entry:update(dt)
    self.timer = self.timer + dt

    if self.timer > self.rate then
        self.timer = 0

        local entryPoint = self:getEntryPoint()

        -- Timer hit, so add a package
        local package = Package(entryPoint.x, entryPoint.y)

        table.insert(game.packages, package)
    end
end

return Entry
