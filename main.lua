function love.load()
	--Carrega imagens
	spaceImg = love.graphics.newImage("space.jpg")
	naveImg = love.graphics.newImage("nave.png")
	balaImg = love.graphics.newImage("bullet.png")
	balaEsq = love.graphics.newImage("bulletleft.png")
	balaDir = love.graphics.newImage("bulletright.png")
	meteoroImg = love.graphics.newImage("meteoro.png")
	playImg = love.graphics.newImage("play.png")
	exitImg = love.graphics.newImage("exit.png")
	exitMenu = love.graphics.newImage("exitMenu.png")
	gameoverImg = love.graphics.newImage("gameover.png")
	balaDisp = love.graphics.newImage("balasDisp.png")
	meteoroDownImg = love.graphics.newImage("meteoroDown.png")
	meteoroPerdidoImg = love.graphics.newImage("meteoroLost.png")
	colisaoImg = love.graphics.newImage("colisao.png")
	precisaoImg = love.graphics.newImage("precisao.png")
	dropImg = love.graphics.newImage("drop.png")
	meteorosRestantesImg = love.graphics.newImage("meteororestante.png")
	tiroTriploImg = love.graphics.newImage("tirotriplo.png")
	speedNaveImg = love.graphics.newImage("speedNave.png")
	speedBalaImg = love.graphics.newImage("speedBala.png")
	ondaImg = love.graphics.newImage("onda.png")
	FMJImg = love.graphics.newImage("fullMetalJacket.png")
	FMJIcon = love.graphics.newImage("fmjIcon.png")
	slowMoIcon = love.graphics.newImage("slowMo.png")
	slowMoImg = love.graphics.newImage("slowMoDrop.png")
	dropsAdquiridos = love.graphics.newImage("dropsadquiridos.png")
	doublePointsIcon = love.graphics.newImage("doublePoints.png")
	doublePointsImg = love.graphics.newImage("doublePointsDrop.png")
	pausaImg = love.graphics.newImage("pausa.png")

	--Configurações da janela
	love.window.setMode(0, 0, {vsync=false, fullscreen = true})
	screen_width = love.graphics.getWidth()
	screen_height = love.graphics.getHeight()

	iniciaValores()
end

function iniciaValores()
	--nave
	nave = {}
	nave.x = screen_width/2
	nave.y = screen_height - 128
	nave.vSpeed = 600
	nave.hSpeed = 800
	nave.tiros = {}
	nave.tirosEsq = {}
	nave.tirosDir = {}

	--bala
	bala = {}
	bala.x = 0
	bala.y = 0
	bala.vSpeed = 1000
	bala.hSpeed = 250

	pontos = 1000 --pontos do jogador
	play = false --play recebe true quando o usuário apertar no botão play do menu
	pause = false

	--meteoro
	minSpeed = 75 --velocidade mínima inicial
	maxSpeed = 150 --velocidade máxima inicial
	inicio = 15 --quantidade da primeira onda
	alturaMaxima = 1500
	alturaMinima = 600

	meteoros = {} --vetor para guardar meteoros
	bateus = {} --guarda a localização do meteoro quando a nave bate nele
	acertos = {} --guarda a localização do meteoro quando a nave acerta um tiro nele
	perdidos = {} --meteoros perdidos
	pegouDrops = {}

	startTime = love.timer.getTime() --tempo de início de partida

	--contadores
	shotsFired = 0 --tiros efetuados
	meteorosDown = 0 --meteoros abatidos
	meteorosLost = 0 --meteoros perdidos
	hitCount = 0 --quantidade de vezes que a nave bate em meteoros
	numDrops = 0
	onda = 1 --número de ondas

	--Drops
	drops = {}
	tripleBullet = false
	fullMetalJacket = false
	slowMo = false
	doublePoints = false
end

function isGameOver()
	if pontos < 0 then
		return true
	else
		return false
	end
end

function isMeteorosEmpty (meteoros)
	if next (meteoros) == nil then
		if onda%5==0 then
			maxSpeed = maxSpeed + 5
			minSpeed = minSpeed + 3
			alturaMaxima = alturaMaxima + 50
			alturaMinima = alturaMinima + 15
		end
		inicio = inicio + 2
		onda = onda + 1

		spawnaMeteoro()

		if onda > 0 --[[and isDivisivel(onda)]] then
			spawnDrop()
		end
	end
