Object = require 'libraries/classic/classic'
Input = require 'libraries/boipushy/Input'
Timer = require 'libraries/EnhancedTimer/EnhancedTimer'
M = require "libraries/Moses/moses"
Camera = require 'libraries/hump/camera'
Vector = require 'libraries/hump/vector'
Physics = require 'libraries/windfield/windfield'
Draft = require 'libraries/draft/draft'
Anim8 = require 'libraries/anim8/anim8'
sti = require 'libraries/Simple-Tiled-Implementation/sti'

require 'libraries/utf8/utf8'
require 'globals'
require "utils"

function love.load()
    input = Input()
    timer = Timer()
    camera = Camera()
    draft = Draft()

    resize(0.667)

    GameObject = require("objects/GameObject")

    local object_files = {}
    recursiveEnumerate('objects', object_files)
    requireFiles(object_files)

    local room_files = {}
    recursiveEnumerate('rooms', room_files)
    requireFiles(room_files)
    current_room = nil

    slow_amount = 1

    flash_frames = nil

    sprites = {
        normalPearl = love.graphics.newImage("resources/sprites/normal.png"),
        hotPearl = love.graphics.newImage("resources/sprites/hot.png"),
        healPearl = love.graphics.newImage("resources/sprites/heal.png"),
        straw = love.graphics.newImage("resources/sprites/straw.png"),
        ice = love.graphics.newImage("resources/sprites/ice.png"),
        background = love.graphics.newImage("resources/sprites/background.png"),
        table = love.graphics.newImage("resources/sprites/table.png"),
        cup = love.graphics.newImage("resources/sprites/cup.png"),
        shadow = love.graphics.newImage("resources/sprites/shadow.png"),
        h4 = love.graphics.newImage("resources/sprites/h4.png"),
        h3 = love.graphics.newImage("resources/sprites/h3.png"),
        h2 = love.graphics.newImage("resources/sprites/h2.png"),
        h1 = love.graphics.newImage("resources/sprites/h1.png"),
        h0 = love.graphics.newImage("resources/sprites/h0.png"),
        liquid = love.graphics.newImage("resources/sprites/liquid.png"),
        progress = love.graphics.newImage("resources/sprites/progress.png"),
        progressIndicator = love.graphics.newImage("resources/sprites/progressIndicator.png"),
        instructions = love.graphics.newImage("resources/sprites/instructions.png"),
        title = love.graphics.newImage("resources/sprites/title.png"),
        ggj = love.graphics.newImage("resources/sprites/ggjv.png"),
        breakPearl = love.graphics.newImage("resources/sprites/break.png"),
        yummy = love.graphics.newImage("resources/sprites/yummy.png"),
        yuck = love.graphics.newImage("resources/sprites/yuck.png"),
    }

    sounds = {
        main = love.audio.newSource("resources/audio/main.mp3", "stream"),
        gameOver = love.audio.newSource("resources/audio/gameover.wav", "static"),
        loss = love.audio.newSource("resources/audio/loss.wav", "static"),
        normal = love.audio.newSource("resources/audio/normal.wav", "static"),
        hot = love.audio.newSource("resources/audio/hot.wav", "static"),
        heal = love.audio.newSource("resources/audio/heal.wav", "static"),
        complete = love.audio.newSource("resources/audio/complete.wav", "static"),
        iceBreak = love.audio.newSource("resources/audio/iceBreak.wav", "static"),
    }

    fonts = {
        qilka = love.graphics.newFont("resources/fonts/Qilkabold-DO6BR.otf", 60)
    }

    sounds.main:setLooping(true)
    sounds.main:setVolume(0.1)
    sounds.heal:setVolume(0.3)
    sounds.main:play()

    flashColor = {1,1,1,1}

    input:bind('mouse1', 'drink')
    input:bind('f2', 'shortcut')
    input:bind('escape', 'exit')
    input:bind('c', 'goToCredits')

    gotoRoom("Start")

    if debug then debugTools = DebugTools() end
end

function love.update(dt)
    if input:pressed('exit') then
        love.event.quit()
    end
    if input:pressed('goToCredits') then
        gotoRoom("Credits")
    end
    timer:update(dt*slow_amount)
    camera:update(dt*slow_amount)
    if current_room then
        --if current_room.name then print("updating "..current_room.name) end
         current_room:update(dt*slow_amount) 
        end
    if debug then debugTools:update(dt) end
end

function love.draw()
    love.graphics.draw(sprites.background, 0, 0, 0, sx, sy)
    if current_room then current_room:draw() end

    if flash_frames then 
        flash_frames = flash_frames - 1
        if flash_frames == -1 then flash_frames = nil end
    end
    if flash_frames then
        love.graphics.setColor(flashColor)
        love.graphics.rectangle('fill', 0, 0, sx*gw, sy*gh)
        love.graphics.setColor(1, 1, 1)
    end

    if debug then debugTools:draw() end
end

function love.keypressed(key)
end

function gotoRoom(room_type, ...)
    if current_room and current_room.destroy then current_room:destroy() end
    current_room = _G[room_type](...)
    --print(current_room.name)
end

--[[
    Stores all possible object files into a table
]]
function recursiveEnumerate(folder, file_list)
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
        local file = folder .. '/' .. item
        if love.filesystem.getInfo(file) then
            table.insert(file_list, file)
        elseif love.filesystem.isDirectory(file) then
            recursiveEnumerate(file, file_list)
        end
    end
end

--[[
    Imports files from a table
]]
function requireFiles(files)
    for _, file in ipairs(files) do
        local file = file:sub(1, -5)
        local className = file:match("([^/]+)$")
        if not _G[className] then
            _G[className] = require(file)
        end
    end
end

function resize(s)
    love.window.setMode(s*gw, s*gh) 
    sx, sy = s, s
end

function slow(amount, duration)
    slow_amount = amount
    timer:tween('slow', duration, _G, {slow_amount = 1}, 'in-out-cubic')
end

function flash(frames, color)
    flash_frames = frames
    flashColor = color or {1,1,1,0.5}
end

function checkGC()
    -- Counts how many of each object type exist in memory after garbage collection
    print("Before collection: " .. collectgarbage("count")/1024)
    collectgarbage()
    print("After collection: " .. collectgarbage("count")/1024)
    print("Object count: ")
    local counts = type_count()
    for k, v in pairs(counts) do print(k, v) end
    print("-------------------------------------")
end

function count_all(f)
    local seen = {}
    local count_table
    count_table = function(t)
        if seen[t] then return end
            f(t)
	    seen[t] = true
	    for k,v in pairs(t) do
	        if type(v) == "table" then
		    count_table(v)
	        elseif type(v) == "userdata" then
		    f(v)
	        end
	end
    end
    count_table(_G)
end

function type_count()
    local counts = {}
    local enumerate = function (o)
        local t = type_name(o)
        counts[t] = (counts[t] or 0) + 1
    end
    count_all(enumerate)
    return counts
end

global_type_table = nil
function type_name(o)
    if global_type_table == nil then
        global_type_table = {}
            for k,v in pairs(_G) do
	        global_type_table[v] = k
	    end
	global_type_table[0] = "table"
    end
    return global_type_table[getmetatable(o) or 0] or "Unknown"
end

function AddTestShortcuts()
    input:bind('f1', checkGC )
    input:bind('f3', function() debug = not debug end )
end