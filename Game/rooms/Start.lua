local Start = Object:extend()

function Start:new()
    self.area = Area(self)
    self.timer = Timer()
    self.room_canvas = love.graphics.newCanvas(gw, gh)

    self.demoFont = love.graphics.newFont(40)

    self.name = 'start'

    self.scale = {
        x = 0,
        y = 0
    }
    self.r = 0
    self.a = 0

    self.canvasPos = {
        x = 0,
        y = 0
    }

    self.timer:tween(0.5, self, {r = 6 * math.pi, a = 1}, 'in-out-cubic')
    self.timer:tween(0.5, self.scale, {x = 1, y = 1}, 'in-out-cubic')

    self.out = false

end

function Start:update(dt)
    -- this keeps the camera centered after shake
    camera.smoother = Camera.smooth.damped(5)
    camera:lockPosition(dt, gw/2, gh/2)
    if self.timer then self.timer:update(dt) end
    
    self.area:update(dt)

    if input:pressed('drink') then
        self:transitionOut()
    end
end

function Start:transitionOut()
    if self.out then return end

    self.out = true

    self.timer:tween(0.3, self.canvasPos, {x = -gw}, 'in-out-cubic',
    function() 
        gotoRoom('Play')
    end)

end

--[[
    Creates a canvas with the game resolution and resizes it to fit the scale
]]
function Start:draw()
    love.graphics.setCanvas(self.room_canvas)
    love.graphics.clear()
    camera:attach(0, 0, gw, gh)
        self.area:draw()
        love.graphics.setColor(1, 1, 1, self.a)
        love.graphics.setFont(fonts.qilka)
        printInsideRect("Click to start!", fonts.qilka, "bottom", 20)
        love.graphics.draw(sprites.title, gw / 2, (gh/ 2) - 30, self.r,  self.scale.x, self.scale.y, sprites.title:getWidth() / 2, sprites.title:getHeight() / 2)
  	camera:detach()
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.room_canvas, self.canvasPos.x, self.canvasPos.y, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
end

return Start