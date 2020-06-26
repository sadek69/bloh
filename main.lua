local anim8 = require 'lib/anim8'
local cron = require 'lib/cron'

local image, animation

function love.load()

  w = love.graphics.getWidth()
  h = love.graphics.getHeight()
  sun = love.graphics.newImage('gfx/sun56.png')

  game = {}
  game.state = 'start'--,'drive','kiosk' sostoanie igri


  back = {}
  back.pic = {}
  back.pic[1] = love.graphics.newImage("gfx/back1.png")
  back.pic[2] = love.graphics.newImage("gfx/back2.png")
  back.pic[3] = love.graphics.newImage("gfx/back3.png")
  back.pic[4] = love.graphics.newImage("gfx/back4.png")
  back.pic[5] = love.graphics.newImage("gfx/back3.png")
  back.pic[6] = love.graphics.newImage("gfx/priezd.png")
  back.pic[7] = love.graphics.newImage("gfx/priezd.png")--hack poslednaja kartinka ne budet otobazatsja
  back.x = 0
  back.y = 0
  back.number = 1
  back.start = 0

  car1 = {}
    car1.x= -20
    car1.y= 350
    car1.pic= love.graphics.newImage("gfx/car1.png")
    car1.timer = cron.every(0.01, function() car1.x = car1.x + 1 end)

  car2 = {}
    car2.x= 600
    car2.y= 320
    car2.k= 1
    car2.pic= love.graphics.newImage("gfx/car2.png")
    car2.timer = cron.every(0.01, function() car2.x = car2.x - car2.k end)

  pers1 = {}
    pers1.x = 300
    pers1.y = 285
    pers1.state = 's'  --gr -goright,s-stay,gl-goleft,gd,gt,inc - incar
    pers1.picgoright = love.graphics.newImage('gfx/pers1rightv3.png')
    pers1.goright =  anim8.newGrid(32,49, pers1.picgoright:getWidth(), pers1.picgoright:getHeight())
    pers1.animationgoright = anim8.newAnimation(pers1.goright('1-9',1), 0.1)
    pers1.picgoleft = love.graphics.newImage('gfx/pers1left4.png')
    pers1.goleft = anim8.newGrid(32,49, pers1.picgoleft:getWidth(), pers1.picgoleft:getHeight())
    pers1.animationgoleft = anim8.newAnimation(pers1.goleft('1-7',1), 0.1)
    pers1.frontpic = love.graphics.newImage('gfx/front2.png')
    pers1.picgotop = love.graphics.newImage('gfx/pers1gotop.png')
    pers1.gotop = anim8.newGrid(32,49, pers1.picgotop:getWidth(), pers1.picgotop:getHeight())
    pers1.animationgotop = anim8.newAnimation(pers1.gotop('1-3',1), 0.15)
    pers1.picgodown = love.graphics.newImage('gfx/pers1godown.png')
    pers1.godown = anim8.newGrid(32,49, pers1.picgodown:getWidth(), pers1.picgodown:getHeight())
    pers1.animationgdown = anim8.newAnimation(pers1.godown('1-3',1), 0.15)

    pers1.speed = 15



  local gsun = anim8.newGrid(56,56, sun:getWidth(), sun:getHeight())
  animationsun = anim8.newAnimation(gsun('1-4',1), 0.1)


  local sky = love.graphics.newImage('gfx/onlysky.png')
  psystem = love.graphics.newParticleSystem(sky, 32)
  psystem:setParticleLifetime(5, 25) -- Particles live at least 2s and at most 5s.
  psystem:setLinearAcceleration(-1,1, 25, 0) -- Randomized movement towards the bottom of the screen.
  psystem:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to black.

end

