--client side, to be started after server is running

local socket = require "socket"
local address, port = "", 25565 --ip address and socket used for server
udp = socket.udp()
udp:setpeername(address, port) 
udp:settimeout(0)

function love.load()
	fullRecSize = 30
	currentTurn = false
	skip = false
	access = false
	boats = 5 --starting number of boats
	boatLocations = {}
	love.graphics.setBackgroundColor(0.4, 0.2, 0)

	-- grid to place users boats 
	boatGrid = { 
		{'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e'},
		{'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e'},
		{'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e'},
		{'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e'},
		{'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e'},
		{'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e'},
		{'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e'},
		{'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e'},
		{'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e'},
		{'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e'}
	}

	-- grid to guess opponets locations 
	battleGrid = {
		{'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e'},
		{'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e'},
		{'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e'},
		{'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e'},
		{'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e'},
		{'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e'},
		{'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e'},
		{'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e'},
		{'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e'},
		{'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e'}
	}
end

--fills grid with appropiate colors, updates if changed during game
function love.draw()
	
	local function drawGrid()
		love.graphics.translate(150, 150)

		for y, row in ipairs(boatGrid) do
			for x, cell in ipairs(row) do
				if cell == 'e' then
					love.graphics.setColor(0, 0, 0.3)
					love.graphics.rectangle("fill", (x - 1) * fullRecSize, (y - 1) * fullRecSize, fullRecSize - 2, fullRecSize - 2)
				elseif cell == 'b' then
					love.graphics.setColor(0.3, 0.3, 0.3)
					love.graphics.rectangle("fill", (x - 1) * fullRecSize, (y - 1) * fullRecSize, fullRecSize - 2, fullRecSize - 2)
				elseif cell == 'r' then
					love.graphics.setColor(1, 0, 0.1)
					love.graphics.rectangle("fill", (x - 1) * fullRecSize, (y - 1) * fullRecSize, fullRecSize - 2, fullRecSize - 2)
				elseif cell == 'w' then
					love.graphics.setColor(1, 1, 1)
					love.graphics.rectangle("fill", (x - 1) * fullRecSize, (y - 1) * fullRecSize, fullRecSize - 2, fullRecSize - 2)
				end
			end
		end

		for y, row in ipairs(battleGrid) do
			for x, cell in ipairs(row) do
				if cell == 'e' then
					love.graphics.setColor(0, 0, 0.3)
					love.graphics.rectangle("fill", (x + 10) * fullRecSize, (y - 1) * fullRecSize, fullRecSize - 2, fullRecSize - 2)
				elseif cell == 'b' then
					love.graphics.setColor(0.3, 0.3, 0.3)
					love.graphics.rectangle("fill", (x + 10) * fullRecSize, (y - 1) * fullRecSize, fullRecSize - 2, fullRecSize - 2)
				elseif cell == 'r' then
					love.graphics.setColor(1, 0, 0.1)
					love.graphics.rectangle("fill", (x + 10) * fullRecSize, (y - 1) * fullRecSize, fullRecSize - 2, fullRecSize - 2)
				elseif cell == 'w' then
					love.graphics.setColor(1, 1, 1)
					love.graphics.rectangle("fill", (x + 10) * fullRecSize, (y - 1) * fullRecSize, fullRecSize - 2, fullRecSize - 2)
				end
			end
		end
	end
	drawGrid()
end


function love.update()

	if access == true then --if there has not been a hit or miss response from users guess send the guess again
		udp:send(tostring(xPos) .. '-' .. tostring(yPos))
	else 
		udp:send('hi') --dummy packet so server can use to get port number to respond to when it is not clients turn
	end

	data = udp:receive() --if data receive it
	--print(data)
	if data then
		if data == 'hit' then -- received a hit response from server 
			print(data)
			battleGrid[xPos][yPos] = 'r' --change position on battlegrid to reflect hit (red square)
			access = false --received a response from server so client can stop sending guess location
		elseif data == 'miss' then
			print(data)
			battleGrid[xPos][yPos] = 'w' --change position on battlegrid to reflect miss (white square)
			access = false --received a response from server so client can stop sending guess location 
		else --only other data to receive is servers guess
			print(data)
			p = split(data, '-') --parse the string into indexes
			for key, tbl in ipairs(boatLocations) do
				if tbl[1] == tonumber(p[1]) and tbl[2] == tonumber(p[2]) then
					udp:send('hit') -- if servers guess was a location in client boat locations then send a hit 
					boatGrid[tonumber(p[1])][tonumber(p[2])] = 'r' --change on clients boat grid where server guessed and missed (white)
					skip = true --miss will not be sent
					break 
				end
			end

			if not skip then
				udp:send('miss') -- servers guess was not a location in clients boat locations
				boatGrid[tonumber(p[1])][tonumber(p[2])] = 'w' --change on clients boat grid where server guessed and missed (white)
			end

			currentTurn = true -- coordinates received so this means it is now clients turn
			skip = false
		end
	end
end


function love.mousepressed(x, y, button, istouch)
	local function findCursor()
		local minOffX1, minOffY1 = 150,150
		local minOffX2, minOffY2 = 480,150

		-- find cursor for grid 1 when placing boats at beggining of game
		if boats > 0 and x >= minOffX1 and y >= minOffY1 then
			for col = 1, 10 do
				if x >= minOffX1 and x < minOffX1 + (fullRecSize - 2) then
					for sqr = 1, 10 do
						if y >= minOffY1 and y < minOffY1 + (fullRecSize - 2) then
							if button == 1 then --if mouse click was left click
								if boatGrid[sqr][col] == 'e' then
									boatGrid[sqr][col] = 'b'
									table.insert(boatLocations, {sqr, col}) -- insert clients boat placements into boatLocations table
									boats = boats - 1 
									if boats == 0 then 
										udp:send('true') -- client has all boats set up, alert server that it is their turn
									end
									break
								else
									break
								end
							end
						else
							minOffY1 = minOffY1 + 30
						end
					end
					
					break
				else
					minOffX1 = minOffX1 + 30
				end
			end
		end

		-- find cursor for grid 2, this is cleints guess
		if boats == 0 and currentTurn and x >= minOffX2 and y >= minOffY2 then
			for col = 1, 10 do
				if x >= minOffX2 and x < minOffX2 + (fullRecSize - 2) then
					for sqr = 1, 10 do
						if y >= minOffY2 and y < minOffY2 + (fullRecSize - 2) then
							if button == 1 then --if mouse click was left click
								if battleGrid[sqr][col] == 'e' then
									xPos, yPos = sqr, col -- xPos and yPos positions of guess for cleint, xPos yPos will be sent to server
									access = true -- client can now send locations to server 
									currentTurn = false --client took guess so now turn is over
									break
								else
									break
								end
							end
						else
							minOffY2 = minOffY2 + 30
						end
					end
					
					break
				else
					minOffX2 = minOffX2 + 30
				end
			end
		end
	end
	findCursor()
end

--parse the locations received and insert them into a table to compare to clients boatLocations table
function split(s, delimiter)
	result = {}
	for match in (s..delimiter):gmatch("(.-)"..delimiter) do --parses data at each '-'
		table.insert(result, match)
	end
	return result
end
