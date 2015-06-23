function love.load()
	--Carrega imagens
	spaceImg = love.graphics.newImage("images/space.jpg")
	naveImg = love.graphics.newImage("images/nave.png")
	balaImg = love.graphics.newImage("images/bullet.png")
	meteoroImg = love.graphics.newImage("images/meteoro.png")
	playImg = love.graphics.newImage("images/play.png")
	exitImg = love.graphics.newImage("images/exit.png")
	exitMenu = love.graphics.newImage("images/exitMenu.png")
	gameoverImg = love.graphics.newImage("images/gameover.png")
	dropImg = love.graphics.newImage("images/drop.png")
	tiroTriploImg = love.graphics.newImage("images/tirotriplo.png")
	speedNaveImg = love.graphics.newImage("images/speedNave.png")
	speedBalaImg = love.graphics.newImage("images/speedBala.png")
	FMJImg = love.graphics.newImage("images/fullMetalJacket.png")
	FMJIcon = love.graphics.newImage("images/fmjIcon.png")
	slowMoIcon = love.graphics.newImage("images/slowMo.png")
	slowMoImg = love.graphics.newImage("images/slowMoDrop.png")
	doublePointsIcon = love.graphics.newImage("images/doublePoints.png")
	doublePointsImg = love.graphics.newImage("images/doublePointsDrop.png")
	pausaImg = love.graphics.newImage("images/pausa.png")
	hf1 = love.graphics.newImage("images/1hf.png")
	hf2 = love.graphics.newImage("images/2hf.png")
	hud = love.graphics.newImage("images/hud.png")
	misselImg = love.graphics.newImage("images/missel.png")

	--Configurações da janela
	love.window.setMode(0, 0, {vsync=false, fullscreen = true})
	screen_width = love.graphics.getWidth()
	screen_height = love.graphics.getHeight()

	--Arquivos .lua
	require("spawn")
	require("interface")
	require("isClasse")
	require("salvaTabelas")
	require("acoes")

	--Objetos
	objSpawn = spawn.new()
	objInterface = interface.new()
	objIs = isClasse.new()
	objTabelas = salvaTabelas.new()
	objAcoes = acoes.new()

	iniciaValores()
end

function retornaHip(v, vv)
	altura = math.abs((vv.y + (meteoroImg:getHeight()/2 * vv.height)) - (v.y))
	largura = math.abs((vv.x + (meteoroImg:getWidth()/2 * vv.width)) - (v.x))

	hip = math.sqrt(math.pow(altura, 2) + math.pow(largura, 2))

	return hip
end

function love.update(dt)
	if play and objIs:isGameOver() == false then

		for i, v in ipairs(circulos) do
			for ii, vv in ipairs(meteoros) do
				if (vv.y + (meteoroImg:getHeight() * vv.height) >= v.y - v.raio) and (vv.y <= v.y + v.raio) and (vv.x + (meteoroImg:getWidth() * vv.width) >= v.x - v.raio) and (vv.x <= v.x + v.raio) then
					distancia = retornaHip(v, vv)
					if (distancia <= (meteoroImg:getWidth()/2 * vv.width) + v.raio) then
						objTabelas:guardaAbatido(vv)
						table.remove(meteoros, ii)
						pontos = pontos + 50
					end
				end
			end
		end

		for i, v in ipairs(misseis) do
			if pause == false then
				if math.abs(v.xFixo - v.x) < naveImg:getWidth()/2 and v.y == v.yFixo then
					v.x = v.x - (dt * v.hSpeed)
				else
					v.y = v.y - (dt * v.vSpeed)
				end

				if v.y < 1 then
					table.remove(misseis, i)
				end

				for ii, vv in ipairs(meteoros) do
					if CheckCollision(v.x, v.y, misselImg:getWidth(), misselImg:getHeight(), vv.x, vv.y, (meteoroImg:getWidth() * vv.width), (meteoroImg:getHeight() * vv.height)) then

						table.remove(meteoros, ii) --remove o meteoro acertado por bala
						table.remove(misseis, i)

						objTabelas:guardaAbatido(vv)

						pontos = pontos + 50

						meteorosDown = meteorosDown + 1

						circulo = {}
						circulo.x = vv.x + meteoroImg:getWidth()
						circulo.y = vv.y + meteoroImg:getHeight()
						circulo.raio = screen_height * 0.05
						circulo.seg = 100
						circulo.a = 255

						table.insert(circulos, circulo)
					end
				end
			end
		end

		if objIs:isGameOver() == false then
			endTime = love.timer.getTime()
		end

		objIs:isMeteorosEmpty(meteoros)

		objAcoes:naveMov(dt)

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

				objTabelas:gotDrop(v)

				numDrops = numDrops + 1

				table.remove(drops, i)
			end
		end

		DPTimeLeft = objIs:isDropTrue(doublePoints, startDPTime)
		FMJTimeLeft = objIs:isDropTrue(fullMetalJacket, startFMJTime)
		SlowMoTimeLeft = objIs:isDropTrue(slowMo, startSlowMoTime)

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
				objTabelas:guardaPerdido(v)
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
					acertouBala(v, vv, i, ii, balaImg, meteoroImg, meteoros, nave.tirosEsq)
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
					acertouBala(v, vv, i, ii, balaImg, meteoroImg, meteoros, nave.tirosDir)
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

				objTabelas:guardaBateu(v)

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

