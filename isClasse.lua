isClasse = {
	new =
		function ()

			local o = {}

				function o:isGameOver()
					if pontos < 0 then
						return true
					else
						return false
					end
				end

				function o:isMeteorosEmpty (meteoros)
					if next (meteoros) == nil then
						if onda%4==0 then
							maxSpeed = maxSpeed + 5
							minSpeed = minSpeed + 3
							alturaMaxima = alturaMaxima + 50
							alturaMinima = alturaMinima + 15
						end
						inicio = inicio + 2
						onda = onda + 1

						objSpawn:spawnaMeteoro()

						o:isDivisivel()
					end
				end

				function o:isDivisivel()
					if onda == ondaDrop then
						objSpawn:spawnDrop()
						ondaDrop = ondaDrop + somaDrop
						somaDrop = somaDrop + 1

						if somaDrop > 17 then
							somaDrop = 10
						end
					end
				end

				function o:isDropTrue(variavel, startTime)
					if variavel then
						return (30 - (math.floor(love.timer.getTime() - startTime)))
					end
				end

			return o;
		end
}
