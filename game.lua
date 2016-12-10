--Test = require "package"
local Conveyor = require("conveyor")
local Entry = require("entry")
local Goal = require("goal")

vector = require "hump.vector"

Package = Class{
    init = function(self, x, y)
       self.x = x
       self.y = y
    end,
    size=16
}
function Package:draw()
    love.graphics.setColor(230, 70, 70)
    love.graphics.draw(game.packageSprite, self.x - self.size / 2, self.y - self.size / 2)
    --love.graphics.polygon("fill", self:getQuad())
end

function Package:getQuad()
    left_x = self.x - self.size / 2
    right_x = self.x + self.size / 2
    top_y = self.y - self.size / 2
    bottom_y = self.y + self.size / 2

    return {left_x, top_y, right_x, top_y, right_x, bottom_y, left_x, bottom_y}
end

function Package:getGridPosition()
    return game.getGridPosition(self.x, self.y)
end

function Package:onConveyor(conveyor)
    local pos = self:getGridPosition()
    if conveyor.row == pos.row and conveyor.col == pos.col then
        return true
    end

    return false
end

function Package:getConveyor()
    for c=1,#game.conveyors,1 do
        if self:onConveyor(game.conveyors[c]) then
            return game.conveyors[c]
        end
    end
    
    return nil
end

function Package:onGoal(goal)
    local pos = self:getGridPosition()
    if goal.row == pos.row and goal.col == pos.col then
        return true
    end

    return false
end


function Package:getGoal()
    for g=1,#game.goals,1 do
        if self:onGoal(game.goals[g]) then
            return game.goals[g]
        end
    end

    return nil
end


function Package:move(dt)
    -- Find which conveyor this package is on
    local conveyor = self:getConveyor()

    -- If there isn't a conveyor don't move hte package
    if conveyor ~= nil then

        local dest = conveyor:getEndPoint()

        -- Create vector from current x,y to goal:0
        local direction = vector(dest.x - self.x, dest.y - self.y)
        local movement = direction:normalized() * game.conveyorSpeed * dt

        self.x = self.x + movement.x
        self.y = self.y + movement.y 
    end

    local goal = self:getGoal()

    if goal ~= nil and goal.active then
        self.shouldDelete = true
        game.score = game.score + 1
    end
end


