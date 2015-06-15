function love.load()
	--Carrega imagens
	spaceImg = love.graphics.newImage("space.jpg")
	naveImg = love.graphics.newImage("nave.png")
	balaImg = love.graphics.newImage("bullet.png")
	meteoroImg = love.graphics.newImage("meteoro.png")
	playImg = love.graphics.newImage("play.png")
	exitImg = love.graphics.newImage("exit.png")
	exitMenu = love.graphics.newImage("exitMenu.png")
	gameoverImg = love.graphics.newImage("gameover.png")
	balaDisp = love.graphics.newImage("balasDisp.png")
	meteoroDownImg = love.graphics.newImage("meteoroDown.png")
	meteoroPerdidoImg = love.graphics.newImage("meteoroLost.png")

	--Configurações da janela
	love.window.setMode(0, 0, {vsync=false, fullscreen = true})
	screen_width = love.graphics.getWidth()
	screen_height = love.graphics.getHeight()

	--nave
	nave = {}
	nave.x = screen_width/2
	nave.y = screen_height - 128
	nave.vSpeed = 600
	nave.hSpeed = 800
	nave.tiros = {}

	--bala
	bala = {}
	bala.x = 0
	bala.y = 0
	bala.speed = 1000

	pontos = 1000 --pontos do jogador
	pressed = false --pressed recebe true quando o usuário apertar no botão play do menu

	--meteoro
	minSpeed = 75 --velocidade mínima inicial
	maxSpeed = 150 --velocidade máxima inicial
	inicio = 15 --quantidade da primeira onda
	meteoros = {} --vetor para guardar meteoros

	bateus = {} --guarda a localização do meteoro quando a nave bate nele
	acertos = {} --guarda a localização do meteoro quando a nave acerta um tiro nele
	perdidos = {} --meteoros perdidos

	startTime = love.timer.getTime()

	--contadores
	shotsFired = 0
	meteorosDown = 0
	meteorosLost = 0
	hitCount = 0
	onda = 1

	math.randomseed(os.time())
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
		end
		inicio = inicio + 2
		onda = onda + 1
		spawnaMeteoro()
	end
end

function love.update(dt)

	if pressed  and isGameOver() == false then

		isMeteorosEmpty(meteoros)

		naveMov(dt)

		x, y = love.mouse.getPosition()

		--Só desce quando o botao de play for acionado
		if pressed then
			for i, v in ipairs(meteoros) do
				v.y = v.y + (dt * v.speed)

				if v.y > screen_height - 1 then
					table.remove(meteoros, i)
					pontos = pontos - 50

					perdido = {}
					perdido.x = v.x
					perdido.y = screen_height - 50
					perdido.a = 255

					meteorosLost = meteorosLost + 1

					table.insert(perdidos, perdido)
				end
			end
		end

		for i,v in ipairs(nave.tiros) do

			--bala sobe
			v.y = v.y - (dt * bala.speed)

			--remove balas que ficarem fora do range da tela
			if v.y < 1 then
				table.remove(nave.tiros, i)
			end

			--checa se algum meteoro foi acertado por alguma bala
			for ii, vv in ipairs(meteoros) do
				if CheckCollision(v.x, v.y, balaImg:getWidth(), balaImg:getHeight(), vv.x, vv.y, (meteoroImg:getWidth() * vv.width), (meteoroImg:getHeight() * vv.height)) then
					pontos = pontos + 50
					table.remove(meteoros, ii) --remove o meteoro acertado por bala
					table.remove(nave.tiros, i) --remove bala que acertou meteoro
					meteorosDown = meteorosDown + 1

					local acertou = {}
					acertou.x = vv.x
					acertou.y = vv.y
					acertou.a = 255

					table.insert(acertos, acertou)
				end
			end

		end

		for i, v in ipairs(meteoros) do
			if CheckCollision(nave.x, nave.y, naveImg:getWidth(), naveImg:getHeight(), v.x, v.y, (v.width * meteoroImg:getWidth()), (v.height * meteoroImg:getHeight())) then
				table.remove(meteoros, i)

				local bateu = {}
				bateu.x = nave.x
				bateu.y = nave.y
				bateu.a = 255

				table.insert(bateus, bateu)

				pontos = pontos - 100
			end
		end
	end
end

