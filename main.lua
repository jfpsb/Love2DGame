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

	--Configura��es da janela
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
	nave.tirosEsq = {}
	nave.tirosDir = {}

	--bala
	bala = {}
	bala.x = 0
	bala.y = 0
	bala.vSpeed = 1000
	bala.hSpeed = 250

	pontos = 1000 --pontos do jogador
	play = false --play recebe true quando o usu�rio apertar no bot�o play do menu

	--meteoro
	minSpeed = 75 --velocidade m�nima inicial
	maxSpeed = 150 --velocidade m�xima inicial
	inicio = 15 --quantidade da primeira onda

	meteoros = {} --vetor para guardar meteoros

	bateus = {} --guarda a localiza��o do meteoro quando a nave bate nele
	acertos = {} --guarda a localiza��o do meteoro quando a nave acerta um tiro nele
	perdidos = {} --meteoros perdidos
	pegouDrops = {}

	startTime = love.timer.getTime() --tempo de in�cio de partida

	--contadores
	shotsFired = 0 --tiros efetuados
	meteorosDown = 0 --meteoros abatidos
	meteorosLost = 0 --meteoros perdidos
	hitCount = 0 --quantidade de vezes que a nave bate em meteoros
	onda = 1 --n�mero de ondas

	drops = {}

	tripleBullet = false
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

		--if onda > 20 and isPrimo(onda) then
		if onda > 1 then
			spawnDrop()
		end
	end
end

function isPrimo(onda)
	if onda%2~=0 and onda%3~=0 and onda%5~=0 and onda%7~=0 then
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
	drop.tipo = math.random(1, 3)

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
			v.y = v.y + (dt * v.speed)

			if v.y > screen_height then
				table.remove(drops, i)
			end

			if CheckCollision (nave.x, nave.y, naveImg:getWidth(), naveImg:getHeight(), v.x, v.y, dropImg:getWidth(), dropImg:getHeight()) then
				if v.tipo == 2 then
					tripleBullet = true
					gotDrop(v)
				end
				if v.tipo == 1 then
					nave.vSpeed = nave.vSpeed + 100
					nave.hSpeed = nave.hSpeed + 100
					gotDrop(v)
				end
				if v.tipo == 3 then
					bala.vSpeed = bala.vSpeed + 100
					gotDrop(v)
				end

				table.remove(drops, i)
			end
		end

		for i, v in ipairs(meteoros) do
			v.y = v.y + (dt * v.speed)
			if v.y > screen_height - 1 then
				table.remove(meteoros, i)
				pontos = pontos - 50

				guardaPerdido(v)
			end
		end

		if tripleBullet then
			for i, v in ipairs(nave.tirosEsq) do
				v.y = v.y - (dt * bala.vSpeed)
				v.x = v.x - (dt * bala.hSpeed)

				if v.y < 1 then
					table.remove(nave.tirosEsq, i)
				end

				for ii, vv in ipairs(meteoros) do
					acertouBala(v, vv, i, ii, balaEsq, meteoroImg, meteoros, nave.tirosEsq)
				end
			end

			for i, v in ipairs(nave.tirosDir) do
				v.y = v.y - (dt * bala.vSpeed)
				v.x = v.x + (dt * bala.hSpeed)

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
			v.y = v.y - (dt * bala.vSpeed)

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
		pontos = pontos + 50
		table.remove(meteorosTable, ii) --remove o meteoro acertado por bala
		table.remove(tirosTable, i) --remove bala que acertou meteoro
		meteorosDown = meteorosDown + 1

		guardaAbatido(vv)
	end
end

