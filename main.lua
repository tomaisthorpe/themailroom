Gamestate = require "hump.gamestate"

require "game"

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(game)
end

function setupWindow()
    love.window.setMode(800,600)
end
