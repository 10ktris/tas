function start()
	vba.print("--------------Start script--------------")
end

function stop()
	vba.print("--------------End script--------------")
end

function warning()
	gui.box(78, 125, 164, 135, "red", "red")
	gui.text(80, 127, "/\\ NOT RECORDING ! /\\", "yellow")
end

function readvalue(adr)
	value = nil
	if adr.lenght == 1 then
		if adr.sign == "signed" then
			value = memory.readbytesigned(adr.adresse)
		else
			value = memory.readbyteunsigned(adr.adresse)
		end
	elseif adr.lenght == 2 then
		if adr.sign == "signed" then
			value = memory.readwordsigned(adr.adresse)
		else
			value = memory.readwordunsigned(adr.adresse)
		end
	elseif adr.lenght == 4 then
		if adr.sign == "signed" then
			value = memory.readdwordsigned(adr.adresse)
		else
			value = memory.readdwordunsigned(adr.adresse)
		end
	end
	return value
end

function show_value(adr)
	value = readvalue(adr)
	x = adr.x
	y = adr.y
	color = adr.color
	if string.sub(adr.name, 1, 1) == "\\" then
		txt = string.sub(adr.name, 2)..value
	else
		txt = adr.name..": "..value
	end
	if adr.format == nil then
		gui.text(x, y, txt, color)
	else
		if value == nil or adr.format[value] == nil then
			txt = "nil"
		else
			if not (adr.format[value].text == nil) then
				if string.sub(adr.name, 1, 1) == "\\" then
					txt = string.sub(adr.name, 2)..adr.format[value].text
				else
					txt = adr.name..": "..adr.format[value].text
				end
			end
			if not (adr.format[value].x == nil) then
				x = adr.format[value].x
			end
			if not (adr.format[value].y == nil) then
				y = adr.format[value].y
			end
			if not (adr.format[value].color == nil) then
				color = adr.format[value].color
			end
		end
		gui.text(x, y, txt, color)
	end
end

function env()
	floor = readvalue({["adresse"] = 0x03007C82, ["lenght"] = 1, ["sign"] = "signed"})
	area = readvalue({["adresse"] = 0x02010E06, ["lenght"] = 1, ["sign"] = "signed"})
	areab = readvalue({["adresse"] = 0x02010DD1, ["lenght"] = 1, ["sign"] = "signed"})
	txt = ""
	color = "white"
	if area == 1 or area == 2 or areab == 1 or areab == 32 then
		if floor == 0 then
			txt = "GROUND"
		elseif floor == 2 then
			txt = "AIR"
		end
	elseif area == 5 or area == 9 then
		txt = "WATER"
	elseif area == -37 then
		txt = "POLAR"
	elseif area == 119 then
		txt = "FLYING"
	end
	return txt
end

function show_env()
	colors = {["WATER"] = "#0090FF", ["FLYING"] = "#DBB84D", ["GROUND"] = "#999900", ["AIR"] = "#66FFCC"}
	txt = env()
	color = colors[txt]
	gui.text(1, 102, txt, color)
end

