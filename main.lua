PPM = 1 -- scale
BLOCKSIZE = 8
local WTWIDTH = 64*2 -- number of blocks on screen along x
local WTHEIGHT = 45*2 -- number of blocks on screen along y
local WORLDWIDTH = 500 -- width of world in block
local WORLDHEIGHT = 500 -- height of world in block
local SWIDTH = WTWIDTH * BLOCKSIZE * PPM -- screen width in pixels
local SHEIGHT = WTHEIGHT * BLOCKSIZE * PPM -- screen height in pixels
local TILES = nil
local ATLAS = nil
local SEED = nil

local rafUtils = require"rafUtils"
local terrain = nil
local rRockCells = 0.5
local nIter =3
local startIter = 3
local neighBorHoodThres = 5
local terrain = nil

function love.load(arg)
  love.graphics.setDefaultFilter('nearest')
  love.keyboard.setKeyRepeat(true)
  love.window.setMode(SWIDTH, SHEIGHT)
  love.window.setTitle('loveCellular')
  
  SEED = love.timer.getTime()
  love.math.setRandomSeed(SEED)
  terrain = createRandTerrain(WORLDWIDTH,WORLDHEIGHT)
  terrain = iterCellular(terrain)
  terrain = createWall(terrain)

end

function love.update(dt)
end

function love.draw()
  for yy=0,#terrain do
    for xx=0,#terrain[yy] do
      if terrain[yy][xx] == 1 then
        love.graphics.rectangle('fill',
        xx*BLOCKSIZE*PPM - rafUtils.camera.x, yy*BLOCKSIZE*PPM - rafUtils.camera.y,
        BLOCKSIZE*PPM, BLOCKSIZE*PPM)
      elseif terrain[yy][xx] == 2 then
        love.graphics.setColor(1,0,0,1)
        love.graphics.rectangle('fill',
        xx*BLOCKSIZE*PPM - rafUtils.camera.x, yy*BLOCKSIZE*PPM - rafUtils.camera.y,
        BLOCKSIZE*PPM, BLOCKSIZE*PPM)
        love.graphics.setColor(1,1,1,1)
      end
    end
  end
  love.graphics.print(startIter,0,0)
end

function love.keypressed (key)
  if key == 'escape' then love.event.quit() end
  if key == 'return' then
    print(SEED)
    nIter=startIter
    love.math.setRandomSeed(SEED)
    terrain = createRandTerrain(WORLDWIDTH,WORLDHEIGHT)
    terrain = iterCellular(terrain)
    terrain = createWall(terrain)
  end
  rafUtils.camera.keypressed(key)
end

function love.wheelmoved(a,dir)
  startIter = startIter + dir
  if startIter < 1 then startIter = 1 end
end

---------------------------------
function createRandTerrain (width, height)
  local terrain,xx,yy = {},0,0

  for yy=0,height-1 do
    terrain[yy] = {}
    for xx=0,width-1 do
      terrain[yy][xx] = love.math.random() < rRockCells and 1 or 0
      
    end
  end

  return terrain
end

function iterCellular(terrain)
  local tmp = {}

  for yy=0,#terrain do
    tmp[yy] = {}
    for xx=0,#terrain[yy] do
      local l = terrain[yy]                   [(xx-1)%(#terrain[yy]+1)]
      local lu = terrain[(yy-1)%(#terrain+1)] [(xx-1)%(#terrain[yy]+1)]
      local u = terrain[(yy-1)%(#terrain+1)]  [xx]
      local ru = terrain[(yy-1)%(#terrain+1)] [(xx+1)%(#terrain[yy]+1)]
      local r = terrain[yy]                   [(xx+1)%(#terrain[yy]+1)]
      local rd = terrain[(yy+1)%(#terrain+1)] [(xx+1)%(#terrain[yy]+1)]
      local d = terrain[(yy+1)%(#terrain+1)]  [xx]
      local ld = terrain[(yy+1)%(#terrain+1)]  [(xx-1)%(#terrain[yy]+1)]
      -- local neighBorSum = l+lu+u+ru+r+rd+d
      local neighBorSum = 0
      if l == 0 then neighBorSum = neighBorSum + 1 end
      if lu == 0 then neighBorSum = neighBorSum + 1 end
      if u == 0 then neighBorSum = neighBorSum + 1 end
      if ru == 0 then neighBorSum = neighBorSum + 1 end
      if r == 0 then neighBorSum = neighBorSum + 1 end
      if rd == 0 then neighBorSum = neighBorSum + 1 end
      if d == 0 then neighBorSum = neighBorSum + 1 end
      if ld == 0 then neighBorSum = neighBorSum + 1 end
      -- tmp[yy][xx] = neighBorSum >= neighBorHoodThres and 1 or 0
      if neighBorSum >= neighBorHoodThres then tmp[yy][xx]=1 else tmp[yy][xx]=0 end
    end
  end

  nIter = nIter - 1
  print(nIter)
  if nIter == 0 then return tmp else return iterCellular(tmp) end
end

function createWall(terrain)
  local tmp = {}
  for yy=0,#terrain do
    tmp[yy] = {}
    for xx=0,#terrain[yy] do
      if terrain[yy][xx] == 0 then
        local l = terrain[yy]                   [(xx-1)%(#terrain[yy]+1)]
        local lu = terrain[(yy-1)%(#terrain+1)] [(xx-1)%(#terrain[yy]+1)]
        local u = terrain[(yy-1)%(#terrain+1)]  [xx]
        local ru = terrain[(yy-1)%(#terrain+1)] [(xx+1)%(#terrain[yy]+1)]
        local r = terrain[yy]                   [(xx+1)%(#terrain[yy]+1)]
        local rd = terrain[(yy+1)%(#terrain+1)] [(xx+1)%(#terrain[yy]+1)]
        local d = terrain[(yy+1)%(#terrain+1)]  [xx]
        local ld = terrain[(yy+1)%(#terrain+1)]  [(xx-1)%(#terrain[yy]+1)]
        -- local neighBorSum = l+lu+u+ru+r+rd+d
        local neighBorSum = 0
        if l == 1 then neighBorSum = neighBorSum + 1 end
        if lu == 1 then neighBorSum = neighBorSum + 1 end
        if u == 1 then neighBorSum = neighBorSum + 1 end
        if ru == 1 then neighBorSum = neighBorSum + 1 end
        if r == 1 then neighBorSum = neighBorSum + 1 end
        if rd == 1 then neighBorSum = neighBorSum + 1 end
        if d == 1 then neighBorSum = neighBorSum + 1 end
        if ld == 1 then neighBorSum = neighBorSum + 1 end
        -- tmp[yy][xx] = neighBorSum >= neighBorHoodThres and 1 or 0
        if neighBorSum >= 1 then tmp[yy][xx]=2 else tmp[yy][xx] = terrain[yy][xx] end
      else tmp[yy][xx] = terrain[yy][xx]
      end
    end
  end
  return tmp
end