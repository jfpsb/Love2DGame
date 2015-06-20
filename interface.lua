interface = {
	new =
	function ()

	local o = {}

		--menu
		function o:menu()
			love.graphics.draw(playImg, (screen_width - playImg:getWidth())/3, (screen_height - playImg:getHeight())/2)
			love.graphics.draw(exitImg, 2*(screen_width - playImg:getWidth())/3, (screen_height - playImg:getHeight())/2, 0, 2, 2)

			x, y = love.mouse.getPosition()
			if CheckCollision((screen_width - playImg:getWidth())/3, (screen_height - playImg:getHeight())/2, playImg:getWidth(), playImg:getHeight(), x, y, 1, 1) then
				if love.mouse.isDown("l") then
					play = true
					objSpawn:spawnaMeteoro()
				end
			end

			if CheckCollision(2*(screen_width - playImg:getWidth())/3, (screen_height - playImg:getHeight())/2, exitImg:getWidth(), exitImg:getHeight(), x, y, 1, 1) then
				if love.mouse.isDown("l") then
					love.event.push ("quit")
				end
			end
		end

		function o:gameover()

			love.graphics.setColor(255, 255, 255)

			love.graphics.rectangle("fill", 0, 0, screen_width, screen_height)
			love.graphics.draw(gameoverImg, (screen_width - gameoverImg:getWidth())/2, 50)
			love.graphics.draw(exitMenu, (screen_width - exitMenu:getWidth()), screen_height - exitMenu:getHeight())
			love.graphics.draw(balaDisp, screen_width/5 - balaDisp:getWidth()/2, screen_height * 0.3, 0, 1, 1)
			love.graphics.draw(meteoroDownImg, (screen_width - meteoroDownImg:getWidth())/2, screen_height * 0.3, 0, 1, 1)
			love.graphics.draw(meteoroPerdidoImg,(3/2)*(screen_width/2) - meteoroPerdidoImg:getWidth()/2, screen_height * 0.3, 0, 1, 1)
			love.graphics.draw(colisaoImg, screen_width/5 - colisaoImg:getWidth()/2, screen_height * 0.5, 0, 1, 1)
			love.graphics.draw(precisaoImg, (screen_width -  precisaoImg:getWidth())/2, screen_height * 0.5, 0, 1, 1)
			love.graphics.draw(dropsAdquiridos, (3/2)*(screen_width/2) - dropsAdquiridos:getWidth()/2, screen_height * 0.5, 0, 1, 1)
			love.graphics.setColor(0, 0, 0)
			love.graphics.print(shotsFired, screen_width/5 + balaDisp:getWidth()/2, screen_height * 0.3 + balaDisp:getHeight()/4, 0, 3, 3)
			love.graphics.print(meteorosDown, screen_width/2 + meteoroDownImg:getWidth()/2, (screen_height * 0.3) + (meteoroDownImg:getHeight()/4), 0, 3, 3)
			love.graphics.print(meteorosLost, (3/2)*(screen_width/2) + meteoroPerdidoImg:getWidth()/2, (screen_height * 0.3) + (meteoroPerdidoImg:getHeight()/4), 0, 3, 3)
			love.graphics.print(hitCount, screen_width/5 + colisaoImg:getWidth()/2, (screen_height * 0.5) + colisaoImg:getHeight()/4, 0, 3, 3)
			love.graphics.print(numDrops, (3/2)*(screen_width/2) + dropsAdquiridos:getWidth()/2, (screen_height * 0.5) + dropsAdquiridos:getHeight()/4, 0, 3, 3)

			if shotsFired == 0 then
				precisao = 0
			else
				precisao = meteorosDown/shotsFired
			end

			MatchTime = math.floor(endTime - startMatchTime)

			if MatchTime > 60 then
				minut = math.floor(MatchTime/60)
				seg = math.floor(MatchTime%60)
				love.graphics.printf("Voce sobreviveu " .. minut .. " minuto(s) e " .. seg .. " segundos.", 0, screen_height * 0.8, screen_width/2, "center", 0, 2, 2)
			else
				minut = 0
				seg = MatchTime
				love.graphics.printf("Voce sobreviveu " .. seg .. " segundos.", 0, screen_height * 0.8, screen_width/2, "center", 0, 2, 2)
			end

			love.graphics.print((math.floor(precisao*100)) .. "%", screen_width/2 + precisaoImg:getWidth()/2, (screen_height * 0.5) + precisaoImg:getHeight()/4, 0, 3, 3)
			love.graphics.setColor(255, 255, 255)

			x, y = love.mouse.getPosition()

			if CheckCollision((screen_width - exitMenu:getWidth()), screen_height - exitMenu:getHeight(), exitMenu:getWidth(), exitMenu:getHeight(), x, y, 1, 1) then
				if love.mouse.isDown("l") then
					iniciaValores()
				end
			end
		end

		function o:desenhaFundo()
			love.graphics.draw(spaceImg, (screen_width - spaceImg:getWidth())/2, 0, 0, 1, 1)
			love.graphics.draw(spaceImg, -(screen_width - spaceImg:getWidth())/2, 0, 0, 1, 1)
			love.graphics.draw(spaceImg, 2*(screen_width - spaceImg:getWidth())/2, 0, 0, 1, 1)
		end

		function o:pausa()
			love.graphics.draw(pausaImg, (screen_width - pausaImg:getWidth())/2, screen_height/3 - pausaImg:getHeight()/2)
			love.graphics.draw(exitMenu, (screen_width - exitMenu:getWidth())/2, screen_height/2 + exitMenu:getHeight())

			x, y = love.mouse.getPosition()

			if CheckCollision((screen_width - exitMenu:getWidth())/2, screen_height/2 + exitMenu:getHeight(), exitMenu:getWidth(), exitMenu:getHeight(), x, y, 1, 1) then
				if love.mouse.isDown("l") then
					pontos = -1
					objInterface:gameover()
				end
			end
		end

		function o:printHUD()
			love.graphics.print("BETA", 0, 0)
			love.graphics.draw(meteorosRestantesImg, screen_width - meteorosRestantesImg:getWidth() - (screen_width * 0.05), 0)
			love.graphics.print(#meteoros, screen_width - (screen_width * 0.05), meteorosRestantesImg:getHeight()/2 - 20, 0, 3, 3)
			love.graphics.draw(ondaImg, screen_width - ondaImg:getWidth() - (screen_width * 0.05), meteorosRestantesImg:getHeight())
			love.graphics.print(onda, screen_width - (screen_width * 0.05), meteorosRestantesImg:getHeight() + (ondaImg:getHeight()/2) - 20, 0, 3, 3)

			if fullMetalJacket and FMJTimeLeft >= 0 then
				love.graphics.draw(FMJIcon, 0, screen_height - FMJIcon:getHeight())
				love.graphics.print(FMJTimeLeft, FMJIcon:getWidth(), screen_height - FMJIcon:getHeight() + 25, 0, 2, 2)
			else
				fullMetalJacket = false
			end

			if slowMo and SlowMoTimeLeft >= 0 then
				love.graphics.draw(slowMoIcon, 0, screen_height - FMJIcon:getHeight() - slowMoIcon:getHeight())
				love.graphics.print(SlowMoTimeLeft, slowMoIcon:getWidth(), screen_height - FMJIcon:getHeight() - slowMoIcon:getHeight()/2, 0, 2, 2)
			else
				slowMo = false
			end

			if doublePoints and DPTimeLeft >= 0 then
				love.graphics.draw(doublePointsIcon, 0, screen_height - FMJIcon:getHeight() - slowMoIcon:getHeight() - doublePointsIcon:getHeight())
				love.graphics.print(DPTimeLeft, doublePointsIcon:getWidth(), screen_height - FMJIcon:getHeight() - slowMoIcon:getHeight() - doublePointsIcon:getHeight()/2, 0, 2, 2)
			else
				doublePoints = false
			end
		end

		return o;
	end
}
