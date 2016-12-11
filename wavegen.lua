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
    
    local max_events = math.floor(3 + (self.wave - 1) * 0.5)
    if max_events > 5 then max_events = 5 end

    local num_events = love.math.random(3, max_events)

    if self.wave == 1 then
        num_events = 1
    end

    for e=1,num_events, 1 do
        -- Choose which entries are open at this event
       
        local max_entries = math.floor(4 + self.wave * 0.25)
        if max_entries > 5 then max_entries = 5 end

        local min_entries = math.floor(2 + self.wave * 0.5)
        if min_entries > 3 then min_entries = 3 end

        local num_entries = love.math.random(3, max_entries)
       
        if self.wave == 1 then
            num_entries = 1
        end

        local chosen_entries = {}
        
        local try_again = false
        for i=1,num_entries,1 do
            local entry = love.math.random(1, #game.entries)
            try_again = false

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

        -- Generate conveyor speed
        local conveyorSpeed = 32

        if self.wave > 1 then 
            local max_speed = math.floor(32 + self.wave * 6.4)
            local min_speed = math.floor(32 + self.wave * 3.2)

            conveyorSpeed = love.math.random(min_speed, max_speed) 
        end

        -- Packages until end of event
        local max_until = 10 + (self.wave - 1) * 5
        if max_until > 40 then max_until = 40 end

        local min_until = 10

        if self.wave > 2 then
            min_until = math.floor(10 + self.wave * 2)

            if min_until > 20 then
                min_until = 20
            end
        end
        local until_next = love.math.random(10, max_until)
        
        table.insert(self.timeline, {until_next = until_next, entries = chosen_entries, conveyorSpeed = conveyorSpeed})

    end
end

function WaveController:scoreNeeded()
    return self.target_score - game.score
end

function WaveController:update(dt)
    if self.running == false then return end

    -- Start from end to make removing easier
    if game.score == self.target_score then
        -- Check if moving onto next wave
        if #self.timeline == 0 then
            self.wave = self.wave + 1
            
            self:generateTimeline()
            self:start()

            game.waveMessage = "Wave " .. self.wave
            game.waveOpacity = game.waveOpacityStart
        end

        next_event = self.timeline[#self.timeline]
    
        -- Setup trigger for next event
        self.target_score = game.score + next_event.until_next
        self.prev_score = game.score

        local has_blue = false
        local has_red = false

        game.conveyorSpeed = next_event.conveyorSpeed

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
        prev_chosen = nil
        also_chosen = nil
        
        while has_red or has_blue do
            chosen = love.math.random(#game.goals)
            
            if chosen ~= prev_chosen then
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
