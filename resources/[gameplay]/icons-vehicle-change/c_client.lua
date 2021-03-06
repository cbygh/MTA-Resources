local signs = {
	-- checkpoint { type: String, showSign: boolean, x, y, z: int, guiImage}
}
local cpIds = {}
local enabled = true

local drawDistance = 150

local screenSizeX, screenSizeY = guiGetScreenSize()
local guiX = screenSizeX * 0.1
local guiY = screenSizeX * 0.1
local globalScale = 5
local globalAlpha = .50

function renderIcons()
	for i, cpId in ipairs(cpIds) do
		if signs[cpId].showSign and signs[cpId].z and enabled then
			local playerx, playery, playerz = getCameraMatrix()
			local dist = getDistanceBetweenPoints3D(signs[cpId].x, signs[cpId].y, signs[cpId].z, playerx, playery, playerz)
			if dist < drawDistance and (isLineOfSightClear(signs[cpId].x, signs[cpId].y, signs[cpId].z+2.5, playerx, playery, playerz, true, false, false, false)) then
				local screenX, screenY = getScreenFromWorldPosition(signs[cpId].x, signs[cpId].y, signs[cpId].z+2.5)
				if (screenX and screenY) then
					local scaled = screenSizeX * (1/(2*(dist+5))) *.60
					local relx, rely = scaled * globalScale, scaled * globalScale
					guiSetAlpha(signs[cpId].guiImage, globalAlpha)
					guiSetSize(signs[cpId].guiImage, relx, rely, false)
					guiSetPosition(signs[cpId].guiImage, screenX - (relx / 2), screenY, false)
					guiSetVisible(signs[cpId].guiImage, true)

					dxDrawTextOnElement(signs[cpId], signs[cpId].name)

				else
					guiSetVisible(signs[cpId].guiImage, false)
				end
			else 
				guiSetVisible(signs[cpId].guiImage, false)
			end
		else
			guiSetVisible(signs[cpId].guiImage, false)
		end
	end
end
addEventHandler("onClientRender", root, renderIcons)

function setSigns(index, position, type, name)
	if type == "Monster Truck" then type = "MonsterTruck" end

	table.insert(cpIds, index)
	signs[index] = {}
	signs[index].type = type
	signs[index].name = name
	signs[index].x = position[1]
	signs[index].y = position[2]
	signs[index].z = position[3]
	signs[index].guiImage = guiCreateStaticImage(0, 0, guiX, guiY, "./icons/" .. type ..".png", false)
	guiSetVisible(signs[index].guiImage, false)

	if index <= 1 then signs[index].showSign = true
	else signs[index].showSign = false
	end
end
addEvent("setSign", true)
addEventHandler("setSign", root, setSigns)

function showSign(index)
	if signs[index] then
		signs[index].showSign = true
	end
end
addEvent("showSign", true)
addEventHandler("showSign", root, showSign)

function hideSign(index)
	if signs[index] then
		signs[index].showSign = false
	end
end
addEvent("hideSign", true)
addEventHandler("hideSign", root, hideSign)

function deleteSigns()
	for i, cpId in ipairs(cpIds) do
		guiSetVisible(signs[cpId].guiImage, false)
	end
	signs = {}
	cpIds = {}
end
addEvent("deleteSigns", true)
addEventHandler("deleteSigns", root, deleteSigns)


function dxDrawTextOnElement(TheElement,text,height,distance,R,G,B,alpha,size,font,...)
	local x = TheElement.x
	local y = TheElement.y
	local z = TheElement.z + 1
	local x2, y2, z2 = getCameraMatrix()
	local distance = distance or drawDistance
	local height = height or -1

	if (isLineOfSightClear(x, y, z+2, x2, y2, z2, ...)) then
		local sx, sy = getScreenFromWorldPosition(x, y, z+height)
		if(sx) and (sy) then
			local distanceBetweenPoints = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
			if(distanceBetweenPoints < distance) then
				dxDrawText(text, sx+2, sy+2, sx, sy, tocolor(R or 255, G or 255, B or 255, alpha or (255 * 0.65)), (size or 1)-(distanceBetweenPoints / distance), font or "pricedown", "center", "center")
			end
		end
	end
end

function enableCPNextVehicleInfoUI()
	enabled = true
end

function disableCPNextVehicleInfoUI()
	enabled = false
end
