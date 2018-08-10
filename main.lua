local rafUtils = require"rafUtils"

function love.load(arg)

end

function love.update(dt)
end

function love.draw()
end

function love.keypressed(key)
  rafUtils.camera.keypressed(key)
end