game = {
    tileSize = 32,
    layer1 = {
        2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,
        3,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,3,0,0,
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
    conveyorSpeed = 32,
    lastConveyorDirection="north",
    packages={},
    gridWidth = 25,
    gridHeight = 17,
    gameTranslateY = 0, -- Needed for mouseOver calculation
    wallColor = {100, 100, 100},
    floorColor = {150, 150, 150},
    backgroundColor = {10, 10, 10},
    borderColor = {130, 130, 130},
    entries={},
    goals={},
    mouseOver=nil, -- Set to non-nil if over editable grid square
    score = 0,
    sprites = {}
}

function game:init()
    game.font = love.graphics.newFont( "assets/veramono.ttf", 12 )
    game.font:setFilter( "nearest", "nearest" )

    -- Load images
    game.conveyorSprites = love.graphics.newImage("assets/conveyor.png")
    game.entrySprites = love.graphics.newImage("assets/entry.png")

    game.sprites[1] = love.graphics.newImage("assets/floor.png")
    game.sprites[2] = love.graphics.newImage("assets/wall_top.png")
    game.sprites[7] = love.graphics.newImage("assets/wall_bottom.png")


    game.packageSprite = love.graphics.newImage("assets/package.png")
end

function game:enter()
    love.graphics.setBackgroundColor(game.backgroundColor)

    table.insert(game.conveyors, Conveyor(3, 4, "south"))
    table.insert(game.conveyors, Conveyor(4, 4, "south"))
    table.insert(game.conveyors, Conveyor(5, 4, "south"))
    table.insert(game.conveyors, Conveyor(6, 4, "south"))
    table.insert(game.conveyors, Conveyor(7, 4, "south"))
    table.insert(game.conveyors, Conveyor(8, 4, "south"))

    table.insert(game.entries, Entry(2, 4, false, 2))
    table.insert(game.goals, Goal(6, 22, true))

    game.entries[1]:setActive(true)
end

function game:update(dt)
    for p=#game.packages,1,-1 do 
        game.packages[p]:move(dt)

        if game.packages[p].shouldDelete then
            table.remove(game.packages, p)
        end
    end

    for e=1,#game.entries,1 do
        game.entries[e]:update(dt)
    end
    
    for c=1,#game.conveyors,1 do
        game.conveyors[c]:update(dt)
    end
end

function game:keyreleased(key)
    if key == "escape" then
        love.event.quit()
    end
end

function game:mousemoved(x, y)
    pos = game.getGridPosition(x, y - game.translateY)

    if game.isConveyorPositionValid(pos.row, pos.col) then
        game.mouseOver = pos
    else
        game.mouseOver = nil
    end
end

function game.isConveyorPositionValid(row, col)
    if game.layer1[game.getId(row, col)] == 1 then
        -- Ensure no goal points
        for g=1,#game.goals,1 do
           if game.goals[g].row == row and game.goals[g].col == col then
               return false
            end
        end

        return true
    end

    return false
end

function game:mousereleased()
    if game.mouseOver ~= nil then
        -- Find if conveyor under mouse
        local conveyorIndex = game.getConveyorIndex(game.mouseOver.row, game.mouseOver.col)

        if conveyorIndex == nil then
            table.insert(game.conveyors, Conveyor(game.mouseOver.row, game.mouseOver.col, game.lastConveyorDirection))
        else
            local conveyor = game.conveyors[conveyorIndex]
            local cycle = {"north", "east", "south", "west"}

            for d=1,#cycle,1 do
                if cycle[d] == conveyor.direction then
                    if d == #cycle then
                        table.remove(game.conveyors, conveyorIndex)
                        game.lastConveyorDirection = cycle[1]
                    else
                        conveyor.direction = cycle[d + 1]
                        game.lastConveyorDirection = conveyor.direction 
                    end
                    break
                end
            end 
        end
    end
end

function game:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(game.font)
    love.graphics.print("Score: " .. game.score, 0, 0, 0, 2)
    love.graphics.print("Mail Delivered: 0", 0, 26, 0, 2)

    -- Shift game window down
    game.translateY = (600 - (game.gridHeight * 32))
    love.graphics.translate(0, game.translateY)
    

    for r=1,game.gridHeight,1 do
        for c=1,game.gridWidth,1 do
            block = game.layer1[game.getId(r, c)] 

            if block > 0 then
                if game.sprites[block] == nil then 
                    if block == 2 or block == 3 then
                        love.graphics.setColor(game.wallColor)
                    elseif block == 4 or block == 5 or block == 6 then
                        love.graphics.setColor(game.borderColor)
                    end

                    love.graphics.polygon("fill", game.getQuad(r, c))
                else
                    love.graphics.setColor(255, 255, 255)
                    love.graphics.draw(game.sprites[block], game.getQuad(r, c)[1], game.getQuad(r, c)[2])
                end
            end
            
        end
    end

    -- Draw entries
    for e=1,#game.entries,1 do
        game.entries[e]:draw()
    end

    -- Draw goals
    for g=1,#game.goals,1 do
        game.goals[g]:draw()
    end
    
    -- Draw conveyors
    for c=1,#game.conveyors,1 do
        game.conveyors[c]:draw()
    end

    -- Draw mail
    for p=1,#game.packages,1 do
        game.packages[p]:draw()
    end

    -- Draw mouse box
    if game.mouseOver ~= nil then
        love.graphics.setColor(40,40, 40)

        love.graphics.polygon("line", game.getQuad(game.mouseOver.row, game.mouseOver.col))
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

function game.getGridPosition(x, y)
    local col = math.ceil(x / 32)
    local row = math.ceil(y / 32)

    return {row=row, col=col}
end

function game.getConveyorIndex(row, col)
    for c=1,#game.conveyors,1 do
        if game.conveyors[c].row == row and game.conveyors[c].col == col then
            return c
        end
    end

    return nil
end

function game.gridToXY(row, col)
    left_x = (col - 1) * 32
    top_y = (row - 1) * 32

    return {x = left_x, y = top_y }
end