function love.draw()

	objInterface:desenhaFundo()

	if play and objIs:isGameOver() == false then

		for i, v in ipairs(circulos) do
			if v.a > 0 then
				love.graphics.setColor(255, 255, 255, v.a)
				love.graphics.circle("fill", v.x, v.y, v.raio, v.seg)

				if pause == false then
					v.a = v.a - (love.timer.getDelta() * 175)
					if v.raio < screen_height * 0.4 then
						v.raio = v.raio + (love.timer.getDelta() * 300)
					end
				end
			else
				table.remove(circulos, i)
			end
		end

		love.graphics.setColor(255, 255, 255)

		for i, v in ipairs(misseis) do
			love.graphics.draw(misselImg, v.x, v.y, 0, 1, 1)
		end

		if pause then
			objInterface:pausa()
		end

		love.graphics.draw(naveImg, nave.x, nave.y, 0, 1, 1)

		objInterface:printHUD()

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
				love.graphics.draw(balaImg, v.x, v.y, math.rad(350), 1, 1)
			end

			for i,v in ipairs(nave.tirosDir) do
				love.graphics.draw(balaImg, v.x, v.y, math.rad(10), 1, 1)
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
	else
		if play == false and objIs:isGameOver() == false then
			objInterface:menu()
		else
			if play and objIs:isGameOver() then
				objInterface:gameover()
			end
		end
	end
end

--Ao liberar a tecla espaço aciona o método atira()
function love.keyreleased(key)
	if (key == " ") and objIs:isGameOver() == false then
		objAcoes:atira()
	end

	if key == "f" then
		objAcoes:atiraMissel()
	end

	if  (key == "escape") then
		pause = not pause
	end
end

function iniciaValores()
	--nave
	nave = {}
	nave.x = screen_width/2
	nave.y = screen_height - naveImg:getHeight()
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
	bala.hSpeed = 200

	pontos = 1000 --pontos do jogador
	play = false --play recebe true quando o usuário apertar no botão play do menu
	pause = false --recebe true quando esc é apertado

	--misseis
	misseis = {}

	--meteoro
	minSpeed = 75 --velocidade mínima inicial
	maxSpeed = 150 --velocidade máxima inicial
	inicio = 13 --quantidade da primeira onda (inicializada em isMeteorosEmpty)
	alturaMaxima = 1500
	alturaMinima = 600

	meteoros = {} --vetor para guardar meteoros
	bateus = {} --guarda a localização do meteoro quando a nave bate nele
	acertos = {} --guarda a localização do meteoro quando a nave acerta um tiro nele
	perdidos = {} --meteoros perdidos
	pegouDrops = {}

	startTime = love.timer.getTime() --tempo de início de partida

	circulos = {}

	--contadores
	shotsFired = 0 --tiros efetuados
	meteorosDown = 0 --meteoros abatidos
	meteorosLost = 0 --meteoros perdidos
	hitCount = 0 --quantidade de vezes que a nave bate em meteoros
	numDrops = 0 --Número de drops adquiridos
	onda = 0 --número de ondas (inicializada em isMeteorosEmpty)

	--Drops
	drops = {}
	tripleBullet = false
	fullMetalJacket = false
	slowMo = false
	doublePoints = false

	math.randomseed(os.time())
	ondaDrop = math.random(7, 15)
	somaDrop = 7

	startMatchTime = love.timer.getTime()

	xMissel = 0
	yMissel = 0
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

		objTabelas:guardaAbatido(vv)
	end
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end
