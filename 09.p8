pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--gameloop and init
function _init()
 cls()
 my_update = update_game
 my_draw = draw_game

--global variables
bg_color = 1

--screen
█ = 
	{
	x1 = 0,
	y1 = 8,
	x2 = 127,
	y2 = 127,
	}

--ball
● =
 {
	x = 64,   --center x loc
	y = 64,   --center y loc
	dx = 0,   --where to move
	dy = 0,   --where to move
	r = 2,    --radius 
	c = 9,    --color
	hdir = 1, --horiz dir
	vdir = 1, --vert dir
	hvel = 1, --horiz velocity
	vvel = 1,  --vertical velocity
	hit = false, --hit this frame
	➡️ = 0,
	⬇️ = 0,
	⬆️ = 0,
	⬅️ = 0,
	}

--paddle
pad =
 {
 x=90,
 dx=0,
 y=115,
 dy=0,
 w=28,
 h=4,
 c=7,
 maxspd = 2.5,
 slow = 1.2,
 }
 
--sfx
hitwall = 0
hitpaddle = 1
die = 2

--lives
♥_max = 5
♥_cur = 3
♥_full = 6 --sprite
♥_now = 7 --sprite
♥_mt = 8 --sprite
♥_x = 1
♥_space = 4
♥_yup = 1
♥_ydown = 3

brick =
 {
 x=30,
 y=30,
 w=50,
 h=4,
 c=14,
 vis=true,
 }

end

function _update60()
 my_update()
end

function _draw()
	my_draw()
end

-->8
--ball functions--

function next●()
 --balls new location if there
 --is no collision
	●.dx = ●.x+(●.hvel*●.hdir)
	●.dy = ●.y+(●.vvel*●.vdir)
end

function ●edges()
 ●.➡️ = ●.dx + ●.r
 ●.⬇️ = ●.dy + ●.r
 ●.⬅️ = ●.dx - ●.r
 ●.⬆️ = ●.dy - ●.r
end

function screencollide●()
	if ●.➡️ > █.x2 then
		●.dx = █.x2 - ●.r
		sfx(hitwall)
		fliph()
	elseif ●.⬅️ < █.x1 then
	 ●.dx = █.x1 + ●.r
	 sfx(hitwall)
	 fliph()
	end
	
	if ●.⬆️ < █.y1 then
	 ●.dy = █.y1 + ●.r
	 sfx(hitwall)
		flipv()
	end
	
	if ●.⬇️ > █.y2 then
	 if ♥_cur > 0 then
	 serveball()
	 ♥_cur -= 1
	 sfx(die)
	 end
	end
	
end

function ●_col(x,y,w,h)
	if ●.➡️ < x
	or ●.⬅️ > x+w
	or ●.⬇️ < y
	or ●.⬆️ > y+h then
 	return false
 else
 	return true	
 end
end

function move●()
	●.x = ●.dx
	●.y = ●.dy
end

function fliph()
 ●.hdir *= -1
end

function flipv()
	●.vdir *= -1
end

function serveball()
	--setup serving the ball.
	if ♥_cur > 1 then
 ●.x = 64
 ●.y = 64
 ●.dx = 64
 ●.dy = 64
 ●.vvel = 1
 ●.hvel = 1
 end
end
-->8
--draw functions

function screenbox()
	rect(█.x1-1,█.y1-1,█.x2+1,█.y2+1)
end

function draw●()
	circfill(●.x,●.y,●.r,●.c)
end

function draw_paddle()
 rectfill(pad.x,pad.y,pad.x+pad.w,pad.y+pad.h,pad.c)
end

function draw♥()
	x = ♥_x
	y = ♥_yup
	
	♥_todraw = ♥_cur
	
	for i=1,(♥_max) do
		if ♥_todraw > 1 then
			spr(♥_full, x, y)
			♥_todraw -= 1
		elseif ♥_todraw == 1 then
			spr(♥_now, x, y)
			♥_todraw -= 1
		else
			spr(♥_mt, x,y)
		end
				
		if y == ♥_yup then
			y = ♥_ydown
		else
			y = ♥_yup
		end	
		
		x += ♥_space
	end
end

function draw_brick()
 if brick.vis then
 rectfill(brick.x,brick.y,brick.x+brick.w,brick.y+brick.h,brick.c)
 end
end

function ui()
 --top bar
	rectfill(0,0,127,7,0)
	
	--hearts
	draw♥()
end
-->8
--input

