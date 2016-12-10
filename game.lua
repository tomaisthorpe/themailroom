--Test = require "package"
Conveyer = require "conveyor"

Class = require "hump.class"

Package = Class{
    init = function(self, x, y)
        self.x = x
        self.y = y
    end,
    size=16
}

function Package:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.polygon("fill", self:getQuad())
end

function Package:getQuad()
    left_x = self.x - self.size / 2
    right_x = self.x + self.size / 2
    top_y = self.y - self.size / 2
    bottom_y = self.y + self.size / 2

    return {left_x, top_y, right_x, top_y, right_x, bottom_y, left_x, bottom_y}
end


game = {
    tileSize = 32,
    layer1 = {
        2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,
        3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4,0,0,
        5,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,5,0,0
    },
    conveyors = {},
    conveyorSpeed = 16,
    packages={},
    gridWidth = 25,
    gridHeight = 17,
    wallColor = {100, 100, 100},
    floorColor = {150, 150, 150},
    backgroundColor = {10, 10, 10},
    borderColor = {130, 130, 130},
}

function game:init()
    game.font = love.graphics.newFont( "assets/veramono.ttf", 12 )
    game.font:setFilter( "nearest", "nearest" )
end

function game:enter()
    love.graphics.setBackgroundColor(game.backgroundColor)

    table.insert(game.conveyors, Conveyor(4, 5, "east"))
    table.insert(game.conveyors, Conveyor(4, 4, "east"))
    table.insert(game.conveyors, Conveyor(4, 6, "east"))

    table.insert(game.packages, Package(96, 112))
end

function game:update(dt)
end

function game:keyreleased(key)
    if key == "escape" then
        love.event.quit()
    end
end

function game:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(game.font)
    love.graphics.print("Score: 0", 0, 0, 0, 2)
    love.graphics.print("Mail Delivered: 0", 0, 26, 0, 2)

    -- Shift game window down
    love.graphics.translate(0, (600 - (game.gridHeight * 32)))
    

    for r=1,game.gridHeight,1 do
        for c=1,game.gridWidth,1 do
            block = game.layer1[game.getId(r, c)] 

            if block > 0 then
                if block == 1 then
                    love.graphics.setColor(game.floorColor)
                elseif block == 2 or block == 3 then
                    love.graphics.setColor(game.wallColor)
                elseif block == 4 or block == 5 or block == 6 then
                    love.graphics.setColor(game.borderColor)
                end
                love.graphics.polygon("fill", game.getQuad(r, c))
            end
            
        end
    end

    -- Draw conveyors
    for c=1,#game.conveyors,1 do
        game.conveyors[c]:draw()
    end

    -- Draw mail
    for p=1,#game.packages,1 do
        game.packages[p]:draw()
    end
end

function game.getId(row, col)
    return (row - 1) * game.gridWidth + col
end

function game.getQuad(row, col)
    left_x = (col - 1) * 32
    top_y = (row - 1) * 32

    return {left_x, top_y, left_x + 32, top_y, left_x + 32, top_y + 32, left_x, top_y + 32}
end