function printHUD()
	love.graphics.print("BETA", 0, 0)
	love.graphics.draw(meteorosRestantesImg, screen_width * 0.83, 0)
	love.graphics.print(#meteoros, (screen_width * 0.83) + meteorosRestantesImg:getWidth(), meteorosRestantesImg:getHeight()/2 - 20, 0, 3, 3)
	love.graphics.draw(ondaImg, screen_width * 0.8, meteorosRestantesImg:getHeight())
	love.graphics.print(onda, (screen_width * 0.8) + ondaImg:getWidth(), meteorosRestantesImg:getHeight() + (ondaImg:getHeight()/2) - 20, 0, 3, 3)
end

function love.draw()

	desenhaFundo()

	if play and isGameOver() == false then

		love.graphics.draw(naveImg, nave.x, nave.y, 0, 1, 1)

		printHUD()

		for i, v in ipairs(pegouDrops) do
			if v.a > 0 then
				love.graphics.setColor(255, 255, 255, v.a)
				v.a = v.a - (love.timer.getDelta() * 50)

				if v.tipo == 1 then
					love.graphics.draw(speedNaveImg, (screen_width - speedNaveImg:getWidth())/2, (screen_height - speedNaveImg:getHeight())/2)
				end

				if v.tipo == 2 then
					love.graphics.draw(tiroTriploImg, (screen_width - tiroTriploImg:getWidth())/2, (screen_height - tiroTriploImg:getHeight())/2)
				end

				if v.tipo == 3 then
					love.graphics.draw(speedBalaImg, (screen_width - speedBalaImg:getWidth())/2, (screen_height - speedBalaImg:getHeight())/2)
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

	if CheckCollision((screen_width - playImg:getWidth())/3, (screen_height - playImg:getHeight())/2, playImg:getWidth(), playImg:getHeight(), x, y, 5, 5) then
		if love.mouse.isDown("l") then
			play = true
			spawnaMeteoro()
		end
	end
end

function gameover()
	X = (screen_width - gameoverImg:getWidth())/2
	Y = screen_height * 0.3

	hSpace = screen_width * 0.05
	vSpace = screen_height * 0.15

	inBetweenSpace = screen_width * 0.005

	endTime = love.timer.getTime()

	love.graphics.setColor(255, 255, 255)

	love.graphics.rectangle("fill", 0, 0, screen_width, screen_height)
	love.graphics.draw(gameoverImg, X, 50)
	love.graphics.draw(exitMenu, (screen_width - exitMenu:getWidth()), screen_height - exitMenu:getHeight())
	love.graphics.draw(balaDisp, X, Y, 0, 1, 1)
	love.graphics.draw(meteoroDownImg, X + balaDisp:getWidth() + hSpace, Y, 0, 1, 1)
	love.graphics.draw(meteoroPerdidoImg, X +  balaDisp:getWidth() + (hSpace * 2) + meteoroDownImg:getWidth(), Y, 0, 1, 1)
	love.graphics.draw(colisaoImg, X, Y + vSpace, 0, 1, 1)
	love.graphics.draw(precisaoImg, X + colisaoImg:getWidth() + hSpace, Y + vSpace, 0, 1, 1)
	love.graphics.setColor(0, 0, 0)
	love.graphics.print(shotsFired, X + balaDisp:getWidth() + inBetweenSpace, (screen_height * 0.3) + (balaDisp:getHeight()/2) - 14, 0, 2, 2)
	love.graphics.print(meteorosDown, X + balaDisp:getWidth() + hSpace + meteoroDownImg:getWidth() + inBetweenSpace, (screen_height * 0.3) + (meteoroDownImg:getHeight()/2) - 14, 0, 2, 2)
	love.graphics.print(meteorosLost, X + balaDisp:getWidth() + (hSpace * 2) + meteoroDownImg:getWidth() + meteoroPerdidoImg:getWidth() + inBetweenSpace, (screen_height * 0.3) + (meteoroPerdidoImg:getHeight()/2) - 14, 0, 2, 2)
	love.graphics.print(hitCount, X + colisaoImg:getWidth() + inBetweenSpace, Y + vSpace + (colisaoImg:getHeight()/2) - 14, 0, 2, 2)

	if shotsFired == 0 then
		precisao = 0
	else
		precisao = meteorosDown/shotsFired
	end

	love.graphics.print((math.floor(precisao*100)) .. "%", X + colisaoImg:getWidth() + precisaoImg:getWidth() + hSpace + inBetweenSpace, Y + vSpace + (precisaoImg:getHeight()/2) - 14, 0, 2, 2)
	love.graphics.setColor(255, 255, 255)
end

--Cria na tela os meteoros
function spawnaMeteoro ()
	for i=1, inicio do
		meteoro = {}
		math.randomseed(os.time() * i)
		meteoro.width = math.random(1, 3)
		meteoro.height = meteoro.width
		meteoro.x = math.random(naveImg:getWidth()/2, screen_width - naveImg:getWidth())
		meteoro.y = - (math.random(600, 1500))
		meteoro.speed = math.random(minSpeed, maxSpeed)

		table.insert(meteoros, meteoro)
	end
end

--Cria os tiros baseados na posi��o da nave e guarda-os em uma tabela
function atira()
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

--Ao liberar a tecla espa�o aciona o m�todo atira()
function love.keyreleased(key)
	if (key == " " or key == "f") and isGameOver() == false then
		atira()
	end
end

--Manipula o movimento e a��o da nave
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