function paddleinput()
	if btn(⬅️) and pad.dx > -pad.maxspd then
		pad.dx-=1
	end
		
	if btn(➡️) and pad.dx < pad.maxspd then
		pad.dx+=1
	end
		
	if not btn(➡️) and not btn(⬅️) then
		pad.dx/=pad.slow
	end
		
	pad.x+=pad.dx
end


-->8
--paddle

function screencolpad()
	if pad.x+pad.w > █.x2 then
		pad.x = █.x2-pad.w
		pad.dx = 0
	elseif pad.x < █.x1 then
		pad.x = █.x1
		pad.dx = 0
	end
end

function ●_check(x,y,w,h,dx)
	if	●_col(x,y,w,h) then
	 ●_deflect(x,y,w,h,dx)
	end
end

function ●_deflect(x,y,w,h,dx)
	if mid(●.y,y,●.⬇️) == y then
	 --going from the top.
	 ●.dy = y-●.r-1
	 sfx(hitpaddle)
	 flipv()
	elseif mid(●.y,y+h,●.⬆️) == y+h then
	 ●.dy = y+h+●.r+1
	 sfx(hitpaddle)
	 flipv()
	elseif mid(●.x,x,●.➡️) == x then
		●.dx = x-●.r-1
		sfx(hitpaddle)
		fliph()
	elseif mid(●.x,x+w,●.⬅️) == x+w then
		●.dx = x+w+●.r+1
		sfx(hitpaddle)
		fliph()
	elseif ●.x < x+(w/2) then
		●.dx = x-●.r-1
		●.hvel += abs(dx)
		sfx(hitpaddle)
	elseif ●.x > x+(w/2) then
		●.dx = x+w+●.r+1
		●.hvel += abs(dx)
		sfx(hitpaddle)
	end
end
-->8
--bricks and powerups

function ▒_check(x,y,w,h,dx)
 if brick.vis then
		if	●_col(x,y,w,h) then
		 ▒_deflect(x,y,w,h,dx)
		 brick.vis = false
		end
	end
end

function brickcol()
		brick.c=3
end

function ▒_deflect(x,y,w,h,dx)
	if mid(●.y,y,●.⬇️) == y then
	 --going from the top.
	 ●.dy = y-●.r-1
	 sfx(hitpaddle)
	 flipv()
	elseif mid(●.y,y+h,●.⬆️) == y+h then
	 ●.dy = y+h+●.r+1
	 sfx(hitpaddle)
	 flipv()
	elseif mid(●.x,x,●.➡️) == x then
		●.dx = x-●.r-1
		sfx(hitpaddle)
		fliph()
	elseif mid(●.x,x+w,●.⬅️) == x+w then
		●.dx = x+w+●.r+1
		sfx(hitpaddle)
		fliph()
	elseif ●.x < x+(w/2) then
		●.dx = x-●.r-1
		●.hvel += abs(dx)
		sfx(hitpaddle)
	elseif ●.x > x+(w/2) then
		●.dx = x+w+●.r+1
		●.hvel += abs(dx)
		sfx(hitpaddle)
	end
end
-->8
--scenes--


-- start!! --
function draw_start()
 cls()
end

function update_start()

end

--game!--
function draw_game()
	cls(1)
	draw_paddle()
 draw●()
 draw_brick()
 ui()
end

function update_game()
 paddleinput()
 screencolpad()
 next●()
 ●edges()
 
 --check paddle with ball
 ●_check(pad.x,pad.y,pad.w,pad.h,pad.dx)
 
 ▒_check(brick.x,brick.y,brick.w,brick.h,brick.dx)
 
 screencollide●()
 
 move●()
end

--gameover!--
function draw_gameover()
 cls()
end

function update_gameover()

end
__gfx__
000000000000000000000a9000aa000000000000000000000aa00000099000000770000000000000000000000000000000000000000000000000000000000000
00000000000aaa000000a79000a790000aa7aaa900000000a7aa0000979900007007000000000000000000000000000000000000000000000000000000000000
0070070000aa7a9000007a90007a90000a7aaaa400000000aaaa0000999900007007000000000000000000000000000000000000000000000000000000000000
0007700000a7aa900000aa9000aa900000aa994000a7aa900aa00000099000000770000000000000000000000000000000000000000000000000000000000000
0007700000aaa9400000aa9000aa9000000000000a7aaaa400000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000994000000aa9000aa4000000000000a99444400000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000094000940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000147400f7500c7400a740097300771007700173001230011300133001c1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000127200c7200c72010730157501d7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000013320113300e3300c3400b340093300732005320023200031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
