spawn = {
	new =
	function ()

		local o = {}

		function o:spawnaMeteoro ()
			for i=1, inicio do
				meteoro = {}
				math.randomseed(os.time() * i)
				meteoro.width = math.random(1, 3)
				meteoro.height = meteoro.width
				meteoro.x = math.random(naveImg:getWidth()/2, screen_width - naveImg:getWidth())
				meteoro.y = - (math.random(alturaMinima, alturaMaxima))
				meteoro.speed = math.random(minSpeed, maxSpeed)

				table.insert(meteoros, meteoro)
			end
		end

		function o:spawnDrop()
			drop = {}
			math.randomseed(os.time())
			drop.x = math.random(0, screen_width - dropImg:getWidth())
			drop.y = - (math.random(800, 1200))
			drop.speed = 100
			drop.tipo = math.random(1, 6)

			table.insert(drops, drop)
		end

		return o;

	end
}


