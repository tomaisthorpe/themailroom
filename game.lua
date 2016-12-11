--Test = require "package"
local Conveyor = require("conveyor")
local Entry = require("entry")
local Goal = require("goal")
local WaveController = require("wavegen")

vector = require "hump.vector"

Package = Class{
    init = function(self, x, y, color)
       self.x = x
       self.y = y
       self.color = color
       self.sprite = love.math.random(#game.packageSprites)
       self.offset = love.math.random(12) - 6
    end,
    size=16,
    delivered=false,
    opacity=255,
}
function Package:draw()
    if self.color == "red" then
        love.graphics.setColor(230, 70, 70, self.opacity)
    else
        love.graphics.setColor(70, 70, 230, self.opacity)
    end
    love.graphics.draw(game.packageSprites[self.sprite], self.x - self.size / 2, self.y - self.size / 2)
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


function Package:move(dt, index)
    if self.delivered then
        self.opacity = self.opacity - 510 * dt
        
        if self.opacity < 0 then
            self.opacity = 0
            self.shouldDelete = true
        end
    else
        -- Find which conveyor this package is on
        local conveyor = self:getConveyor()

        -- If there isn't a conveyor don't move hte package
        if conveyor ~= nil then

            local dest = conveyor:getEndPoint()
           
            if conveyor.direction == "west" or conveyor.direction == "east" then
                dest.y = dest.y + self.offset
            else
                dest.x = dest.x + self.offset
            end

            -- Create vector from current x,y to goal:0
            local direction = vector(dest.x - self.x, dest.y - self.y)
            local movement = direction:normalized() * game.conveyorSpeed * dt

            self.x = self.x + movement.x
            self.y = self.y + movement.y 

            -- Check if package is near
            local test_x = self.x
            local test_y = self.y

            if game.isSquareEmpty(index, self.x, self.y) == false then
               self.x = self.x - movement.x
               self.y = self.y - movement.y
            end

            goal = self:getGoal()
            if goal ~= nil and goal.active == false then
                self.x = self.x - movement.x
                self.y = self.y - movement.y
            end
        end

        local goal = self:getGoal()

        if goal ~= nil and goal.active then
            self.delivered = true
            if goal.color ~= self.color then
                game.lives = game.lives - 1
                game.wrongSound:play()
            else
                game.score = game.score + 1
                game.deliveredSound:play()
            end
        end
    end
end


game = {
    tileSize = 32,
    layer1 = {
        8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,10,0,0,
        3,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,11,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,0,0,
        4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,0,0,
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
    backgroundColor = {0, 39, 59},
    borderColor = {130, 130, 130},
    entries={},
    goals={},
    mouseOver=nil, -- Set to non-nil if over editable grid square
    score = 0,
    waveController = nil,
    lives = 5,
    scaling = 1,
    sprites = {},
    paused = false,
    gameOver = false,
}

function game:init()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setFullscreen(true)
   
    -- Work out scaling factor
    min_edge = love.graphics.getHeight()
    
    if min_edge < love.graphics.getWidth() then
        game.scaling = min_edge / 600
        game.translate = {(love.graphics.getWidth() - (800 * game.scaling)) / 2, 0}
    else
        game.scaling = love.graphics.getWidth() / 800
    end

    game.font = love.graphics.newFont( "assets/veramono.ttf", 12 )
    game.font:setFilter( "nearest", "nearest" )

    -- Load images
    game.conveyorSprites = love.graphics.newImage("assets/conveyor.png")
    game.entrySprites = love.graphics.newImage("assets/entry.png")

    game.goalSprites = {
        blue = love.graphics.newImage("assets/goal_blue.png"),
        red = love.graphics.newImage("assets/goal_red.png"),
        inactive = love.graphics.newImage("assets/goal_inactive.png")
    }

    game.sprites[1] = love.graphics.newImage("assets/floor.png")
    game.sprites[2] = love.graphics.newImage("assets/wall_top.png")
    game.sprites[7] = love.graphics.newImage("assets/wall_bottom.png")
    game.sprites[8] = love.graphics.newImage("assets/wall_left_top.png")
    game.sprites[3] = love.graphics.newImage("assets/wall_left_bottom.png")
    game.sprites[4] = love.graphics.newImage("assets/floor_left.png")
    game.sprites[9] = love.graphics.newImage("assets/floor_right.png")
    game.sprites[10] = love.graphics.newImage("assets/wall_right_top.png")
    game.sprites[11] = love.graphics.newImage("assets/wall_right_bottom.png")
    game.sprites[12] = love.graphics.newImage("assets/goal_box_inactive.png")
    game.sprites[13] = love.graphics.newImage("assets/goal_box_active.png")
    game.sprites[14] = love.graphics.newImage("assets/goal_box_wire.png")

    game.packageSprites = {}
    game.packageSprites[1] = love.graphics.newImage("assets/package.png")
    game.packageSprites[2] = love.graphics.newImage("assets/package_2.png")
    --game.packageSprites[3] = love.graphics.newImage("assets/package_3.png")

    game.heartSprite = love.graphics.newImage("assets/heart.png")

    game.deliveredSound = love.audio.newSource("assets/delivered.wav", "static")
    game.wrongSound = love.audio.newSource("assets/wrong.wav", "static")
end

function game:enter()
    love.graphics.setBackgroundColor(game.backgroundColor)
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    game.packages = {}
    game.score = 0
    game.lives = 5
    game.paused = false
    game.gameOver = false

    game.conveyors = {}
    table.insert(game.conveyors, Conveyor(3, 4, "south"))
    table.insert(game.conveyors, Conveyor(3, 8, "south"))
    table.insert(game.conveyors, Conveyor(3, 12, "south"))
    table.insert(game.conveyors, Conveyor(3, 16, "south"))
    table.insert(game.conveyors, Conveyor(3, 20, "south"))

    -- Set all conveyors as "fixed"
    for c=1,#game.conveyors,1 do
        game.conveyors[c]:setFixed(true)
    end

    game.entries = {}
    table.insert(game.entries, Entry(2, 4, false, 2))
    table.insert(game.entries, Entry(2, 8, false, 2))
    table.insert(game.entries, Entry(2, 12, false, 2))
    table.insert(game.entries, Entry(2, 16, false, 2))
    table.insert(game.entries, Entry(2, 20, false, 2))

    game.goals = {}
    table.insert(game.goals, Goal(5, 22, "red", false))
    table.insert(game.goals, Goal(10, 22, "blue", false))
    table.insert(game.goals, Goal(15, 22, "blue", false))

    game.waveController = WaveController()
    game.waveController:start()

end

function game:update(dt)

    if game.paused == false then
        if game.lives < 1 then
            game.doGameOver()
        end

        for p=#game.packages,1,-1 do 
            game.packages[p]:move(dt, p)

            if game.packages[p].shouldDelete then
                table.remove(game.packages, p)
            end
        end

        game.waveController:update(dt)

        for e=1,#game.entries,1 do
            game.entries[e]:update(dt)
        end
        
        for c=1,#game.conveyors,1 do
            game.conveyors[c]:update(dt)
        end

        for g=1,#game.goals,1 do
            game.goals[g]:update(dt)
        end

    end
end

function game.doGameOver()
    game.paused = true
    game.gameOver = true
end

function game:keyreleased(key)
    if key == "escape" then
        love.event.quit()
    end

    if game.gameOver and key == "space" then
        Gamestate.switch(game)
    end
end

function game:mousemoved(x, y)
    pos = game.getGridPosition((x - game.translate[1]) / game.scaling, (y - game.translateY * game.scaling - game.translate[2]) / game.scaling)

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

function game:mousepressed()
    game.dragStart = game.mouseOver
end

function game:mousereleased(x, y, button)
    if game.mouseOver ~= nil then
        -- If dragging then create that conveyor
        if game.dragStart ~= nil and (game.mouseOver.row ~= game.dragStart.row or game.mouseOver.col ~= game.dragStart.col) then
            st = game.dragStart
            en = game.mouseOver

            if math.abs(st.row - en.row) > math.abs(st.col - en.col) then
                direction = "south"
                step = 1

                begin = st.row
                to = en.row

                if to < begin then
                    step = -1
                    direction = "north"
                end

                col = st.col
                
                for row=begin,to,step do
                    -- Check if conveyor already there, if so remove
                    local conveyorIndex = game.getConveyorIndex(row, col)
                    if conveyorIndex ~= nil and game.conveyors[conveyorIndex].fixed == false then 
                        table.remove(game.conveyors, conveyorIndex) 
                    end
                    
                    if button == 1 and game.isConveyorPositionValid(row, col) then
                        table.insert(game.conveyors, Conveyor(row, col, direction))
                    end
                end
            else
                direction = "east"
                step = 1

                begin = st.col
                to = en.col

                if to < begin then
                    step = -1
                    direction = "west"
                end

                row = st.row
                
                for col=begin,to,step do
                    -- Check if conveyor already there, if so remove
                    local conveyorIndex = game.getConveyorIndex(row, col)
                    if conveyorIndex ~= nil and game.conveyors[conveyorIndex].fixed == false then 
                        table.remove(game.conveyors, conveyorIndex) 
                    end
                    
                    if button == 1 and game.isConveyorPositionValid(row, col) then
                        table.insert(game.conveyors, Conveyor(row, col, direction))
                    end
                end
            end
        else
            -- Find if conveyor under mouse
            local conveyorIndex = game.getConveyorIndex(game.mouseOver.row, game.mouseOver.col)
            
            if conveyorIndex == nil or game.conveyors[conveyorIndex].fixed == false then
                if button == 2 then
                    if conveyorIndex ~= nil then
                        table.remove(game.conveyors, conveyorIndex)
                    end 
                else
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
        end
    end
    game.dragStart = nil
end

function game:draw()
    -- Scale and move the window
    love.graphics.translate(game.translate[1], game.translate[2])
    love.graphics.scale(game.scaling)
    
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(game.font)
    love.graphics.print("Score: " .. game.score, 5, 5, 0, 2)
    --love.graphics.print("Lives: " .. game.lives, 0, 26, 0, 2)
    love.graphics.printf("Wave: " .. game.waveController.wave, 0, 28, 736 / 2, "right", 0, 2)

    -- Draw hearts for lives
    local current_x = 6
    for l=1,game.lives,1 do
        love.graphics.draw(game.heartSprite, current_x, 32)
        current_x = current_x + 22
    end
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
        
        if game.dragStart == nil or (game.dragStart.row == game.mouseOver.row and game.dragStart.col == game.mouseOver.col) then
            love.graphics.polygon("line", game.getQuad(game.mouseOver.row, game.mouseOver.col))
        else
            -- Find if drag should be horizontal or vertical
            startQuad = game.getQuad(game.dragStart.row, game.dragStart.col)
            endQuad = game.getQuad(game.mouseOver.row, game.mouseOver.col)
            
            if math.abs(game.dragStart.row - game.mouseOver.row) > math.abs(game.dragStart.col - game.mouseOver.col) then
                if game.dragStart.row > game.mouseOver.row then
                    love.graphics.polygon("line", startQuad[1], endQuad[2], startQuad[3], endQuad[4], startQuad[5], startQuad[6], startQuad[7], startQuad[8])
                else
                    love.graphics.polygon("line", startQuad[1], startQuad[2], startQuad[3], startQuad[4], startQuad[5], endQuad[6], startQuad[7], endQuad[8])
                end
            else
                if game.dragStart.col > game.mouseOver.col then
                    love.graphics.polygon("line", endQuad[1], startQuad[2], startQuad[3], startQuad[4], startQuad[5], startQuad[6], endQuad[7], startQuad[8])
                else
                    love.graphics.polygon("line", startQuad[1], startQuad[2], endQuad[3], startQuad[4], endQuad[5], startQuad[6], startQuad[7], startQuad[8])
                end
            end
        end
    end

    if game.gameOver then
        love.graphics.setColor(50, 50, 50)
        love.graphics.printf("Game over!", 0, 203, 800/3, "center", 0, 3)
        love.graphics.printf("Press to space to restart.", 0, 253, 800/1.5, "center", 0, 1.5)
        
        love.graphics.setColor(255, 255, 255)
        love.graphics.printf("Game over!", 0, 200, 800/3, "center", 0, 3)
        love.graphics.printf("Press to space to restart.", 0, 250, 800/1.5, "center", 0, 1.5)
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

function game.isPackageNear(package, x, y)
    for p=1,#game.packages,1 do
       if p ~= package then
            x2 = game.packages[p].x
            y2 = game.packages[p].y

            dist = math.sqrt((x - x2) ^ 2 + (y - y2) ^ 2)
            if dist < 14 then
                return true
            end
        end
    end
    return false
end

function game.isSquareEmpty(exclude_package, x, y)
    local pos = game.getGridPosition(x, y)

    for p=1,#game.packages,1 do
        if p ~= exclude_package then
            local pos2 = game.getGridPosition(game.packages[p].x, game.packages[p].y)

            if pos.col == pos2.col and pos.row == pos2.row then
                return false
            end
        end
    end

    return true
end
