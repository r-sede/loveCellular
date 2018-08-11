local rafUtils = {}

rafUtils.toZeroIndex = function (arr)
  local res = {}
  local i
  for i = 0,#arr do
    res[i] = arr[i+1]
  end
  return res
end

rafUtils.camera = {x=0, y=0, speed=BLOCKSIZE*PPM}
rafUtils.camera.keypressed = function (key)
  if key == 'up' then rafUtils.camera.y = rafUtils.camera.y + rafUtils.camera.speed end
  if key == 'down' then rafUtils.camera.y = rafUtils.camera.y - rafUtils.camera.speed end
  if key == 'right' then rafUtils.camera.x = rafUtils.camera.x - rafUtils.camera.speed end
  if key == 'left' then rafUtils.camera.x = rafUtils.camera.x + rafUtils.camera.speed end
end



return rafUtils