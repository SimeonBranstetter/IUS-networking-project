local socket = require('socket') -- socket library setup
udp = socket.udp() -- sets up the udp socket for connections
udp:setsockname('*', 25565) -- * means bind to any interface, 2nd paramter is the port
udp:settimeout(0) -- time out for blocking set to 0, thus always blocking

-- LOVE engines variables and function initializing section
function love.load()
	fullRecSize = 30 -- size of squares to be drawn
	currentTurn = false -- is it your turn?
	skip = false -- dummy variable used for proccessing positional data
	boats = 5 -- number of boats
	boatLocations = {} -- table full of smaller tables in {x, y} format indicating boat locations
	love.graphics.setBackgroundColor(0.4, 0.2, 0)

	-- left side grid for players boats
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

	-- right side grid for player 1's interpretation of player2's boat grid in which player 1 can not see player 2's boat locations
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

-- callback function called constantly for drawing graphics
function love.draw()
	
	local function drawGrid()
		love.graphics.translate(150, 150)

		-- draws the first grid (left most grid)
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

		-- draws the 2nd grid (right most grid)
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

-- callback function called constantly, this is where the networking happens
function love.update()
	data, msg_or_ip, port_or_nil = udp:receivefrom() -- receives the data along with IP and port
	if data and data ~= 'hi' then -- if data exists and does not equal 'hi', a dummy value constantly sent to establish connection
		if data == 'true' then -- tells server that client has fully set up his ships
			print(data)
			currentTurn = true
		elseif data == 'hit' then -- client sent back a 'hit' to let server know that said area that was pressed in battlegrid had a boat
			print(data)
			battleGrid[xPos][yPos] = 'r'
			access = false -- data for a hit has been received, stop sending coordinate data
		elseif data == 'miss' then -- client sent back a 'miss' to let server know that said area that was pressed in battlegrid did not have a boat
			print(data)
			battleGrid[xPos][yPos] = 'w'
			access = false -- data for a miss has been received, stop sending coordinate data
		else -- if data is not above then data must be positional data in the form 'x-y'
			p = split(data, '-') -- calls split function to split the data 'x-y' into a table
			for key, tbl in ipairs(boatLocations) do
				if tbl[1] == tonumber(p[1]) and tbl[2] == tonumber(p[2]) then -- if data received that was split matches a coordinate in boatlocations then...
					udp:sendto('hit', msg_or_ip, port_or_nil) -- tell client that area was a hit
					boatGrid[tonumber(p[1])][tonumber(p[2])] = 'r'
					skip = true -- dummy variable defined above to tell section below to skip sending a 'miss' string since coordinate was a hit
					break
				end
			end

			if not skip then -- if data was a hit skip this, if not, then...
				udp:sendto('miss', msg_or_ip, port_or_nil) -- tell client that area was a miss
				boatGrid[tonumber(p[1])][tonumber(p[2])] = 'w'
			end

			currentTurn = true -- coordinate data was proccessed thus it means they picked a spot and thus means it is now your turn
			skip = false -- reset dummy variable for sending the 'miss' data to client
		end
	end

	-- send positional data 'x-y' if you have access to this statement as if xPos and yPos are holding valid coordinates and that data received is the dummy value
	if access and xPos ~= nil and yPos ~= nil and data == 'hi' then
		udp:sendto(tostring(xPos) .. '-' .. tostring(yPos), msg_or_ip, port_or_nil) -- send coordinate data to client in string form 'x-y'
	end
end

-- function used to properly split client coordinate data into a table for easy access
function split(s, delimiter)
	result = {}
	for match in (s..delimiter):gmatch("(.-)"..delimiter) do -- uses pattern matching to look for the delimeter '-' which indicates seperation of data
		table.insert(result, match)
	end
	return result -- return the table with properly parsed data
end

-- callback function called only when player presses down on mouse
function love.mousepressed(x, y, button, istouch)

	local function findCursor()
		local minOffX1, minOffY1 = 150, 150 -- offsets for grid one for cursor finding below
		local minOffX2, minOffY2 = 480, 150 -- offsets for grid two for cursor finding below


		-- if player still has boat and mouse is in area of boat grid then...
		if boats > 0 and x >= minOffX1 and y >= minOffY1 then
			for col = 1, 10 do
				if x >= minOffX1 and x < minOffX1 + (fullRecSize - 2) then
					for sqr = 1, 10 do
						if y >= minOffY1 and y < minOffY1 + (fullRecSize - 2) then
							if button == 1 then -- if the mouse press was a left click
								if boatGrid[sqr][col] == 'e' then -- if the space is empty
									boatGrid[sqr][col] = 'b' -- put a boat in that area pressed by mouse
									table.insert(boatLocations, {sqr, col}) -- insert its coordinates into the table holding all boat coordinates
									boats = boats - 1 -- decrement boats
									break
								else -- if space was not empty, disregard and try again
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


		-- if player has no more boats and it is his turn and his mouse is in the area for the battle grid then...
		if boats == 0 and currentTurn and x >= minOffX2 and y >= minOffY2 then
			for col = 1, 10 do
				if x >= minOffX2 and x < minOffX2 + (fullRecSize - 2) then
					for sqr = 1, 10 do
						if y >= minOffY2 and y < minOffY2 + (fullRecSize - 2) then
							if button == 1 then -- if the mouse press was a left click
								if battleGrid[sqr][col] == 'e' then -- if the space is empty
									xPos, yPos = sqr, col -- update global variables used in love.update callback for the sending of new coordinate data to client
									currentTurn = false -- mouse press has happened, thus turn is over
									access = true -- dummy variable used for opening and closing the access to the constant sending of data
									break
								else -- if space was not empty, disregard and try again
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