end

function isDivisivel(onda)
	if shotsFired%onda == 0 then
		return true
	else
		return false
	end
end

function spawnDrop()
	drop = {}
	math.randomseed(os.time())
	drop.x = math.random(0, screen_width - dropImg:getWidth())
	drop.y = - (math.random(800, 1200))
	drop.speed = 100
	drop.tipo = math.random(4, 6)

	table.insert(drops, drop)
end

function gotDrop(v)
	pegouDrop = {}
	pegouDrop.x = v.x
	pegouDrop.y = v.y
	pegouDrop.tipo = v.tipo
	pegouDrop.a = 255
	table.insert(pegouDrops, pegouDrop)
end

function love.update(dt)
	if play and isGameOver() == false then

		isMeteorosEmpty(meteoros)

		naveMov(dt)

		x, y = love.mouse.getPosition()

		for i, v in ipairs(drops) do
			if pause == false then
				v.y = v.y + (dt * v.speed)
			end

			if v.y > screen_height then
				table.remove(drops, i)
			end

			if CheckCollision (nave.x, nave.y, naveImg:getWidth(), naveImg:getHeight(), v.x, v.y, dropImg:getWidth(), dropImg:getHeight()) then
				if v.tipo == 1 then
					if nave.vSpeed < 1000  and nave.hSpeed < 1200 then
						nave.vSpeed = nave.vSpeed + 100
						nave.hSpeed = nave.hSpeed + 100
					end
				else
					if v.tipo == 2 then
						tripleBullet = true
					else
						if v.tipo == 3 then
							if bala.vSpeed < 1500 then
								bala.vSpeed = bala.vSpeed + 100
							end
						else
							if v.tipo == 4 then
								startFMJTime = love.timer.getTime()
								fullMetalJacket = true
							else
								if v.tipo == 5 then
									startSlowMoTime = love.timer.getTime()
									slowMo = true
								else
									startDPTime = love.timer.getTime()
									doublePoints = true
								end
							end
						end
					end
				end

				gotDrop(v)

				numDrops = numDrops + 1

				table.remove(drops, i)
			end
		end

		DPTimeLeft = isDropTrue(doublePoints, startDPTime)
		FMJTimeLeft = isDropTrue(fullMetalJacket, startFMJTime)
		SlowMoTimeLeft = isDropTrue(slowMo, startSlowMoTime)

		for i, v in ipairs(meteoros) do
			if pause == false then
				if slowMo then
					v.y = v.y + (dt * 30)
				else
					v.y = v.y + (dt * v.speed)
				end
			end
			if v.y > screen_height - 1 then
				table.remove(meteoros, i)
				pontos = pontos - 50
				guardaPerdido(v)
			end
		end

		if tripleBullet then
			for i, v in ipairs(nave.tirosEsq) do
				if pause == false then
					v.y = v.y - (dt * bala.vSpeed)
					v.x = v.x - (dt * bala.hSpeed)
				end

				if v.y < 1 then
					table.remove(nave.tirosEsq, i)
				end

				for ii, vv in ipairs(meteoros) do
					acertouBala(v, vv, i, ii, balaEsq, meteoroImg, meteoros, nave.tirosEsq)
				end
			end

			for i, v in ipairs(nave.tirosDir) do
				if pause == false then
					v.y = v.y - (dt * bala.vSpeed)
					v.x = v.x + (dt * bala.hSpeed)
				end
				if v.y < 1 then
					table.remove(nave.tirosDir, i)
				end

				for ii, vv in ipairs(meteoros) do
					acertouBala(v, vv, i, ii, balaDir, meteoroImg, meteoros, nave.tirosDir)
				end
			end
		end

		for i,v in ipairs(nave.tiros) do

			--bala sobe
			if pause == false then
				v.y = v.y - (dt * bala.vSpeed)
			end

			--remove balas que ficarem fora do range da tela
			if v.y < 1 then
				table.remove(nave.tiros, i)
			end

			--checa se algum meteoro foi acertado por alguma bala
			for ii, vv in ipairs(meteoros) do
				acertouBala(v, vv, i, ii, balaImg, meteoroImg, meteoros, nave.tiros)
			end

		end

		for i, v in ipairs(meteoros) do
			if CheckCollision(nave.x, nave.y, naveImg:getWidth(), naveImg:getHeight(), v.x, v.y, (v.width * meteoroImg:getWidth()), (v.height * meteoroImg:getHeight())) then
				table.remove(meteoros, i)

				guardaBateu(v)

				pontos = pontos - 100

				hitCount = hitCount + 1

				tripleBullet = false
				nave.vSpeed = 600
				nave.hSpeed = 800
				bala.vSpeed = 1000
			end
		end
	end