function love.draw()

	desenhaFundo()

	if pressed and isGameOver() == false then

		love.audio.stop()

		love.graphics.draw(naveImg, nave.x, nave.y, 0, 1, 1)

		love.graphics.print("BETA", 0, 0)

		for i,v in ipairs(nave.tiros) do
			love.graphics.draw(balaImg, v.x, v.y)
		end

		for i, v in ipairs(meteoros) do
			love.graphics.draw(meteoroImg, v.x, v.y, 0, v.width, v.height)

			love.graphics.print("Onda: " .. onda, screen_width * 0.9, screen_height * 0.1, 0, 1, 1)
			love.graphics.print("Meteoros restantes: " .. #meteoros, screen_width * 0.8, screen_height * 0.15, 0, 1, 1)
		end

		for i, v in ipairs (bateus) do
			if v.a > 0 then
				love.graphics.setColor(255, 0, 0, v.a)
				v.a = v.a - (love.timer.getDelta() * 200)
				love.graphics.print("-100", v.x, v.y, 0, 4, 4)
			end
		end

		for i, v in ipairs(acertos) do
			if v.a > 0 then
				love.graphics.setColor(0, 255, 0, v.a)
				v.a = v.a - (love.timer.getDelta() * 200)
				love.graphics.print("+50", v.x, v.y, 0, 4, 4)
			end
		end

		for i, v in ipairs(perdidos) do
			if v.a > 0 then
				love.graphics.setColor(255, 0, 0, v.a)
				v.a = v.a - (love.timer.getDelta() * 200)
				love.graphics.print("-50", v.x, v.y, 0, 4, 4)
			end
		end

		love.graphics.setColor(255, 255, 255)

		love.graphics.print("Pontos: " .. pontos, 0, screen_height * 0.015, 0, 3, 3)
	else
		if pressed == false and isGameOver() == false then
			menu()
		else
			if pressed and isGameOver() then
				gameover()
			end
		end
	end
end

--menu
function menu()
	play = love.graphics.draw(playImg, (screen_width - playImg:getWidth())/3, (screen_height - playImg:getHeight())/2)
	exit = love.graphics.draw(exitImg, 2*(screen_width - playImg:getWidth())/3, (screen_height - playImg:getHeight())/2, 0, 2, 2)

	x, y = love.mouse.getPosition()

	if CheckCollision((screen_width - playImg:getWidth())/3, (screen_height - playImg:getHeight())/2, playImg:getWidth(), playImg:getHeight(), x, y, 5, 5) then
		if love.mouse.isDown("l") then
			pressed = true
			spawnaMeteoro()
		end
	end
end

function gameover()
	endTime = love.timer.getTime()

	love.graphics.setColor(255, 255, 255)

	love.graphics.rectangle("fill", 0, 0, screen_width, screen_height)
	love.graphics.draw(gameoverImg, (screen_width - gameoverImg:getWidth())/2, 50)
	love.graphics.draw(exitMenu, (screen_width - exitMenu:getWidth()), screen_height - exitMenu:getHeight())
	love.graphics.draw(balaDisp, screen_width * 0.2, screen_height * 0.3, 0, 1, 1)
	love.graphics.draw(meteoroDownImg, screen_width * 0.2, screen_height * 0.4, 0, 1, 1)
	love.graphics.draw(meteoroPerdidoImg, screen_width * 0.2, screen_height * 0.5, 0, 1, 1)
	love.graphics.setColor(0, 0, 0)
	love.graphics.print(shotsFired, (screen_width * 0.2) + balaDisp:getWidth() + 20, (screen_height * 0.3) + (balaDisp:getHeight()/2) - 14, 0, 2, 2)
	love.graphics.print(meteorosDown, (screen_width * 0.2) + meteoroDownImg:getWidth() + 20, (screen_height * 0.4) + (meteoroDownImg:getHeight()/2) - 14, 0, 2, 2)
	love.graphics.print(meteorosLost, (screen_width * 0.2) + meteoroPerdidoImg:getWidth() + 20, (screen_height * 0.5) + (meteoroPerdidoImg:getHeight()/2) - 14, 0, 2, 2)
	love.graphics.setColor(255, 255, 255)
end

--Cria na tela os meteoros
function spawnaMeteoro ()
	for i=1, inicio do
		meteoro = {}
		meteoro.width = math.random(1, 3)
		meteoro.height = meteoro.width
		meteoro.x = math.random(naveImg:getWidth()/2, screen_width - naveImg:getWidth())
		meteoro.y = - (math.random((meteoroImg:getWidth() * meteoro.width), 900))
		meteoro.speed = math.random(minSpeed, maxSpeed)
		table.insert(meteoros, meteoro)
	end
end

--Cria os tiros baseados na posiçào da nave e guarda-os em uma tabela
function atira()
	local tiro = {}
	tiro.x = nave.x + (naveImg:getWidth()/2) - (balaImg:getWidth()/2)
	tiro.y = nave.y
	tiro.som = bala.som
	table.insert(nave.tiros, tiro)
	shotsFired = shotsFired + 1
end

--Ao liberar a tecla espaço aciona o método atira()
function love.keyreleased(key)
	if (key == " " or key == "f") and isGameOver() == false then
		atira()
	end
end

--Manipula o movimento e ação da nave
function naveMov(dt)
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
