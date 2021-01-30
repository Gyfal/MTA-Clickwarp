local isMinimuze = false;
local cursorEnable = false;
local sw,sh = guiGetScreenSize()
local marker;


-- CFG
local keyToggle = "mouse3" -- actived script
local keyApply =  "mouse1" -- teleport 
local keyOnCar = "mouse2" -- сonfirmation for teleporting to the car
local sizePickup = 1.5

function isPauseMenuActive()
	return isMTAWindowActive() or isMinimuze or isConsoleActive() or false 
end


function click()
	if isPauseMenuActive() then
		if cursorEnable and isCursorShowing() then
			showCursor(false)
		end 
	end 
	if cursorEnable and not isCursorShowing() then
		showCursor(true)
	end

	if cursorEnable and not isPauseMenuActive() then
		local sx, sy, posX, posY, posZ = getCursorPosition()
		if sx >= 0 and sy >= 0 and sx < sw and sy < sh then
			local camera = {getCameraMatrix()}
			local result, x,y,z,object,normalX, normalY, normalZ,material,lighting,piece = processLineOfSight(camera[1], camera[2], camera[3], posX, posY, posZ, true, true, false, true, false, false, false)
			if result then
				local curX, curY, curZ = getElementPosition(getLocalPlayer())
				local normal = {normalX, normalY, normalZ};
				local hitCord = {x,y,z}
				local car_info;
				local pos = Vector3(hitCord[1], hitCord[2], hitCord[3]) - (Vector3(normal[1], normal[2], normal[3]) * 0.1)
				local zOffset = 300
				if normal[3] >= 0.5 then zOffset = 1 end
				local result, x,y,z = processLineOfSight(pos:getX(), pos:getY() , pos:getZ() + zOffset, pos:getX(), pos:getY() , pos:getZ() - 0.3,  true, true, false, true, false, false, false)
				
				-- corrector Z
				if result then
					pos = Vector3(x,y,z + 1)
				end
				
				-- delete last marker and create new marker
				if isElement(marker) then
					destroyElement(marker)
				end
				marker = createMarker(pos:getX(), pos:getY() , pos:getZ() + 0.5,"arrow", sizePickup, 255,255,255)
				
				-- Car info
				if object and getElementType(object) == "vehicle" and not getPedOccupiedVehicle(localPlayer) then
					local idCar = getElementModel(object);
					local name = getVehicleName(object);
					car_info = object;
					dxDrawText(string.format("Hold right mouse button to teleport into the car Vehicle: %s[%d]", name,idCar), sw * sx + 40  , sh * sy - 20 )
				end
				-- dist to point
				local dist = getDistanceBetweenPoints3D(curX, curY, curZ, pos)
				dxDrawText(string.format("Distance: %0.2fm ", dist), sw * sx + 40  , sh * sy )
				
				if getKeyState(keyApply) then
					local car = isCharInAnyCar(car_info) 
					if car then
						-- If the player is already in the car
						if getPedOccupiedVehicle(localPlayer) then
							teleport(car,pos)
						elseif getKeyState(keyOnCar) then -- if press mouse2 and mouse 1 > Teleport to the car
							if CarSeat(object) then -- We get the number of the free passenger seat
								triggerServerEvent("ClickWarp[Teleport]", resourceRoot, object, CarSeat(object))
							else -- If there are no seats available
								teleport(false,pos)
							end
						end
					else -- teleport from your feet
						teleport(false,pos)
					end
					removeMark()
				end 
			end 
		end
	end
end


function teleport(vehicle,pos)
	if getPedOccupiedVehicle(localPlayer) then
		setElementVelocity(vehicle,0,0,0)  -- Stop the car
	end
	setElementPosition (vehicle and vehicle or localPlayer, pos)
end


function isCharInAnyCar(veh)
	return veh or getPedOccupiedVehicle(localPlayer)
end

function CarSeat(veh)
	for i = 0, getVehicleMaxPassengers(veh) do
		if not getVehicleOccupants(veh)[i] then return i end
	end
	return false 
end

		
function removeMark()
	start()
	if isElement(marker) then
		destroyElement(marker)
	end
end


--

function start()
	cursorEnable = not cursorEnable
	showCursor(cursorEnable)
	if not cursorEnable then 
		removeEventHandler("onClientRender", root, click)
	else
		addEventHandler("onClientRender", root, click)
	end
end


function resourceInit()
	outputChatBox("[clickwarp] press "..keyToggle.." to activate")
	bindKey(keyToggle, "down", start)
end

addEventHandler("onClientResourceStart", resourceRoot, resourceInit)


function onClientMinimize()
    isMinimuze = true
end
addEventHandler( "onClientMinimize", root , onClientMinimize )

function onClientRestore()
    isMinimuze = false 
end
addEventHandler("onClientRestore", root ,onClientRestore)