end

function isDropTrue(variavel, startTime)
	if variavel then
		return (30 - (math.floor(love.timer.getTime() - startTime)))
	end
end

function guardaBateu(v)
	bateu = {}
	bateu.x = nave.x
	bateu.y = nave.y
	bateu.a = 255
	table.insert(bateus, bateu)
end

function guardaPerdido(v)
	perdido = {}
	perdido.x = v.x
	perdido.y = screen_height - 50
	perdido.a = 255
	meteorosLost = meteorosLost + 1
	table.insert(perdidos, perdido)
end

function guardaAbatido(vv)
	acertou = {}
	acertou.x = vv.x
	acertou.y = vv.y
	acertou.a = 255
	table.insert(acertos, acertou)
end

function acertouBala(v, vv, i, ii, imagemBala, imagemMeteoro, meteorosTable, tirosTable)
	if CheckCollision(v.x, v.y, imagemBala:getWidth(), imagemBala:getHeight(), vv.x, vv.y, (imagemMeteoro:getWidth() * vv.width), (imagemMeteoro:getHeight() * vv.height)) then
		if doublePoints then
			pontos = pontos + 100
		else
			pontos = pontos + 50
		end

		table.remove(meteorosTable, ii) --remove o meteoro acertado por bala

		if fullMetalJacket == false then
			table.remove(tirosTable, i) --remove bala que acertou meteoro
		end

		meteorosDown = meteorosDown + 1

		guardaAbatido(vv)
	end
end

function printHUD()
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

function pausa()
	love.graphics.draw(pausaImg, (screen_width - pausaImg:getWidth())/2, screen_height/3 - pausaImg:getHeight()/2)
	love.graphics.draw(exitMenu, (screen_width - exitMenu:getWidth())/2, screen_height/2 + exitMenu:getHeight())

	x, y = love.mouse.getPosition()

	if CheckCollision((screen_width - exitMenu:getWidth())/2, screen_height/2 + exitMenu:getHeight(), exitMenu:getWidth(), exitMenu:getHeight(), x, y, 1, 1) then
		if love.mouse.isDown("l") then
			pontos = -1
			gameover()
		end
	end
end

