Class = require "hump.class"

local WaveController = Class{
    init = function(self)
        self.wave = 0 -- Automatically increases to 1 on start
        self.running = false
    end,
    timeline = {}
}

function WaveController:start()
    self.running = true
    self.prev_score = game.score
    self.target_score = game.score
end

function WaveController:generateTimeline()
    -- First decide which entries should be open
    
    local num_events = 3

    for e=1,num_events, 1 do
        -- Choose which entries are open at this event
        
        local num_entries = love.math.random(1, 3)
        
        local chosen_entries = {}
        
        local try_again = false
        for i=1,num_entries,1 do
            entry = love.math.random(1, #game.entries)
            
            -- Make sure not already in chosen
            for j=1,#chosen_entries,1 do
                if chosen_entries[j] == entry then
                    try_again = true
                    i = i - 1
                end
            end
            if try_again == false then
                table.insert(chosen_entries, entry)
            end
        end

        -- Packages until end of event
        local until_next = love.math.random(10, 20)
        until_next = 5
        table.insert(self.timeline, {until_next = until_next, entries = chosen_entries})

    end
end

function WaveController:scoreNeeded()
    print(self.target_score)
    return self.target_score - game.score
end

function WaveController:update(dt)
    if self.running == false then return end

    -- Start from end to make removing easier
    if game.score == self.target_score then
        -- Check if moving onto next wave
        if #self.timeline == 0 then
            self:generateTimeline()
            self.wave = self.wave + 1

            self:start()
        end

        next_event = self.timeline[#self.timeline]
    
        -- Setup trigger for next event
        self.target_score = game.score + next_event.until_next
        self.prev_score = game.score

        local has_blue = false
        local has_red = false

        -- Activate/De-activate entries
        for e=1,#game.entries,1 do
            local found = false
            for f=1,#next_event.entries,1 do
                if e == next_event.entries[f] then
                    found = true
                end
            end

            game.entries[e]:setActive(found)
    
            -- If set to active, need a color
            if found then
               local color = love.math.random(2)

               if color == 1 then
                   game.entries[e]:setColor("red")
                   has_red = true
                else
                    game.entries[e]:setColor("blue")
                    has_blue = true
                end
            end
        end

        -- Setup the goal points
        goal_count = 1
        if has_blue and has_red then goal_count = 2 end

        prev_chosen = nil
        also_chosen = nil

        for i=1,goal_count,1 do
            chosen = love.math.random(#game.goals)

            if chosen == prev_chosen then
                i = i - 1
            else
                game.goals[chosen]:setActive(true)
                
                if has_blue then
                    game.goals[chosen]:setColor("blue")
                    has_blue = false
                elseif has_red then
                    game.goals[chosen]:setColor("red")
                    has_red = false
                end

                if prev_chosen == nil then
                    prev_chosen = chosen
                else
                    also_chosen = chosen
                end  
            end
        end

        for g=1,#game.goals,1 do
            if g ~= prev_chosen and g ~= also_chosen then
                game.goals[g]:setActive(false)
            end
        end


 
        -- remove this event from timeline
        table.remove(self.timeline, #self.timeline)
    end
end

return WaveController
