ESX = exports["es_extended"]:getSharedObject()

RegisterCommand(Config.Command, function(source)
    if source > 0 then
        local xPlayer = ESX.GetPlayerFromId(source)
        if not Config.UseCommand[xPlayer.getGroup()] then
            Citizen.Wait(50)
            TriggerClientEvent('chatMessage', source,  _U("no_perm"))
            return
        end
        Citizen.Wait(50)
        TriggerClientEvent('chatMessage', source,  _U("reset_0"))
    elseif source ~= 0 then
        return
    end
    MySQL.Async.execute('UPDATE crafting_system SET countitem = 0', {}, function (rowsChanged)
        if rowsChanged then
            print("All crafting data successfully reseted to 0!")
        end
    end)
end)

RegisterServerEvent("crafting_system:sqlinsert")
AddEventHandler("crafting_system:sqlinsert", function(id, job, item)
    MySQL.Async.fetchAll('SELECT * FROM crafting_system WHERE id = @id', {
        ['@id'] = id
    }, function(result)
        if result == nil or #result == 0 then
            Citizen.Wait(100)
            MySQL.Async.execute('INSERT INTO crafting_system (id, job, item) VALUES (@id, @job, @item)', {
                ['@id'] = id,
                ['@job'] = job,
                ['@item'] = item
            }, function(rowsAffected)
            end)
        else
            Citizen.Wait(100)
            MySQL.Async.execute('UPDATE crafting_system SET job = @job, item = @item WHERE id = @id', {
                ['@id'] = id,
                ['@job'] = job,
                ['@item'] = item
            }, function(rowsAffected)
            end)
        end
    end)
end)

RegisterServerEvent("crafting_system:sqldelete")
AddEventHandler("crafting_system:sqldelete", function(krafts)
    MySQL.Async.fetchAll('SELECT * FROM crafting_system', {}, function(result)
        if result and #result > 0 then
            for i = 1, #result do
                local found = false
                for _, v in ipairs(krafts) do
                    if v.jobid == result[i].id then
                        found = true
                        break
                    end
                end
                if not found then
                    Citizen.Wait(100)
                    MySQL.Async.execute('DELETE FROM crafting_system WHERE id = @id', {
                        ['@id'] = result[i].id
                    }, function(rowsAffected)
                    end)
                end
            end
        end
    end)
end)

RegisterServerEvent("crafting_system:sqlselect")
AddEventHandler("crafting_system:sqlselect", function(job)
    local _source = source
    MySQL.Async.fetchAll('SELECT * FROM crafting_system WHERE job = @job', {
        ['@job'] = job
    }, function(result)
        if result then
            Citizen.Wait(100)
            for _, row in ipairs(result) do
                TriggerClientEvent('crafting_system:showitem', _source, row.item, row.countitem)
                Citizen.Wait(1000)
            end
        end
    end)
end)

RegisterServerEvent("crafting_system:sqlcheck")
AddEventHandler("crafting_system:sqlcheck", function(id, money, item, countitem, maxstack, time, label, job)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local name = GetPlayerName(_source)
    local license = ESX.GetIdentifier(_source)
    MySQL.Async.fetchScalar('SELECT countitem FROM crafting_system WHERE id = @id', {
		['@id'] = id
	}, function(result)
        if result then
            local newCount = result + tonumber(countitem)
            if newCount > maxstack then
                Citizen.Wait(100)
                TriggerClientEvent('crafting_system:notify', _source, _U("craft"), _U("cant_craft_more"))
            else
                Citizen.Wait(100)
                MySQL.Async.execute('UPDATE crafting_system SET countitem = countitem + @countitem WHERE id = @id', {
                    ['@id'] = id,
                    ['@countitem'] = countitem,
                }, function (result)
                    TriggerClientEvent("crafting_system:craftingmain", _source, time)
                    Citizen.Wait(time)
                    TriggerClientEvent('crafting_system:notify', _source,_U("craft"), _U("success_upload", countitem))
                    xPlayer.removeInventoryItem(item, countitem)
                    PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({embeds={{title="Crafting Log\n"..os.date("%Y/%m/%d %X"),description="\n\n **Player**: \n"..name.." (**"..license.."**)\n\nItem: **"..label.."**\nCount: **"..countitem.."**\nIn Warehouse: **"..math.floor(newCount).."**\nJob: **"..job.."**",color=65280}}}), { ['Content-Type'] = 'application/json' })
                    Citizen.Wait(50)
                    local addmoney = money * countitem
                    xPlayer.addInventoryItem("money", addmoney)
                end)
            end
        end
	end)
end)

RegisterServerEvent("crafting_system:sqldeleteitem")
AddEventHandler("crafting_system:sqldeleteitem", function(id, item, countitem, price)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    MySQL.Async.fetchScalar('SELECT countitem FROM crafting_system WHERE id = @id', {
        ['@id'] = id,
    }, function (result)
        if result and tonumber(result) >= tonumber(countitem) then
            Citizen.Wait(100)
            MySQL.Async.execute('UPDATE crafting_system SET countitem = countitem - @countitem WHERE id = @id', {
                ['@id'] = id,
                ['@countitem'] = countitem,
            }, function (affectedRows)
                local items = item
                local countitems = countitem
                xPlayer.removeInventoryItem("money", price)
                Citizen.Wait(100)
                xPlayer.addInventoryItem(items, countitems)               
            end)
        else
            Citizen.Wait(100)
            TriggerClientEvent('crafting_system:notify', _source,_U("buy"), _U("not_enough_buyitem"))
        end
    end)
end)