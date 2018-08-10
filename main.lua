PPM = 1 -- scale
BLOCKSIZE = 16
local WTWIDTH = 64 -- number of blocks on screen along x
local WTHEIGHT = 45 -- number of blocks on screen along y
local WORLDWIDTH = 50 -- width of world in block
local WORLDHEIGHT = 50 -- height of world in block
local SWIDTH = WTWIDTH * BLOCKSIZE * PPM -- screen width in pixels
local SHEIGHT = WTHEIGHT * BLOCKSIZE * PPM -- screen height in pixels
local TILES = nil
local ATLAS = nil

local rafUtils = require"rafUtils"
local terrain = nil
local rRockCells = 0.5
local nIter = 3
local neighBorHoodThres = 5

function love.load(arg)
  love.graphics.setDefaultFilter('nearest')
  love.keyboard.setKeyRepeat(true)
  love.window.setMode(SWIDTH, SHEIGHT)
  love.window.setTitle('loveCellular')
  
  love.math.setRandomSeed(love.timer.getTime())
end

function love.update(dt)
end

function love.draw()
end

function love.keypressed(key)
  if key == 'escape' then love.event.quit() end
  rafUtils.camera.keypressed(key)
end