function love.draw()

	desenhaFundo()

	if play and isGameOver() == false then

		if pause then
			pausa()
		end

		love.graphics.draw(naveImg, nave.x, nave.y, 0, 1, 1)

		printHUD()

		for i, v in ipairs(pegouDrops) do
			if v.a > 0 then
				love.graphics.setColor(255, 255, 255, v.a)
				v.a = v.a - (love.timer.getDelta() * 75)

				if v.tipo == 1 then
					love.graphics.draw(speedNaveImg, (screen_width - speedNaveImg:getWidth())/2, (screen_height - speedNaveImg:getHeight())/2)
					if nave.vSpeed == 1000 then
						love.graphics.printf("Limite de velocidade atingido.", 0, (screen_height/2) + speedNaveImg:getHeight()/4, screen_width, "center")
					end
				else
					if v.tipo == 2 then
						love.graphics.draw(tiroTriploImg, (screen_width - tiroTriploImg:getWidth())/2, (screen_height - tiroTriploImg:getHeight())/2)
					else
						if v.tipo == 3 then
							love.graphics.draw(speedBalaImg, (screen_width - speedBalaImg:getWidth())/2, (screen_height - speedBalaImg:getHeight())/2)
							if bala.vSpeed == 1500 then
								love.graphics.printf("Limite de velocidade atingido.", 0, (screen_height/2) + speedBalaImg:getHeight()/4, screen_width, "center")
							end
						else
							if v.tipo == 4 then
								love.graphics.draw(FMJImg, (screen_width - FMJImg:getWidth())/2, (screen_height - FMJImg:getHeight())/2)
							else
								if v.tipo == 5 then
									love.graphics.draw(slowMoImg, (screen_width - slowMoImg:getWidth())/2, (screen_height - slowMoImg:getHeight())/2)
								else
									love.graphics.draw(doublePointsImg, (screen_width - doublePointsImg:getWidth())/2, (screen_height - doublePointsImg:getHeight())/2)
								end
							end
						end
					end
				end
			else
				table.remove(pegouDrops, i)
			end


		end

		love.graphics.setColor(255, 255, 255)

		for i, drop in ipairs(drops) do
			love.graphics.draw(dropImg, drop.x, drop.y, 0, 1, 1)
		end

		for i,v in ipairs(nave.tiros) do
			love.graphics.draw(balaImg, v.x, v.y)
		end

		if tripleBullet then
			for i,v in ipairs(nave.tirosEsq) do
				love.graphics.draw(balaEsq, v.x, v.y)
			end

			for i,v in ipairs(nave.tirosDir) do
				love.graphics.draw(balaDir, v.x, v.y)
			end
		end

		for i, v in ipairs(meteoros) do
			love.graphics.draw(meteoroImg, v.x, v.y, 0, v.width, v.height)
		end

		for i, v in ipairs (bateus) do
			if v.a > 0 then
				love.graphics.setColor(255, 0, 0, v.a)

				if pause == false then
					v.a = v.a - (love.timer.getDelta() * 200)
				end

				love.graphics.print("-100", v.x, v.y, 0, 4, 4)
			end
		end

		for i, v in ipairs(acertos) do
			if v.a > 0 then
				love.graphics.setColor(0, 255, 0, v.a)

				if pause == false then
					v.a = v.a - (love.timer.getDelta() * 200)
				end

				if doublePoints then
					love.graphics.print("+100", v.x, v.y, 0, 4, 4)
				else
					love.graphics.print("+50", v.x, v.y, 0, 4, 4)
				end
			end
		end

		for i, v in ipairs(perdidos) do
			if v.a > 0 then
				love.graphics.setColor(255, 0, 0, v.a)

				if pause == false then
					v.a = v.a - (love.timer.getDelta() * 200)
				end

				love.graphics.print("-50", v.x, v.y, 0, 4, 4)
			end
		end

		love.graphics.setColor(255, 255, 255)

		love.graphics.print("Pontos: " .. pontos, 0, screen_height * 0.015, 0, 3, 3)
	else
		if play == false and isGameOver() == false then
			menu()
		else
			if play and isGameOver() then
				gameover()
			end
		end
	end
end

--menu
function menu()
	love.graphics.draw(playImg, (screen_width - playImg:getWidth())/3, (screen_height - playImg:getHeight())/2)
	love.graphics.draw(exitImg, 2*(screen_width - playImg:getWidth())/3, (screen_height - playImg:getHeight())/2, 0, 2, 2)

	x, y = love.mouse.getPosition()

	if CheckCollision((screen_width - playImg:getWidth())/3, (screen_height - playImg:getHeight())/2, playImg:getWidth(), playImg:getHeight(), x, y, 1, 1) then
		if love.mouse.isDown("l") then
			play = true
			spawnaMeteoro()
		end
	end

	if CheckCollision(2*(screen_width - playImg:getWidth())/3, (screen_height - playImg:getHeight())/2, exitImg:getWidth(), exitImg:getHeight(), x, y, 1, 1) then
		if love.mouse.isDown("l") then
			love.event.push ("quit")
		end
	end
end

