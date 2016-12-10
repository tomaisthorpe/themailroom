Class = require "hump.class"

local Goal = Class{
    init = function(self, row, col, active)
        self.row = row
        self.col = col
        self.active = active
    end
}

function Goal:draw()
    if self.active then
        love.graphics.setColor(28, 154, 186)
    else
        love.graphics.setColor(110, 130, 164)
    end

    love.graphics.polygon("fill", game.getQuad(self.row, self.col))
end

return Goal

