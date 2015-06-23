acoes = {
	new =
		function ()

			local o = {}

			--Manipula o movimento e ação da nave
			function o:naveMov(dt)
				if pause == false then
					if love.keyboard.isDown ("right") then
						if nave.x < screen_width - 128 then
							nave.x = nave.x + (nave.hSpeed * dt)
						end
					end

					if love.keyboard.isDown ("left") then
						if nave.x > 0 then
							nave.x = nave.x - (nave.hSpeed * dt)
						end
					end

					if love.keyboard.isDown ("down") then
						if nave.y < screen_height - 128 then
							nave.y = nave.y + (nave.vSpeed * dt)
						end
					end

					if love.keyboard.isDown ("up") then
						if nave.y > 0 then
							nave.y = nave.y - (nave.vSpeed * dt)
						end
					end

					if love.keyboard.isDown (" ") then
						bala.x = nave.x + ((naveImg:getWidth()/2) - 9)
						bala.y = nave.y - 60
					end
				end
			end

			function o:atira()
				if pause == false then
					local tiro = {}
					tiro.x = nave.x + (naveImg:getWidth()/2) - (balaImg:getWidth()/2)
					tiro.y = nave.y
					table.insert(nave.tiros, tiro)
					shotsFired = shotsFired + 1

					if tripleBullet then
						local tiroEsq = {}
						tiroEsq.x = nave.x + (naveImg:getWidth()/2) - (balaImg:getWidth()/2)
						tiroEsq.y = nave.y + 3
						table.insert(nave.tirosEsq, tiroEsq)
						shotsFired = shotsFired + 1

						local tiroDir = {}
						tiroDir.x = nave.x + (naveImg:getWidth()/2) - (balaImg:getWidth()/2)
						tiroDir.y = nave.y
						table.insert(nave.tirosDir, tiroDir)
						shotsFired = shotsFired + 1
					end
				end
			end

			function o:atiraMissel()
				if pause == false then
					local missel = {}
					missel.x = nave.x + (naveImg:getWidth()/2) - misselImg:getWidth()
					missel.y = nave.y + naveImg:getHeight()/2
					missel.xFixo = nave.x
					missel.yFixo = nave.y + naveImg:getHeight()/2
					missel.vSpeed = 550
					missel.hSpeed = 150
					table.insert(misseis, missel)
				end
			end

			return o;
		end
}
