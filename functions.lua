Config = {}

Config.Locale = "en"            -- hu, en

Config.Title = true             -- if your notify support this extra message

Config.Webhook = ''             -- discord Webhook

Config.Command = "resetcraft"   -- command to set all crafts 0
Config.UseCommand = {           -- groups that can use the command.
    ["admin"] = true,
    ["owner"] = true
}


Config.CraftDistance = 10.0     -- player - kraft spaen distance

--npc settings
Config.FadeIn = true
Config.MinusOne = true          --i f you don't want to edit always the Z coords for the npc
Config.NPCDistance = 10.0       -- player - npc spawn distance
Config.GenderNumbers = {
	['male'] = 4,
	['female'] = 5
}

--notify system
RegisterNetEvent("crafting_system:notify", function(title, message)
    if not Config.Title then
        TriggerEvent("esx:showNotification", message)
    else
        TriggerEvent("esx:showNotification", title..": "..message)
    end
end)
