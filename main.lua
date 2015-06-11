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

	pontos = 0
	pressed = false
	
	--meteoro
	mSpeed = 200
	meteoros = {}
	for i=1, 15 do 
		meteoro = {}
		math.randomseed(123 * i)
		meteoro.x = i * math.random(50, 250)
		meteoro.y = - (math.random(0, 900))
		meteoro.width = math.random(0, 3)
		meteoro.height = meteoro.width
		meteoro.speed = math.random(100, mSpeed)
		table.insert(meteoros, meteoro)
	end
	
end

function atira()
	local tiro = {}
	tiro.x = nave.x + (naveImg:getWidth()/2) - (balaImg:getWidth()/2)
	tiro.y = nave.y
	table.insert(nave.tiros, tiro)
end

function love.keyreleased(key)
	if (key == " " or key == "f") then
		atira()
	end
end

function love.update(dt)

	naveMov(dt)
	
	x, y = love.mouse.getPosition()

	for i,v in ipairs(nave.tiros) do

        -- move them up up up
        v.y = v.y - (dt * bala.speed)

	end
	
	for i, v in ipairs(meteoros) do
		v.y = v.y + (dt * v.speed)
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
		end

		--love.graphics.draw(meteoroImg, screen_width/2, screen_height/2)

		love.graphics.print("Pontos: " .. pontos, 0, screen_height * 0.015, 0, 3, 3)
	else
		play = love.graphics.draw(playImg, (screen_width - playImg:getWidth())/3, (screen_height - playImg:getHeight())/2)
		exit = love.graphics.draw(exitImg, 2*(screen_width - playImg:getWidth())/3, (screen_height - playImg:getHeight())/2)
		
		x, y = love.mouse.getPosition()
		
		if CheckCollision((screen_width - playImg:getWidth())/3, (screen_height - playImg:getHeight())/2, playImg:getWidth(), playImg:getHeight(), x, y, 5, 5) then
			if love.mouse.isDown("l") then
				pressed = true
			end
		end
	end
end

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