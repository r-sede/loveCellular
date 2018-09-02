local rafUtils = {}

rafUtils.toZeroIndex = function(arr)
  local res = {}
  local i
  for i = 0, #arr do
    res[i] = arr[i + 1]
  end
  return res
end

rafUtils.camera = {x = 0, y = 0, speed = BLOCKSIZE * PPM, mag = 5, time = 0, shakeTime = 0.5, shake = false}
rafUtils.camera.keypressed = function(key)
  if key == "up" then
    rafUtils.camera.y = rafUtils.camera.y + rafUtils.camera.speed
  end
  if key == "down" then
    rafUtils.camera.y = rafUtils.camera.y - rafUtils.camera.speed
  end
  if key == "right" then
    rafUtils.camera.x = rafUtils.camera.x - rafUtils.camera.speed
  end
  if key == "left" then
    rafUtils.camera.x = rafUtils.camera.x + rafUtils.camera.speed
  end
end

rafUtils.clamp = function(val, min, max)
  return math.min(math.max(val, min), max)
end

rafUtils.round = function(val)
  local floor = math.floor(val)
  if (val % 1 >= 0.5) then
    return floor + 1
  end
  return floor
end
rafUtils.lerp = function(a, b, t)
  return a + (b - a) * t
end
rafUtils.camera.lookAt = function(x, y)
  if x < 2 or x > #terrain[0] - 2 or y < 2 or y > #terrain - 2 then
    rafUtils.camera.x = x * PPM * BLOCKSIZE - WTWIDTH * 0.5 * PPM * BLOCKSIZE
    rafUtils.camera.y = y * PPM * BLOCKSIZE - WTHEIGHT * 0.5 * PPM * BLOCKSIZE
  else
    rafUtils.camera.x =
      rafUtils.lerp(rafUtils.camera.x, x * PPM * BLOCKSIZE - WTWIDTH * 0.5 * PPM * BLOCKSIZE, 0.05 * 0.25 * PPM)
    rafUtils.camera.y =
      rafUtils.lerp(rafUtils.camera.y, y * PPM * BLOCKSIZE - WTHEIGHT * 0.5 * PPM * BLOCKSIZE, 0.05 * 0.25 * PPM)
  end
  rafUtils.camera.x = rafUtils.clamp(rafUtils.camera.x, 0, (WORLDWIDTH * PPM * BLOCKSIZE) - (WTWIDTH * PPM * BLOCKSIZE))
  rafUtils.camera.y =
    rafUtils.clamp(rafUtils.camera.y, 0, (WORLDHEIGHT * PPM * BLOCKSIZE) - (WTHEIGHT * PPM * BLOCKSIZE))
end

rafUtils.isCollide = function(ent1, ent2)
  return ent1.x < ent2.x + ent2.width and ent1.x + ent1.width > ent2.x and ent1.y < ent2.y + ent2.height and
    ent1.height + ent1.y > ent2.y
end

rafUtils.distance = function(x1, y1, x2, y2)
  return math.abs(math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2))
end

rafUtils.isCollideRec = function(x1, y1, width1, height1, x2, y2, width2, height2)
  -- print(x1, y1, width1, height1, x2, y2, width2, height2)
  return x1 < x2 + width2 and x1 + width1 > x2 and y1 < y2 + height2 and height1 + y1 > y2
end

return rafUtils