function main()
	common_lvl = {{["name"] = "mask", ["adresse"] = 0x0200009C, ["lenght"] = 1, ["sign"] = "signed", ["x"] = 1, ["y"] = 85, ["color"] = "green"},
				  {["name"] = "lives", ["adresse"] = 0x02000098, ["lenght"] = 1, ["sign"] = "signed", ["x"] = 156, ["y"] = 3, ["color"] = "white"},
				  {["name"] = "apples", ["adresse"] = 0x02000090, ["lenght"] = 1, ["sign"] = "signed", ["x"] = 45, ["y"] = 3, ["color"] = "white"},
				  {["name"] = "boxes", ["adresse"] = 0x02000094, ["lenght"] = 1, ["sign"] = "signed", ["x"] = 95, ["y"] = 3, ["color"] = "white"},
				  {["name"] = "\\/", ["adresse"] = 0x020000E0, ["lenght"] = 2, ["sign"] = "signed", ["x"] = 136, ["y"] = 3, ["color"] = "whithe"}}
				  -- values displayed only during normal lvl
	common_lvl_func = {show_env}
	spec_common_lvl = {[0] = {}} -- additionnal values (normal lvl)
	spec_common_lvl_func = {[0] = {}}

	boss_lvl = {{["name"] = "Lives", ["adresse"] = 0x02000098, ["lenght"] = 1, ["sign"] = "signed", ["x"] = 8, ["y"] = 33, ["color"] = "white"}} -- only for boss
	boss_lvl_func = {}
	spec_boss_lvl = {[20] = {{["name"] = "Shield", ["adresse"] = 0x02003EFC, ["lenght"] = 1, ["sign"] = "signed", ["x"] = 100, ["y"] = 18, ["color"] = "white", 
					    			["format"] = {[0] = {["color"] = "red", ["text"] = "Off"}, [1] = {["color"] = "green", ["text"] = "On"}}}}} -- additionnal values (boss lvl)
	spec_boss_lvl_func = {[20] = {}}

	warproom_lvl = {{["name"] = "Lives", ["adresse"] = 0x02000098, ["lenght"] = 1, ["sign"] = "signed", ["x"] = 100, ["y"] = 18, ["color"] = "white"},
				    {["name"] = "Mask", ["adresse"] = 0x0200009C, ["lenght"] = 1, ["sign"] = "signed", ["x"] = 104, ["y"] = 25, ["color"] = "green"}}

	GROUND_AIR = {{["name"] = "spdX", ["adresse"] = 0x02010A74, ["lenght"] = 2, ["sign"] = "signed", ["x"] = 5, ["y"] = 30, ["color"] = "orange"},
				  {["name"] = "spdY", ["adresse"] = 0x02010A78, ["lenght"] = 2, ["sign"] = "signed", ["x"] = 5, ["y"] = 37, ["color"] = "orange"},
				  {["name"] = "posX", ["adresse"] = 0x02010A80, ["lenght"] = 4, ["sign"] = "unsigned", ["x"] = 5, ["y"] = 44, ["color"] = "orange"},
				  {["name"] = "posY", ["adresse"] = 0x02010A84, ["lenght"] = 4, ["sign"] = "unsigned", ["x"] = 5, ["y"] = 51, ["color"] = "orange"},
				  {["name"] = "posX nxt", ["adresse"] = 0x02010A14, ["lenght"] = 4, ["sign"] = "unsigned", ["x"] = 5, ["y"] = 58, ["color"] = "orange"},
				  {["name"] = "posY nxt", ["adresse"] = 0x02010A18, ["lenght"] = 4, ["sign"] = "unsigned", ["x"] = 5, ["y"] = 65, ["color"] = "orange"},
				  {["name"] = "spin/slide cd", ["adresse"] = 0x02010DDC, ["lenght"] = 1, ["sign"] = "signed", ["x"] = 1, ["y"] = 118, ["color"] = "teal"}}

	WATER = {{["name"] = "spdX", ["adresse"] = 0x02010A74, ["lenght"] = 2, ["sign"] = "signed", ["x"] = 5, ["y"] = 30, ["color"] = "orange"},
		     {["name"] = "spdY", ["adresse"] = 0x02010A78, ["lenght"] = 2, ["sign"] = "signed", ["x"] = 5, ["y"] = 37, ["color"] = "orange"},
		     {["name"] = "posX", ["adresse"] = 0x02010A80, ["lenght"] = 4, ["sign"] = "unsigned", ["x"] = 5, ["y"] = 44, ["color"] = "orange"},
		     {["name"] = "posY", ["adresse"] = 0x02010A84, ["lenght"] = 4, ["sign"] = "unsigned", ["x"] = 5, ["y"] = 51, ["color"] = "orange"},
		     {["name"] = "posX nxt", ["adresse"] = 0x02010A14, ["lenght"] = 4, ["sign"] = "unsigned", ["x"] = 5, ["y"] = 58, ["color"] = "orange"},
		     {["name"] = "posY nxt", ["adresse"] = 0x02010A18, ["lenght"] = 4, ["sign"] = "unsigned", ["x"] = 5, ["y"] = 65, ["color"] = "orange"},
		     {["name"] = "spin progress", ["adresse"] = 0x02010DDC, ["lenght"] = 1, ["sign"] = "signed", ["x"] = 1, ["y"] = 118, ["color"] = "teal"},
		     {["name"] = "spin cd", ["adresse"] = 0x02010DE7, ["lenght"] = 1, ["sign"] = "signed", ["x"] = 1, ["y"] = 125, ["color"] = "teal"}}

	env_func = {["FLYING"] = {}}

	env_adr = {["FLYING"] = {{["name"] = "Cooldown", ["adresse"] = 0x030014E0, ["lenght"] = 1, ["sign"] = "unsigned", ["x"] = 1, ["y"] = 110, ["color"] = "teal"}},
			   ["GROUND"] = GROUND_AIR,
			   ["AIR"] = GROUND_AIR,
			   ["WATER"] = WATER}

	adr_lvl = {["adresse"] = 0x020000E8, ["lenght"] = 1, ["sign"] = "unsigned"}
	adr_lvl_type = {["adresse"] = 0x02003AB8, ["lenght"] = 1, ["sign"] = "signed"}
	while true do
		lvl = readvalue(adr_lvl)
		lvl_type = readvalue(adr_lvl_type)
		if lvl_type == 64 then -- warp room /// and 128 ?
			for num, val in pairs(warproom_lvl) do show_value(val) end
		else
			if lvl < 20 then -- common lvl
				for num, val in pairs(common_lvl) do show_value(val) end
				for num, func in pairs(common_lvl_func) do func() end
			else -- boss lvl
				for num, val in pairs(boss_lvl) do show_value(val) end
				if not (spec_boss_lvl[lvl] == nil) then
					for num, val in pairs(spec_boss_lvl[lvl]) do show_value(val) end
				end
				if not (spec_boss_lvl_func[lvl] == nil) then
					for num, func in pairs(spec_boss_lvl_func[lvl]) do func() end
				end
			end
			-- env
			if not (env_func[env()] == nil) then
				for num, func in pairs(env_func[env()]) do func() end
			end
			if not (env_adr[env()] == nil) then
				for num, val in pairs(env_adr[env()]) do show_value(val) end
			end
			show_env()
		end

		if not movie.recording() then
			warning()
		end
		if movie.active() then gui.text(1,0,"RR: " .. movie.rerecordcount()) end
		vba.frameadvance()
	end
end

vba.registerexit(stop)
start()
main()

-- adresses
-- Fly lvl : "Boss" pos x : 0x03001520

-- ingame frame : 0x030007D8 4b unsigned
-- level duration : 0x0300082C 4b unsigned