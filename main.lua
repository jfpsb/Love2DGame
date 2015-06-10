function love.load()
	--Carrega imagens
	spaceImg = love.graphics.newImage("space.jpg")
	naveImg = love.graphics.newImage("nave.png")
	balaImg = love.graphics.newImage("bullet.png")
	meteoroImg = love.graphics.newImage("meteoro.png")

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
end

function atira()
	local tiro = {}
	tiro.x = nave.x + naveImg:getWidth()/2 - 10
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

	for i,v in ipairs(nave.tiros) do

        -- move them up up up
        v.y = v.y - dt * bala.speed
		
		if CheckCollision (v.x, v.y, balaImg:getWidth(), balaImg:getHeight(), screen_width/2, screen_height/2, meteoroImg:getWidth(), meteoroImg:getHeight()) then
			pontos = pontos + 1
		end
	end
end

function love.draw()
	desenhaFundo()

	love.graphics.draw(naveImg, nave.x, nave.y, 0, 1, 1)

	love.graphics.print("BETA", 0, 0)

	for i,v in ipairs(nave.tiros) do
		love.graphics.draw(balaImg, v.x, v.y)
	end

	love.graphics.draw(meteoroImg, screen_width/2, screen_height/2)

	love.graphics.print("Pontos: " .. pontos, 0, screen_height * 0.015, 0, 3, 3)
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