function love.load()
	--Carrega imagens
	spaceImg = love.graphics.newImage("space.jpg")
	naveImg = love.graphics.newImage("nave.png")
	balaImg = love.graphics.newImage("bullet.png")
	meteoroImg = love.graphics.newImage("meteoro.png")
	playImg = love.graphics.newImage("play.png")
	exitImg = love.graphics.newImage("exit.png")

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
	bala.speed = 700

	pontos = 0 --pontos do jogador
	pressed = false --pressed recebe true quando o usuário apertar no botão play do menu

	--meteoro
	minSpeed = 75 --velocidade inicial
	maxSpeed = 175
	inicio = 15 --quantidade da primeira onda
	meteoros = {} --vetor para guardar meteoros

	bateus = {}

	math.randomseed(os.time())
end

function love.update(dt)

	if pressed then

		naveMov(dt)

		x, y = love.mouse.getPosition()

		--Só desce quando o botao de play for acionado
		if pressed then
			for i, v in ipairs(meteoros) do
				v.y = v.y + (dt * v.speed)

				if v.y > screen_height - 1 then
					table.remove(meteoros, i)
					pontos = pontos - 25
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
				if (v.x >= vv.x and v.x <= vv.x + (vv.width * meteoroImg:getWidth())) and (v.y >= vv.y and v.y <= vv.y + (vv.height * meteoroImg:getHeight())) then
					pontos = pontos + 50
					table.remove(meteoros, ii) --remove o meteoro acertado por bala
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

	if pressed then

		love.graphics.draw(naveImg, nave.x, nave.y, 0, 1, 1)

		love.graphics.print("BETA", 0, 0)

		for i,v in ipairs(nave.tiros) do
			love.graphics.draw(balaImg, v.x, v.y)
		end

		for i, v in ipairs(meteoros) do
			love.graphics.draw(meteoroImg, v.x, v.y, 0, v.width, v.height)
			love.graphics.print(#meteoros, screen_width/2, screen_height/2, 0, 5, 5)

			if #meteoros == 1 then
				maxSpeed = maxSpeed + 10
				minSpeed = minSpeed + 5
				inicio = inicio + 2
				spawnaMeteoro()
			end
		end

		for i, v in ipairs (bateus) do
			if v.a > 0 then
				love.graphics.setColor(255, 0, 0, v.a)
				v.a = v.a - 0.2
				love.graphics.print("-100", v.x, v.y, 0, 4, 4)
			end
		end

		love.graphics.setColor(255, 255, 255)

		love.graphics.print("Pontos: " .. pontos, 0, screen_height * 0.015, 0, 3, 3)
	else
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
	table.insert(nave.tiros, tiro)
end

--Ao liberar a tecla espaço aciona o método atira()
function love.keyreleased(key)
	if (key == " " or key == "f") then
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
