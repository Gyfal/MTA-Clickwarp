


function warpPed (vehicle, seat)
    if client then
        warpPedIntoVehicle (client, vehicle, seat)   
    end 
end

addEvent("ClickWarp[Teleport]", true)
addEventHandler("ClickWarp[Teleport]", resourceRoot, warpPed)

