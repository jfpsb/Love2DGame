interface = {
	new =
	function ()

	local o = {}
	fundos = {}

		--menu
		function o:menu()
			love.graphics.draw(playImg, (screen_width - playImg:getWidth())/3, (screen_height - playImg:getHeight())/2)
			love.graphics.draw(exitImg, 2*(screen_width - playImg:getWidth())/3, (screen_height - playImg:getHeight())/2, 0, 2, 2)

			x, y = love.mouse.getPosition()
			if CheckCollision((screen_width - playImg:getWidth())/3, (screen_height - playImg:getHeight())/2, playImg:getWidth(), playImg:getHeight(), x, y, 1, 1) then
				if love.mouse.isDown("l") then
					play = true
					objIs:isMeteorosEmpty(meteoros)
				end
			end

			if CheckCollision(2*(screen_width - playImg:getWidth())/3, (screen_height - playImg:getHeight())/2, exitImg:getWidth(), exitImg:getHeight(), x, y, 1, 1) then
				if love.mouse.isDown("l") then
					love.event.push ("quit")
				end
			end
		end

		function o:gameover()

			borda = screen_height * 0.05

			vSpace = hf1:getHeight()/20


			love.graphics.rectangle("fill", 0, 0, screen_width, screen_height)
			love.graphics.draw(gameoverImg, (screen_width - gameoverImg:getWidth())/2, borda)
			love.graphics.draw(exitMenu, (screen_width - exitMenu:getWidth()), screen_height - exitMenu:getHeight())

			love.graphics.draw(hf1, screen_width/3 - hf1:getWidth()/2, gameoverImg:getHeight() + borda)
			love.graphics.draw(hf2, 2*(screen_width/3) - hf2:getWidth()/2, gameoverImg:getHeight() + borda)

			love.graphics.setColor(0, 0, 0)

			love.graphics.print(meteorosDown, screen_width/3 + hf1:getWidth()/2 + 15, gameoverImg:getHeight() + borda + 2*vSpace, 0, 2, 2)
			love.graphics.print(meteorosLost, screen_width/3 + hf1:getWidth()/2 + 15, gameoverImg:getHeight() + borda + 9*vSpace, 0, 2, 2)
			love.graphics.print(hitCount, screen_width/3 + hf1:getWidth()/2 + 15, gameoverImg:getHeight() + borda + 17*vSpace, 0, 2, 2)

			love.graphics.print(shotsFired, 2*(screen_width/3) + hf2:getWidth()/2 + 15, gameoverImg:getHeight() + borda + 2*vSpace, 0, 2, 2)

			if shotsFired == 0 then
				precisao = 0
			else
				precisao = meteorosDown/shotsFired
			end

			love.graphics.print((math.floor(precisao*100)) .. "%", 2*(screen_width/3) + hf2:getWidth()/2 + 15, gameoverImg:getHeight() + borda + 9*vSpace, 0, 2, 2)
			love.graphics.print(numDrops, 2*(screen_width/3) + hf2:getWidth()/2 + 15, gameoverImg:getHeight() + borda + 17*vSpace, 0, 2, 2)

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

			love.graphics.setColor(255, 255, 255)

			x, y = love.mouse.getPosition()

			if CheckCollision((screen_width - exitMenu:getWidth()), screen_height - exitMenu:getHeight(), exitMenu:getWidth(), exitMenu:getHeight(), x, y, 1, 1) then
				if love.mouse.isDown("l") then
					iniciaValores()
				end
			end


		end

		function o:addFundo()
			for i = 0, 1 do
				fundo = {}
				fundo.x = 0
				fundo.y = (i * -(spaceImg:getHeight())) + (screen_height - spaceImg:getHeight())
				table.insert(fundos, fundo)
			end
		end

		function o:desenhaFundo()

			if next (fundos) == nil then
				o:addFundo()
			end

			for i, v in ipairs(fundos) do
				if pause == false then
					v.y = v.y + (love.timer.getDelta() * 20)
				end

				if #fundos == 1 then
					o:addFundo()
				end

				if v.y > screen_height then
					table.remove(fundos, i)
				end

				love.graphics.draw(spaceImg, v.x, v.y, 0, 1, 1)
			end
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
			love.graphics.print("Pontos: " .. pontos, 0, screen_height * 0.015, 0, 3, 3)
			love.graphics.draw(hud, 0, screen_height * 0.06)

			love.graphics.print(#meteoros, hud:getWidth(), screen_height * 0.06 + hud:getHeight()/6, 0, 2, 2)
			love.graphics.print(onda, hud:getWidth(), (screen_height * 0.06 + hud:getHeight()/6) + hud:getHeight()/2, 0, 2, 2)

			love.graphics.rectangle("fill", 15, screen_height * 0.065 + hud:getHeight(), 20, 150)

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
