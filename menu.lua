
require "game"

menu = {
    scaling = 1,
    translate = {0, 0},
}

function menu:init()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setFullscreen(true)
   
    -- Work out scaling factor
    min_edge = love.graphics.getHeight()
    
    if min_edge < love.graphics.getWidth() then
        menu.scaling = min_edge / 600
        menu.translate = {(love.graphics.getWidth() - (800 * menu.scaling)) / 2, 0}
    else
        menu.scaling = love.graphics.getWidth() / 800
    end

    menu.image = love.graphics.newImage("assets/menu.png")
end

function menu:keyreleased(key)
    if key == "space" then
        Gamestate.switch(game)
    elseif key == "escape" then
        love.event.push("quit")
    end

end

function menu:draw()
    love.graphics.translate(menu.translate[1], menu.translate[2])
    love.graphics.scale(menu.scaling)
    love.graphics.draw(menu.image, 0, 0, 0, 1)
end