function gameover()

	love.graphics.setColor(255, 255, 255)

	love.graphics.rectangle("fill", 0, 0, screen_width, screen_height)
	love.graphics.draw(gameoverImg, (screen_width - gameoverImg:getWidth())/2, 50)
	love.graphics.draw(exitMenu, (screen_width - exitMenu:getWidth()), screen_height - exitMenu:getHeight())
	love.graphics.draw(balaDisp, screen_width/4 - balaDisp:getWidth()/2, screen_height * 0.3, 0, 1, 1)
	love.graphics.draw(meteoroDownImg, (screen_width - meteoroDownImg:getWidth())/2, screen_height * 0.3, 0, 1, 1)
	love.graphics.draw(meteoroPerdidoImg,(3/2)*(screen_width/2) - meteoroPerdidoImg:getWidth()/2, screen_height * 0.3, 0, 1, 1)
	love.graphics.draw(colisaoImg, screen_width/4 - colisaoImg:getWidth()/2, screen_height * 0.5, 0, 1, 1)
	love.graphics.draw(precisaoImg, (screen_width -  precisaoImg:getWidth())/2, screen_height * 0.5, 0, 1, 1)
	love.graphics.draw(dropsAdquiridos, (3/2)*(screen_width/2) - dropsAdquiridos:getWidth()/2, screen_height * 0.5, 0, 1, 1)
	love.graphics.setColor(0, 0, 0)
	love.graphics.print(shotsFired, screen_width/4 + balaDisp:getWidth()/2, screen_height * 0.3 + balaDisp:getHeight()/4, 0, 3, 3)
	love.graphics.print(meteorosDown, screen_width/2 + meteoroDownImg:getWidth()/2, (screen_height * 0.3) + (meteoroDownImg:getHeight()/4), 0, 3, 3)
	love.graphics.print(meteorosLost, (3/2)*(screen_width/2) + meteoroPerdidoImg:getWidth()/2, (screen_height * 0.3) + (meteoroPerdidoImg:getHeight()/4), 0, 3, 3)
	love.graphics.print(hitCount, screen_width/4 + colisaoImg:getWidth()/2, (screen_height * 0.5) + colisaoImg:getHeight()/4, 0, 3, 3)
	love.graphics.print(numDrops, (3/2)*(screen_width/2) + dropsAdquiridos:getWidth()/2, (screen_height * 0.5) + dropsAdquiridos:getHeight()/4, 0, 3, 3)

	if shotsFired == 0 then
		precisao = 0
	else
		precisao = meteorosDown/shotsFired
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

--Cria na tela os meteoros
function spawnaMeteoro ()
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

--Cria os tiros baseados na posiçào da nave e guarda-os em uma tabela
function atira()
	if pause == false then
		local tiro = {}
		tiro.x = nave.x + (naveImg:getWidth()/2) - (balaImg:getWidth()/2)
		tiro.y = nave.y
		table.insert(nave.tiros, tiro)
		shotsFired = shotsFired + 1

		if tripleBullet then
			local tiroEsq = {}
			tiroEsq.x = nave.x + (naveImg:getWidth()/2) - (balaEsq:getWidth()/2)
			tiroEsq.y = nave.y
			table.insert(nave.tirosEsq, tiroEsq)
			shotsFired = shotsFired + 1

			local tiroDir = {}
			tiroDir.x = nave.x + (naveImg:getWidth()/2) - (balaDir:getWidth()/2)
			tiroDir.y = nave.y
			table.insert(nave.tirosDir, tiroDir)
			shotsFired = shotsFired + 1
		end
	end
end

--Ao liberar a tecla espaço aciona o método atira()
function love.keyreleased(key)
	if (key == " " or key == "f") and isGameOver() == false then
		atira()
	end

	if  (key == "escape") then
		pause = not pause
	end
end

--Manipula o movimento e ação da nave
function naveMov(dt)
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

--Desenha o background
function desenhaFundo()
	love.graphics.draw(spaceImg, (screen_width - spaceImg:getWidth())/2, 0, 0, 1, 1)
	love.graphics.draw(spaceImg, -(screen_width - spaceImg:getWidth())/2, 0, 0, 1, 1)
	love.graphics.draw(spaceImg, 2*(screen_width - spaceImg:getWidth())/2, 0, 0, 1, 1)
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end
