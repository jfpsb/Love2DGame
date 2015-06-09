function love.load()
	--Carrega imagens
	spaceImg = love.graphics.newImage("space.jpg")
	naveImg = love.graphics.newImage("nave.png")
	balaImg = love.graphics.newImage("bullet.png")
	meteoroImg = love.graphics.newImage("meteoro.png")
	gameoverImg = love.graphics.newImage("gameover.png")

	--Configurações da janela
	love.window.setMode(0, 0, {vsync=false, fullscreen = true})
	screen_width = love.graphics.getWidth()
	screen_height = love.graphics.getHeight()

	--nave
	nave = {}
	nave.x = screen_width/2
	nave.y = screen_height-128
	nave.speed = 800

	--bala
	bala = {}
	bala.x = 0
	bala.y = 0
	bala.speed = 20
	gameover = false

	math.randomseed(os.time())

	--meteoro
	dropMeteoros(meteoros)

end

function dropMeteoros()

	meteoros = {}
	for i=1, 15 do
		meteoro = {}
		meteoro.x = math.random(0, screen_width - meteoroImg:getWidth())
		meteoro.y = - math.random(0, screen_height)
		table.insert(meteoros, meteoro)
	end
end

function love.update(dt)
	naveMov(dt)

	for i,v in ipairs(meteoros) do

    -- let them fall down slowly
    v.y = v.y + dt * 55

	end


end

function love.draw()
	desenhaFundo()

	love.graphics.draw(naveImg, nave.x, nave.y, 0, 1, 1)

	love.graphics.print("BETA", 0, 0)

	for i,v in ipairs(meteoros) do
		love.graphics.draw(meteoroImg, v.x, v.y)
	end
end

function naveMov(dt)
	if love.keyboard.isDown ("right") then
		if nave.x < screen_width - 128 then
			nave.x = nave.x + (nave.speed * dt)
		end
	end

	if love.keyboard.isDown ("left") then
		if nave.x > 0 then
			nave.x = nave.x - (nave.speed * dt)
		end
	end

	if love.keyboard.isDown ("down") then
		if nave.y < screen_height - 128 then
			nave.y = nave.y + (nave.speed * dt)
		end
	end

	if love.keyboard.isDown ("up") then
		if nave.y > 0 then
			nave.y = nave.y - (nave.speed * dt)
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