function love.update(dt)


   if game.state == 'drive' or game.state == 'start' then
     if love.keyboard.isDown('escape') then love.event.quit() end
     animationsun:update(dt)
     pers1.animationgoright:update(dt)
     pers1.animationgoleft:update(dt)
     pers1.animationgotop:update(dt)
     pers1.animationgdown:update(dt)

     car1.timer:update(dt)
     if car1.x >= 600 then car1.x = -20 end
     car2.timer:update(dt)
     if car2.x == 180 then car2.k=0 end--ostanavlivaet marwrutku na ostanovke

      psystem:update(dt)
      psystem:emit(32)
      --upravlenie rabotaet tolko togda kogda pasazir ne v marwrutke
      if love.keyboard.isDown('left') and pers1.state ~= 'inc' then
        pers1.state = 'gl'
        pers1.x=pers1.x - (pers1.speed * dt)
      elseif love.keyboard.isDown('right') and pers1.state ~= 'inc' then
        pers1.state = 'gr'
        pers1.x = pers1.x + (pers1.speed * dt)
      elseif love.keyboard.isDown('up') and pers1.state ~= 'inc' then
        pers1.state = 'gt'
        pers1.y=pers1.y - (pers1.speed*dt)
      elseif love.keyboard.isDown('down') and pers1.state ~= 'inc' then
        pers1.state = 'gd'
        pers1.y=pers1.y + (pers1.speed*dt)
      else pers1.state = 's' end
      --ograni4enija po peredvizeniju personaza na pervom ekrane! i smena smena statusa na marwrutku
      if pers1.x <= 0 then pers1.x=pers1.x+1 end
      if pers1.x >= w-20 then pers1.x=pers1.x-1 end
      if pers1.y >= 285 then pers1.y=pers1.y-1 end
      if pers1.y <= 275 then pers1.y=pers1.y+1 end
      if pers1.y > 284 and pers1.y < 286 and pers1.x < 217 and pers1.x > 213 then pers1.state = 'inc' end
      --upravlenie bakgroundom
      if back.number == #back.pic-1 and back.x == 0 and game.state == 'drive' then
        game.state = 'priezd'  --ostanovka smena backgraunda smenit na blohu!? ili kak sdelat smenu sostojanija!?!!!
        pers1.state = 's' --vihod personaza iz mawini po priezdu!!!
        pers1.x = pers1.x + 1 --ustranjaem morganie personaza
        car2.k = 1 --zastavljaem marwrutku uehat
      end
      if game.state == 'drive' then back.x = back.x+1 end  --smeshenie vpravo
      if back.x >= w then
        back.number = back.number+1
        back.x = 0
       end
      end
      if game.state == 'priezd' then
        pers1.animationgoright:update(dt)
        pers1.animationgoleft:update(dt)
        pers1.animationgotop:update(dt)
        pers1.animationgdown:update(dt)
        --upravlenie rabotaet tolko togda kogda pasazir ne v marwrutke
        if love.keyboard.isDown('left') and pers1.state ~= 'inc' then
          pers1.state = 'gl'
          pers1.x=pers1.x - (pers1.speed * dt)
        elseif love.keyboard.isDown('right') and pers1.state ~= 'inc' then
          pers1.state = 'gr'
          pers1.x = pers1.x + (pers1.speed * dt)
        elseif love.keyboard.isDown('up') and pers1.state ~= 'inc' then
          pers1.state = 'gt'
          pers1.y=pers1.y - (pers1.speed*dt)
        elseif love.keyboard.isDown('down') and pers1.state ~= 'inc' then
          pers1.state = 'gd'
          pers1.y=pers1.y + (pers1.speed*dt)
        else pers1.state = 's' end
        --ograni4enija po peredvizeniju personaza na pervom ekrane! i smena smena statusa na marwrutku
        if pers1.x <= 0 then pers1.x=pers1.x+1 end
        if pers1.x >= w-20 then pers1.x=pers1.x-1 end
        if pers1.y >= 285 then pers1.y=pers1.y-1 end
        if pers1.y <= 275 then pers1.y=pers1.y+1 end
        if pers1.y > 275 and pers1.y < 277 and pers1.x < 67 and pers1.x > 62 then game.state = 'kiosk' end
        if pers1.y > 275 and pers1.y < 277 and pers1.x < 428 and pers1.x > 425 then game.state = 'save' end
     end

     if game.state == 'kiosk' then
       if love.keyboard.isDown('escape') then
          pers1.y = 270
          pers1.x = 60
          game.state = 'priezd'
       end


     end

     if game.state == 'save' then
         if love.keyboard.isDown('escape') then
            pers1.y =270
            pers1.x = 460
            game.state = 'priezd'
         end


     end

end



function love.draw()
  if game.state == 'drive' or game.state == 'start' then
    love.graphics.setBackgroundColor(19/255, 70/255, 139/255)--sinii
    love.graphics.draw(back.pic[back.number],back.x,back.y)
    love.graphics.draw(back.pic[back.number+1],back.x-w,back.y)--pitajus otobrazat srazy dva backgrounda

    animationsun:draw(sun, w/2,h/10)

    if pers1.state == 'gr' then pers1.animationgoright:draw(pers1.picgoright,pers1.x,pers1.y)
    elseif pers1.state == 'gl' then pers1.animationgoleft:draw(pers1.picgoleft,pers1.x,pers1.y)
    elseif pers1.state == 'gt' then pers1.animationgotop:draw(pers1.picgotop,pers1.x,pers1.y)
    elseif pers1.state == 'gd' then pers1.animationgdown:draw(pers1.picgodown,pers1.x,pers1.y)
    elseif pers1.state == 'inc' then game.state = 'drive' --zapuskaem backgrounda peremewenie
    else love.graphics.draw(pers1.frontpic,pers1.x,pers1.y) end

    love.graphics.draw(car2.pic,car2.x,car2.y)
    if game.state == 'start' then love.graphics.draw(car1.pic,car1.x,car1.y) end
    love.graphics.draw(psystem,-h/2,h/10)
  end
  if game.state == 'priezd' then
    love.graphics.setBackgroundColor(19/255, 70/255, 139/255)--sinii
    love.graphics.draw(back.pic[7],0,0)
    if pers1.state == 'gr' then pers1.animationgoright:draw(pers1.picgoright,pers1.x,pers1.y)
    elseif pers1.state == 'gl' then pers1.animationgoleft:draw(pers1.picgoleft,pers1.x,pers1.y)
    elseif pers1.state == 'gt' then pers1.animationgotop:draw(pers1.picgotop,pers1.x,pers1.y)
    elseif pers1.state == 'gd' then pers1.animationgdown:draw(pers1.picgodown,pers1.x,pers1.y)
    elseif pers1.state == 'inc' then game.state = 'drive' --zapuskaem backgrounda peremewenie
    else love.graphics.draw(pers1.frontpic,pers1.x,pers1.y) end
  end

  --love.graphics.print(game.state,170,40)
  --love.graphics.print(pers1.x,170,60)
  --love.graphics.print(pers1.y,170,80)
  if game.state == 'kiosk' then

  end
  if game.state == 'save' then

  end


--zdelat vid iz okna kioska!
--sdelat kartinku kioska,sdelat kartinki lic pokupatelei!!!
--sdelat sostojanie pokupatelja !
--posle popadanija v kiosk  igra idet toka v nem
--sohranenie vseh dannii igroka.

--kogda net pokupatelei sto dolzen videt prodavec iz kioska??!
--nuzen kakoito generator pokupatelei
--s naborom fraz
--nabor fraz prodavca i ego svoistva
--patom v kioske dolzen bit elementi upravlenija kioskom dlja raboti s pokupateljami





end
