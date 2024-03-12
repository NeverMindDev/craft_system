ESX = exports["es_extended"]:getSharedObject()
local spawnedPeds = {}
local registeredEvents = {}
local kraftok = false
local spam1 = 1     --during crafting
local spam2 = 1     --open the buy
--menukey
function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		blockinput = false
		return result
    else
        Citizen.Wait(500)
		blockinput = false
		return nil
    end
end
--create ped
function NearPed(model, coord, h, gender)
	RequestModel(model)
	while not HasModelLoaded(model) do
		Citizen.Wait(50)
	end
	if Config.MinusOne then
		spawnedPed = CreatePed(Config.GenderNumbers[gender], model, coord.x, coord.y, coord.z - 1.0, h, false, true)
	else
		spawnedPed = CreatePed(Config.GenderNumbers[gender], model, coord.x, coord.y, coord.z, h, false, true)
	end
	SetEntityAlpha(spawnedPed, 0, false)
	FreezeEntityPosition(spawnedPed, true)
	SetEntityInvincible(spawnedPed, true)
	SetBlockingOfNonTemporaryEvents(spawnedPed, true)
	if Config.FadeIn then
		for i = 0, 255, 51 do
			Citizen.Wait(50)
			SetEntityAlpha(spawnedPed, i, false)
		end
	end
	SetEntityAsMissionEntity(spawnedPed, true, true)
	return spawnedPed
end
--item need
function RequiredItem(itemname, itemcount)
    local hasItem = false
    PlayerData = ESX.GetPlayerData()
    for k, v in ipairs(PlayerData.inventory) do
        if v.name == itemname and v.count >= itemcount then
            hasItem = true
            break
        end
    end
    return hasItem
end
--crafting main
RegisterNetEvent("crafting_system:craftingmain")
AddEventHandler("crafting_system:craftingmain", function(time)
    exports.rprogress:Start(_U("craft"), time)
end)
Citizen.CreateThread(function()
    while true do
        local coords = GetEntityCoords(PlayerPedId(),true)
        for _,v in pairs(Config.Krafts) do
            local distance = #(coords - v.coord.xyz)
            if distance < 1.0 then
                if IsControlJustReleased(0, 38) then
                    if spam1 <= GetGameTimer() then                        
                        if ESX.GetPlayerData().job.name == v.job then
                            Citizen.Wait(100)
                            local krafts = KeyboardInput(_U("craft_input", v.label, v.maxcraft), "", 2)
                            local info = tonumber(krafts)
                            if info then
                                if info == tonumber(0) then
                                    Citizen.Wait(50)
                                    TriggerEvent('crafting_system:notify', _U("craft"),_U("no_zero"))
                                elseif info < tonumber(0) then
                                    Citizen.Wait(50)
                                    TriggerEvent('crafting_system:notify',_U("craft"),_U("no_minus"))
                                elseif info > tonumber(v.maxcraft) then
                                    Citizen.Wait(50)
                                    TriggerEvent('crafting_system:notify',_U("craft"), _U("give_number", v.maxcraft))
                                else
                                    local hasItem = RequiredItem(v.needitem, info)
                                    if hasItem then
                                        local time = (v.krafttime * 1000) * info
                                        Citizen.Wait(50)
                                        TriggerServerEvent("crafting_system:sqlcheck", v.jobid, v.addmoney, v.needitem, tonumber(info), v.maxstack, time, v.label, v.job)
                                        spam1 = GetGameTimer() + time
                                    else
                                        TriggerEvent('crafting_system:notify',_U("craft"), _U("not_enough_craftitem"))
                                    end
                                end
                            else
                                Citizen.Wait(50)
                                TriggerEvent('crafting_system:notify',_U("craft"), _U("give_number", v.maxcraft))
                            end
                        else
                            Citizen.Wait(50)
                            TriggerEvent('crafting_system:notify',_U("craft"), _U("not_job"))
                        end
                    else
                        Citizen.Wait(50)
                        TriggerEvent('crafting_system:notify',_U("craft"), _U("no_spam"))
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end)
--craft marker
Citizen.CreateThread(function()
    while true do
    Citizen.Wait(0)
    local pos = GetEntityCoords(GetPlayerPed(-1))
    for k, v in pairs(Config.Krafts) do
        local dist = #(pos - v.coord.xyz)
        if dist < Config.CraftDistance then
            DrawMarker(3, v.coord.xyz, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 1.0, 0.3, v.colorr, v.colorg, v.colorb, 200, false, false, 2, true, nil, nil, false)
        end
    end
end
end)
--spawn ped
Citizen.CreateThread(function()
    while true do
		Citizen.Wait(500)
        local coords = GetEntityCoords(PlayerPedId())
		for k,v in pairs(Config.NPC) do
			local distance = #(coords - v.coord.xyz)
			if distance < Config.NPCDistance and not spawnedPeds[k] then
				local spawnedPed = NearPed(v.model, v.coord.xyz, v.h, v.gender)
				spawnedPeds[k] = { spawnedPed = spawnedPed }
			end
			if distance >= Config.NPCDistance and spawnedPeds[k] then
				if Config.FadeIn then
					for i = 255, 0, -51 do
						Citizen.Wait(50)
						SetEntityAlpha(spawnedPeds[k].spawnedPed, i, false)
					end
				end
				SetEntityAsNoLongerNeeded(spawnedPeds[k].spawnedPed)
				DeletePed(spawnedPeds[k].spawnedPed)
				spawnedPeds[k] = nil
			end
		end
	end
end)
--ox target to buy
Citizen.CreateThread(function()
    for job, npcData in pairs(Config.NPC) do
        local itemCounts = {}
        for _, kraftData in ipairs(Config.Krafts) do
            if kraftData.job == job then
                itemCounts[kraftData.additem] = {jobid = kraftData.jobid, label = kraftData.label, price = kraftData.price ,count = (itemCounts[kraftData.additem] and itemCounts[kraftData.additem].count or 0) + 1}
            end
        end
        for itemName, data in pairs(itemCounts) do
            local eventName = "crafting_system:buyItem_" .. itemName .. "_" .. job
            if not registeredEvents[eventName] then
                exports.ox_target:addBoxZone({
                    coords = vec3(npcData.coord.xyz),
                    size = vec3(2, 2, 1.5),
                    rotation = 45,
                    options = {
                        {
                            name = 'buy',
                            event = eventName,
                            icon = 'fa-solid fa-landmark',
                            label = data.label.." - "..data.price.."$",
                            distance = 1.5,
                        }
                    }
                })
                AddEventHandler(eventName, function()
                    local jobId = data.jobid
                    TriggerEvent("crafting_system:buyItem", itemName, jobId, npcData.maxbuy, data.price, data.label)                    
                end)
                registeredEvents[eventName] = true
            end
        end
        local eventName2 = "crafting_system:view" .. job
        exports.ox_target:addBoxZone({
            coords = vec3(npcData.coord.xyz),
            size = vec3(2, 2, 1.5),
            rotation = 45,
            options = {
                {
                    name = 'view',
                    event = eventName2,
                    icon = 'fa-solid fa-landmark',
                    label = _U("warehouse"),
                    distance = 1.5,
                }
            }
        })
        AddEventHandler(eventName2, function()
            local jobs = job
            if spam2 <= GetGameTimer() then
                spam2 = GetGameTimer() + 10000
                TriggerServerEvent("crafting_system:sqlselect", jobs)
            else
                Citizen.Wait(50)
                TriggerEvent('crafting_system:notify',_U("craft"), _U("use_after"))
            end
        end)
    end
end)
--buy system
RegisterNetEvent("crafting_system:buyItem")
AddEventHandler("crafting_system:buyItem", function(itemName, jobid, maximum, price, label)
    if spam2 <= GetGameTimer() then
        spam2 = GetGameTimer() + 10000
        local buy = KeyboardInput(_U("buy_input", maximum), "", 2)
        local buyinfo = tonumber(buy)
        if buyinfo then
            local needprice = price*buyinfo
            if buyinfo == tonumber(0) then
                Citizen.Wait(50)
                TriggerEvent('crafting_system:notify', _U("buy"),_U("no_zero"))
            elseif buyinfo < tonumber(0) then
                Citizen.Wait(50)
                TriggerEvent('crafting_system:notify',_U("buy"),_U("no_minus"))
            elseif buyinfo > tonumber(maximum) then
                Citizen.Wait(50)
                TriggerEvent('crafting_system:notify',_U("buy"), _U("give_number", maximum))
            else
                local hasMoney = RequiredItem("money", needprice)
                if hasMoney then
                    Citizen.Wait(50)
                    TriggerServerEvent('crafting_system:sqldeleteitem', jobid, itemName, buyinfo, needprice)
                    TriggerEvent('crafting_system:notify',_U("buy"),_U("success_buy", label, buyinfo))
                else
                    TriggerEvent('crafting_system:notify',_U("buy"),_U("not_enough_cash"))
                end
            end
        else
            Citizen.Wait(50)
            TriggerEvent('crafting_system:notify',_U("buy"), _U("give_number", maximum))
        end
    else
        Citizen.Wait(50)
        TriggerEvent('crafting_system:notify',_U("craft"), _U("use_after"))
    end
end)
--sql part
Citizen.CreateThread(function()
    if not kraftok then
        kraftok = true
        Citizen.Wait(0)
        for key,v in pairs(Config.Krafts) do
            TriggerServerEvent("crafting_system:sqlinsert", v.jobid, v.job, v.label)
        end
        TriggerServerEvent("crafting_system:sqldelete", Config.Krafts)
    end
end)
RegisterNetEvent('crafting_system:showitem')
AddEventHandler('crafting_system:showitem', function(item, countitem)
    TriggerEvent('crafting_system:notify',item, _U("count", countitem))
end)